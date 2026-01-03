// ignore: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: unused_import
import 'dart:html' as html; 

class AppConfig {
  // ĐỊA CHỈ BACKEND RENDER
  static const String _productionBackendUrl = 'https://english-app-backend-7min.onrender.com';

  static String get _autoBase {
    // Xóa bỏ logic check localhost để ép app dùng Render 100%
    // Sau này khi nào muốn dùng lại localhost ở máy nhà thì mới sửa lại sau
    return _productionBackendUrl; 
  }

  static String get base => _autoBase;

  // ... Các endpoint bên dưới giữ nguyên 100% ...
  static String get geminiChat => '$base/gemini/chat'; 
  static String get generateQuiz => '$base/deepseek/generate-quiz';
  static String get login => '$base/login';
  static String get register => '$base/register';
  static String get updateProgress => '$base/update-progress';
  static String getUserInfo(String userId) => '$base/user-info/$userId'; 
  static String get resetPassword => '$base/reset-password';
  static String get updateAvatar => '$base/update-avatar';
}