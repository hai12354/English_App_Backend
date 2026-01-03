# -*- coding: utf-8 -*-
import os
import logging
from datetime import datetime
from uuid import uuid4
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
from sqlalchemy.dialects import mysql

# ============================================================
# 🔐 1. NẠP CẤU HÌNH & KHỞI TẠO APP
# ============================================================
load_dotenv("ai.env")

app = Flask(__name__, static_folder='static', static_url_path='')
app.config['JSON_AS_ASCII'] = False 
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

# Cấu hình CORS mở rộng để tránh lỗi Preflight/Options
CORS(app, supports_credentials=True, resources={r"/*": {
    "origins": "*",  # Cho phép tất cả các nguồn
    "allow_headers": ["Content-Type", "Authorization", "Access-Control-Allow-Origin"],
    "methods": ["GET", "POST", "OPTIONS"]
}})

# Tắt strict_slashes để tránh lỗi 405/404 khi Flutter gọi URL có dấu "/" ở cuối
app.url_map.strict_slashes = False

# ============================================================
# 🗄️ 2. CẤU HÌNH DATABASE
# ============================================================
DATABASE_URL = os.getenv("DATABASE_URL")

# Fix lỗi dialect cho thư viện SQLAlchemy mới
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
if DATABASE_URL and DATABASE_URL.startswith("mysql://"):
    DATABASE_URL = DATABASE_URL.replace("mysql://", "mysql+pymysql://", 1)

# Fallback cho môi trường local
if not DATABASE_URL:
    DATABASE_URL = "mysql+pymysql://root:123456@127.0.0.1:3306/english"

app.config["SQLALCHEMY_DATABASE_URI"] = DATABASE_URL
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["SQLALCHEMY_ENGINE_OPTIONS"] = {
    "pool_recycle": 280, 
    "pool_pre_ping": True,
    # Chỉ bật SSL nếu dùng cloud DB yêu cầu (ví dụ Aiven)
    "connect_args": {"ssl": {"fake_config": True}} if "aivencloud" in str(DATABASE_URL) else {}
}

# Khởi tạo đối tượng DB
db = SQLAlchemy(app)
@app.before_request
def handle_db_session():
    # Đảm bảo mỗi request đều có một session sạch sẽ
    if db.session.is_active is False:
        db.session.rollback()
# ============================================================
# 📋 3. MODELS (Cấu trúc dữ liệu)
# ============================================================

class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid4()))
    name = db.Column(db.String(120), nullable=False)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    password = db.Column(db.String(255), nullable=False)
    xp = db.Column(db.Integer, default=0)
    streak = db.Column(db.Integer, default=0)
    avatar = db.Column(db.Text().with_variant(mysql.LONGTEXT(), "mysql"), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id, 
            "name": self.name, 
            "username": self.username, 
            "xp": self.xp, 
            "streak": self.streak, 
            "avatar": self.avatar
        }

class DictionaryCache(db.Model):
    __tablename__ = "dictionary_cache"
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    word = db.Column(db.String(255), unique=True, nullable=False, index=True)
    phonetic = db.Column(db.String(255))
    word_type = db.Column(db.String(100))
    definition = db.Column(db.Text)
    examples = db.Column(db.Text)
    grammar_notes = db.Column(db.Text)

class Quiz(db.Model):
    __tablename__ = "quizzes"
    id = db.Column(db.Integer, primary_key=True)
    topic = db.Column(db.String(100), index=True)
    level = db.Column(db.String(50), index=True)
    type = db.Column(db.String(50), default="text") 
    question = db.Column(db.Text)
    options = db.Column(db.Text) 
    answer = db.Column(db.Integer)
    explanation = db.Column(db.Text)

class SpeakingSession(db.Model):
    __tablename__ = "speaking_sessions"
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), index=True)
    topic = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class SpeakingTurn(db.Model):
    __tablename__ = "speaking_turns"
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid4()))
    session_id = db.Column(db.String(36), db.ForeignKey('speaking_sessions.id'))
    question_text = db.Column(db.Text)
    answer_text = db.Column(db.Text)
    feedback = db.Column(db.Text)

# ============================================================
# 🚀 4. ROUTES CƠ BẢN
# ============================================================

# --- ROUTE PHỤC VỤ FLUTTER WEB ---
@app.route('/')
def serve_index():
    return send_from_directory(app.static_folder, 'index.html')

@app.errorhandler(404)
def not_found(e):
    return send_from_directory(app.static_folder, 'index.html')

# --- AUTHENTICATION ---
@app.post("/register")
def register():
    data = request.get_json()
    if User.query.filter_by(username=data.get("username")).first():
        return jsonify({"error": "User exists"}), 409
    
    # Hash password
    hashed_pw = generate_password_hash(data['password'])
    new_user = User(name=data['name'], username=data['username'], password=hashed_pw)
    
    db.session.add(new_user)
    db.session.commit()
    return jsonify(new_user.to_dict()), 201

@app.post("/login")
def login():
    data = request.get_json()
    user = User.query.filter_by(username=data.get("username")).first()
    if user and check_password_hash(user.password, data.get("password")):
        return jsonify({"token": user.id, "user": user.to_dict()})
    return jsonify({"error": "Unauthorized"}), 401
# --- YÊU CẦU BỔ SUNG: ĐẶT LẠI MẬT KHẨU ---
@app.post("/reset-password")
def reset_password():
    data = request.get_json()
    username = data.get("username")
    new_password = data.get("password")

    # Tìm user dựa trên tên tài khoản
    user = User.query.filter_by(username=username).first()
    
    if not user:
        return jsonify({"error": "Tên tài khoản không tồn tại"}), 404

    # Cập nhật mật khẩu mới (đã hash)
    user.password = generate_password_hash(new_password)
    db.session.commit()
    
    return jsonify({"message": "Đặt lại mật khẩu thành công"}), 200

# --- TIẾN TRÌNH NGƯỜI DÙNG ---
@app.post("/update-progress")
def update_progress():
    data = request.get_json()
    user = User.query.get(data.get("user_id"))
    if not user: return jsonify({"error": "Not found"}), 404
    
    user.xp += int(data.get("xp_gain", 0))
    if data.get("streak"): user.streak = int(data.get("streak"))
    if data.get("avatar"): user.avatar = data.get("avatar")
    
    db.session.commit()
    return jsonify(user.to_dict())

@app.post("/update-avatar")
def update_avatar():
    data = request.get_json()
    user_id = data.get("userId")
    avatar_data = data.get("avatar") # Chuỗi Base64 từ Flutter

    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    user.avatar = avatar_data
    db.session.commit()
    return jsonify({"status": "success", "message": "Avatar updated"})


# --- CÁC TÍNH NĂNG PHỤ TRỢ ---
@app.post("/cache-dictionary")
def cache_dict():
    data = request.get_json()
    existing = DictionaryCache.query.filter_by(word=data.get("word")).first()
    if not existing:
        new_word = DictionaryCache(
            word=data.get("word"), phonetic=data.get("phonetic"),
            word_type=data.get("word_type"), definition=data.get("definition"),
            examples=data.get("examples"), grammar_notes=data.get("grammar_notes")
        )
        db.session.add(new_word)
        db.session.commit()
    return jsonify({"status": "cached"})

@app.get("/user-info/<user_id>")
def get_user_info(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(user.to_dict())

@app.post("/save-quiz")
def save_quiz():
    data = request.get_json()
    new_quiz = Quiz(
        topic=data.get("topic"), level=data.get("level"),
        question=data.get("question"), options=str(data.get("options")),
        answer=data.get("answer"), explanation=data.get("explanation"),
        type=data.get("type", "text")
    )
    db.session.add(new_quiz)
    db.session.commit()
    return jsonify({"status": "quiz saved"})

@app.get("/health")
def health():
    # Gọi cái này để đảm bảo bảng DB được tạo nếu chưa có (trên Cloud)
    with app.app_context():
        db.create_all()
    return jsonify({"status": "ok", "db": "connected"})


# ============================================================
# ⚙️ 5. ĐĂNG KÝ BLUEPRINTS (QUAN TRỌNG: ĐỂ NGOÀI __MAIN__)
# ============================================================
def register_blueprints(application):
    """
    Import và đăng ký blueprint để nạp các route AI (Gemini, Deepseek, v.v.)
    """
    try:
        from ai_routes import ai_bp
        from gemini_routes import gemini_bp
        from deepseek_routes import deepseek_bp
        
        application.register_blueprint(ai_bp)
        application.register_blueprint(gemini_bp)
        application.register_blueprint(deepseek_bp)
        print("✅ [SYSTEM] Đã nạp thành công các AI routes.")
    except Exception as e:
        print(f"⚠️ [ERROR] Lỗi khi nạp AI routes: {e}")

# 🔥 GỌI HÀM NÀY NGAY TẠI ĐÂY ĐỂ SERVER PRODUCTION NẠP ĐƯỢC ROUTES
register_blueprints(app)

# ============================================================
# 🏁 MAIN ENTRY POINT (Chỉ chạy khi run local: python app.py)
# ============================================================
if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    
    port = int(os.getenv("PORT", 8000))
    print(f"🚀 Server đang chạy tại: http://0.0.0.0:{port}")
    app.run(host="0.0.0.0", port=port)