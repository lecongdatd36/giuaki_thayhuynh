import 'package:flutter/material.dart';
import '../../services/registration_service.dart';

class LecturerActivityDetailPage extends StatefulWidget {
  final Map<String, dynamic> activity;
  const LecturerActivityDetailPage({super.key, required this.activity});

  @override
  State<LecturerActivityDetailPage> createState() =>
      _LecturerActivityDetailPageState();
}

class _LecturerActivityDetailPageState
    extends State<LecturerActivityDetailPage> {
  List<dynamic> registrations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadList();
  }

  Future<void> loadList() async {
    try {
      final data = await RegistrationService.getRegistrations(
        widget.activity["id"],
      );
      setState(() {
        registrations = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(" Lỗi tải danh sách: $e")));
    }
  }

  Future<void> markAttendance(int regId, String status) async {
    final res = await RegistrationService.markAttendance(regId, status);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res["message"] ?? "Lỗi")));
    loadList(); // reload lại danh sách
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;

    return Scaffold(
      appBar: AppBar(
        title: Text("Điểm danh: ${a["title"]}"),
        backgroundColor: Colors.orangeAccent,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : registrations.isEmpty
              ? const Center(
                child: Text(
                  " Chưa có sinh viên nào đăng ký hoạt động này",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                onRefresh: loadList,
                child: ListView.builder(
                  itemCount: registrations.length,
                  itemBuilder: (context, i) {
                    final r = registrations[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          child: Text(
                            (r["student_name"]?[0] ?? "?").toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(r["student_name"] ?? "Không rõ tên"),
                        subtitle: Text("Email: ${r["email"] ?? ""}"),
                        trailing: DropdownButton<String>(
                          value: r["attendance_status"] ?? "PENDING",
                          onChanged: (val) {
                            if (val != null) markAttendance(r["id"], val);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: "PRESENT",
                              child: Text(" Có mặt"),
                            ),
                            DropdownMenuItem(
                              value: "ABSENT",
                              child: Text(" Vắng mặt"),
                            ),
                            DropdownMenuItem(
                              value: "PENDING",
                              child: Text(" Chưa điểm danh"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
