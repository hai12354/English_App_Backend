import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PastPerfectContinuousScreen extends StatelessWidget {
  const PastPerfectContinuousScreen({super.key});

  final String markdownContent = """
# 🟢 **Past Perfect Continuous (Thì Quá Khứ Hoàn Thành Tiếp Diễn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + had + been + V-ing + O** | She had been studying for two hours before the exam. |
| Phủ định | **S + had + not + been + V-ing + O** | They hadn’t been working for long before they quit. |
| Nghi vấn | **Had + S + been + V-ing + O?** | Had you been waiting long when he arrived? |

> 📘 **Lưu ý:**  
> - Trợ động từ luôn là **had**, không đổi theo chủ ngữ.  
> - Dùng để nhấn mạnh **quá trình kéo dài trước một mốc trong quá khứ**.  
> - Thường đi kèm các từ: *before, until, for, since, when, by the time.*

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động đã diễn ra liên tục cho đến một thời điểm hoặc hành động khác trong quá khứ.**  
> 👉 I had been working for 5 hours before I took a break.  
> 👉 They had been studying English before they moved to Canada.

2️⃣ **Nhấn mạnh tính kéo dài hoặc nguyên nhân của một trạng thái trong quá khứ.**  
> 👉 She was tired because she had been working all day.  
> 👉 The ground was wet because it had been raining.

3️⃣ **Dùng khi muốn nói “đã đang làm gì đó trong một khoảng thời gian trước quá khứ”.**  
> 👉 He had been living in Hanoi for 10 years before he moved to Da Nang.  

---

## 🕰️ **Dấu hiệu nhận biết**

- before  
- for + khoảng thời gian (*for two hours, for a week*)  
- since + mốc thời gian (*since morning, since 2010*)  
- until + mốc thời gian  
- by the time  

> 🧠 **Ví dụ:**  
> - We **had been talking** for 30 minutes when the teacher **came in.**  
> - She **had been working** there **since 2018** before she quit.  
> - It **had been raining** for hours before the storm stopped.

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Past Perfect** | I had worked for 2 hours before dinner. | Nhấn mạnh kết quả đã hoàn thành. |
| **Past Perfect Continuous** | I had been working for 2 hours before dinner. | Nhấn mạnh quá trình kéo dài, liên tục. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + had + been + V-ing | had + been |
| Phủ định | S + hadn’t + been + V-ing | had + been |
| Nghi vấn | Had + S + been + V-ing? | had + been |

> ✅ **Ghi nhớ:**  
> Thì quá khứ hoàn thành tiếp diễn dùng để nói về **hành động kéo dài liên tục trước một mốc trong quá khứ.**  
> 👉 *She was exhausted because she had been working all day!* 💪
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
            h1: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accentColor, height: 1.4),
            h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor, height: 1.3),
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
            tableHead: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
            tableBody: TextStyle(fontSize: 15, color: textColor),
            tableBorder: TableBorder.all(color: tableBorderColor, width: 1),
          ),
        ),
      ),
    );
  }
}
