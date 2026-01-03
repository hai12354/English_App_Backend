import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PresentSimpleScreen extends StatelessWidget {
  const PresentSimpleScreen({super.key});

  final String markdownContent = """
# 🟢 **Present Simple (Thì Hiện Tại Đơn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + V(s/es) + O** | She works every day. |
| Phủ định | **S + do/does + not + V + O** | He doesn’t like coffee. |
| Nghi vấn | **Do/Does + S + V + O?** | Do you play football? |

> 📘 **Lưu ý:**  
> - Thêm **-s / -es** với động từ khi **chủ ngữ là He / She / It**.  
> - Các động từ bất quy tắc như *have → has*, *go → goes*.

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả thói quen, hành động lặp lại theo chu kỳ**  
👉 I go to school every morning.  
👉 She usually drinks coffee before work.

2️⃣ **Diễn tả sự thật hiển nhiên, quy luật tự nhiên**  
👉 The sun rises in the east.  
👉 Water boils at 100°C.

3️⃣ **Diễn tả thời gian biểu, lịch trình cố định**  
👉 The train leaves at 8 a.m.  
👉 My class starts at 7 o’clock.

4️⃣ **Miêu tả cảm xúc, suy nghĩ, trạng thái**  
👉 I love this song.  
👉 She believes in you.

---

## 🕰️ **Dấu hiệu nhận biết**

Một số trạng từ thường đi với thì hiện tại đơn:

- always  
- usually  
- often  
- sometimes  
- seldom / rarely  
- never  
- every day / week / month  
- on Mondays / at weekends  

> 🧠 **Ví dụ:**  
> - She **always** wakes up early.  
> - They **never** eat fast food.  
> - I go to the gym **every day**.

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + V(s/es) + O | ❌ |
| Phủ định | S + do/does + not + V | do/does |
| Nghi vấn | Do/Does + S + V + O? | do/does |

> ✅ Đây là thì **cơ bản và phổ biến nhất** trong tiếng Anh.  
> Hãy luyện tập với các ví dụ hằng ngày để nhớ lâu hơn! 💪
""";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white70 : const Color(0xFF1E2E50);
    final accentColor = isDark ? Colors.tealAccent.shade100 : const Color(0xFF2F80ED);
    final tableBorderColor = isDark ? Colors.white24 : Colors.black26;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: MarkdownBody(
          data: markdownContent,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            h1: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: accentColor,
              height: 1.4,
            ),
            h2: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
              height: 1.3,
            ),
            p: TextStyle(
              fontSize: 16,
              color: textColor,
              height: 1.6,
            ),
            listBullet: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
            strong: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            // ✨ Blockquote: Lưu ý – làm đẹp và rõ ràng
            blockquoteDecoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.tealAccent.withOpacity(0.3) : const Color(0xFF2F80ED).withOpacity(0.3),
                width: 1.2,
              ),
            ),
            blockquote: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
              fontStyle: FontStyle.italic,
              fontSize: 15.5,
              height: 1.5,
            ),
            tableHead: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
            tableBody: TextStyle(
              fontSize: 15,
              color: textColor,
            ),
            tableBorder: TableBorder.all(
              color: tableBorderColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
