import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'lesson_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? errorMsg;

  Future<void> _login() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    final success = await ApiService.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LessonPage()),
      );
    } else {
      setState(() {
        errorMsg = "Нэвтрэхэд алдаа гарлаа. Хэрэглэгчийн нэр эсвэл нууц үг буруу байна.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Нэвтрэх")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Нэр"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Нууц үг"),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (errorMsg != null)
                Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loading ? null : _login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Нэвтрэх"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
