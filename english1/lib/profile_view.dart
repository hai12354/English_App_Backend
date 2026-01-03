// ignore_for_file: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_config.dart';

class ProfileView extends StatefulWidget {
  final String username;
  final String userId;

  const ProfileView({super.key, required this.username, required this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _streak = 0;
  int _xp = 0;
  String _rank = "Đồng";
  Color _rankColor = Colors.brown;
  bool _isLoading = true;
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- LOGIC 1: CẬP NHẬT LÊN SERVER ---
  Future<void> _updateAvatarOnServer(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.base}/update-avatar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.userId,
          "avatar": base64Image, 
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Database đã cập nhật thành công");
      } else {
        debugPrint("❌ Lỗi Server: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối: $e");
    }
  }

  // --- LOGIC 2: CHỌN ẢNH ---
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 250,
        imageQuality: 50,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        String base64String = base64Encode(bytes);

        setState(() => _avatarBase64 = base64String);
        await _updateAvatarOnServer(base64String);
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  // --- LOGIC 3: GỠ ẢNH ---
  Future<void> _removeAvatar() async {
    setState(() => _avatarBase64 = null); 
    await _updateAvatarOnServer(""); 

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đã gỡ ảnh đại diện")),
      );
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text("Tùy chọn ảnh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Chọn ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (_avatarBase64 != null && _avatarBase64!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Gỡ ảnh hiện tại', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${AppConfig.base}/user-info/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _xp = data['xp'] ?? 0;
          _streak = data['streak'] ?? 0;
          String? avatarData = data['avatar'];
          _avatarBase64 = (avatarData != null && avatarData.isNotEmpty) ? avatarData : null;
        });
      }
    } catch (e) {
      debugPrint("Lỗi load data: $e");
    }
    _updateRank();
    if (mounted) setState(() => _isLoading = false);
  }

  void _updateRank() {
    if (_xp >= 3000) { _rank = "Kim Cương"; _rankColor = Colors.cyan; }
    else if (_xp >= 1500) { _rank = "Vàng"; _rankColor = Colors.amber; }
    else if (_xp >= 500) { _rank = "Bạc"; _rankColor = Colors.blueGrey; }
    else { _rank = "Đồng"; _rankColor = Colors.brown; }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF2F80ED);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: (_avatarBase64 != null && _avatarBase64!.isNotEmpty)
                              ? MemoryImage(base64Decode(_avatarBase64!))
                              : null,
                          child: (_avatarBase64 == null || _avatarBase64!.isEmpty)
                              ? const Icon(Icons.person, size: 60, color: primaryColor)
                              : null,
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: primaryColor,
                            child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // CHỈ CÒN HIỂN THỊ TÊN NGƯỜI DÙNG
                  Text(
                    widget.username, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildStatsSection(),
            const SizedBox(height: 30),
            _buildMenuSection(cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Ngày học", "$_streak", Icons.local_fire_department, Colors.orange),
              _buildStatItem("Điểm XP", _xp >= 1000 ? "${(_xp/1000).toStringAsFixed(1)}k" : "$_xp", Icons.bolt, Colors.yellow[700]!),
              _buildStatItem("Thứ hạng", _rank, Icons.emoji_events, _rankColor),
            ],
          ),
    );
  }

  Widget _buildMenuSection(Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            _buildListTile(Icons.info_outline, "Về ứng dụng", Colors.purple, () => _showAboutDialog(context)),
            _buildListTile(Icons.logout, "Đăng xuất", Colors.redAccent, () => _logout(context), isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, Color color, VoidCallback onTap, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, indent: 55, color: Colors.grey.withOpacity(0.1)),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); 
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _showAboutDialog(BuildContext context) async {
    try {
      final String response = await rootBundle.loadString('assets/app_info.json');
      final data = await json.decode(response);
      final List<dynamic> aboutList = data['about'];
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Thông tin ứng dụng ✨"),
          content: SizedBox(
            // Giới hạn chiều rộng trên Web để không bị quá to
            width: kIsWeb ? 400 : MediaQuery.of(context).size.width * 0.9,
            // Sử dụng SingleChildScrollView để cho phép cuộn, tránh lỗi tràn (vạch vàng đen)
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Quan trọng: chỉ chiếm đủ không gian cần thiết
                children: aboutList.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'], 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F80ED))
                      ),
                      const SizedBox(height: 4),
                      Text(item['desc'], style: const TextStyle(fontSize: 14)),
                      const Divider(),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Đóng", style: TextStyle(fontWeight: FontWeight.bold))
            )
          ],
        ),
      );
    } catch (e) { 
      debugPrint("Lỗi đọc JSON: $e"); 
    }
  }
}
