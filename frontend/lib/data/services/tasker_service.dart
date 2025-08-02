import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasker_model.dart';

class TaskerService {
  final String _baseUrl = 'http://10.93.89.181:5000/api/taskers/all';

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

  final taskerId = prefs.getString('taskerId');
  print('🆔 Retrieved taskerId: $taskerId');

  if (taskerId == null) {
    print('❗ No taskerId found in SharedPreferences');
    return null;
  }

  final url = Uri.parse('http://10.93.89.181:5000/api/tasker/profile');
  final body = jsonEncode({'taskerId': taskerId});

  print('🌐 Sending POST request to $url');
  print('📤 Request body: $body');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
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


}
