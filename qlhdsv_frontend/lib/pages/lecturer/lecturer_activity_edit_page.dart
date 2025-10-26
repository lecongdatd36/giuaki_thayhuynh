import 'package:flutter/material.dart';
import '../../services/activity_service.dart';

class LecturerActivityEditPage extends StatefulWidget {
  final Map<String, dynamic> activity;
  const LecturerActivityEditPage({super.key, required this.activity});

  @override
  State<LecturerActivityEditPage> createState() =>
      _LecturerActivityEditPageState();
}

class _LecturerActivityEditPageState extends State<LecturerActivityEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController locCtrl;
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;
  late TextEditingController slotCtrl;
  late TextEditingController pointCtrl;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    titleCtrl = TextEditingController(text: a["title"] ?? "");
    descCtrl = TextEditingController(text: a["description"] ?? "");
    locCtrl = TextEditingController(text: a["location"] ?? "");
    startCtrl = TextEditingController(text: a["start_at"] ?? "");
    endCtrl = TextEditingController(text: a["end_at"] ?? "");
    slotCtrl = TextEditingController(text: a["max_slots"]?.toString() ?? "");
    pointCtrl = TextEditingController(
      text: a["reward_point"]?.toString() ?? "25",
    );
  }

  Future<void> saveEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final payload = {
      "title": titleCtrl.text,
      "description": descCtrl.text,
      "location": locCtrl.text,
      "start_at": startCtrl.text,
      "end_at": endCtrl.text,
      "max_slots": int.tryParse(slotCtrl.text) ?? 0,
      "reward_point": int.tryParse(pointCtrl.text) ?? 25,
    };

    final res = await ActivityService.updateActivity(
      widget.activity["id"],
      payload,
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Cập nhật thất bại")),
    );

    if (res["message"]?.contains("thành công") == true) {
      Navigator.pop(context, true); // quay lại danh sách
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("✏️ Sửa hoạt động"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Tên hoạt động"),
                validator:
                    (v) =>
                        v == null || v.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Mô tả"),
                maxLines: 3,
              ),
              TextFormField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: "Địa điểm"),
              ),
              TextFormField(
                controller: startCtrl,
                decoration: const InputDecoration(
                  labelText: "Thời gian bắt đầu (YYYY-MM-DD HH:mm)",
                ),
              ),
              TextFormField(
                controller: endCtrl,
                decoration: const InputDecoration(
                  labelText: "Thời gian kết thúc (YYYY-MM-DD HH:mm)",
                ),
              ),
              TextFormField(
                controller: slotCtrl,
                decoration: const InputDecoration(labelText: "Số lượng tối đa"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: pointCtrl,
                decoration: const InputDecoration(
                  labelText: "Điểm thưởng (reward)",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                icon:
                    loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.save),
                label: const Text("Lưu thay đổi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: loading ? null : saveEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
