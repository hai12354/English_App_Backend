import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:english/app_config.dart';
import 'package:english/user_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class ListeningScreen extends StatefulWidget {
  final String username;
  final String userId;
  const ListeningScreen({super.key, required this.username, required this.userId});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final FlutterTts _tts = FlutterTts();

  List<Map<String, dynamic>> _quiz = [];
  List<int?> _selectedAnswers = [];

  bool _isStarted = false;
  bool _isPlaying = false;
  bool _finished = false;

  int currentQuestion = 0;
  int score = 0;

  Duration _remainingTime = const Duration(minutes: 10);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data.json');
      final List<dynamic> data = json.decode(jsonString);

      final List<Map<String, dynamic>> allQuestions = [];
      for (var track in data) {
        final List<Map<String, dynamic>> questions =
            List<Map<String, dynamic>>.from(track['questions'] ?? []);
        for (var q in questions) {
          q['transcript'] = track['transcript'];
          q['title'] = track['id'] ?? "Listening Task";
          allQuestions.add(q);
        }
      }

      allQuestions.shuffle(Random());
      final selectedQuestions = allQuestions.take(10).toList();

      setState(() {
        _quiz = selectedQuestions;
        _selectedAnswers = List.filled(_quiz.length, null);
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  void _startQuiz() {
    setState(() => _isStarted = true);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingTime -= const Duration(seconds: 1);
          });
        }
      } else {
        timer.cancel();
        _finishQuiz();
      }
    });
  }

  Future<void> _playAudio(String? transcript) async {
    if (transcript == null || transcript.isEmpty) return;

    try {
      if (_isPlaying) {
        await _tts.stop();
        setState(() => _isPlaying = false);
        return;
      }

      setState(() => _isPlaying = true);
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5); // Web thường cần tốc độ chậm hơn một chút
      await _tts.setPitch(1.0);
      await _tts.speak(transcript);

      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (e) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  void _nextQuestion() async {
    if (currentQuestion < _quiz.length - 1) {
      if (_isPlaying) {
        await _tts.stop();
        setState(() => _isPlaying = false);
      }
      setState(() => currentQuestion++);
    }
  }

  void _previousQuestion() async {
    if (currentQuestion > 0) {
      if (_isPlaying) {
        await _tts.stop();
        setState(() => _isPlaying = false);
      }
      setState(() => currentQuestion--);
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    int correct = 0;
    for (int i = 0; i < _quiz.length; i++) {
      if (_selectedAnswers[i] == _quiz[i]['answerIndex']) correct++;
    }

    int xpGained = correct * 10;
    int totalXPAfterUpdate = 0;

    if (xpGained > 0) {
      try {
        final response = await http.post(
          Uri.parse('${AppConfig.base}/update-progress'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'user_id': widget.userId,
            'xp_gain': xpGained,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          totalXPAfterUpdate = data['xp'] ?? 0;
          await UserDataHelper.setXP(totalXPAfterUpdate);
        }
      } catch (e) {
        debugPrint("Server error: $e");
      }
    }

    setState(() {
      _finished = true;
      score = correct;
      currentQuestion = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
          '🎉 Hoàn thành! Đúng $correct/${_quiz.length}. '
          '+$xpGained XP. Tổng điểm: $totalXPAfterUpdate',
          style: const TextStyle(fontWeight: FontWeight.bold),), 
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB);
    const blue = Color(0xFF2F80ED);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        title: const Text("🎧 Listening Practice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(16),
              // FIX: Dùng SingleChildScrollView để không bao giờ bị tràn chiều dọc
              child: Column(
                children: [
                  Expanded(
                    child: Card(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: !_isStarted 
                            ? _buildStartView(isDark) 
                            : SingleChildScrollView(child: _buildQuizView(isDark, blue)),
                      ),
                    ),
                  ),
                  if (_isStarted) _buildBottomButtons(blue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.headphones, size: 80, color: isDark ? Colors.white24 : Colors.black12),
        const SizedBox(height: 20),
        const Text('Ready to test your listening skills?', 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('10 questions • 10 minutes', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
        const SizedBox(height: 30),
        SizedBox(width: 200, child: _buildButton("Start Now", _startQuiz)),
      ],
    );
  }

  Widget _buildQuizView(bool isDark, Color blue) {
    final question = _quiz[currentQuestion];
    final options = List<String>.from(question['options']);
    final selected = _selectedAnswers[currentQuestion];
    final transcript = question['transcript'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row (Question count & Timer)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Question ${currentQuestion + 1}/${_quiz.length}", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (!_finished) Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(_formatTime(_remainingTime), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const Divider(height: 30),

        // Audio Button
        GestureDetector(
          onTap: () => _playAudio(transcript),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle_fill, color: blue, size: 30),
                const SizedBox(width: 12),
                // FIX: Dùng Expanded để text không đẩy icon ra ngoài màn hình
                Expanded(
                  child: Text(
                    _isPlaying ? "Listening... Tap to stop" : "Click to listen to the audio",
                    style: TextStyle(color: blue, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),

        // Question Text
        Text(
          question['question'],
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        // Options List
        ...List.generate(options.length, (i) {
          final isSelected = selected == i;
          final isCorrect = _finished && i == question['answerIndex'];
          final isWrong = _finished && selected == i && i != question['answerIndex'];

          Color bgColor = isDark ? const Color(0xFF334155) : Colors.grey.shade50;
          Color borderColor = isDark ? Colors.white10 : Colors.grey.shade300;

          if (isCorrect) {
            bgColor = Colors.green.withOpacity(0.2);
            borderColor = Colors.green;
          } else if (isWrong) {
            bgColor = Colors.red.withOpacity(0.2);
            borderColor = Colors.red;
          } else if (isSelected && !_finished) {
            bgColor = blue.withOpacity(0.1);
            borderColor = blue;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: _finished ? null : () => setState(() => _selectedAnswers[currentQuestion] = i),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  children: [
                    // Số thứ tự A, B, C...
                    Text("${String.fromCharCode(65 + i)}.", 
                        style: TextStyle(fontWeight: FontWeight.bold, color: isSelected || isCorrect ? blue : null)),
                    const SizedBox(width: 10),
                    // FIX: Expanded cực kỳ quan trọng để chữ dài tự xuống dòng
                    Expanded(
                      child: Text(options[i], style: const TextStyle(fontSize: 15)),
                    ),
                    if (isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    if (isWrong) const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomButtons(Color blue) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (currentQuestion > 0) 
            Expanded(child: _buildButton("Previous", _previousQuestion, color: Colors.grey)),
          if (currentQuestion > 0) const SizedBox(width: 12),
          Expanded(
            child: _buildButton(
              _finished 
                ? (currentQuestion < _quiz.length - 1 ? "Next" : "Home")
                : (currentQuestion == _quiz.length - 1 ? "Finish" : "Next"),
              () {
                if (_finished) {
                  if (currentQuestion < _quiz.length - 1) {
                    _nextQuestion();
                  } else {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(username: widget.username, userId: widget.userId)));
                  }
                } else {
                  if (currentQuestion == _quiz.length - 1) {
                    _finishQuiz();
                  } else {
                    _nextQuestion();
                  }
                }
              },
              color: blue
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {Color color = const Color(0xFF2F80ED)}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}