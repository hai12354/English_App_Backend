// lib/topic_transport.dart
// Load chủ đề Transport từ assets/vocabulary.json

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// 🚗 Model cho từng từ trong chủ đề "Transport"
class TransportWordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const TransportWordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory TransportWordItem.fromMap(Map<String, dynamic> map) => TransportWordItem(
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

/// 🚍 Model chủ đề “Transport”
class TopicTransport {
  final String name;
  final List<TransportWordItem> words;

  const TopicTransport({
    required this.name,
    required this.words,
  });

  factory TopicTransport.fromMap(Map<String, dynamic> map) {
    final rawWords = (map['words'] as List?)
            ?.map((e) => TransportWordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return TopicTransport(
      name: (map['name'] ?? 'Transport').toString(),
      words: rawWords,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'words': words.map((e) => e.toMap()).toList(),
      };
}

/// 🔹 Biến dữ liệu chủ đề (trống ban đầu)
TopicTransport topicTransport = const TopicTransport(name: 'Transport', words: []);

/// 🚌 Load dữ liệu JSON và lọc trùng
Future<void> loadTransportData(Function(TopicTransport) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    // 🔍 Tên chủ đề có thể gặp trong JSON
    final topicMap = data.firstWhere(
      (e) =>
          e['topic'] == 'Transportsssss' ||
          e['name'] == 'Transportation' ||
          e['name'] == 'Vehicles' ||
          e['name'] == 'Giao thông' ||
          e['name'] == 'Phương tiện đi lại' ||
          e['name'] == 'Phương tiện giao thông',
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
      'name': topicMap['name'] ?? 'Transport',
      'words': uniqueWords,
    };

    topicTransport = TopicTransport.fromMap(cleanTopic);
    onLoaded(topicTransport);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON Transport: $e');
  }
}

/// 🔊 Đọc từ bằng Flutter TTS
final FlutterTts flutterTtsTransport = FlutterTts();

Future<void> speakTransport(String text) async {
  await flutterTtsTransport.setLanguage("en-US");
  await flutterTtsTransport.setSpeechRate(0.5);
  await flutterTtsTransport.setPitch(1.0);
  await flutterTtsTransport.speak(text);
}
