import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api"; // local backend

  // 🟢 GET
  static Future<dynamic> get(String endpoint, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    try {
      return jsonDecode(res.body);
    } catch (e) {
      return {"message": "Lỗi parse JSON: ${res.body}"};
    }
  }

  // 🟡 POST
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    try {
      return jsonDecode(res.body);
    } catch (e) {
      return {"message": "Lỗi parse JSON: ${res.body}"};
    }
  }

  // 🔴 DELETE
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final res = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    try {
      return jsonDecode(res.body);
    } catch (e) {
      return {"message": "Lỗi parse JSON: ${res.body}"};
    }
  }

  // 🟢 PUT (update)
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    try {
      return jsonDecode(res.body);
    } catch (e) {
      return {"message": "Lỗi parse JSON: ${res.body}"};
    }
  }
}
