import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 1. Thêm thư viện TTS
import 'topic_technology.dart';

class TechnologyTopicScreen extends StatefulWidget {
  const TechnologyTopicScreen({super.key});

  @override
  State<TechnologyTopicScreen> createState() => _TechnologyTopicScreenState();
}

class _TechnologyTopicScreenState extends State<TechnologyTopicScreen> {
  bool _loading = true;
  List<TechWordItem> _words = [];
  
  // 2. Cấu hình TTS
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    loadTechnologyData((topic) {
      if (mounted) {
        setState(() {
          _words = topic.words;
          _loading = false;
        });
      }
    });
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  // 3. Hàm phát âm từ vựng công nghệ
  void speakTech(String word) async {
    if (word.isNotEmpty) {
      await _flutterTts.speak(word);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
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
        title: const Text('💻 Technology Vocabulary'),
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
                      childAspectRatio: 0.85, 
                    ),
                    itemCount: _words.length,
                    itemBuilder: (context, i) {
                      final w = _words[i];
                      return _buildTechCard(w, cardColor, textMain, textSub, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildTechCard(TechWordItem w, Color card, Color textMain, Color textSub, bool isDark) {
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
          // Row 1: Word and Speaker icon
          Row(
            children: [
              Expanded(
                child: SelectionArea(
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
                onPressed: () => speakTech(w.word),
                tooltip: 'Phát âm',
              ),
            ],
          ),
          
          // Row 2: IPA Phonetic
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

          // Scrollable Area for Content
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

                  // Example Box
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