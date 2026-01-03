# -*- coding: utf-8 -*-
from flask import Blueprint, request, jsonify
from flask_cors import CORS
import os, requests, json
from sqlalchemy import func

deepseek_bp = Blueprint("deepseek_bp", __name__)
CORS(deepseek_bp)

GROQ_KEY = os.getenv("GROQ_API_KEY")
GROQ_BASE = "https://api.groq.com/openai/v1"

@deepseek_bp.route("/deepseek/generate-quiz", methods=["POST"])
def get_quiz():
    from app import db, Quiz 
    try:
        data = request.get_json(silent=True) or {}
        topic = str(data.get("topic", "General English")).strip()
        level = str(data.get("level", "Intermediate")).strip()

        current_count = Quiz.query.filter_by(topic=topic, level=level).count()

        if current_count >= 800:
            new_questions = Quiz.query.filter_by(topic=topic, level=level).order_by(func.random()).limit(20).all()
            source = "database_full"
        else:
            new_questions = generate_twenty_grammar_questions(topic, level)
            source = "ai_seeding"

        if not new_questions:
            new_questions = Quiz.query.filter_by(level=level).order_by(func.random()).limit(20).all()
            source = "fallback_db"

        if not new_questions:
            return _get_topic_based_emergency(topic, level)

        return jsonify({
            "status": "success",
            "source": source,
            "total_in_db": current_count,
            "topic": topic,
            "level": level,
            "quiz": [{
                "question": q.question,
                "options": q.options if isinstance(q.options, list) else json.loads(q.options),
                "answer": q.answer,
                "explanation": q.explanation
            } for q in new_questions[:20]]
        }), 200

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

def generate_twenty_grammar_questions(topic, level):
    from app import db, Quiz 
    if not GROQ_KEY: return []

    # NÂNG CẤP PROMPT ĐỂ TĂNG ĐỘ KHÓ
    system_prompt = (
        "You are an elite English Professor preparing students for IELTS/TOEFL.\n"
        f"CORE TOPICS: Animals, Food, Clothes, Jobs, Technology, Sports. LEVEL: {level}.\n"
        "GRAMMAR FOCUS: Detailed 12 Tenses, Passive Voice, Subjunctive Mood, and Inversion.\n\n"
        "STRICT DIFFICULTY RULES:\n"
        "1. DO NOT create simple sentences. Use complex or compound-complex sentences.\n"
        "2. Use advanced vocabulary and academic context related to the topic.\n"
        "3. Focus on 'tricky' aspects of the 12 tenses (e.g., Future Perfect Continuous, Past Perfect vs Past Simple in complex narratives).\n"
        "4. Options must be challenging: use distractors that look grammatically plausible but are contextually wrong.\n"
        "5. 'explanation' MUST be in VIETNAMESE, providing deep grammatical insight.\n"
        "6. Return ONLY a valid JSON object.\n\n"
        "JSON STRUCTURE:\n"
        "{\n"
        "  \"quiz\": [\n"
        "    {\n"
        "      \"question\": \"By the time the new technology is implemented next year, the engineers _____ on the prototype for over a decade.\",\n"
        "      \"options\": [\"will have been working\", \"will be working\", \"have worked\", \"will have worked\"],\n"
        "      \"answer\": 0,\n"
        "      \"explanation\": \"Thì tương lai hoàn thành tiếp diễn được dùng để nhấn mạnh tính liên tục của hành động kéo dài đến một thời điểm trong tương lai.\"\n"
        "    }\n"
        "  ]\n"
        "}"
    )

    try:
        response = requests.post(
            f"{GROQ_BASE}/chat/completions",
            headers={"Authorization": f"Bearer {GROQ_KEY}", "Content-Type": "application/json"},
            json={
                "model": "llama-3.3-70b-versatile",
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"Create 20 HIGH-LEVEL challenge questions about {topic}. Mix the 12 tenses with academic structures. Ensure level is {level}."}
                ],
                "response_format": {"type": "json_object"},
                "temperature": 0.9 # Tăng một chút để AI biến hóa cấu trúc câu hơn
            },
            timeout=50
        )

        if response.status_code == 200:
            content = response.json()['choices'][0]['message']['content']
            questions_data = json.loads(content).get("quiz", [])
            
            new_objects = []
            for q in questions_data:
                if Quiz.query.filter_by(question=q['question'].strip()).first():
                    continue

                new_q = Quiz(
                    topic=topic, level=level, type="text",
                    question=q['question'].strip(), 
                    options=json.dumps(q['options'], ensure_ascii=False),
                    answer=int(q['answer']),
                    explanation=q.get('explanation', "")
                )
                db.session.add(new_q)
                new_objects.append(new_q)
            
            db.session.commit()
            return new_objects
        return []
    except Exception as e:
        print(f"Hard-mode AI Error: {e}")
        return []

def _get_topic_based_emergency(topic, level):
    quiz = []
    for i in range(1, 21):
        quiz.append({
            "question": f"[{topic}] Advanced grammar challenge {i} (Syncing...)",
            "options": ["Option A", "Option B", "Option C", "Option D"],
            "answer": 0,
            "explanation": "Đang đồng bộ câu hỏi nâng cao từ hệ thống."
        })
    return jsonify({
        "status": "success", "source": "emergency_sync", "topic": topic, "quiz": quiz
    }), 200