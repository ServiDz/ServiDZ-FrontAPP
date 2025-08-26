// earning_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EarningService {
  final String _baseUrl = 'http://192.168.1.24:5000/api';

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

Future<Map<String, dynamic>?> fetchEarnings(String accessToken) async {
  final url = Uri.parse('$_baseUrl/earnings');

  print('[INFO] Sending GET to: $url');
  print('[INFO] With token: Bearer $accessToken');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  print('[INFO] Status Code: ${response.statusCode}');
  print('[INFO] Response Body: ${response.body}');

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else if (response.statusCode == 401) {
    print('[WARNING] Unauthorized - token expired');
    throw UnauthorizedException();
  } else {
    print('[ERROR] Unexpected status: ${response.statusCode}');
    throw Exception('Failed to load earnings');
  }
}


  Future<String?> refreshToken() async {
    final refreshToken = await getRefreshToken();

    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveAccessToken(data['accessToken']);
      return data['accessToken'];
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}

class UnauthorizedException implements Exception {}
