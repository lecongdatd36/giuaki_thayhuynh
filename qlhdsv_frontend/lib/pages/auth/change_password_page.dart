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
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String message = "";

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPass = oldPassCtrl.text.trim();
    final newPass = newPassCtrl.text.trim();

    setState(() {
      loading = true;
      message = "";
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await ApiService.put("/auth/change-password", {
      "oldPassword": oldPass,
      "newPassword": newPass,
    }, token: token);

    setState(() => loading = false);

    if ((res["message"] ?? "").contains("thành công")) {
      setState(() => message = "success:${res["message"]}");
      oldPassCtrl.clear();
      newPassCtrl.clear();
      confirmCtrl.clear();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      setState(() => message = "error:${res["message"] ?? "Lỗi đổi mật khẩu"}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = message.startsWith("success:");
    final displayMessage =
        message.contains(":") ? message.split(":")[1] : message;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Nút quay lại
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey[800],
                ),
              ),
            ),

            // Nội dung chính
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo hoặc Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tiêu đề
                    Text(
                      "Đổi mật khẩu",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Cập nhật mật khẩu mới của bạn",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),

                    // Form đổi mật khẩu
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Mật khẩu cũ
                            TextFormField(
                              controller: oldPassCtrl,
                              obscureText: !_isOldPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu cũ",
                                hintText: "Nhập mật khẩu hiện tại",
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Colors.orange.shade600,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isOldPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _isOldPasswordVisible =
                                              !_isOldPasswordVisible,
                                    );
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator:
                                  (v) =>
                                      v!.isEmpty
                                          ? "Vui lòng nhập mật khẩu cũ"
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            // Mật khẩu mới
                            TextFormField(
                              controller: newPassCtrl,
                              obscureText: !_isNewPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu mới",
                                hintText: "Nhập mật khẩu mới",
                                prefixIcon: Icon(
                                  Icons.vpn_key_outlined,
                                  color: Colors.orange.shade600,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isNewPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _isNewPasswordVisible =
                                              !_isNewPasswordVisible,
                                    );
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator:
                                  (v) =>
                                      v!.length < 6
                                          ? "Mật khẩu phải từ 6 ký tự trở lên"
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            // Xác nhận mật khẩu
                            TextFormField(
                              controller: confirmCtrl,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Xác nhận mật khẩu mới",
                                hintText: "Nhập lại mật khẩu mới",
                                prefixIcon: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.orange.shade600,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible,
                                    );
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade600,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator:
                                  (v) =>
                                      v != newPassCtrl.text
                                          ? "Mật khẩu không khớp"
                                          : null,
                            ),
                            const SizedBox(height: 24),

                            // Nút đổi mật khẩu
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: loading ? null : changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child:
                                    loading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : const Text(
                                          "Xác nhận đổi mật khẩu",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),

                            // Thông báo
                            if (message.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isSuccess
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isSuccess
                                            ? Colors.green.shade200
                                            : Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSuccess
                                          ? Icons.check_circle_outline
                                          : Icons.error_outline,
                                      color:
                                          isSuccess
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        displayMessage,
                                        style: TextStyle(
                                          color:
                                              isSuccess
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tip box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Mật khẩu mạnh nên có ít nhất 6 ký tự và kết hợp chữ, số",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    oldPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }
}
