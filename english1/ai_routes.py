# -*- coding: utf-8 -*-
from flask import Blueprint, request, jsonify # type: ignore
import os, requests, random # type: ignore
from uuid import uuid4
from app import db, SpeakingSession, SpeakingTurn  # Thêm dòng này
from datetime import datetime
ai_bp = Blueprint("ai_bp", __name__)

# ===== Cấu hình AI =====
AI_API_KEY  = os.getenv("OPENAI_API_KEY")
OPENAI_BASE = os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
OPENAI_MODEL= os.getenv("OPENAI_MODEL_NAME", "gpt-4o-mini")

if not AI_API_KEY:
    raise RuntimeError("Thiếu OPENAI_API_KEY trong env (ai.env hoặc .env)")

# ============================================================
# 🎓 1️⃣ Chat chung (dùng cho assistant tổng quát)
# ============================================================
@ai_bp.route("/ai/chat", methods=["POST"])
def ai_chat():
    try:
        data = request.get_json(silent=True) or {}
        msg = (data.get("message") or "").strip()
        history = data.get("history") or []  # [{role, content}]

        if not msg:
            return jsonify({"error": "message is required"}), 400

        # ===== Chuẩn bị messages =====
        messages = [
            {"role": "system", "content": "Bạn là trợ giảng lịch thiệp, trả lời ngắn gọn, rõ ràng."}
        ]
        for m in history:
            r, c = m.get("role"), m.get("content")
            if r in ("user", "assistant") and isinstance(c, str):
                messages.append({"role": r, "content": c})
        messages.append({"role": "user", "content": msg})

        # ===== Gọi OpenAI API =====
        resp = requests.post(
            f"{OPENAI_BASE}/chat/completions",
            headers={
                "Authorization": f"Bearer {AI_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": OPENAI_MODEL,
                "messages": messages,
                "temperature": 0.7,
                "max_tokens": 300,
            },
            timeout=25,
        )

        # ===== Xử lý lỗi HTTP =====
        if resp.status_code >= 400:
            return jsonify({
                "reply": f"[Fallback] AI upstream error {resp.status_code}: {resp.text[:120]}"
            }), 200

        # ===== Trả kết quả =====
        payload = resp.json()
        reply = (
            payload.get("choices", [{}])[0]
                   .get("message", {})
                   .get("content", "")
                   .strip()
        )
        if not reply:
            reply = "[Fallback] Empty AI response."

        return jsonify({"reply": reply}), 200

    except requests.Timeout:
        return jsonify({"reply": "[Fallback] AI service timeout"}), 200
    except Exception as e:
        return jsonify({"reply": f"[Fallback] Flask exception: {str(e)}"}), 200


# ============================================================
# 🗣️ 2️⃣ Speaking Mode – sinh 3 câu hỏi luyện nói
# ============================================================
_sessions = {}  # Lưu session tạm (RAM)

@ai_bp.route("/ai/speaking/start", methods=["POST"])
def ai_speaking_start():
    """
    📚 Gọi 1 lần → sinh ra 3 câu hỏi luyện nói (Part 1)
    """
    try:
        data = request.get_json(silent=True) or {}
        topic = (data.get("topic") or "daily life").strip()

        prompt = f"Hãy tạo 3 câu hỏi luyện nói IELTS Speaking Part 1, chủ đề '{topic}', viết bằng tiếng Anh. \
Mỗi câu hỏi nên ngắn gọn, tự nhiên như trong bài thi thật."

        resp = requests.post(
            f"{OPENAI_BASE}/chat/completions",
            headers={
                "Authorization": f"Bearer {AI_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": OPENAI_MODEL,
                "messages": [
                    {"role": "system", "content": "Bạn là giám khảo IELTS tạo câu hỏi Speaking Part 1."},
                    {"role": "user", "content": prompt},
                ],
                "temperature": 0.8,
                "max_tokens": 400,
            },
            timeout=25,
        )

        data_ai = resp.json()
        text = (
            data_ai.get("choices", [{}])[0]
                   .get("message", {})
                   .get("content", "")
                   .strip()
        )

        # Tách thành 3 câu hỏi (bằng dấu ?)
        raw_qs = [q.strip("-• \n") for q in text.replace("\n", " ").split("?") if q.strip()]
        questions = [q + "?" for q in raw_qs[:3]]
        
        # BỎ ĐOẠN NÀY:
        # _sessions[session_id] = { ... } 

        # THAY BẰNG ĐOẠN NÀY:
        session_id = str(uuid4())
        new_session = SpeakingSession(
            id=session_id,
            user_id=data.get("user_id"), # Lấy user_id từ Flutter gửi lên
            topic=topic,
            created_at=datetime.utcnow()
        )
        db.session.add(new_session)
        db.session.commit() # Lưu vào bảng speaking_sessions

        return jsonify({
            "session_id": session_id,
            "topic": topic,
            "questions": questions,
        }), 200

    except Exception as e:
        return jsonify({"error": f"Exception: {e}"}), 500


# ============================================================
# 💬 3️⃣ Speaking Feedback – chấm từng câu trả lời học sinh
# ============================================================
@ai_bp.route("/ai/speaking/feedback", methods=["POST"])
def ai_speaking_feedback():
    """
    Nhận câu trả lời học sinh → gọi AI phản hồi, chấm điểm, góp ý phát âm.
    """
    try:
        data = request.get_json(silent=True) or {}
        session_id = data.get("session_id")
        answer = (data.get("answer") or "").strip()
        question = data.get("question")
        

        if not session_id:
            return jsonify({"error": "Thiếu session_id"}), 400

        session_record = SpeakingSession.query.get(session_id)
        if not session_record:
            return jsonify({"error": "Phiên học không tồn tại trong hệ thống"}), 404

        prompt = f"""
        You are an IELTS speaking examiner.
        Evaluate the student's answer below for the question:
        Question: {question}
        Answer: {answer}
        Give a short feedback (1-3 sentences) in English, mentioning pronunciation, vocabulary, and fluency briefly.
        """

        resp = requests.post(
            f"{OPENAI_BASE}/chat/completions",
            headers={
                "Authorization": f"Bearer {AI_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": OPENAI_MODEL,
                "messages": [
                    {"role": "system", "content": "You are a friendly IELTS speaking examiner."},
                    {"role": "user", "content": prompt.strip()},
                ],
                "temperature": 0.7,
                "max_tokens": 200,
            },
            timeout=25,
        )

        fb_data = resp.json()
        feedback = (
            fb_data.get("choices", [{}])[0]
                   .get("message", {})
                   .get("content", "")
                   .strip()
        )

        if not feedback:
            feedback = "Good effort! Try to speak more naturally next time."
        try:
            new_turn = SpeakingTurn(
                id=str(uuid4()),
                session_id=session_id,
                question_text=question,
                answer_text=answer,
                feedback=feedback
            )
            db.session.add(new_turn)
            db.session.commit()
        except Exception as db_err:
            db.session.rollback()
            print(f"Lưu database thất bại: {db_err}")

        return jsonify({
            "session_id": session_id,
            "question": question,
            "feedback": feedback,
        }), 200

    except Exception as e:
        return jsonify({"error": f"Exception: {e}"}), 500
