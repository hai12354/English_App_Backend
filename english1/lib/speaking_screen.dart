import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform; 
import 'package:english/app_config.dart';
import 'package:english/user_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'openai_service.dart';
import 'home_page.dart';

class SpeakingScreen extends StatefulWidget {
  final String userId;
  final String username;

  const SpeakingScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _loading = false;
  bool _started = false;
  bool _isListening = false;

  int _currentIndex = 0;
  String? _sessionId;
  String _topic = '';
  String _question = '';
  String _recognizedText = '';
  String _feedback = '';
  final String _locale = 'en-US';
  List<String> _questions = [];

  static const List<String> _topics = [
    'Hometown', 'Family', 'Work', 'Study', 'Food', 'Movies',
    'Books', 'Technology', 'Music', 'Sports', 'Travel',
    'Environment', 'Weather', 'Friends', 'Dreams',
    'Daily habits', 'Shopping', 'Transportation'
  ];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  @override
  void dispose() {
    _tts.stop(); 
    _speech.stop();
    super.dispose();
  }

  Future<void> _initTTS() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    await _tts.setLanguage(_locale);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setErrorHandler((message) => debugPrint("TTS Error: $message"));

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ]);
    }
    await _tts.awaitSpeakCompletion(true);
  }

  // Hàm speak có delay để đợi UI render
  Future<void> _speak(String text) async {
    if (!mounted || text.isEmpty) return; 
  
  try {
    // 1. Phải dừng hẳn những gì đang nói dở để tránh xung đột
    await _tts.stop(); 
    
    // 2. Thêm một khoảng nghỉ nhỏ để trình duyệt kịp xử lý luồng âm thanh
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 3. Thực hiện nói và kiểm tra kết quả
    await _tts.speak(text);
  } catch (e) {
    // In ra debug thay vì hiện lên màn hình cho người dùng thấy
    debugPrint("TTS Web Error: $e");
  }
  }

  Future<void> _startSession() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _started = true;
      _feedback = '';
      _recognizedText = '';
      _questions.clear();
    });

    try {
      final randomTopic = _topics[_rng.nextInt(_topics.length)];
      final data = await OpenAIService.startSpeakingSession(randomTopic, widget.userId);
      final qs = List<String>.from(data['questions'] ?? []);
      
      if (qs.isEmpty) throw Exception("No questions returned.");

      if (mounted) {
        setState(() {
          _loading = false; // Tắt loading trước để khung Card hiện ra
          _sessionId = data['sessionId'];
          _topic = data['topic'] ?? randomTopic;
          _questions = qs;
          _currentIndex = 0;
          _question = _questions.first;
        });

        // Sau khi setState đã update UI, mới gọi hàm nói
        await _speak(_question);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _feedback = '⚠️ Connection Error: $e';
          _started = false;
        });
      }
    }
  }

  Future<void> _nextQuestion() async {
    if (_questions.isEmpty) return;
    await _tts.stop(); 

    if (_currentIndex + 1 >= _questions.length) {
      if (mounted) {
        setState(() {
          _question = '✅ All Done!';
          _feedback = '🎯 You finished the topic. Press Finish to go home.';
        });
        await _speak("Session completed. Great work!");
      }
      return;
    }

    if (mounted) {
      setState(() {
        _currentIndex++;
        _question = _questions[_currentIndex];
        _recognizedText = '';
        _feedback = '';
      });
      // Đợi chữ mới render rồi mới nói
      await _speak(_question);
    }
  }

  Future<void> _sendAnswer(String answer) async {
    if (_sessionId == null || answer.trim().isEmpty) return;
    
    if (mounted) setState(() => _loading = true);
    try {

      final fb = await OpenAIService.sendSpeakingFeedback(
        sessionId: _sessionId!,
        question: _question,
        answer: answer.trim(),
      );

      int xpGained = 20;
      int totalXPAfterUpdate = 0;
      try {
      // 2. Gửi cập nhật XP lên server
      final response = await http.post(
        Uri.parse('${AppConfig.base}/update-progress'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'user_id': widget.userId, 'xp_gain': xpGained}),
      );

      if (response.statusCode == 200) {
        // 3. Giải mã JSON từ server trả về để lấy con số tổng thật sự
        final data = json.decode(response.body);
        totalXPAfterUpdate = data['xp'] ?? 0; // Lấy giá trị 'current_xp' mà server đã tính toán
        
        // Cập nhật lại local nếu cần
        await UserDataHelper.addXP(xpGained); 
      }
    } catch (e) { 
      debugPrint("❌ Sync error: $e"); 
    }

    if (mounted) {
      setState(() {
        _recognizedText = answer;
        _feedback = fb;
      });

      // 4. Hiển thị thông báo với tổng điểm lấy từ Database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⭐ +$xpGained XP Speaking! Tổng điểm hiện tại: $totalXPAfterUpdate'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (mounted) setState(() => _feedback = '⚠️ Feedback error: $e');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  Future<void> _toggleRecording() async {
    await _tts.stop();
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    bool available = await _speech.initialize(
      onError: (val) => debugPrint('Speech Error: $val'),
      onStatus: (val) => debugPrint('Speech Status: $val'),
    );

    if (!available) {
      if (mounted) setState(() => _feedback = '⚠️ Mic unavailable. Check permissions.');
      return;
    }

    if (mounted) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });
    }

    _speech.listen(
      localeId: _locale,
      onResult: (val) async {
        if (mounted) setState(() => _recognizedText = val.recognizedWords);
        if (val.finalResult && val.recognizedWords.isNotEmpty) {
          if (mounted) setState(() => _isListening = false);
          await _speech.stop();
          await _sendAnswer(val.recognizedWords);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const blue = Color(0xFF2F80ED);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        title: const Text('🎤 IELTS Practice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _tts.stop(); 
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                if (_topic.isNotEmpty) 
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Topic: $_topic', style: const TextStyle(fontWeight: FontWeight.bold, color: blue)),
                  ),
                Expanded(
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _loading 
                        ? const Center(child: CircularProgressIndicator())
                        : (!_started 
                            ? _buildStartView(isDark) 
                            : _QuestionView(question: _question, recognized: _recognizedText, feedback: _feedback)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildControls(isDark, blue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(bool isDark, Color blue) {
    bool isLast = _questions.isNotEmpty && (_currentIndex + 1 >= _questions.length);
    bool showMic = _started && _question != '✅ All Done!' && !_loading;
    
    return Column(
      children: [
        if (showMic) ...[
          GestureDetector(
            onTap: _toggleRecording,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: _isListening ? Colors.redAccent : blue,
              child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(height: 10),
          Text(_isListening ? '🎙️ Listening...' : 'Tap to answer',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
          const SizedBox(height: 15),
        ],
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blue, 
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: _loading ? null : () async {
              if (!_started) {
                await _startSession();
              } else if (isLast || _question == '✅ All Done!') {
                await _tts.stop(); 
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage(username: widget.username, userId: widget.userId)),
                );
              } else {
                await _nextQuestion();
              }
            },
            child: Text(
              !_started ? 'START PRACTICE' : (isLast || _question == '✅ All Done!' ? 'FINISH' : 'NEXT QUESTION'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, size: 80, color: Colors.blue.withOpacity(0.3)),
        const SizedBox(height: 20),
        const Text('Ready to practice IELTS Speaking?', 
          textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('AI will ask questions and give feedback on your answer.', 
          textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

class _QuestionView extends StatelessWidget {
  final String question;
  final String recognized;
  final String feedback;
  const _QuestionView({required this.question, required this.recognized, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AI QUESTION:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 10),
          Text(question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
          if (recognized.isNotEmpty || feedback.isNotEmpty) const Divider(height: 40),
          if (recognized.isNotEmpty) ...[
            const Text("YOUR ANSWER:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 10),
            Text(recognized, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
          ],
          if (feedback.isNotEmpty) ...[
            const Text("AI FEEDBACK:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Text(feedback, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87, height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }
}