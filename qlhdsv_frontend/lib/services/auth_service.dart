import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // 🟢 Đăng ký (role mặc định STUDENT)
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await ApiService.post("/auth/register", {
      "name": name,
      "email": email,
      "password": password,
    });
    return res;
  }

  // 🟢 Đăng nhập
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await ApiService.post("/auth/login", {
      "email": email,
      "password": password,
    });

    if (res["token"] != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("token", res["token"]);

      // Lưu tên người dùng nếu backend trả về user info
      if (res["user"] != null && res["user"]["name"] != null) {
        prefs.setString("username", res["user"]["name"]);
      }
    }

    return res;
  }

  // 🟡 Lấy tên user đã lưu
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }

  // 🔴 Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
