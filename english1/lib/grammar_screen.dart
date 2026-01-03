import 'package:flutter/material.dart';

// 👉 Giữ nguyên các dòng Import của bạn
import 'tenses/present_simple_screen.dart';
import 'tenses/present_continuous_screen.dart';
import 'tenses/present_perfect_screen.dart';
import 'tenses/present_perfect_continuous_screen.dart';
import 'tenses/past_simple_screen.dart';
import 'tenses/past_continuous_screen.dart';
import 'tenses/past_perfect_screen.dart';
import 'tenses/past_perfect_continuous_screen.dart';
import 'tenses/future_simple_screen.dart';
import 'tenses/future_continuous_screen.dart';
import 'tenses/future_perfect_screen.dart';
import 'tenses/future_perfect_continuous_screen.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  String selectedTense = "Present Simple";

  final Map<String, List<String>> tenses = {
    "Hiện tại": ["Present Simple", "Present Continuous", "Present Perfect", "Present Perfect Continuous"],
    "Quá khứ": ["Past Simple", "Past Continuous", "Past Perfect", "Past Perfect Continuous"],
    "Tương lai": ["Future Simple", "Future Continuous", "Future Perfect", "Future Perfect Continuous"]
  };

  Widget _getTenseContent(String tense, Color textColor) {
    switch (tense) {
      case "Present Simple": return const PresentSimpleScreen();
      case "Present Continuous": return const PresentContinuousScreen();
      case "Present Perfect": return const PresentPerfectScreen();
      case "Present Perfect Continuous": return const PresentPerfectContinuousScreen();
      case "Past Simple": return const PastSimpleScreen();
      case "Past Continuous": return const PastContinuousScreen();
      case "Past Perfect": return const PastPerfectScreen();
      case "Past Perfect Continuous": return const PastPerfectContinuousScreen();
      case "Future Simple": return const FutureSimpleScreen();
      case "Future Continuous": return const FutureContinuousScreen();
      case "Future Perfect": return const FuturePerfectScreen();
      case "Future Perfect Continuous": return const FuturePerfectContinuousScreen();
      default:
        return Center(
          child: Text("⏳ Nội dung cho '$tense' đang được cập nhật...",
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final sidebarColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4FF);
    final textColor = isDark ? Colors.white : const Color(0xFF1E2E50);
    final accentColor = isDark ? Colors.tealAccent.shade100 : const Color(0xFF2F80ED);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 🔥 FIX 1: Tăng Breakpoint lên cao (1100) để đảm bảo trên Mobile/Máy ảo luôn hiện Menu 3 gạch
        // Điều này giúp nội dung bài học có đủ chỗ để không bị "xếp dọc" chữ.
        bool isMobile = constraints.maxWidth < 1100;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: isMobile
              ? AppBar(
                  elevation: 0,
                  backgroundColor: sidebarColor,
                  centerTitle: true,
                  title: Text(selectedTense, 
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  iconTheme: IconThemeData(color: accentColor),
                )
              : null,
          
          drawer: isMobile
              ? Drawer(
                  width: MediaQuery.of(context).size.width * 0.8, // Drawer chiếm 80% chiều rộng
                  child: Container(
                    color: sidebarColor,
                    child: _buildSidebarContent(context, accentColor, textColor),
                  ),
                )
              : null,

          body: Row(
            children: [
              if (!isMobile)
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: sidebarColor,
                    border: Border(right: BorderSide(color: textColor.withOpacity(0.1))),
                  ),
                  child: _buildSidebarContent(context, accentColor, textColor),
                ),

              Expanded(
                child: Container(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FB),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(selectedTense),
                      child: _getTenseContent(selectedTense, textColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarContent(BuildContext context, Color accentColor, Color textColor) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 50, 12, 10),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: tenses.entries.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(group.key.toUpperCase(),
                        style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                    ),
                    ...group.value.map((tense) {
                      final isActive = tense == selectedTense;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isActive ? accentColor.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(tense,
                            style: TextStyle(
                              fontSize: 14,
                              color: isActive ? accentColor : textColor.withOpacity(0.7),
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            )),
                          onTap: () {
                            setState(() => selectedTense = tense);
                            // Đóng drawer nếu đang mở
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        
        // 🔥 FIX 2: NÚT THOÁT - ÉP BUỘC QUAY VỀ TRANG CHỦ
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.home_rounded, size: 20, color: Colors.white),
            label: const Text("Về trang chủ", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED), 
              minimumSize: const Size.fromHeight(55),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Lệnh này sẽ xóa sạch các trang đang mở và quay về màn hình đầu tiên (Home)
              Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }
}