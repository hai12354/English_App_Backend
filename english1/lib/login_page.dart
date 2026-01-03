import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  Widget _eyeToggle() {
    return IconButton(
      icon: Icon(
        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.grey,
      ),
      onPressed: () => setState(() => _obscure = !_obscure),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      late final Uri url;
      late final Map<String, dynamic> payload;

      if (_isLogin) {
        url = Uri.parse('${AppConfig.base}/login');
        payload = {'username': username, 'password': password};
      } else {
        url = Uri.parse('${AppConfig.base}/register');
        payload = {
          'name': _nameController.text.trim(),
          'username': username,
          'password': password,
        };
      }

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(payload),
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (_isLogin) {
        if (res.statusCode == 200 && body['token'] != null && body['user'] != null) {
          final user = body['user'];
          final userId = user['id'];
          final userName = user['username'];

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(username: userName, userId: userId),
            ),
          );
        } else {
          throw Exception(body['error'] ?? 'Sai tài khoản hoặc mật khẩu');
        }
      } else {
        if (res.statusCode == 201 || res.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Đăng ký thành công! Vui lòng đăng nhập.')),
          );
          await Future.delayed(const Duration(milliseconds: 800));
          if (!mounted) return;
          setState(() {
            _isLogin = true;
            _passwordController.clear();
          });
        } else {
          throw Exception(body['error'] ?? 'Đăng ký thất bại');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword(String username, String newPass) async {
    final url = Uri.parse('${AppConfig.base}/reset-password');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'username': username, 'new_password': newPass}),
    );

    if (res.statusCode == 200) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đổi mật khẩu thành công. Hãy đăng nhập lại!')),
      );
    } else {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      throw Exception(body['error'] ?? 'Đổi mật khẩu thất bại (${res.statusCode})');
    }
  }

  void _showForgotPasswordDialog() {
    final usernameController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Ép nền trắng đồng bộ
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Đặt lại mật khẩu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2E50), // Màu tiêu đề đậm
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập tên tài khoản và mật khẩu mới để thay đổi.',
              style: TextStyle(color: Colors.black87), // Chữ mô tả rõ nét
            ),
            const SizedBox(height: 16),
            // Ô nhập tên tài khoản
            TextField(
              controller: usernameController,
              style: const TextStyle(color: Color(0xFF1E2E50)), // Chữ nhập vào màu đậm
              decoration: _inputDecoration(
                hint: 'Tên tài khoản',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(height: 12),
            // Ô nhập mật khẩu mới
            TextField(
              controller: newPassController,
              obscureText: true,
              style: const TextStyle(color: Color(0xFF1E2E50)), // Chữ nhập vào màu đậm
              decoration: _inputDecoration(
                hint: 'Mật khẩu mới',
                icon: Icons.lock_outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final acc = usernameController.text.trim();
              final newPass = newPassController.text.trim();

              if (acc.isEmpty || newPass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ Vui lòng nhập đầy đủ thông tin!')),
                );
                return;
              }

              try {
                await _resetPassword(acc, newPass);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Lỗi: $e')),
                );
              }
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF74B3F3), Color(0xFFD3E7FF)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 390,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school, size: 42, color: Color(0xFF2F80ED)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isLogin ? 'Đăng nhập' : 'Tạo tài khoản mới',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2E50),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Đăng nhập để tiếp tục hành trình học tập.'
                        : 'Bắt đầu hành trình chinh phục tri thức.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 26),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin)
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Color(0xFF1E2E50)), // Thêm dòng này
                            decoration: _inputDecoration(
                              hint: 'Họ và tên',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Nhập họ và tên' : null,
                          ),
                        if (!_isLogin) const SizedBox(height: 14),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Color(0xFF1E2E50)), // Thêm dòng này
                          decoration: _inputDecoration(
                            hint: 'Tên tài khoản',
                            icon: Icons.person_outline,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Nhập tên tài khoản' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Color(0xFF1E2E50)), // Thêm dòng này
                          obscureText: _obscure,
                          decoration: _inputDecoration(
                            hint: 'Mật khẩu',
                            icon: Icons.lock_outline,
                            suffix: _eyeToggle(),
                          ),
                          validator: (v) =>
                              v == null || v.length < 6 ? 'Ít nhất 6 ký tự' : null,
                        ),
                      ],
                    ),
                  ),
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2F80ED),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Đăng nhập' : 'Đăng ký',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? 'Chưa có tài khoản? ' : 'Đã có tài khoản? ',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? 'Đăng ký' : 'Đăng nhập',
                          style: const TextStyle(
                            color: Color(0xFF2F80ED),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black45),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 15), 
    filled: true,
    fillColor: const Color(0xFFF4F7FB), // Giữ nền trắng xanh nhạt
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }
}
