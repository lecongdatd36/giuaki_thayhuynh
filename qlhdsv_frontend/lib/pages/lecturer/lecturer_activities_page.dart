import 'package:flutter/material.dart';
import '../../services/activity_service.dart';
import 'lecturer_activity_detail_page.dart';
import 'lecturer_activity_create_page.dart';
import 'lecturer_activity_edit_page.dart';

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
    setState(() => loading = true);
    final data = await ActivityService.getActivities();
    setState(() {
      activities = data;
      loading = false;
    });
  }

  Future<void> deleteActivity(int id, String title) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Xác nhận xóa"),
            content: Text("Bạn có chắc muốn xóa hoạt động \"$title\" không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Xóa"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final res = await ActivityService.deleteActivity(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Lỗi khi xóa hoạt động")),
    );
    loadData();
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
                    final title = a["title"] ?? "Không có tiêu đề";

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
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Địa điểm: ${a["location"] ?? "-"}\n"
                          "Thời gian: ${a["start_at"] ?? "-"}",
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => LecturerActivityEditPage(
                                        activity: a,
                                      ),
                                ),
                              );
                              if (updated == true) loadData();
                            } else if (value == 'delete') {
                              deleteActivity(a["id"], title);
                            }
                          },
                          itemBuilder:
                              (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Sửa"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Xóa"),
                                    ],
                                  ),
                                ),
                              ],
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
            loadData();
          }
        },
      ),
    );
  }
}
