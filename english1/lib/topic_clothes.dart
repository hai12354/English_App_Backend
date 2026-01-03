// lib/topic_clothes.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// 👕 Model cho từng từ trong chủ đề "Clothes"
class ClothesWordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const ClothesWordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory ClothesWordItem.fromMap(Map<String, dynamic> map) => ClothesWordItem(
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

/// 🧵 Model chủ đề “Clothes”
class TopicClothes {
  final String name;
  final List<ClothesWordItem> words;

  const TopicClothes({
    required this.name,
    required this.words,
  });

  factory TopicClothes.fromMap(Map<String, dynamic> map) {
    final rawWords = (map['words'] as List?)
            ?.map((e) => ClothesWordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return TopicClothes(
      name: (map['name'] ?? 'Clothes').toString(),
      words: rawWords,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'words': words.map((e) => e.toMap()).toList(),
      };
}

/// 🔹 Biến dữ liệu chủ đề (tạm trống ban đầu)
TopicClothes topicClothes = const TopicClothes(name: 'Clothes', words: []);

/// 👔 Load dữ liệu JSON và lọc trùng nhau
Future<void> loadClothesData(Function(TopicClothes) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    // 🔍 Tìm chủ đề “Clothes” hoặc tương tự
    final topicMap = data.firstWhere(
      (e) =>
          e['name'] == 'Clothes' ||
          e['name'] == 'Clothing' ||
          e['name'] == 'Trang phục' ||
          e['name'] == 'Quần áo',
      orElse: () => {'words': []},
    );

    // ✅ Lọc trùng theo 'word'
    final seen = <String>{};
    final List<Map<String, dynamic>> uniqueWords = [];
    for (var item in topicMap['words']) {
      final word = (item['word'] ?? '').toString().trim().toLowerCase();
      if (word.isEmpty) continue;
      if (seen.add(word)) {
        uniqueWords.add(Map<String, dynamic>.from(item));
      }
    }

    final cleanTopic = {
      'name': topicMap['name'],
      'words': uniqueWords,
    };

    topicClothes = TopicClothes.fromMap(cleanTopic);
    onLoaded(topicClothes);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON Clothes: $e');
  }
}

/// 🔊 Phát âm bằng Flutter TTS
final FlutterTts flutterTtsClothes = FlutterTts();

Future<void> speakClothes(String text) async {
  await flutterTtsClothes.setLanguage("en-US");
  await flutterTtsClothes.setSpeechRate(0.5);
  await flutterTtsClothes.setPitch(1.0);
  await flutterTtsClothes.speak(text);
}
