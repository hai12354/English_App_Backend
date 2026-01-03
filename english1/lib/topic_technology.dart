// lib/topic_technology.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// 💻 Model cho từng từ trong chủ đề “Technology”
class TechWordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const TechWordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory TechWordItem.fromMap(Map<String, dynamic> map) => TechWordItem(
        word: (map['word'] ?? '').toString(),
        ipa: (map['ipa'] ?? '').toString(),
        meaning: (map['meaning'] ?? '').toString(),
        example: (map['example'] ?? '').toString(),
        exampleVi: (map['example_vi'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {
        'word': word,
        'ipa': ipa,
        'meaning': meaning,
        'example': example,
        'example_vi': exampleVi,
      };
}

/// 🧠 Model chủ đề “Technology”
class TopicTechnology {
  final String name;
  final List<TechWordItem> words;

  const TopicTechnology({
    required this.name,
    required this.words,
  });

  factory TopicTechnology.fromMap(Map<String, dynamic> map) {
    final rawWords = (map['words'] as List?)
            ?.map((e) => TechWordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return TopicTechnology(
      name: (map['name'] ?? 'Technologyyyyy').toString(),
      words: rawWords,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'words': words.map((e) => e.toMap()).toList(),
      };
}

/// 🔹 Biến dữ liệu chủ đề (tạm trống ban đầu)
TopicTechnology topicTechnology =
    const TopicTechnology(name: 'Technologyyyyy', words: []);

/// 🧩 Load dữ liệu JSON và lọc trùng
Future<void> loadTechnologyData(Function(TopicTechnology) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    // 🔍 Tên chủ đề có thể gặp
    final topicMap = data.firstWhere(
      (e) =>
          e['topic'] == 'Technologyyyyy' ||
          e['name'] == 'Công nghệ' ||
          e['name'] == 'Information Technology' ||
          e['name'] == 'Tech' ||
          e['name'] == 'IT',
      orElse: () => {'words': []},
    );

    // ✅ Lọc trùng theo 'word'
    final seen = <String>{};
    final List<Map<String, dynamic>> uniqueWords = [];
    for (var item in topicMap['words']) {
      final word = (item['word'] ?? '').toString().trim().toLowerCase();
      if (word.isEmpty) continue;
      if (seen.add(word)) uniqueWords.add(Map<String, dynamic>.from(item));
    }

    final cleanTopic = {
      'name': topicMap['name'] ?? 'Technologyyyyy',
      'words': uniqueWords,
    };

    topicTechnology = TopicTechnology.fromMap(cleanTopic);
    onLoaded(topicTechnology);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON Technology: $e');
  }
}

/// 🔊 Đọc từ bằng Flutter TTS (phát âm)
final FlutterTts flutterTtsTech = FlutterTts();

Future<void> speakTech(String text) async {
  await flutterTtsTech.setLanguage("en-US");
  await flutterTtsTech.setSpeechRate(0.5);
  await flutterTtsTech.setPitch(1.0);
  await flutterTtsTech.speak(text);
}
