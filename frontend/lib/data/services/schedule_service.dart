import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Booking {
  final DateTime date;
  final String description;

  Booking({required this.date, required this.description});

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}

class ScheduleService {
  final String _apiBaseUrl = 'http://192.168.1.4:5000';

  Future<String?> getTaskerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('taskerId');
  }

  Future<List<Booking>> fetchSchedule(String taskerId) async {
    final url = Uri.parse('$_apiBaseUrl/api/bookings/schedule/$taskerId');

    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final bookingsJson = data['bookings'] as List;
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load schedule');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
