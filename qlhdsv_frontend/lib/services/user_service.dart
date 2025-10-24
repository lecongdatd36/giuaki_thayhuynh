import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserService {
  static Future<List<dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get("/auth/users", token: token);
    if (res is List) return res;
    return [];
  }

  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.post("/auth/users", body, token: token);
  }

  static Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.put("/auth/users/$id", body, token: token);
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return await ApiService.delete("/auth/users/$id", token: token);
  }

  static Future<List<dynamic>> getLecturers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await ApiService.get("/auth/users", token: token);
    if (res is List) {
      // lọc chỉ lấy giảng viên
      return res.where((u) => u["role"] == "LECTURER").toList();
    }
    return [];
  }
}
