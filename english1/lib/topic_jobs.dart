// lib/topic_jobs.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// 💼 Model cho từng từ trong chủ đề “Jobs & Careers”
class JobWordItem {
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final String exampleVi;

  const JobWordItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    required this.exampleVi,
  });

  factory JobWordItem.fromMap(Map<String, dynamic> map) => JobWordItem(
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

/// 🧑‍🏭 Model chủ đề “Jobs & Careers”
class TopicJobs {
  final String name;
  final List<JobWordItem> words;

  const TopicJobs({
    required this.name,
    required this.words,
  });

  factory TopicJobs.fromMap(Map<String, dynamic> map) {
    final rawWords = (map['words'] as List?)
            ?.map((e) => JobWordItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return TopicJobs(
      name: (map['name'] ?? 'Job').toString(),
      words: rawWords,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'words': words.map((e) => e.toMap()).toList(),
      };
}

/// 🔹 Biến dữ liệu chủ đề (tạm trống ban đầu)
TopicJobs topicJobs = const TopicJobs(name: 'Job', words: []);

/// 🧾 Load dữ liệu JSON và lọc trùng nhau
Future<void> loadJobsData(Function(TopicJobs) onLoaded) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/vocabulary.json');
    final List data = json.decode(jsonStr);

    // 🔍 Tìm các tên tương ứng trong JSON
    final topicMap = data.firstWhere(
      (e) =>
          e['name'] == 'Jobs & Careers' ||
          e['name'] == 'job' ||
          e['name'] == 'Careers' ||
          e['name'] == 'Nghề nghiệp' ||
          e['name'] == 'Công việc',
      orElse: () => {'words': []},
    );

    // ✅ Lọc trùng từ vựng
    final seen = <String>{};
    final List<Map<String, dynamic>> uniqueWords = [];
    for (var item in topicMap['words']) {
      final word = (item['word'] ?? '').toString().trim().toLowerCase();
      if (word.isEmpty) continue;
      if (seen.add(word)) uniqueWords.add(Map<String, dynamic>.from(item));
    }

    final cleanTopic = {
      'name': topicMap['name'] ?? 'job',
      'words': uniqueWords,
    };

    topicJobs = TopicJobs.fromMap(cleanTopic);
    onLoaded(topicJobs);
  } catch (e) {
    debugPrint('❌ Lỗi đọc JSON Jobs & Careers: $e');
  }
}

/// 🔊 Phát âm bằng Flutter TTS
final FlutterTts flutterTtsJobs = FlutterTts();

Future<void> speakJob(String text) async {
  await flutterTtsJobs.setLanguage("en-US");
  await flutterTtsJobs.setSpeechRate(0.5);
  await flutterTtsJobs.setPitch(1.0);
  await flutterTtsJobs.speak(text);
}
