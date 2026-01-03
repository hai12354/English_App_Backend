import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FutureSimpleScreen extends StatelessWidget {
  const FutureSimpleScreen({super.key});

  final String markdownContent = """
# 🔵 **Future Simple (Thì Tương Lai Đơn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + will + V + O** | She will go to the party tonight. |
| Phủ định | **S + will not (won’t) + V + O** | I won’t forget your birthday. |
| Nghi vấn | **Will + S + V + O?** | Will they come tomorrow? |

> 📘 **Lưu ý:**  
> - **Will** dùng cho **mọi chủ ngữ** (I / You / We / They / He / She / It).  
> - Động từ giữ **nguyên thể (V)**, không chia.  
> - Dạng rút gọn phổ biến: **I will → I’ll**, **will not → won’t**.  

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động sẽ xảy ra trong tương lai (không có kế hoạch chắc chắn).**  
> 👉 I’ll call you later.  
> 👉 She will help you with your homework.

2️⃣ **Diễn tả dự đoán, phán đoán về tương lai.**  
> 👉 It will rain tomorrow.  
> 👉 I think she will pass the exam.

3️⃣ **Diễn tả lời hứa, quyết định tức thời.**  
> 👉 I’ll be there for you.  
> 👉 I’ll take this one! (quyết định tại chỗ)

4️⃣ **Diễn tả đề nghị, yêu cầu, lời mời.**  
> 👉 Will you marry me? 💍  
> 👉 Will you help me with this report?

---

## 🕰️ **Dấu hiệu nhận biết**

- tomorrow  
- next week / month / year  
- soon  
- later  
- in + thời gian (*in 2 days, in the future*)  

> 🧠 **Ví dụ:**  
> - I **will visit** my grandparents **next weekend.**  
> - It **will snow** soon.  
> - Don’t worry, I **won’t tell** anyone.

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Future Simple** | I will go to school tomorrow. | Hành động sẽ xảy ra (ý định hoặc dự đoán). |
| **Be Going To** | I’m going to go to school tomorrow. | Có kế hoạch hoặc dự định rõ ràng. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + will + V | will |
| Phủ định | S + won’t + V | will |
| Nghi vấn | Will + S + V? | will |

> ✅ **Ghi nhớ:**  
> - “Will” thể hiện **ý định, lời hứa, dự đoán hoặc hành động chưa có kế hoạch cụ thể.**  
> 👉 *Don’t worry, I’ll help you!* 💪
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
