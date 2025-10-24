import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../admin/admin_home.dart';
import '../lecturer/lecturer_home.dart';
import '../student/student_home.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String message = "";

  Future<void> login() async {
    final res = await AuthService.login(emailCtrl.text, passCtrl.text);

    if (res["token"] != null) {
      final userName = res["user"]?["name"] ?? "Người dùng";
      final role = res["user"]?["role"] ?? "STUDENT";

      if (role == "ADMIN") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomePage(userName: userName)),
        );
      } else if (role == "LECTURER") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LecturerHomePage(userName: userName),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHomePage(userName: userName),
          ),
        );
      }
    } else {
      setState(() => message = res["message"] ?? "Sai tài khoản hoặc mật khẩu");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
              child: const Text("Đăng nhập"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Chưa có tài khoản? Đăng ký"),
            ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(message, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
