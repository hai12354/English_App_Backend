# -*- coding: utf-8 -*-
from flask import Blueprint, request, jsonify
import os, requests, json
from app import db, DictionaryCache 

gemini_bp = Blueprint("gemini_bp", __name__)

# Lấy Key từ môi trường
GEMINI_KEY = os.getenv("GEMINI_API_KEY", "").strip()

@gemini_bp.route("/gemini/chat", methods=["POST"])
def gemini_chat():
    try:
        data = request.get_json(silent=True) or {}
        raw_message = (data.get("message") or "").strip()
        if not raw_message:
            return jsonify({"error": "Vui lòng nhập từ cần tra"}), 400

        # Lấy từ cuối cùng để tra cứu
        search_word = raw_message.lower().split()[-1].strip("'.?!")[:100]

        # 1. Kiểm tra Database Cache (Ưu tiên lấy dữ liệu đã có)
        cached = DictionaryCache.query.filter_by(word=search_word).first()
        if cached:
            return jsonify({
                "source": "database",
                "word": cached.word.upper(),
                "phonetic": cached.phonetic,
                "word_type": cached.word_type,
                "definition": cached.definition,
                "examples": cached.examples,
                "grammar_notes": cached.grammar_notes
            }), 200

        # 2. Cấu hình Model & URL (Theo ý bạn là 2.5 Flash)
        # Lưu ý: Nếu Google báo lỗi 404, hãy kiểm tra lại tên model trong AI Studio
        model_name = "gemini-2.5-flash" # Tên chính thức hiện tại của Google
        full_url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={GEMINI_KEY}"

        prompt = (
            f"Trả về JSON duy nhất cho từ: \"{search_word}\".\n"
            "KHÔNG ĐƯỢC giải thích, KHÔNG dùng Markdown, KHÔNG dùng ```json.\n"
            "Nội dung phải là tiếng Việt.\n"
            "Mẫu JSON:\n"
            "{\n"
            "  \"phonetic\": \"phiên âm\",\n"
            "  \"word_type\": \"loại từ\",\n"
            "  \"definition\": \"nghĩa\",\n"
            "  \"examples\": \"ví dụ\",\n"
            "  \"grammar_notes\": \"ngữ pháp\"\n"
            "}"
        )

        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {
                "temperature": 0.1,
                "maxOutputTokens": 1024
            }
        }

        # 3. Gọi API Gemini
        resp = requests.post(full_url, json=payload, timeout=25)

        # Xử lý trường hợp v1beta lỗi thì thử v1
        if resp.status_code != 200:
            alt_url = f"https://generativelanguage.googleapis.com/v1/models/{model_name}:generateContent?key={GEMINI_KEY}"
            resp = requests.post(alt_url, json=payload, timeout=25)

        if resp.status_code != 200:
            error_data = resp.json()
            error_text = error_data.get('error', {}).get('message', 'Unknown error')
            # Trả về lỗi chi tiết để dễ debug (như lỗi Quota 429 bạn gặp)
            return jsonify({"reply": f"Lỗi API: {error_text}"}), 200

        # 4. Parse JSON từ phản hồi của AI
        res_json = resp.json()
        try:
            ai_text = res_json['candidates'][0]['content']['parts'][0]['text']
            ai_text = ai_text.replace("```json", "").replace("```", "").strip()
            # Tìm cặp dấu ngoặc nhọn để đảm bảo lấy đúng JSON
            start = ai_text.find("{")
            end = ai_text.rfind("}") + 1
            if start == -1 :
                raise ValueError("AI không trả về đúng định dạng JSON")
            
            ai_data = json.loads(ai_text[start:end])
        except Exception as e:
            print(f"Dữ liệu AI trả về lỗi: {ai_text}")
            return jsonify({"reply": f"Lỗi xử lý AI: {str(e)}"}), 200

        # 5. Hàm định dạng dữ liệu (Xử lý nếu AI trả về List thay vì String)
        def fmt(val):
            if isinstance(val, list): return "\n".join(str(x) for x in val)
            return str(val or "")

        # 6. Lưu vào MySQL
        new_entry = DictionaryCache(
            word=search_word,
            phonetic=fmt(ai_data.get("phonetic")),
            word_type=fmt(ai_data.get("word_type")),
            definition=fmt(ai_data.get("definition")),
            examples=fmt(ai_data.get("examples")),
            grammar_notes=fmt(ai_data.get("grammar_notes"))
        )
        db.session.add(new_entry)
        db.session.commit()

        # 7. Trả về kết quả cho Frontend (Flutter)
        return jsonify({
            "source": "api",
            "word": search_word.upper(),
            "phonetic": new_entry.phonetic,
            "word_type": new_entry.word_type,
            "definition": new_entry.definition,
            "examples": new_entry.examples,
            "grammar_notes": new_entry.grammar_notes
        }), 200

    except Exception as e:
        if 'db' in locals() and db.session:
            db.session.rollback()
        return jsonify({"reply": f"Lỗi hệ thống: {str(e)}"}), 200