import 'package:flutter/material.dart';
import '../../services/registration_service.dart';

class LecturerActivityReportPage extends StatefulWidget {
  final Map<String, dynamic> activity;
  const LecturerActivityReportPage({super.key, required this.activity});

  @override
  State<LecturerActivityReportPage> createState() =>
      _LecturerActivityReportPageState();
}

class _LecturerActivityReportPageState
    extends State<LecturerActivityReportPage> {
  bool loading = true;
  List<dynamic> registrations = [];

  @override
  void initState() {
    super.initState();
    loadRegistrations();
  }

  Future<void> loadRegistrations() async {
    try {
      final res =
          await RegistrationService.getRegistrations(widget.activity["id"]);
      setState(() {
        registrations = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải danh sách: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;

    return Scaffold(
      appBar: AppBar(
        title: Text("Báo cáo: ${a["title"]}"),
        backgroundColor: Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : registrations.isEmpty
              ? const Center(
                  child: Text("Chưa có sinh viên nào đăng ký hoạt động này."),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: registrations.length,
                  itemBuilder: (context, i) {
                    final r = registrations[i];
                    final status = r["attendance_status"] ?? "PENDING";

                    Color statusColor;
                    String statusText;

                    switch (status) {
                      case "PRESENT":
                        statusColor = Colors.green;
                        statusText = "Có mặt";
                        break;
                      case "ABSENT":
                        statusColor = Colors.red;
                        statusText = "Vắng mặt";
                        break;
                      default:
                        statusColor = Colors.orange;
                        statusText = "Chưa điểm danh";
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: statusColor,
                          ),
                        ),
                        title: Text(r["student_name"] ?? "Không rõ tên"),
                        subtitle: Text(r["email"] ?? "Không có email"),
                        trailing: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
