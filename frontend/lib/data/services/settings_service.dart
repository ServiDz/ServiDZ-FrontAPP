import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class SettingsService {
  static const String baseUrl = 'http://192.168.1.4:5000';

  // 🔐 Helper to get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print('📦 Retrieved token: $token');
    return token;
  }

  // 🔐 Change password
  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token not found'};

    final response = await http.put(
      Uri.parse('$baseUrl/api/settings/change-password'),
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

  // 🚪 Logout
  static Future<Map<String, dynamic>> logout() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token not found'};

    final response = await http.post(
      Uri.parse('$baseUrl/api/settings/logout'),
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

  // ❎ Deactivate account
  static Future<Map<String, dynamic>> deactivateAccount() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token not found'};

    final response = await http.post(
      Uri.parse('$baseUrl/api/settings/deactivate'),
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

  // ☎️ Update phone number
  static Future<Map<String, dynamic>> updatePhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('accessToken');

    if (userId == null || token == null) {
      return {'success': false, 'message': 'Missing credentials'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/profile/update-phone'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId, 'phone': phone}),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Unknown error',
    };
  }

  // 📄 Upload certificate
  static Future<List<dynamic>> uploadCertificate({
    required String taskerId,
    required File file,
    required String description,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final uri = Uri.parse('$baseUrl/api/tasker/upload');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['taskerId'] = taskerId;
    request.fields['description'] = description;

    final stream = http.ByteStream(file.openRead());
    final length = await file.length();

    final multipartFile = http.MultipartFile(
      'certificate',
      stream,
      length,
      filename: path.basename(file.path),
    );

    request.files.add(multipartFile);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseBody);
      return List.from(jsonResponse['certifications'] ?? []);
    } else {
      throw Exception('Upload failed: ${response.statusCode}: $responseBody');
    }
  }
}
