import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String baseUrl = 'http://10.93.89.181:5000/api/settings'; // ⚠️ Change for real device

  // Helper: Get token from local storage
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // 1. Change Password
  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token not found'};

    final response = await http.put(
      Uri.parse('$baseUrl/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Something went wrong',
    };
  }

  // 2. Logout
  static Future<Map<String, dynamic>> logout() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token not found'};

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Logout failed',
    };
  }
  

  // 3. Deactivate Account
  static Future<Map<String, dynamic>> deactivateAccount() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token not found'};

    final response = await http.post(
      Uri.parse('$baseUrl/deactivate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Deactivation failed',
    };
  }
}
