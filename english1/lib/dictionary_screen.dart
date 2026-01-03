import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'app_config.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();
  
  FlutterTts? _flutterTts; 
  Map<String, dynamic>? _data; 
  String _errorMessage = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    if (kIsWeb) {
      _flutterTts?.setSharedInstance(true);
    }
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty || _flutterTts == null) return;
    try {
      await _flutterTts!.setLanguage("en-US");
      await _flutterTts!.setPitch(1.0);
      await _flutterTts!.setSpeechRate(0.5);
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint("Lỗi phát âm: $e");
    }
  }

  // --- ĐÃ XÓA HÀM _saveToDatabase VÌ BACKEND ĐÃ TỰ LƯU ---

  Future<void> _fetchDefinition() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() { 
      _isLoading = true; 
      _data = null; 
      _errorMessage = ""; 
    });

    try {
      // Gọi API Gemini 2.0 Flash thông qua Backend của bạn
      final response = await http.post(
        Uri.parse(AppConfig.geminiChat),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}), 
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        
        setState(() {
          if (result.containsKey('reply')) { 
            // Nếu Backend trả về thông báo lỗi hoặc text chat thuần
            _errorMessage = result['reply']; 
          } else { 
            // Hiển thị dữ liệu từ điển (đã được Backend lưu vào MySQL)
            _data = result; 
          }
        });
      } else {
        setState(() => _errorMessage = "Server đang bận (${response.statusCode})");
      }
    } catch (e) {
      setState(() => _errorMessage = "Lỗi kết nối. Vui lòng kiểm tra Internet.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent, // Giữ nền trong suốt để dùng với Background của App
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchInput(isDark, cardColor),
            const SizedBox(height: 20),
            Expanded(
              child: _buildResultContainer(isDark, cardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContainer(bool isDark, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _errorMessage.isNotEmpty
              ? _buildCenterMessage(_errorMessage, Icons.error_outline, Colors.red)
              : _data == null
                  ? _buildCenterMessage("Nhập từ vựng để bắt đầu tra cứu", Icons.search_rounded, Colors.grey)
                  : _buildDetailedResult(isDark),
    );
  }

  Widget _buildCenterMessage(String msg, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: color.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDetailedResult(bool isDark) {
    // Helper để lấy giá trị an toàn
    String val(String key) => _data![key]?.toString() ?? "";
    String currentWord = val('word');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Từ vựng + Phiên âm + Loa
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentWord.toUpperCase(), 
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    const SizedBox(height: 4),
                    Text(val('phonetic'), 
                      style: TextStyle(fontSize: 18, color: Colors.grey[600], fontStyle: FontStyle.italic, fontFamily: 'monospace')),
                  ],
                ),
              ),
              Material(
                color: Colors.blue.withOpacity(0.1),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Colors.blue, size: 28),
                  onPressed: () => _speak(currentWord),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Loại từ (Noun, Verb...)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(val('word_type'), 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          const Divider(height: 40, thickness: 1),
          
          // Các Section nội dung
          _sectionHeader(Icons.menu_book_rounded, "Định nghĩa"),
          Text(val('definition'), style: const TextStyle(fontSize: 16, height: 1.6)),
          
          const SizedBox(height: 24),
          _sectionHeader(Icons.translate_rounded, "Ví dụ thực tế"),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: Colors.blue.shade400, width: 4)),
            ),
            child: Text(val('examples'), 
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: isDark ? Colors.blue.shade100 : Colors.blue.shade900)),
          ),
          
          const SizedBox(height: 24),
          _sectionHeader(Icons.lightbulb_outline_rounded, "Ghi chú ngữ pháp"),
          Text(val('grammar_notes'), style: const TextStyle(fontSize: 15, color: Colors.orangeAccent, height: 1.5)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchInput(bool isDark, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: (_) => _fetchDefinition(),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Nhập từ vựng tiếng Anh...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.blue),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.blue),
              onPressed: _fetchDefinition,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }
} 