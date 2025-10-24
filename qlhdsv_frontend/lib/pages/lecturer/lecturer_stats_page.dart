import 'package:flutter/material.dart';
import '../../services/stat_service.dart';
import 'lecturer_activity_report_page.dart'; // 👈 import thêm trang chi tiết

class LecturerStatsPage extends StatefulWidget {
  const LecturerStatsPage({super.key});

  @override
  State<LecturerStatsPage> createState() => _LecturerStatsPageState();
}

class _LecturerStatsPageState extends State<LecturerStatsPage> {
  bool loading = true;
  Map<String, dynamic>? summary;
  List<dynamic> activities = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final res = await StatService.getLecturerOwnStats();
      setState(() {
        summary = res["summary"] ?? {};
        activities = res["activities"] ?? [];
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi tải thống kê giảng viên: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Báo cáo thống kê"),
        backgroundColor: Colors.deepOrange,
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            const Text(
              "📘 Danh sách hoạt động đã tạo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text("Chưa có hoạt động nào."),
                ),
              )
            else
              ...activities.map((a) => _buildActivityCard(a)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final s = summary ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tổng quan thống kê",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow("Hoạt động đã tạo", s["total_activities"] ?? 0),
          _buildSummaryRow("Số lượt đăng ký", s["total_registrations"] ?? 0),
          _buildSummaryRow("Số lượt có mặt", s["total_present"] ?? 0),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> a) {
    final title = a["title"] ?? "Không rõ";
    final reg = int.tryParse(a["registered_count"].toString()) ?? 0;
    final att = int.tryParse(a["attended_count"].toString()) ?? 0;
    final rate = reg > 0 ? ((att / reg) * 100).toStringAsFixed(1) : "0.0";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orangeAccent.shade100,
          child: const Icon(Icons.event, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "Đăng ký: $reg • Có mặt: $att • Tỉ lệ: $rate%",
          style: const TextStyle(color: Colors.black54),
        ),
        // 👇 Thêm onTap mở chi tiết báo cáo
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LecturerActivityReportPage(activity: a),
            ),
          );
        },
      ),
    );
  }
}
