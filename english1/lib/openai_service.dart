// ⚙️ Gọi API Flask AI backend
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class OpenAIService {
  /// 🧠 Chat tổng quát
  static Future<String> ask(String prompt) async {
    final url = Uri.parse('${AppConfig.base}/ai/chat');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'message': prompt, 'history': []}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['reply'] ?? '').toString();
      } else {
        final err = res.body.isNotEmpty ? jsonDecode(res.body) : {};
        throw Exception(err['error'] ?? 'Chat API error (${res.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối Flask: $e');
    }
  }

  // ==========================================================
  // 🗣️ Speaking mode: Sửa để nhận thêm userId
  // ==========================================================
  static Future<Map<String, dynamic>> startSpeakingSession(String topic, String userId) async {
    final url = Uri.parse('${AppConfig.base}/ai/speaking/start');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'topic': topic,
          'user_id': userId, // Gửi userId để Backend lưu vào MySQL
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'sessionId': data['session_id'],
          'topic': data['topic'],
          'questions': List<String>.from(data['questions'] ?? []),
        };
      } else {
        throw Exception('Không thể khởi tạo buổi luyện nói (${res.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối Flask: $e');
    }
  }

  // ==========================================================
  // 💬 Speaking feedback: Sửa question_index thành question (String)
  // ==========================================================
  static Future<String> sendSpeakingFeedback({
    required String sessionId,
    required String question, // Chuyển từ int sang String để gửi nội dung câu hỏi
    required String answer,
  }) async {
    final url = Uri.parse('${AppConfig.base}/ai/speaking/feedback');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'session_id': sessionId,
          'question': question, // Gửi nội dung câu hỏi để AI chấm
          'answer': answer,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['feedback'] ?? '').toString();
      } else {
        throw Exception('Không thể gửi feedback (${res.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi gửi feedback: $e');
    }
  }
}