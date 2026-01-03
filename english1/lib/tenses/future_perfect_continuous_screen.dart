import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FuturePerfectContinuousScreen extends StatelessWidget {
  const FuturePerfectContinuousScreen({super.key});

  final String markdownContent = """
# 🔵 **Future Perfect Continuous (Thì Tương Lai Hoàn Thành Tiếp Diễn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + will have been + V-ing + O** | She will have been working here for 10 years by next month. |
| Phủ định | **S + will not (won’t) have been + V-ing + O** | I won’t have been studying long enough to pass the exam. |
| Nghi vấn | **Will + S + have been + V-ing + O?** | Will they have been living in Hanoi for five years by 2026? |

> 📘 **Lưu ý:**  
> - “Will” dùng cho tất cả các chủ ngữ.  
> - Động từ ở dạng **V-ing** như trong thì hiện tại tiếp diễn.  
> - Dùng để nói về **một hành động sẽ kéo dài đến một thời điểm trong tương lai** và **nhấn mạnh thời gian kéo dài**.

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động bắt đầu trong quá khứ, tiếp tục đến tương lai và kéo dài tới một thời điểm xác định trong tương lai.**  
> 👉 By next month, I will have been working here for 5 years.  
> 👉 She will have been studying English for 10 years by 2030.

2️⃣ **Nhấn mạnh thời gian kéo dài của hành động trong tương lai.**  
> 👉 When you arrive, they will have been waiting for two hours.  
> 👉 He will have been driving for 6 hours by midnight.

3️⃣ **Dự đoán nguyên nhân của một trạng thái trong tương lai.**  
> 👉 She will be tired because she will have been working all day.  
> 👉 He will have been studying hard, so he’ll deserve the prize.

---

## 🕰️ **Dấu hiệu nhận biết**

- by + mốc thời gian trong tương lai (*by next year, by 2030*)  
- for + khoảng thời gian (*for 2 hours, for 10 years*)  
- when + mệnh đề chỉ thời điểm tương lai  
- by the time + hành động tương lai  

> 🧠 **Ví dụ:**  
> - I **will have been studying** for 3 hours **by 9 p.m.**  
> - They **will have been traveling** for a week **by the time** you see them.  
> - **Will you have been working** here for long **by then**?

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Future Perfect** | I will have studied English for 5 years by 2025. | Hành động **hoàn thành** trước thời điểm tương lai. |
| **Future Perfect Continuous** | I will have been studying English for 5 years by 2025. | Hành động **kéo dài liên tục** đến thời điểm tương lai. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + will have been + V-ing | will have been |
| Phủ định | S + won’t have been + V-ing | will have been |
| Nghi vấn | Will + S + have been + V-ing? | will have been |

> ✅ **Ghi nhớ:**  
> Thì tương lai hoàn thành tiếp diễn dùng để diễn tả **hành động sẽ kéo dài liên tục cho đến một thời điểm trong tương lai**, nhấn mạnh **thời gian thực hiện hành động**.  
> 👉 *By 2030, I’ll have been teaching English for 15 years!* 👨‍🏫
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
