import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PresentContinuousScreen extends StatelessWidget {
  const PresentContinuousScreen({super.key});

  final String markdownContent = """
# 🟢 **Present Continuous (Thì Hiện Tại Tiếp Diễn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + am/is/are + V-ing + O** | She is watching TV. |
| Phủ định | **S + am/is/are + not + V-ing + O** | They are not studying now. |
| Nghi vấn | **Am/Is/Are + S + V-ing + O?** | Are you doing your homework? |

> 📘 **Lưu ý:**  
> - **am** dùng với **I**, **is** với **He / She / It**, **are** với **You / We / They**.  
> - Động từ thêm **-ing** theo quy tắc:  
>   👉 *work → working*, *run → running*, *make → making*.

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động đang xảy ra tại thời điểm nói**  
> 👉 I am talking to you right now.  
> 👉 She is cooking dinner.

2️⃣ **Diễn tả hành động tạm thời (chưa kết thúc)**  
> 👉 He is living in Hanoi these days.  
> 👉 I’m working on a new project this week.

3️⃣ **Diễn tả hành động có kế hoạch trong tương lai gần**  
> 👉 We are meeting them tomorrow.  
> 👉 I am flying to Singapore next week.

---

## 🕰️ **Dấu hiệu nhận biết**

- now  
- right now  
- at the moment  
- today  
- this week / month / year  
- look! / listen!  

> 🧠 **Ví dụ:**  
> - She **is studying** at the moment.  
> - They **are playing** football now.  
> - I **am not watching** TV.

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Present Simple** | I work every day. | Hành động lặp lại thường xuyên |
| **Present Continuous** | I am working now. | Hành động đang diễn ra tại hiện tại |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + am/is/are + V-ing | am/is/are |
| Phủ định | S + am/is/are + not + V-ing | am/is/are |
| Nghi vấn | Am/Is/Are + S + V-ing? | am/is/are |

> ✅ Dùng thì **hiện tại tiếp diễn** để nói về hành động **đang xảy ra** hoặc **tạm thời đang diễn ra**.  
> 👉 *Right now, you’re reading this explanation!* 😄
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

            // 🌈 Blockquote làm đẹp như file mày gửi
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
