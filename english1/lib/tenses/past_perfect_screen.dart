import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PastPerfectScreen extends StatelessWidget {
  const PastPerfectScreen({super.key});

  final String markdownContent = """
# 🟣 **Past Perfect (Thì Quá Khứ Hoàn Thành)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + had + V3 (past participle) + O** | She had finished her homework before dinner. |
| Phủ định | **S + had not (hadn’t) + V3 + O** | I hadn’t seen him before that day. |
| Nghi vấn | **Had + S + V3 + O?** | Had you ever been to London before 2015? |

> 📘 **Lưu ý:**  
> - Trợ động từ luôn là **had** cho mọi chủ ngữ.  
> - **V3** là dạng **quá khứ phân từ** (past participle): *go → gone, eat → eaten, see → seen, work → worked.*

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động xảy ra trước một hành động khác trong quá khứ.**  
> 👉 She **had left** when I **arrived**.  
> 👉 They **had eaten** dinner before he **came** home.

2️⃣ **Dùng với “before”, “after”, “when”, “by the time”, “already”.**  
> 👉 By the time we arrived, the movie **had started**.  
> 👉 He **had already gone** to work when I called.

3️⃣ **Diễn tả kinh nghiệm, sự kiện xảy ra trước một mốc thời gian trong quá khứ.**  
> 👉 I **had never seen** snow before 2010.  
> 👉 She **had been** to Japan twice before she moved there.

---

## 🕰️ **Dấu hiệu nhận biết**

- before  
- after  
- by the time  
- when  
- already / just / never  

> 🧠 **Ví dụ:**  
> - The train **had left** before we **got** to the station.  
> - I **hadn’t finished** my work when the teacher **came in**.  
> - She **had lived** in Paris before she **moved** to London.

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Past Simple** | I ate dinner before 8 p.m. | Hai hành động quá khứ, nói bình thường. |
| **Past Perfect** | I had eaten dinner before 8 p.m. | Nhấn mạnh hành động xảy ra **trước** hành động khác. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + had + V3 | had |
| Phủ định | S + hadn’t + V3 | had |
| Nghi vấn | Had + S + V3? | had |

> ✅ **Ghi nhớ:**  
> Dùng **Past Perfect** để nói về hành động **xảy ra trước một hành động khác trong quá khứ.**  
> 👉 *I had studied English before I moved to Canada.* 😄
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
