import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final String baseUrl = 'http://10.93.89.181:5000/api/auth';

  // ✅ Reusable storage method
  Future<void> _storeAuthData(String accessToken, String refreshToken, Map<String, dynamic> user, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user['_id']);
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('role', role); // optional: store role
  }

  // ✅ Logout / cleanup method
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
  }

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/login');

    // ✅ Get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
        'fcmToken': fcmToken, // ✅ Send to backend
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = data['user'];

      // ✅ Store tokens and user
      await _storeAuthData(accessToken, refreshToken, user, role);

      return {'success': true, 'user': user};
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Invalid credentials'
      };
    }
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'tempUserId': data['tempUserId']};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Signup failed'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'otp': otp,
          'role': role,
        }),
      );

      print('🔁 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'accessToken': data['accessToken'],
          'user': data['user'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final oldRefreshToken = prefs.getString('refreshToken');

    if (oldRefreshToken == null) return false;

    final url = Uri.parse('$baseUrl/refresh-token');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': oldRefreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];

      await prefs.setString('accessToken', newAccessToken);
      await prefs.setString('refreshToken', newRefreshToken);

      return true;
    } else {
      // Optional: clear stored tokens if refresh fails
      await clearAuthData();
      return false;
    }
  }

  // ✅ Tasker Registration
  Future<Map<String, dynamic>> registerTasker(Map<String, String> taskerData) async {
    final response = await http.post(
      Uri.parse('http://10.93.89.181:5000/api/tasker/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taskerData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'tempTaskerId': data['tempTaskerId']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Registration failed.'};
    }
  }
}
