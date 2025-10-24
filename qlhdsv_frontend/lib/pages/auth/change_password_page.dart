import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool loading = false;

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPass = oldPassCtrl.text.trim();
    final newPass = newPassCtrl.text.trim();

    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await ApiService.put("/auth/change-password", {
      "oldPassword": oldPass,
      "newPassword": newPass,
    }, token: token);

    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Lỗi đổi mật khẩu")),
    );

    if ((res["message"] ?? "").contains("thành công")) {
      oldPassCtrl.clear();
      newPassCtrl.clear();
      confirmCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đổi mật khẩu"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cập nhật mật khẩu mới của bạn 👇",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // 🔒 Mật khẩu cũ
              TextFormField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu cũ",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => v!.isEmpty ? "Vui lòng nhập mật khẩu cũ" : null,
              ),
              const SizedBox(height: 15),

              // 🔑 Mật khẩu mới
              TextFormField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu mới",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        v!.length < 6
                            ? "Mật khẩu phải từ 6 ký tự trở lên"
                            : null,
              ),
              const SizedBox(height: 15),

              // ✅ Xác nhận lại mật khẩu
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Xác nhận mật khẩu mới",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => v != newPassCtrl.text ? "Mật khẩu không khớp" : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: loading ? null : changePassword,
                icon:
                    loading
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                        : const Icon(Icons.save),
                label: const Text("Xác nhận đổi mật khẩu"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
