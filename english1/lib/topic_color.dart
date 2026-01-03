// lib/topic_color.dart
// Load chủ đề Colors từ assets/vocabulary.json

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// 🎨 Model cho từng từ trong chủ đề "Colors"
class ColorWordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const ColorWordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory ColorWordItem.fromMap(Map<String, dynamic> map) => ColorWordItem(
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

/// 🌈 Model chủ đề “Colors”
class TopicColor {
  final String name;
  final List<ColorWordItem> words;

  const TopicColor({
    required this.name,
    required this.words,
  });

  factory TopicColor.fromMap(Map<String, dynamic> map) {
    final rawWords = (map['words'] as List?)
            ?.map((e) => ColorWordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return TopicColor(
      name: (map['name'] ?? 'Colors').toString(),
      words: rawWords,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'words': words.map((e) => e.toMap()).toList(),
      };
}

/// 🔹 Biến dữ liệu chủ đề (tạm trống ban đầu)
TopicColor topicColor = const TopicColor(name: 'Colors', words: []);

/// 🎨 Load dữ liệu JSON và lọc trùng nhau
Future<void> loadColorData(Function(TopicColor) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    // 🔍 Tên chủ đề có thể gặp trong JSON
    final topicMap = data.firstWhere(
      (e) =>
          e['name'] == 'Colors' ||
          e['name'] == 'Colour' ||
          e['name'] == 'Color' ||
          e['name'] == 'Màu sắc' ||
          e['name'] == 'Các màu',
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
      'name': topicMap['name'] ?? 'Colors',
      'words': uniqueWords,
    };

    topicColor = TopicColor.fromMap(cleanTopic);
    onLoaded(topicColor);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON Colors: $e');
  }
}

/// 🔊 Đọc từ bằng Flutter TTS
final FlutterTts flutterTtsColor = FlutterTts();

Future<void> speakColor(String text) async {
  await flutterTtsColor.setLanguage("en-US");
  await flutterTtsColor.setSpeechRate(0.5);
  await flutterTtsColor.setPitch(1.0);
  await flutterTtsColor.speak(text);
}
