import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PresentPerfectScreen extends StatelessWidget {
  const PresentPerfectScreen({super.key});

  final String markdownContent = """
# 🟣 **Present Perfect (Thì Hiện Tại Hoàn Thành)**

---

## 🧩 **Cấu trúc**

| Loại câu | Cấu trúc | Ví dụ |
|-----------|-----------|--------|
| Khẳng định | **S + have/has + V3 (past participle) + O** | She has finished her homework. |
| Phủ định | **S + have/has + not + V3 + O** | I haven’t seen that movie. |
| Nghi vấn | **Have/Has + S + V3 + O?** | Have you ever been to Japan? |

> 📘 **Lưu ý:**  
> - **Have** dùng với **I / You / We / They**,  
> - **Has** dùng với **He / She / It**.  
> - **V3** là **động từ ở dạng quá khứ phân từ (past participle)**.  
>   → *work → worked, go → gone, do → done, see → seen.*

---

## 💡 **Cách dùng**

1️⃣ **Diễn tả hành động đã xảy ra trong quá khứ nhưng còn liên quan đến hiện tại**  
> 👉 I have lost my keys. (→ Bây giờ tôi vẫn chưa tìm thấy)  
> 👉 She has broken her leg. (→ Giờ vẫn bị đau hoặc đang bó bột)

2️⃣ **Diễn tả kinh nghiệm, trải nghiệm đã có trong đời (không nói rõ thời điểm)**  
> 👉 I have visited Thailand three times.  
> 👉 Have you ever eaten sushi?

3️⃣ **Diễn tả hành động bắt đầu trong quá khứ và kéo dài đến hiện tại**  
> 👉 I have lived in Hanoi for 10 years.  
> 👉 She has worked here since 2020.

4️⃣ **Diễn tả hành động vừa mới xảy ra (với “just”, “recently”)**  
> 👉 He has just arrived home.  
> 👉 We have recently finished the project.

---

## ⏰ **Dấu hiệu nhận biết**

- already  
- just  
- yet  
- ever / never  
- recently / lately  
- since / for  
- so far / up to now / until now  

> 🧠 **Ví dụ:**  
> - I have **already** done my homework.  
> - She hasn’t finished it **yet**.  
> - Have you **ever** been to Da Nang?  
> - We have lived here **for** 5 years.

---

## ⚙️ **Phân biệt nhanh**

| Thì | Ví dụ | Ý nghĩa |
|------|--------|---------|
| **Present Perfect** | I have eaten breakfast. | (Không nói khi nào, kết quả quan trọng) |
| **Past Simple** | I ate breakfast at 7 a.m. | (Nói rõ thời gian, đã kết thúc trong quá khứ) |

---

## 🌟 **Tóm tắt nhanh**

| Dạng | Cấu trúc | Trợ động từ |
|------|-----------|-------------|
| Khẳng định | S + have/has + V3 | have/has |
| Phủ định | S + have/has + not + V3 | have/has |
| Nghi vấn | Have/Has + S + V3? | have/has |

> ✅ **Ghi nhớ:**  
> Thì hiện tại hoàn thành dùng để nói về hành động **đã xảy ra nhưng ảnh hưởng đến hiện tại** hoặc **vừa mới kết thúc**.  
> 👉 *I’ve just finished reading this lesson!* 😄
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

            // 🌈 Blockquote đẹp như các file khác
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
