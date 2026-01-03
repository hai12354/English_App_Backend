import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FuturePerfectScreen extends StatelessWidget {
  const FuturePerfectScreen({super.key});

  final String markdownContent = """
# 🔵 **Future Perfect (Thì Tương Lai Hoàn Thành)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + will have + V3 (past participle) + O** | She will have finished her homework by 9 p.m. |
| Phủ định | **S + will not (won’t) have + V3 + O** | I won’t have completed the report by tomorrow. |
| Nghi vấn | **Will + S + have + V3 + O?** | Will you have graduated by next year? |

> 📘 **Lưu ý:**  
> - “Will” dùng cho tất cả các chủ ngữ.  
> - **V3** là động từ ở dạng quá khứ phân từ (*go → gone, do → done, finish → finished*).  
> - Dùng để nói về **hành động sẽ hoàn thành trước một thời điểm hoặc hành động khác trong tương lai.**

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động sẽ hoàn thành trước một thời điểm xác định trong tương lai.**  
> 👉 By 8 o’clock, I will have finished my dinner.  
> 👉 She will have left before you arrive.

2️⃣ **Diễn tả hành động sẽ hoàn thành trước một hành động khác trong tương lai.**  
> 👉 When he comes, I will have cleaned the house.  
> 👉 They will have finished the project before the deadline.

3️⃣ **Dự đoán về điều đã xảy ra trước một thời điểm tương lai.**  
> 👉 He will have reached home by now.  
> 👉 They will have landed in Paris by the time we wake up.

---

## 🕰️ **Dấu hiệu nhận biết**

- by + mốc thời gian tương lai (*by tomorrow, by next week, by 2030*)  
- before + một hành động khác  
- when + hành động tương lai  
- by the time + mệnh đề tương lai  

> 🧠 **Ví dụ:**  
> - I **will have finished** this book **by Sunday.**  
> - She **won’t have arrived** by 10 p.m.  
> - **Will you have done** your homework before class?

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Future Continuous** | I will be studying at 9 p.m. | Hành động đang diễn ra ở thời điểm tương lai. |
| **Future Perfect** | I will have studied by 9 p.m. | Hành động **đã hoàn thành trước** thời điểm tương lai đó. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + will have + V3 | will have |
| Phủ định | S + won’t have + V3 | will have |
| Nghi vấn | Will + S + have + V3? | will have |

> ✅ **Ghi nhớ:**  
> Thì tương lai hoàn thành dùng để diễn tả **một hành động hoàn tất trước một thời điểm khác trong tương lai**.  
> 👉 *By next month, I’ll have learned all 12 English tenses!* 💪
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
