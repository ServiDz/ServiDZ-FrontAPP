import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String baseUrl = 'http://192.168.1.16:5000/api/settings';

  // Helper: Get token from local storage
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print('📦 Retrieved token: $token');
    return token;
  }

  // 1. Change Password
  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final token = await _getToken();
    if (token == null) {
      print('❌ Token not found');
      return {'success': false, 'message': 'Token not found'};
    }

    print('🔐 Sending password change request...');
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

    print('📤 Request body: ${jsonEncode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    })}');
    print('📥 Status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Something went wrong',
    };
  }

  // 2. Logout
  static Future<Map<String, dynamic>> logout() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ Token not found');
      return {'success': false, 'message': 'Token not found'};
    }

    print('🚪 Sending logout request...');
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 Status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Logout failed',
    };
  }

  // 3. Deactivate Account
  static Future<Map<String, dynamic>> deactivateAccount() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ Token not found');
      return {'success': false, 'message': 'Token not found'};
    }

    print('❎ Sending account deactivation request...');
    final response = await http.post(
      Uri.parse('$baseUrl/deactivate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 Status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Deactivation failed',
    };
  }

  static Future<Map<String, dynamic>> updatePhoneNumber(String phone) async {
  print('📦 Starting phone update...');
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final token = prefs.getString('accessToken');

  if (userId == null || token == null) {
    print('❗ userId or token not found in SharedPreferences');
    return {'success': false, 'message': 'Missing credentials'};
  }

  final url = Uri.parse('http://192.168.1.16:5000/api/profile/update-phone');
  final body = jsonEncode({'userId': userId, 'phone': phone});

  print('🌐 Sending POST request to $url');
  print('📤 Request body: $body');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print('📥 Status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    final data = jsonDecode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Unknown error'
    };
  } catch (e) {
    print('❌ Exception during phone update: $e');
    return {'success': false, 'message': 'Error updating phone number'};
  }
}
}
