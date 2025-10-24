import 'package:flutter/material.dart';
import '../../services/stat_service.dart';
import 'admin_activity_report_page.dart';
import 'admin_lecturer_report_page.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Map<String, dynamic>? summaryData;
  List<dynamic> activityData = [];
  List<dynamic> lecturerData = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final summary = await StatService.getAdminStats();
      final activities = await StatService.getActivityStats();
      final lecturers = await StatService.getLecturerStats();

      setState(() {
        summaryData = summary;
        activityData = activities;
        lecturerData = lecturers;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi tải dữ liệu thống kê: $e");
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Báo cáo thống kê hệ thống"),
        backgroundColor: Colors.redAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Tổng quan"),
            Tab(text: "Theo hoạt động"),
            Tab(text: "Theo giảng viên"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildActivityTab(),
          _buildLecturerTab(),
        ],
      ),
    );
  }

  // 📈 TAB 1: TỔNG QUAN
  Widget _buildSummaryTab() {
    final s = summaryData?["summary"] ?? {};
    final top = (summaryData?["topStudents"] ?? []) as List<dynamic>;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("📈 Tổng quan hệ thống",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildStatGrid(s),
        const SizedBox(height: 30),
        const Divider(thickness: 1),
        const SizedBox(height: 20),
        const Text("🏅 Top 5 sinh viên tích cực nhất",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (top.isEmpty)
          const Text("Chưa có dữ liệu sinh viên tham gia.")
        else
          ...top.asMap().entries.map((e) {
            final i = e.key + 1;
            final t = e.value;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.shade100,
                  child: Text("$i",
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(t["name"]),
                subtitle: Text(t["email"]),
                trailing: Text("${t["total_point"] ?? 0} điểm",
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold)),
              ),
            );
          }),
      ],
    );
  }

  // 📊 TAB 2: THEO HOẠT ĐỘNG
  Widget _buildActivityTab() {
    if (activityData.isEmpty) {
      return const Center(child: Text("Không có dữ liệu hoạt động."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: activityData.length,
      itemBuilder: (context, index) {
        final a = activityData[index];
        final title = a["title"] ?? "Không rõ";
        final total = int.tryParse(a["total_registered"].toString()) ?? 0;
        final present = int.tryParse(a["total_attended"].toString()) ?? 0;
        final percent =
            total > 0 ? ((present / total) * 100).toStringAsFixed(1) : "0";

        return Card(
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.blueAccent),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text("Đăng ký: $total • Có mặt: $present • Tỉ lệ: $percent%"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminActivityReportPage(activity: a),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 👨‍🏫 TAB 3: THEO GIẢNG VIÊN
  Widget _buildLecturerTab() {
    if (lecturerData.isEmpty) {
      return const Center(child: Text("Không có dữ liệu giảng viên."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: lecturerData.length,
      itemBuilder: (context, index) {
        final l = lecturerData[index];
        final name = l["lecturer_name"] ?? "Không rõ";
        final totalActs = int.tryParse(l["total_activities"].toString()) ?? 0;
        final regs = int.tryParse(l["total_registrations"].toString()) ?? 0;
        final pres = int.tryParse(l["total_present"].toString()) ?? 0;
        final percent =
            regs > 0 ? ((pres / regs) * 100).toStringAsFixed(1) : "0";

        return Card(
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.orangeAccent),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Hoạt động: $totalActs • Đăng ký: $regs • Có mặt: $pres • Tỉ lệ: $percent%"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminLecturerReportPage(lecturer: l),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 🧩 Lưới tổng quan
  Widget _buildStatGrid(Map<String, dynamic> s) {
    final stats = [
      {"icon": Icons.event, "label": "Hoạt động", "value": s["total_activities"] ?? 0},
      {"icon": Icons.people, "label": "Sinh viên", "value": s["total_students"] ?? 0},
      {"icon": Icons.how_to_reg, "label": "Đăng ký", "value": s["total_registrations"] ?? 0},
      {"icon": Icons.check_circle, "label": "Có mặt", "value": s["total_present"] ?? 0},
    ];

    return GridView.builder(
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, i) {
        final st = stats[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(st["icon"], color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(st["label"], style: const TextStyle(color: Colors.white70)),
                Text("${st["value"]}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}
