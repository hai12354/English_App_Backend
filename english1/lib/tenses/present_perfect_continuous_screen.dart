import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PresentPerfectContinuousScreen extends StatelessWidget {
  const PresentPerfectContinuousScreen({super.key});

  final String markdownContent = """
# 🟢 **Present Perfect Continuous (Thì Hiện Tại Hoàn Thành Tiếp Diễn)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + have/has + been + V-ing + O** | She has been studying for two hours. |
| Phủ định | **S + have/has + not + been + V-ing + O** | I haven’t been sleeping well lately. |
| Nghi vấn | **Have/Has + S + been + V-ing + O?** | Have they been working all day? |

> 📘 **Lưu ý:**  
> - **Have** dùng với **I / You / We / They**, **Has** dùng với **He / She / It**.  
> - Dạng **V-ing** là động từ thêm **-ing** như trong thì hiện tại tiếp diễn.  
> - Thì này thường đi với các từ chỉ **thời gian kéo dài**: *for, since, all day, recently, lately.*

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động bắt đầu trong quá khứ, tiếp tục đến hiện tại và có thể vẫn đang diễn ra.**  
> 👉 I have been learning English for 5 years.  
> 👉 She has been waiting for you since morning.

2️⃣ **Nhấn mạnh tính liên tục hoặc kéo dài của hành động.**  
> 👉 It has been raining all day.  
> 👉 They have been talking for over an hour.

3️⃣ **Diễn tả hành động vừa kết thúc và để lại kết quả hiện tại.**  
> 👉 I’m tired because I have been running.  
> 👉 The ground is wet because it has been raining.

---

## 🕰️ **Dấu hiệu nhận biết**

- for + khoảng thời gian (*for two hours, for a long time*)  
- since + mốc thời gian (*since 2010, since morning*)  
- all day / all week  
- recently / lately  
- up to now  

> 🧠 **Ví dụ:**  
> - He has been working **since 7 a.m.**  
> - I have been waiting for you **for 30 minutes.**  
> - They have been arguing **all day.**

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Present Perfect** | I have painted the room. | Hành động đã hoàn thành, tập trung vào kết quả. |
| **Present Perfect Continuous** | I have been painting the room. | Hành động kéo dài, nhấn mạnh quá trình. |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + have/has + been + V-ing | have/has + been |
| Phủ định | S + have/has + not + been + V-ing | have/has + been |
| Nghi vấn | Have/Has + S + been + V-ing? | have/has + been |

> ✅ **Ghi nhớ:**  
> Thì hiện tại hoàn thành tiếp diễn dùng để nói về **hành động kéo dài liên tục** từ quá khứ đến hiện tại (và có thể vẫn đang tiếp tục).  
> 👉 *I’ve been explaining this for 10 minutes already!* 😄
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

            // 🌈 Blockquote Decoration (y hệt PresentSimple)
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
