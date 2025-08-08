import 'dart:convert';
import 'package:http/http.dart' as http;

class RatingService {
  static Future<Map<String, dynamic>> submitRating({
    required String taskerId,
    required String userId,
    required double value,
    String? review,
  }) async {
    final url = Uri.parse('http://192.168.1.4:5000/api/tasker/rate'); // Your backend IP/port

    print("📤 Sending rating request to: $url");
    print("📝 Payload:");
    print("   🆔 Tasker ID: $taskerId");
    print("   🙋 User ID: $userId");
    print("   ⭐ Rating Value: $value");
    print("   💬 Review: $review");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'taskerId': taskerId,
          'userId': userId,
          'value': value,
          'review': review,
        }),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Success! Parsed response: $data");
        return data;
      } else {
        print("❌ Failed to submit rating: ${response.body}");
        throw Exception('Failed to submit rating: ${response.body}');
      }
    } catch (e) {
      print("⚠️ Exception occurred: $e");
      rethrow;
    }
  }
}
