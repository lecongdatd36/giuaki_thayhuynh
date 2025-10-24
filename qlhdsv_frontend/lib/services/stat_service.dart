import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class StatService {
  // 🧮 1. Thống kê tổng quan (Admin)
  static Future<Map<String, dynamic>> getAdminStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get("/stats/admin", token: token);
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  // 📊 2. Thống kê theo hoạt động (Admin)
  static Future<List<dynamic>> getActivityStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get("/stats/admin/activities", token: token);
    if (res is List) return res;
    return [];
  }

  // 👩‍🏫 3. Thống kê theo giảng viên (Admin)
  static Future<List<dynamic>> getLecturerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get("/stats/admin/lecturers", token: token);
    if (res is List) return res;
    return [];
  }

  // 🧑‍🏫 4. Thống kê riêng của giảng viên (khi giảng viên đăng nhập)
  static Future<Map<String, dynamic>> getLecturerOwnStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get("/stats/lecturer", token: token);
    if (res is Map<String, dynamic>) return res;
    return {};
  }

  // 🧾 Danh sách sinh viên của 1 hoạt động
static Future<List<dynamic>> getActivityParticipants(int activityId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");
  final res =
      await ApiService.get("/stats/lecturer/activity/$activityId", token: token);
  if (res is List) return res;
  return [];
}
}
