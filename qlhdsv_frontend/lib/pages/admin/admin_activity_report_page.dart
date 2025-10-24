import 'package:flutter/material.dart';
import '../../services/registration_service.dart';

class AdminActivityReportPage extends StatefulWidget {
  final Map<String, dynamic> activity;
  const AdminActivityReportPage({super.key, required this.activity});

  @override
  State<AdminActivityReportPage> createState() => _AdminActivityReportPageState();
}

class _AdminActivityReportPageState extends State<AdminActivityReportPage> {
  bool loading = true;
  List<dynamic> registrations = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final res = await RegistrationService.getRegistrations(widget.activity["id"]);
    setState(() {
      registrations = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;

    return Scaffold(
      appBar: AppBar(
        title: Text("📘 Báo cáo: ${a["title"]}"),
        backgroundColor: Colors.redAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : registrations.isEmpty
              ? const Center(child: Text("Chưa có sinh viên đăng ký."))
              : ListView.builder(
                  itemCount: registrations.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, i) {
                    final r = registrations[i];
                    final status = r["attendance_status"] ?? "PENDING";
                    Color color;
                    String text;
                    switch (status) {
                      case "PRESENT":
                        color = Colors.green;
                        text = "Có mặt";
                        break;
                      case "ABSENT":
                        color = Colors.red;
                        text = "Vắng mặt";
                        break;
                      default:
                        color = Colors.orange;
                        text = "Chưa điểm danh";
                    }
                    return Card(
                      child: ListTile(
                        title: Text(r["student_name"] ?? "Không rõ"),
                        subtitle: Text(r["email"] ?? ""),
                        trailing: Text(text,
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
    );
  }
}
