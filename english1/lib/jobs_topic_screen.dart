import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 1. Import thư viện phát âm
import 'topic_jobs.dart';

class JobsTopicScreen extends StatefulWidget {
  const JobsTopicScreen({super.key});

  @override
  State<JobsTopicScreen> createState() => _JobsTopicScreenState();
}

class _JobsTopicScreenState extends State<JobsTopicScreen> {
  bool _loading = true;
  List<JobWordItem> _words = [];

  // 2. Khai báo đối tượng TTS
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts(); // Khởi tạo giọng nói
    loadJobsData((topic) {
      if (mounted) {
        setState(() {
          _words = topic.words;
          _loading = false;
        });
      }
    });
  }

  // 3. Cấu hình giọng nói tiếng Anh
  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
  }

  // 4. Hàm phát âm thực tế
  void speakJob(String word) async {
    if (word.isNotEmpty) {
      await _flutterTts.speak(word);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Dừng âm thanh khi thoát màn hình
    super.dispose();
  }

  int _cols(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1100) return 4;
    if (w >= 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF1E2E50);
    final textSub = isDark ? const Color(0xFF9CA3AF) : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        title: const Text('💼 Jobs & Careers'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _words.isEmpty
              ? const Center(child: Text('Không có dữ liệu'))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _cols(context),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82, // Tỉ lệ giúp Card cao hơn một chút
                    ),
                    itemCount: _words.length,
                    itemBuilder: (context, i) {
                      final w = _words[i];
                      return _buildJobCard(w, cardColor, textMain, textSub, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildJobCard(JobWordItem w, Color card, Color textMain, Color textSub, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Word + Audio Button
          Row(
            children: [
              Expanded(
                child: SelectionArea( // Hỗ trợ sao chép từ vựng
                  child: Text(
                    w.word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textMain,
                    ),
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.volume_up_outlined, size: 20),
                color: const Color(0xFF2F80ED),
                onPressed: () => speakJob(w.word),
              ),
            ],
          ),
          
          // Row 2: Phonetic/IPA
          if (w.ipa.isNotEmpty)
            Text(
              w.ipa,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                color: textSub,
              ),
            ),
          
          const SizedBox(height: 8),

          // Nội dung có thể cuộn
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (w.meaning.isNotEmpty)
                    SelectionArea(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Meaning: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF2F80ED),
                              ),
                            ),
                            TextSpan(
                              text: w.meaning,
                              style: TextStyle(color: textSub, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 8),

                  // Example Section
                  if (w.example.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : const Color(0xFFF0F4F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${w.example}"',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: textMain,
                                fontSize: 12.5,
                              ),
                            ),
                            if (w.exampleVi.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                w.exampleVi,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSub,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}