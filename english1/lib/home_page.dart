import 'package:flutter/material.dart';
import 'topic_list_screen.dart';
import 'theme_controller.dart';
import 'speaking_screen.dart';
import 'grammar_screen.dart';
import 'Listening_Screen.dart'; 
import 'profile_view.dart';
import 'dictionary_screen.dart'; 
import 'quiz_screen.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String userId;

  const HomePage({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Map<String, dynamic>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'title': 'Home',
        'widget': _Dashboard(username: widget.username, userId: widget.userId),
      },
      {
        'title': 'AI Dictionary',
        'widget': const DictionaryScreen(),
      },
      {
        'title': 'Practice',
        'widget': QuizScreen(userId: widget.userId, username: widget.username),
      },
      {
        'title': 'Profile',
        'widget': ProfileView(username: widget.username, userId: widget.userId),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        title: Text(
          _pages[_currentIndex]['title'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Chuyển sáng' : 'Chuyển tối',
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            onPressed: () => ThemeController.instance.toggle(),
          ),
        ],
      ),
      body: IndexedStack( // Dùng IndexedStack để giữ trạng thái trang tốt hơn
        index: _currentIndex,
        children: _pages.map((p) => p['widget'] as Widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF2F80ED),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Dictionary'),
          BottomNavigationBarItem(icon: Icon(Icons.headphones_outlined), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  final String username;
  final String userId;

  const _Dashboard({required this.username, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? Colors.white70 : const Color(0xFF1E2E50);
    final textSub = isDark ? Colors.grey[400] : Colors.black54;

    return SingleChildScrollView( // ✅ Fix 1: Cho phép cuộn toàn bộ trang để tránh lỗi overflow dọc
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xin chào, $username 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textMain)),
          const SizedBox(height: 10),
          Text('Chúc bạn một ngày học tập hiệu quả!',
              style: TextStyle(fontSize: 15, color: textSub)),
          const SizedBox(height: 30),
          GridView.count(
            shrinkWrap: true, // ✅ Fix 2: Để GridView nằm gọn trong SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(), // Để SingleChildScrollView xử lý cuộn
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // ✅ Fix 3: Tăng chiều cao các ô để không bị tràn chữ bên dưới
            children: [
              _HomeCard(
                title: 'Vocabulary',
                subtitle: 'Expand your words',
                icon: Icons.menu_book_outlined,
                color: const Color(0xFF4A90E2),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopicListScreen())),
              ),
              _HomeCard(
                title: 'Grammar',
                subtitle: 'Master the rules',
                icon: Icons.edit_note_outlined,
                color: const Color(0xFF8E6FF7),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrammarScreen())),
              ),
              _HomeCard(
                title: 'Speaking',
                subtitle: 'Practice conversations',
                icon: Icons.record_voice_over_outlined,
                color: const Color(0xFF6FCF97),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SpeakingScreen(userId: userId, username: username))),
              ),
              _HomeCard(
                title: 'Listening',
                subtitle: 'Tune your ear',
                icon: Icons.hearing_outlined,
                color: const Color(0xFF2D9CDB),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListeningScreen(username: username, userId: userId))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2E50);
    final subColor = isDark ? Colors.grey[400] : Colors.black54;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Giảm padding một chút
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible( // ✅ Fix 4: Icon tự co lại nếu thiếu chỗ
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: color), // Giảm size icon từ 36 -> 28
                ),
              ),
              const SizedBox(height: 10),
              FittedBox( // ✅ Fix 5: Chữ tự thu nhỏ size nếu tên quá dài (Ví dụ: Vocabulary)
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: subColor),
                textAlign: TextAlign.center,
                maxLines: 1, // ✅ Fix 6: Ép hiển thị 1 dòng để tránh vỡ khung
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}