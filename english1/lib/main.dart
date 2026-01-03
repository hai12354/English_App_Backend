import 'package:flutter/material.dart';
import 'login_page.dart';
import 'theme_controller.dart';
import 'splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeController.instance.mode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F80ED)),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F80ED),
              brightness: Brightness.dark,
            ),
          ),
          // 👉 Khởi chạy Splash trước
          home: const SplashScreen(),
          // (tuỳ chọn) định nghĩa route đặt tên
          routes: {
            '/login': (_) => const LoginPage(),
          },
        );
      },
    );
  }
}
