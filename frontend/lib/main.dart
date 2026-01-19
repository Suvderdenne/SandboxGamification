import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/topics_page.dart';
import 'pages/profile_page.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sandbox Quiz',
      
      // 🎨 Theme тохиргоо
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // 🗺️ Routes тохиргоо
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/topics': (context) => const TopicsPage(),
        '/profile': (context) => const ProfilePage(),
        // Дараагийн хуудсуудыг энд нэмнэ
      },
    );
  }
}