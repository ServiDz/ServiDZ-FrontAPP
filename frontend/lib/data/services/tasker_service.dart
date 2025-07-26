import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
