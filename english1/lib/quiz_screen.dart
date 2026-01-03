import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: unused_import
import 'dart:io';
// ignore: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_config.dart';

class QuizScreen extends StatefulWidget {
  final String userId;
  final String username;

  const QuizScreen({super.key, required this.userId, required this.username});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = false;
  List<dynamic> _questions = [];
  List<int?> _userAnswers = [];
  int _currentIndex = 0;
  bool _isSubmitted = false;
  int _finalScore = 0;

  String _selectedTopic = "Animals";
  String _selectedLevel = "Intermediate";

  final List<String> _topics = ["Animals", "Food", "Clothes", "Jobs", "Technology", "Sports", "English Grammar"];
  final List<String> _levels = ["Beginner", "Intermediate", "Advanced"];

  final Color bluePrimary = const Color(0xFF2F80ED);

  

  void _handleExit() {
    if (_questions.isNotEmpty && !_isSubmitted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Xác nhận thoát?"),
          content: const Text("Tiến trình làm bài này sẽ bị mất. Bạn có muốn tiếp tục không?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ở LẠI")),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _questions = []);
              }, 
              child: const Text("THOÁT", style: TextStyle(color: Colors.red))
            ),
          ],
        ),
      );
    } else if (_isSubmitted) {
      setState(() => _questions = []);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isLoading = true;
      _questions = [];
      _isSubmitted = false;
      _currentIndex = 0;
    });

    try {
      final response = await http.post(
        Uri.parse(AppConfig.generateQuiz),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"topic": _selectedTopic, "level": _selectedLevel}),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _questions = responseData['quiz'] ?? [];
          _userAnswers = List<int?>.filled(_questions.length, null);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi: $e');
    }
  }

  void _submitQuiz() {
    if (_userAnswers.contains(null)) {
      _showSnackBar("Vui lòng hoàn thành tất cả câu hỏi!");
      return;
    }
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['answer']) score++;
    }
    setState(() {
      _finalScore = score;
      _isSubmitted = true;
    });
    _updateUserProgress(score);
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("KẾT QUẢ", style: TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 10),
            Text("$_finalScore / ${_questions.length}", 
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text("+ ${_finalScore * 10} XP", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() => _questions = []); }, child: const Text("LÀM ĐỀ KHÁC")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: bluePrimary),
            onPressed: () => Navigator.pop(context), 
            child: const Text("XEM LẠI BÀI", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserProgress(int score) async {
    try {
      await http.post(
        Uri.parse(AppConfig.updateProgress),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": widget.userId, "xp_gain": score * 10}),
      );
    } catch (e) { debugPrint(e.toString()); }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1E2E50);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _handleExit,
        ),
        title: Text(
          _questions.isNotEmpty ? "$_selectedTopic - $_selectedLevel" : "Thiết lập bài thi",
          style: TextStyle(fontSize: 18, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textColor,
        actions: [
          if(_questions.isNotEmpty && !_isSubmitted) Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: _submitQuiz, 
              child: Text("NỘP BÀI", style: TextStyle(fontWeight: FontWeight.bold, color: bluePrimary))
            ),
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
            ? _buildLoadingUI(textColor) 
            : _questions.isEmpty 
                ? _buildSetupUI(textColor, isDark) 
                : _buildQuizUI(isDark, textColor),
      ),
    );
  }

  Widget _buildSetupUI(Color textColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.psychology, size: 80, color: Color(0xFF2F80ED)),
          const SizedBox(height: 20),
          Text("Quiz Challenge", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
          Text("Chọn cấu hình bài thi của bạn", style: TextStyle(color: textColor.withOpacity(0.7))),
          const SizedBox(height: 40),
          
          _buildDropdown("Chủ đề", _selectedTopic, _topics, (val) => setState(() => _selectedTopic = val!), textColor, isDark),
          const SizedBox(height: 20),
          _buildDropdown("Mức độ", _selectedLevel, _levels, (val) => setState(() => _selectedLevel = val!), textColor, isDark),
          
          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _generateQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: bluePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("BẮT ĐẦU NGAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bluePrimary.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              style: TextStyle(color: textColor, fontSize: 16),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizUI(bool isDark, Color textColor) {
    final currentQ = _questions[_currentIndex];
    final selectedIdx = _userAnswers[_currentIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            color: bluePrimary,
            backgroundColor: bluePrimary.withOpacity(0.1),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Câu ${_currentIndex + 1} / ${_questions.length}", style: TextStyle(color: bluePrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(currentQ['question'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 30),
                ...List.generate(currentQ['options'].length, (index) {
                  return _buildOptionItem(index, currentQ, selectedIdx, isDark, textColor);
                }),
                if (_isSubmitted) _buildExplanation(currentQ, textColor, isDark),
              ],
            ),
          ),
        ),
        _buildNavigationButtons(textColor),
      ],
    );
  }

  Widget _buildOptionItem(int index, dynamic q, int? selected, bool isDark, Color textColor) {
    bool isCorrect = q['answer'] == index;
    bool isUserSelected = selected == index;
    Color borderColor = isUserSelected ? bluePrimary : Colors.grey.withOpacity(0.3);
    
    if (_isSubmitted) {
      if (isCorrect) borderColor = Colors.green;
      else if (isUserSelected) borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: _isSubmitted ? null : () => setState(() => _userAnswers[_currentIndex] = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Text(String.fromCharCode(65 + index), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(width: 15),
            Expanded(child: Text(q['options'][index], style: TextStyle(color: textColor))),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(dynamic q, Color textColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.3))
      ),
      child: Text("Giải thích: ${q['explanation']}", style: TextStyle(color: textColor)),
    );
  }

  Widget _buildNavigationButtons(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null, icon: const Icon(Icons.chevron_left)),
          if (_isSubmitted) Text("Điểm: $_finalScore / ${_questions.length}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          IconButton.filledTonal(onPressed: _currentIndex < _questions.length - 1 ? () => setState(() => _currentIndex++) : null, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }

  Widget _buildLoadingUI(Color textColor) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(), const SizedBox(height: 20), Text("Đang tải đề thi...", style: TextStyle(color: textColor))]));
  }
}