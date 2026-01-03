// lib/topic_animal.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// Model cho từng từ
class WordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const WordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory WordItem.fromMap(Map<String, dynamic> map) => WordItem(
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

/// Model chủ đề “Động vật”
class TopicAnimal {
  final String name;
  final List<WordItem> words;

  const TopicAnimal({
    required this.name,
    required this.words,
  });

  factory TopicAnimal.fromMap(Map<String, dynamic> map) {
    final rawWords = (map['words'] as List?)
            ?.map((e) => WordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return TopicAnimal(
      name: (map['name'] ?? 'Động Vật').toString(),
      words: rawWords,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'words': words.map((e) => e.toMap()).toList(),
      };
}

/// 🔹 Dữ liệu chủ đề (tạm trống)
TopicAnimal topicAnimal = const TopicAnimal(name: 'Động Vật', words: []);

/// 🐾 Load dữ liệu JSON và lọc trùng nhau
Future<void> loadAnimalData(Function(TopicAnimal) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    // 🔍 Tìm chủ đề “Động Vật”
    final topicMap = data.firstWhere(
      (e) => e['name'] == 'Động Vật',
      orElse: () => {'words': []},
    );

    // ✅ Lọc trùng theo từ
    final seen = <String>{};
    final List<Map<String, dynamic>> uniqueWords = [];
    for (var item in topicMap['words']) {
      final word = (item['word'] ?? '').toString().trim().toLowerCase();
      if (word.isEmpty) continue;
      if (!seen.contains(word)) {
        seen.add(word);
        uniqueWords.add(Map<String, dynamic>.from(item));
      }
    }

    final cleanTopic = {
      'name': topicMap['name'],
      'words': uniqueWords,
    };

    topicAnimal = TopicAnimal.fromMap(cleanTopic);
    onLoaded(topicAnimal);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON: $e');
  }
}

/// 🔊 Đọc từ bằng TTS
final FlutterTts flutterTts = FlutterTts();

Future<void> speakWord(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.setPitch(1.0);
  await flutterTts.speak(text);
}
