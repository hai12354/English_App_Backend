import 'package:shared_preferences/shared_preferences.dart';

class UserDataHelper {
  static const String xpKey = 'user_xp';
  static const String streakKey = 'user_streak';

  // 1. Cộng thêm XP (dùng khi vừa làm xong bài tập)
  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentXP = prefs.getInt(xpKey) ?? 0;
    int newXP = currentXP + amount;
    await prefs.setInt(xpKey, newXP);
    print("⭐ Đã cộng: $amount XP local. Tổng local: $newXP");
  }

  // 2. Ghi đè XP (Dùng để đồng bộ dữ liệu chuẩn xác từ Server về máy)
  static Future<void> setXP(int finalTotalXP) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(xpKey, finalTotalXP);
    print("🔄 Đã đồng bộ XP từ Server vào máy: $finalTotalXP");
  }

  // 3. Lưu số ngày học (Streak) từ Server trả về
  static Future<void> setStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(streakKey, streak);
  }

  // 4. Lấy XP ra để hiển thị trên giao diện
  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(xpKey) ?? 0;
  }

  // 5. Lấy Streak ra để hiển thị
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(streakKey) ?? 0;
  }

  // 6. Xóa sạch dữ liệu khi Đăng xuất
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(xpKey);
    await prefs.remove(streakKey);
  }
}