import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ActivityService {
  // 🟢 Lấy danh sách hoạt động
  static Future<List<dynamic>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await ApiService.get("/activities", token: token);
    if (res is List) return res;
    return [];
  }

  // 🧍 Sinh viên đăng ký hoạt động
  static Future<Map<String, dynamic>> register(int activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.post(
      "/registrations/$activityId",
      {},
      token: token,
    );
  }

  // 🔴 Xóa hoạt động
  static Future<Map<String, dynamic>> deleteActivity(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.delete("/activities/$id", token: token);
  }

  // 🟢 Tạo mới hoạt động
  static Future<Map<String, dynamic>> createActivity(
    Map<String, dynamic> body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.post("/activities", body, token: token);
  }

  // 🟠 Cập nhật hoạt động
  static Future<Map<String, dynamic>> updateActivity(
    int id,
    Map<String, dynamic> body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.put("/activities/$id", body, token: token);
  }

  // đăng kí hoạt động sv
  static Future<Map<String, dynamic>> unregister(int activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.delete("/registrations/$activityId", token: token);
  }

  static Future<Map<String, dynamic>> checkStatus(int activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    // gọi đúng ApiService thay vì BaseApi
    final res = await ApiService.get(
      "/registrations/status/$activityId",
      token: token,
    );
    return res;
  }
}
