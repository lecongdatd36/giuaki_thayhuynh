import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class RegistrationService {
  // 🔹 Lấy danh sách sinh viên đăng ký 1 hoạt động
  static Future<List<dynamic>> getRegistrations(int activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get(
      "/registrations/$activityId",
      token: token,
    );
    if (res is List) return res;
    return [];
  }

  // 🔹 Điểm danh (dành cho giảng viên hoặc admin)
  static Future<Map<String, dynamic>> markAttendance(
    int registrationId,
    String status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.post(
      "/registrations/attendance/mark", // ✅ route khớp backend
      {"registration_id": registrationId, "status": status},
      token: token,
    );
  }
   // 🔹 Lấy lịch sử hoạt động của sinh viên
  static Future<List<dynamic>> getMyRegistrations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get("/registrations/mine", token: token);
    if (res is List) return res;
    return [];
  
}
}