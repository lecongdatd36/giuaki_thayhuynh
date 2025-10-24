import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/registration_service.dart';

class StudentHistoryPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const StudentHistoryPage({super.key, this.onBackToHome});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  bool loading = true;
  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    final data = await RegistrationService.getMyRegistrations();
    setState(() {
      history = data;
      loading = false;
    });
  }

  String getStatusText(String? status) {
    switch (status) {
      case "PRESENT":
        return "Có mặt";
      case "ABSENT":
        return "Vắng mặt";
      default:
        return "Chờ điểm danh";
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case "PRESENT":
        return Colors.green;
      case "ABSENT":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData getStatusIcon(String? status) {
    switch (status) {
      case "PRESENT":
        return Icons.check_circle;
      case "ABSENT":
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  String formatDateTime(String? datetime) {
    if (datetime == null) return "-";
    try {
      final dt = DateTime.parse(datetime);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return datetime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadData,
                child:
                    history.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: history.length,
                          itemBuilder:
                              (context, i) => _buildHistoryCard(history[i]),
                        ),
              ),
      floatingActionButton:
          widget.onBackToHome != null
              ? FloatingActionButton.extended(
                icon: const Icon(Icons.home),
                label: const Text("Về trang chủ"),
                backgroundColor: Colors.blueAccent,
                onPressed: widget.onBackToHome,
              )
              : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Chưa có hoạt động nào",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy đăng ký tham gia các hoạt động",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> h) {
    final status = h["attendance_status"];
    final statusColor = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(getStatusIcon(status), color: statusColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    h["title"] ?? "Không có tiêu đề",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getStatusText(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.location_on_outlined,
                  "Địa điểm",
                  h["location"] ?? "Chưa xác định",
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time,
                  "Thời gian",
                  formatDateTime(h["start_at"]),
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person_outline,
                  "Giảng viên",
                  h["lecturer_name"] ?? "Chưa rõ",
                  Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.stars_rounded,
                  "Điểm thưởng",
                  "${h["reward_point"] ?? 0} điểm",
                  Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
