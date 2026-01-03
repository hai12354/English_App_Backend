import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PastContinuousScreen extends StatelessWidget {
  const PastContinuousScreen({super.key});

  final String markdownContent = """
# 🟡 **Past Continuous (Thì Quá Khứ Tiếp Diễn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + was/were + V-ing + O** | She was cooking dinner at 7 p.m. |
| Phủ định | **S + was/were + not + V-ing + O** | They weren’t watching TV last night. |
| Nghi vấn | **Was/Were + S + V-ing + O?** | Were you sleeping at 10 o’clock? |

> 📘 **Lưu ý:**  
> - **Was** dùng với **I / He / She / It**.  
> - **Were** dùng với **You / We / They**.  
> - Dạng **V-ing**: thêm **-ing** vào sau động từ (*go → going, play → playing*).  
> - Với động từ tận cùng bằng **e** → bỏ **e**, thêm **ing** (*write → writing*).  

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động đang xảy ra tại một thời điểm trong quá khứ**  
> 👉 At 8 p.m. last night, I was studying.  
> 👉 She was watching TV at that time.

2️⃣ **Hai hành động xảy ra song song trong quá khứ**  
> 👉 While I was reading, my sister was listening to music.  
> 👉 They were talking while it was raining.

3️⃣ **Hành động đang diễn ra thì bị hành động khác xen vào (dạng Past Simple)**  
> 👉 I was cooking when he arrived.  
> 👉 She was sleeping when the phone rang.

---

## 🕰️ **Dấu hiệu nhận biết**

- at + thời điểm trong quá khứ (*at 7 p.m. yesterday*)  
- while / when  
- yesterday / last night  
- as / at that time  

> 🧠 **Ví dụ:**  
> - I **was doing** my homework **at 9 p.m.**  
> - They **were talking** when the teacher **came in.**  
> - While we **were walking**, it **started to rain.**

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Past Simple** | I watched TV last night. | Hành động xảy ra và kết thúc trong quá khứ. |
| **Past Continuous** | I was watching TV when you called. | Hành động đang diễn ra tại thời điểm trong quá khứ. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + was/were + V-ing | was / were |
| Phủ định | S + was/were + not + V-ing | was / were |
| Nghi vấn | Was/Were + S + V-ing? | was / were |

> ✅ **Ghi nhớ:**  
> Thì quá khứ tiếp diễn dùng để diễn tả **hành động đang xảy ra tại một thời điểm trong quá khứ**, hoặc **hai hành động song song / bị xen vào.**  
> 👉 *I was studying when you texted me!* 😄
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
            p: TextStyle(
              fontSize: 16,
              color: textColor,
              height: 1.6,
            ),
            listBullet: TextStyle(fontSize: 16, color: textColor),
            strong: const TextStyle(fontWeight: FontWeight.bold),

            // 🌈 Blockquote Decoration (như các thì khác)
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

            tableHead:
                TextStyle(fontWeight: FontWeight.bold, color: accentColor),
            tableBody: TextStyle(fontSize: 15, color: textColor),
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
