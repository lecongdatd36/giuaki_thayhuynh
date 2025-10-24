import 'package:flutter/material.dart';
import '../../services/activity_service.dart';
import 'lecturer_activity_detail_page.dart';
import 'lecturer_activity_create_page.dart'; // 🆕 import trang tạo mới

class LecturerActivitiesPage extends StatefulWidget {
  const LecturerActivitiesPage({super.key});

  @override
  State<LecturerActivitiesPage> createState() => _LecturerActivitiesPageState();
}

class _LecturerActivitiesPageState extends State<LecturerActivitiesPage> {
  List<dynamic> activities = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await ActivityService.getActivities();
    setState(() {
      activities = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hoạt động giảng viên quản lý"),
        backgroundColor: Colors.orangeAccent,
      ),

      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadData,
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, i) {
                    final a = activities[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_available,
                          color: Colors.orangeAccent,
                        ),
                        title: Text(
                          a["title"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Địa điểm: ${a["location"] ?? "-"}\nThời gian: ${a["start_at"] ?? "-"}",
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      LecturerActivityDetailPage(activity: a),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

      // 🆕 Nút tạo hoạt động mới
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orangeAccent,
        icon: const Icon(Icons.add),
        label: const Text("Tạo hoạt động"),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LecturerActivityCreatePage(),
            ),
          );
          if (created == true) {
            loadData(); // reload danh sách sau khi tạo xong
          }
        },
      ),
    );
  }
}
