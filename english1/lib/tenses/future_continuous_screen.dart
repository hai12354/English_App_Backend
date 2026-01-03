import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FutureContinuousScreen extends StatelessWidget {
  const FutureContinuousScreen({super.key});

  final String markdownContent = """
# 🔵 **Future Continuous (Thì Tương Lai Tiếp Diễn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + will be + V-ing + O** | She will be studying at 8 p.m. tonight. |
| Phủ định | **S + will not (won’t) be + V-ing + O** | I won’t be sleeping at that time. |
| Nghi vấn | **Will + S + be + V-ing + O?** | Will you be working tomorrow? |

> 📘 **Lưu ý:**  
> - “Will” không chia theo chủ ngữ.  
> - Động từ thêm **-ing** như trong thì hiện tại tiếp diễn.  
> - Dạng rút gọn: **will not → won’t**.  
> - Dùng để nói về **hành động đang diễn ra tại một thời điểm xác định trong tương lai**.

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động sẽ đang diễn ra tại một thời điểm xác định trong tương lai.**  
> 👉 At 10 a.m. tomorrow, I’ll be driving to work.  
> 👉 This time next week, we’ll be lying on the beach.

2️⃣ **Diễn tả hành động sẽ xảy ra song song với một hành động khác trong tương lai.**  
> 👉 She will be cooking while I’ll be cleaning the house.  
> 👉 When you arrive, I’ll be waiting for you.

3️⃣ **Dự đoán hành động đang diễn ra ở tương lai (theo lịch trình, kế hoạch).**  
> 👉 Don’t call her now — she’ll be having a meeting.  
> 👉 They’ll be traveling in Japan next month.

4️⃣ **Hỏi lịch trình một cách lịch sự (dạng câu hỏi).**  
> 👉 Will you be joining us for dinner tonight?  
> 👉 Will you be using the car tomorrow?

---

## 🕰️ **Dấu hiệu nhận biết**

- at this time + thời gian tương lai (*at this time tomorrow*)  
- at + giờ + thời điểm tương lai (*at 7 p.m. tonight*)  
- this time next week / next month / next year  
- when + mốc tương lai  

> 🧠 **Ví dụ:**  
> - I **will be studying** at 9 tonight.  
> - She **won’t be working** on Sunday.  
> - Will you **be staying** with us this weekend?

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Future Simple** | I will study at 9 p.m. | Hành động sẽ xảy ra (chưa bắt đầu). |
| **Future Continuous** | I will be studying at 9 p.m. | Hành động **đang diễn ra tại thời điểm tương lai**. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + will be + V-ing | will be |
| Phủ định | S + won’t be + V-ing | will be |
| Nghi vấn | Will + S + be + V-ing? | will be |

> ✅ **Ghi nhớ:**  
> Thì tương lai tiếp diễn dùng để nói về **hành động đang diễn ra tại một thời điểm trong tương lai** hoặc **diễn ra song song với hành động khác**.  
> 👉 *I’ll be waiting for your message!* 💬
""";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white70 : const Color(0xFF1E2E50);
    final accentColor =
        isDark ? Colors.tealAccent.shade100 : const Color(0xFF2F80ED);
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
            p: TextStyle(fontSize: 16, color: textColor, height: 1.6),
            listBullet: TextStyle(fontSize: 16, color: textColor),
            strong: const TextStyle(fontWeight: FontWeight.bold),
            blockquoteDecoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.tealAccent.withOpacity(0.3)
                    : const Color(0xFF2F80ED).withOpacity(0.3),
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
            tableBorder: TableBorder.all(color: tableBorderColor, width: 1),
          ),
        ),
      ),
    );
  }
}
