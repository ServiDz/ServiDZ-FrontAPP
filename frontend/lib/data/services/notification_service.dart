import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final String baseUrl = 'http://192.168.1.5:5000'; // Make sure this is reachable from your device

  Future<List<dynamic>> fetchNotifications() async {
    print("🔄 Starting fetchNotifications...");

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final role = prefs.getString('role');

    print("📦 SharedPreferences => userId: $userId | role: $role");

    if (userId == null || role == null) {
      print("❌ ERROR: userId or role is null.");
      throw Exception("User ID or role not found in SharedPreferences.");
    }

    final url = Uri.parse('$baseUrl/api/notifications/$role/$userId');
    print("🌐 Sending GET request to: $url");

    try {
      final response = await http.get(url);

      print("✅ Response received: Status Code = ${response.statusCode}");
      print("🧾 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print("📥 Parsed JSON: $jsonBody");

        return jsonBody['notifications'] ?? [];
      } else {
        print("❌ ERROR: Failed to fetch notifications — ${response.reasonPhrase}");
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      print("🔥 Exception during fetch: $e");
      throw Exception('An error occurred while fetching notifications');
    }
  }
}
