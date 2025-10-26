import 'package:flutter/material.dart';
import '../../services/activity_service.dart';

class StudentActivityDetailPage extends StatefulWidget {
  final Map<String, dynamic> activity;
  const StudentActivityDetailPage({super.key, required this.activity});

  @override
  State<StudentActivityDetailPage> createState() =>
      _StudentActivityDetailPageState();
}

class _StudentActivityDetailPageState extends State<StudentActivityDetailPage> {
  bool loading = false;
  bool isRegistered = false;
  bool isAttended = false;

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  /// 🔍 Kiểm tra trạng thái đăng ký & điểm danh của sinh viên
  Future<void> checkStatus() async {
    try {
      setState(() => loading = true);
      final res = await ActivityService.checkStatus(widget.activity["id"]);
      setState(() {
        isRegistered = res["is_registered"] ?? false;
        isAttended = res["is_attended"] ?? false;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi kiểm tra trạng thái: $e");
      setState(() => loading = false);
    }
  }

  /// 🕒 Định dạng ngày giờ
  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "-";
    try {
      DateTime dateTime;
      if (dateTimeStr.contains('T')) {
        dateTime = DateTime.parse(dateTimeStr);
      } else {
        final parts = dateTimeStr.split(' ');
        final dateParts = parts[0].split('-');
        final timeParts = parts.length > 1 ? parts[1].split(':') : ['00', '00'];
        dateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
        );
      }
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// 🟢 Sinh viên đăng ký hoạt động
  Future<void> registerActivity() async {
    setState(() => loading = true);
    final res = await ActivityService.register(widget.activity["id"]);
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Lỗi không xác định")),
    );

    final msg = res["message"]?.toLowerCase() ?? "";
    if (msg.contains("thành công") || msg.contains("đã đăng ký")) {
      setState(() => isRegistered = true);
    }
  }

  /// 🔴 Hủy đăng ký hoạt động
  Future<void> cancelRegistration() async {
    setState(() => loading = true);
    final res = await ActivityService.unregister(widget.activity["id"]);
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Lỗi không xác định")),
    );

    if (res["message"]?.contains("hủy") == true) {
      setState(() {
        isRegistered = false;
        isAttended = false;
      });
    }
  }

  /// 🧭 Xác định trạng thái hoạt động (chưa diễn ra / đang diễn ra / đã kết thúc)
  String getActivityStatus() {
    try {
      final now = DateTime.now();
      DateTime? startTime;
      DateTime? endTime;
      final startStr = widget.activity["start_at"];
      final endStr = widget.activity["end_at"];

      if (startStr != null && startStr.isNotEmpty) {
        startTime =
            DateTime.tryParse(startStr) ??
            DateTime.parse(startStr.replaceAll(' ', 'T'));
      }
      if (endStr != null && endStr.isNotEmpty) {
        endTime =
            DateTime.tryParse(endStr) ??
            DateTime.parse(endStr.replaceAll(' ', 'T'));
      }

      if (endTime != null && now.isAfter(endTime)) return "ended";
      if (startTime != null &&
          endTime != null &&
          now.isAfter(startTime) &&
          now.isBefore(endTime))
        return "ongoing";
      return "upcoming";
    } catch (e) {
      return "upcoming";
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final status = getActivityStatus();

    return Scaffold(
      appBar: AppBar(
        title: Text(a["title"] ?? "Chi tiết hoạt động"),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Tiêu đề
                    Center(
                      child: Text(
                        a["title"] ?? "Không có tiêu đề",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Các thẻ thông tin
                    _buildInfoCard(
                      icon: Icons.description,
                      iconColor: Colors.indigo,
                      title: "Mô tả",
                      content: a["description"] ?? "Không có mô tả",
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      title: "Địa điểm",
                      content: a["location"] ?? "Chưa cập nhật",
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      iconColor: Colors.blue,
                      title: "Thời gian bắt đầu",
                      content: formatDateTime(a["start_at"]),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.event_available,
                      iconColor: Colors.green,
                      title: "Thời gian kết thúc",
                      content: formatDateTime(a["end_at"]),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.people,
                      iconColor: Colors.orange,
                      title: "Số lượng tối đa",
                      content: "${a["max_slots"] ?? '-'} người",
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.stars,
                      iconColor: Colors.amber,
                      title: "Điểm thưởng",
                      content: "${a["reward_point"] ?? 0} điểm",
                    ),

                    const SizedBox(height: 30),
                    _buildStatusButton(status),
                  ],
                ),
              ),
    );
  }

 
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 Nút hoặc thông báo trạng thái
  Widget _buildStatusButton(String status) {
    if (status == "ended") {
      return _statusContainer("Hoạt động đã kết thúc", Colors.grey);
    }

    if (status == "ongoing") {
      return _statusContainer(" Hoạt động đang diễn ra", Colors.blueAccent);
    }

    if (isAttended) {
      return _statusContainer("Bạn đã được điểm danh", Colors.green);
    }

    if (isRegistered) {
      return _statusContainer("Chờ giảng viên điểm danh", Colors.orange);
    }

    // chỉ khi chưa đăng ký và hoạt động chưa diễn ra
    return ElevatedButton.icon(
      onPressed: loading ? null : registerActivity,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      label: const Text("Đăng ký tham gia"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 🪧 Container hiển thị trạng thái
  Widget _statusContainer(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
