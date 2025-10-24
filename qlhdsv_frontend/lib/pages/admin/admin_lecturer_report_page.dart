import 'package:flutter/material.dart';
import '../../services/stat_service.dart';

class AdminLecturerReportPage extends StatefulWidget {
  final Map<String, dynamic> lecturer;
  const AdminLecturerReportPage({super.key, required this.lecturer});

  @override
  State<AdminLecturerReportPage> createState() =>
      _AdminLecturerReportPageState();
}

class _AdminLecturerReportPageState extends State<AdminLecturerReportPage> {
  bool loading = true;
  List<dynamic> activities = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // nếu backend có API riêng cho giảng viên thì gọi theo id, còn không thì reuse ActivityStats
    final res = await StatService.getActivityStats();
    setState(() {
      activities =
          res
              .where(
                (a) => a["lecturer_name"] == widget.lecturer["lecturer_name"],
              )
              .toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.lecturer["lecturer_name"] ?? "Giảng viên";

    return Scaffold(
      appBar: AppBar(
        title: Text("👨‍🏫 Hoạt động của $name"),
        backgroundColor: Colors.redAccent,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : activities.isEmpty
              ? const Center(child: Text("Giảng viên chưa tạo hoạt động nào."))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: activities.length,
                itemBuilder: (_, i) {
                  final a = activities[i];
                  final title = a["title"];
                  final reg =
                      int.tryParse(a["total_registered"].toString()) ?? 0;
                  final att = int.tryParse(a["total_attended"].toString()) ?? 0;
                  final rate =
                      reg > 0 ? ((att / reg) * 100).toStringAsFixed(1) : "0";
                  return Card(
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Đăng ký: $reg • Có mặt: $att • Tỉ lệ: $rate%",
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
