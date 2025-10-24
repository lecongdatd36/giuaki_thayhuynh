import 'package:flutter/material.dart';
import '../../services/activity_service.dart';
import 'student_activity_detail_page.dart';

class StudentActivitiesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const StudentActivitiesPage({super.key, this.onBackToHome});

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
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

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "-";

    try {
      DateTime dateTime;

      // Thử parse ISO format trước (2025-10-25T14:30:00)
      if (dateTimeStr.contains('T')) {
        dateTime = DateTime.parse(dateTimeStr);
      }
      // Thử parse format yyyy-MM-dd HH:mm:ss
      else if (dateTimeStr.contains(' ')) {
        final parts = dateTimeStr.split(' ');
        final dateParts = parts[0].split('-');
        final timeParts =
            parts.length > 1 ? parts[1].split(':') : ['00', '00', '00'];

        dateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
        );
      } else {
        return dateTimeStr;
      }

      // Format thủ công: dd/MM/yyyy - HH:mm
      String day = dateTime.day.toString().padLeft(2, '0');
      String month = dateTime.month.toString().padLeft(2, '0');
      String year = dateTime.year.toString();
      String hour = dateTime.hour.toString().padLeft(2, '0');
      String minute = dateTime.minute.toString().padLeft(2, '0');

      return '$day/$month/$year - $hour:$minute';
    } catch (e) {
      return dateTimeStr; // Trả về chuỗi gốc nếu không parse được
    }
  }

  String getRelativeDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "";

    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      final DateTime now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays == 0) {
        return "Hôm nay";
      } else if (difference.inDays == 1) {
        return "Ngày mai";
      } else if (difference.inDays > 1 && difference.inDays <= 7) {
        return "Còn ${difference.inDays} ngày";
      } else if (difference.inDays < 0) {
        return "Đã qua";
      }
      return "";
    } catch (e) {
      return "";
    }
  }

  Color getStatusColor(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return Colors.grey;

    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      final DateTime now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays < 0) {
        return Colors.grey; // Đã qua
      } else if (difference.inDays == 0) {
        return Colors.red; // Hôm nay
      } else if (difference.inDays <= 3) {
        return Colors.orange; // Sắp diễn ra
      } else {
        return Colors.green; // Còn xa
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadData,
                child:
                    activities.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Không có hoạt động nào",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Kéo xuống để tải lại",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: activities.length,
                          itemBuilder: (context, i) {
                            final a = activities[i];
                            final relativeDate = getRelativeDate(a["start_at"]);
                            final statusColor = getStatusColor(a["start_at"]);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => StudentActivityDetailPage(
                                              activity: a,
                                            ),
                                      ),
                                    ).then((_) => loadData());
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header với icon và badge
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade400,
                                                    Colors.blue.shade600,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.event,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    a["title"] ??
                                                        "Không có tiêu đề",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (relativeDate
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: statusColor
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        border: Border.all(
                                                          color: statusColor
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            size: 12,
                                                            color: statusColor,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            relativeDate,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  statusColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: Colors.grey.shade400,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // Thông tin chi tiết
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      formatDateTime(
                                                        a["start_at"],
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade700,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Colors.red.shade400,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      a["location"] ??
                                                          "Chưa có địa điểm",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade700,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.home),
        label: const Text("Về trang chủ"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        onPressed: () {
          if (widget.onBackToHome != null) {
            widget.onBackToHome!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
