import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'topic_animal.dart';

class AnimalTopicScreen extends StatefulWidget {
  const AnimalTopicScreen({super.key});

  @override
  State<AnimalTopicScreen> createState() => _AnimalTopicScreenState();
}

class _AnimalTopicScreenState extends State<AnimalTopicScreen> {
  bool _loading = true;
  List<WordItem> _words = [];
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    loadAnimalData((topic) {
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
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void speakWord(String word) async {
    if (word.isNotEmpty) {
      await _flutterTts.speak(word);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
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
        title: const Text('🐾 Animal Vocabulary'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _words.isEmpty
              ? const Center(child: Text("Không có dữ liệu"))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.85, 
                    ),
                    itemCount: _words.length,
                    itemBuilder: (context, i) {
                      final w = _words[i];
                      return _buildWordCard(w, cardColor, textMain, textSub, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildWordCard(WordItem w, Color card, Color textMain, Color textSub, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SelectionArea( // --- THÊM TÍNH NĂNG NHẤN GIỮ CHO TỪ VỰNG ---
                  child: Text(
                    w.word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
                onPressed: () => speakWord(w.word),
              ),
            ],
          ),
          if (w.ipa.isNotEmpty)
            Text(
              w.ipa,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: textSub,
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (w.meaning.isNotEmpty)
                    SelectionArea( // --- THÊM TÍNH NĂNG NHẤN GIỮ CHO NGHĨA ---
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
                      child: SelectionArea( // --- THÊM TÍNH NĂNG NHẤN GIỮ CHO VÍ DỤ ---
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
                              const SizedBox(height: 2),
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