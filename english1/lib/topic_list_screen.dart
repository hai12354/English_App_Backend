import 'package:flutter/material.dart';

// 🔗 Import từng trang chủ đề
import 'animal_topic_screen.dart';
import 'fooddrink_topic_screen.dart';
import 'clothes_topic_screen.dart';
import 'jobs_topic_screen.dart';
import 'technology_topic_screen.dart';
import 'color_topic_screen.dart';
import 'sports_topic_screen.dart';
import 'daily_activities_topic_screen.dart';

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});

  // 📘 Danh sách chủ đề và biểu tượng
  final List<_Topic> _topics = const [
    _Topic('Animals', Icons.pets_outlined),
    _Topic('Food & Drinks', Icons.restaurant_outlined),
    _Topic('Clothes',Icons.checkroom_outlined),
    _Topic('Jobs & Careers', Icons.work_outline),
    _Topic('Technology', Icons.computer_outlined),
    _Topic('Colors',Icons.color_lens_outlined),
    _Topic('Sports', Icons.sports_basketball_outlined),
    _Topic('Transportation',Icons.directions_car_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    // 🧭 Map chủ đề → màn hình tương ứng
    final Map<String, Widget Function()> screens = {
      'Animals': () => const AnimalTopicScreen(),
      'Food & Drinks': () => const FoodDrinkTopicScreen(),
      'Clothes': () => const ClothesTopicScreen(),
      'Jobs & Careers': () => const JobsTopicScreen(),
      'Technology': () => const TechnologyTopicScreen(),
      'Colors': () => const ColorTopicScreen(),
      'Sports': () => const SportsTopicScreen(),
      'Transportation': () => const TransportTopicScreen(),
    };

    // 🎨 Tuỳ chỉnh giao diện theo chế độ sáng / tối
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final card = isDark ? const Color(0xFF111827) : Colors.white;
    final border = isDark ? const Color(0xFF1F2937) : const Color(0xFFE6ECF5);
    final textMain = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1E2E50);
    final textSub = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    final iconColor = isDark ? const Color(0xFF8AB4FF) : const Color(0xFF2F80ED);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        title: const Text('Vocabulary Topics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                'Chọn chủ đề để bắt đầu học với AI 🧠',
                style: TextStyle(color: textSub, fontSize: 14),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: _topics.length,
                  itemBuilder: (context, i) {
                    final t = _topics[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        final builder = screens[t.title];
                        if (builder != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => builder()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chủ đề ${t.title} chưa được triển khai!')),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: iconColor.withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(t.icon, size: 34, color: iconColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textMain,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 📘 Model đơn giản cho topic
class _Topic {
  final String title;
  final IconData icon;
  const _Topic(this.title, this.icon);
}
