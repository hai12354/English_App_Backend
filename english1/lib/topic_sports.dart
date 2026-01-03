// lib/topic_sports.dart
// Load chủ đề Sports từ assets/vocabulary.json

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'topic_animal.dart' show speakWord;

class SportWordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const SportWordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory SportWordItem.fromMap(Map<String, dynamic> map) => SportWordItem(
        word: (map['word'] ?? '').toString(),
        ipa: (map['ipa'] ?? '').toString(),
        meaning: (map['meaning'] ?? '').toString(),
        example: (map['example'] ?? '').toString(),
        exampleVi: (map['example_vi'] ?? '').toString(),
      );
}

class TopicSports {
  final String name;
  final List<SportWordItem> words;
  const TopicSports({required this.name, required this.words});

  factory TopicSports.fromMap(Map<String, dynamic> map) {
    final list = (map['words'] as List?)
            ?.map((e) => SportWordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return TopicSports(
      name: (map['name'] ?? 'Sports').toString(),
      words: list,
    );
  }
}

TopicSports topicSports = const TopicSports(name: 'Sports', words: []);

Future<void> loadSportsData(Function(TopicSports) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    final names = {'Sports', 'Thể thao', 'Games & Sports'};

    Map<String, dynamic> topic = {'name': 'Sports', 'words': []};
    for (final e in data) {
      final n = (e['name'] ?? '').toString();
      if (names.contains(n)) {
        topic = Map<String, dynamic>.from(e);
        break;
      }
    }

    // lọc trùng
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final item in (topic['words'] as List? ?? [])) {
      final word = (item['word'] ?? '').toString().trim().toLowerCase();
      if (word.isEmpty) continue;
      if (seen.add(word)) unique.add(Map<String, dynamic>.from(item));
    }

    topicSports = TopicSports.fromMap({
      'name': topic['name'] ?? 'Sports',
      'words': unique,
    });

    onLoaded(topicSports);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON Sports: $e');
  }
}

Future<void> speakSport(String text) => speakWord(text);
