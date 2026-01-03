// lib/topic_foods.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// 🍔 Model cho từng từ vựng trong chủ đề "Thức ăn & Đồ uống"
class FoodWordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const FoodWordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory FoodWordItem.fromMap(Map<String, dynamic> map) => FoodWordItem(
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

/// 📘 Model chủ đề “Thức ăn & Đồ uống”
class TopicFoods {
  final String name;
  final List<FoodWordItem> words;

  const TopicFoods({
    required this.name,
    required this.words,
  });

  factory TopicFoods.fromMap(Map<String, dynamic> map) {
    final rawWords = (map['words'] as List?)
            ?.map((e) => FoodWordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return TopicFoods(
      name: (map['name'] ?? 'Thức ăn & Đồ uống').toString(),
      words: rawWords,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'words': words.map((e) => e.toMap()).toList(),
      };
}

/// 🔹 Biến dữ liệu toàn cục (tạm trống ban đầu)
TopicFoods topicFoods = const TopicFoods(name: 'Thức ăn & Đồ uống', words: []);

/// 🍱 Hàm load dữ liệu JSON từ assets/vocabulary.json
Future<void> loadFoodsData(Function(TopicFoods) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    // 🔍 Tìm chủ đề có tên tương ứng
    final topicMap = data.firstWhere(
      (e) =>
          e['name'] == 'Food & Drinks' ||
          e['name'] == 'Foods' ||
          e['name'] == 'Thức ăn & Đồ uống' ||
          e['name'] == 'Đồ ăn & Nước uống',
      orElse: () => {'words': []},
    );

    // ✅ Lọc trùng lặp theo trường 'word'
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

    topicFoods = TopicFoods.fromMap(cleanTopic);
    onLoaded(topicFoods);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON (Foods): $e');
  }
}

/// 🔊 Đọc phát âm bằng FlutterTTS
final FlutterTts flutterTtsFood = FlutterTts();

Future<void> speakFood(String text) async {
  await flutterTtsFood.setLanguage("en-US");
  await flutterTtsFood.setSpeechRate(0.5);
  await flutterTtsFood.setPitch(1.0);
  await flutterTtsFood.speak(text);
}
