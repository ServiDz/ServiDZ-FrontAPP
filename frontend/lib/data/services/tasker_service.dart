import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasker_model.dart';

class TaskerService {
  final String _baseUrl = 'http://192.168.1.16:5000/api/taskers/all';

  Future<List<Tasker>> getAllTaskers() async {
    final url = Uri.parse(_baseUrl);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Tasker.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load taskers');
    }
  }


Future<Map<String, dynamic>?> fetchTaskerProfile() async {
  print('📦 Getting SharedPreferences...');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    print('❗ No token found in SharedPreferences');
    return null;
  }

  final url = Uri.parse('http://192.168.1.16:5000/api/tasker/profile');
  print('🌐 Sending GET request to $url');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Tasker data fetched successfully.');
      return data['tasker'];
    } else {
      print('❌ Failed to fetch tasker profile: ${response.body}');
      return null;
    }
  } catch (e) {
    print('🔥 Exception during profile fetch: $e');
    return null;
  }
}


Future<Map<String, dynamic>> fetchTaskerRatings(String taskerId) async {
    final response = await http.get(Uri.parse('http://192.168.1.16:5000/api/tasker/$taskerId/ratings'));

    if (response.statusCode == 200) {
      print('Ratings fetched successfully');
      return json.decode(response.body); 
    } else {
      throw Exception('Failed to load ratings');
    }
  }

}
