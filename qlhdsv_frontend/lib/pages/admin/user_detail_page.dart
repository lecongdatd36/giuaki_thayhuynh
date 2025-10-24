import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class UserDetailPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  const UserDetailPage({super.key, this.user});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passCtrl;
  String selectedRole = "STUDENT";

  bool loading = false;
  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    nameCtrl = TextEditingController(text: u?["name"] ?? "");
    emailCtrl = TextEditingController(text: u?["email"] ?? "");
    passCtrl = TextEditingController();
    selectedRole = u?["role"] ?? "STUDENT";
  }

  Future<void> saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final payload = {
      "name": nameCtrl.text,
      "email": emailCtrl.text,
      if (!isEdit || passCtrl.text.isNotEmpty)
        "password": passCtrl.text, // chỉ gửi khi tạo mới hoặc có thay đổi
      "role": selectedRole,
    };

    final res = isEdit
        ? await UserService.updateUser(widget.user!["id"], payload)
        : await UserService.createUser(payload);

    setState(() => loading = false);

    if (res["id"] != null || res["message"]?.contains("thành công") == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEdit ? "Cập nhật thành công" : "Tạo người dùng thành công"),
      ));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Lỗi khi lưu")),
      );
    }
  }

  Future<void> deleteUser() async {
    if (!isEdit) return;
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa người dùng"),
        content: const Text("Bạn có chắc chắn muốn xóa tài khoản này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => loading = true);
    final res = await UserService.deleteUser(widget.user!["id"]);
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Lỗi khi xóa")),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Sửa người dùng" : "Tạo người dùng mới"),
        backgroundColor: Colors.redAccent,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Xóa tài khoản",
              onPressed: loading ? null : deleteUser,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Họ và tên"),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              if (!isEdit)
                TextFormField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: "Mật khẩu"),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? "Không được để trống mật khẩu" : null,
                ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: "ADMIN", child: Text("Quản trị viên")),
                  DropdownMenuItem(value: "LECTURER", child: Text("Giảng viên")),
                  DropdownMenuItem(value: "STUDENT", child: Text("Sinh viên")),
                ],
                onChanged: (val) => setState(() => selectedRole = val!),
                decoration: const InputDecoration(labelText: "Cấp quyền"),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                icon: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? "Lưu thay đổi" : "Tạo người dùng"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: loading ? null : saveUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
