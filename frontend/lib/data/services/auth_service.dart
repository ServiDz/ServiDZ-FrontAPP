import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.93.89.181:5000/api/auth';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = data['user'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user['_id']);
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);

      return {'success': true, 'user': user};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Invalid credentials'};
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
  }) async {
    final url = Uri.parse('http://10.93.89.181:5000/api/auth/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'otp': otp}),
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

    // Update tokens in SharedPreferences
    await prefs.setString('accessToken', newAccessToken);
    await prefs.setString('refreshToken', newRefreshToken);

    return true;
  } else {
    // Optional: clear stored tokens if refresh fails
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
    return false;
  }
}



}
