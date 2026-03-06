// pages/login_page.dart

import 'package:flutter/material.dart';
import '../layouts/empty_layout.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'topics_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    
    final success = await ApiService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TopicsPage()),
      );
    }
    
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 EmptyLayout ашиглаж байгаа нь (Header/Footer-гүй)
    return EmptyLayout(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text('Sandbox Quiz', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'Мэдлэгээ шалгаарай',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 48),
              
              // Login form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Нэвтрэх нэр',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Нууц үг',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const CircularProgressIndicator()
                              : const Text('Нэвтрэх'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Бүртгэлгүй юу? Шинэ бүртгэл үүсгэх'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}