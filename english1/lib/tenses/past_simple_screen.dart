import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PastSimpleScreen extends StatelessWidget {
  const PastSimpleScreen({super.key});

  final String markdownContent = """
# 🔵 **Past Simple (Thì Quá Khứ Đơn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + V2 (quá khứ) + O** | She went to school yesterday. |
| Phủ định | **S + did not (didn’t) + V (nguyên mẫu) + O** | I didn’t watch TV last night. |
| Nghi vấn | **Did + S + V (nguyên mẫu) + O?** | Did you see that movie? |

> 📘 **Lưu ý:**  
> - Động từ **thêm -ed** ở thì quá khứ nếu là **động từ có quy tắc** (*work → worked, play → played*).  
> - **Bất quy tắc**: dùng **dạng V2** (*go → went, eat → ate, see → saw*).  
> - Trợ động từ luôn là **did**, và **động từ chính trở lại dạng nguyên mẫu.**

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động đã xảy ra và kết thúc trong quá khứ (có thời gian cụ thể)**  
> 👉 I visited my grandparents yesterday.  
> 👉 She watched a movie last night.

2️⃣ **Diễn tả các hành động nối tiếp nhau trong quá khứ**  
> 👉 He came home, took a shower, and went to bed.

3️⃣ **Diễn tả thói quen trong quá khứ (thường với “used to”)**  
> 👉 I used to play football when I was a kid.  
> 👉 She didn’t use to eat vegetables.

---

## 🕰️ **Dấu hiệu nhận biết**

- yesterday  
- last night / last week / last year  
- ago (*two days ago, a month ago*)  
- in + mốc thời gian quá khứ (*in 1999, in May*)  
- when + mệnh đề quá khứ (*when I was young*)  

> 🧠 **Ví dụ:**  
> - They **went** to Paris last summer.  
> - I **didn’t sleep** well **last night**.  
> - **Did** you **see** him **yesterday**?

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Past Simple** | I studied English last night. | Hành động đã hoàn thành, có thời điểm xác định. |
| **Present Perfect** | I have studied English. | Hành động đã xảy ra, không nói rõ khi nào, còn liên quan hiện tại. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + V2 | ❌ |
| Phủ định | S + didn’t + V | did |
| Nghi vấn | Did + S + V? | did |

> ✅ **Ghi nhớ:**  
> Thì quá khứ đơn dùng để nói về **hành động đã xảy ra và kết thúc trong quá khứ**.  
> 👉 *I didn’t know that until you told me!* 😄
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
            listBullet: TextStyle(fontSize: 16, color: textColor),
            strong: const TextStyle(fontWeight: FontWeight.bold),

            // 🌈 Blockquote Decoration
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
