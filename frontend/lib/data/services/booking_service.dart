import 'dart:convert';
import 'package:frontend/data/models/booking.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static Future<http.Response> createBooking({
    required String userId,
    required String taskerId,
    required DateTime date,
    required String time,
    required LatLng location,
    required String address,
    required String description,
  }) async {
    const apiUrl = 'http://10.93.89.181:5000/api/bookings/create';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'taskerId': taskerId,
        'date': date.toIso8601String(),
        'time': time,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': address,
        },
        'description': description,
      }),
    );

    return response;
  }

Future<Booking?> fetchNextJob() async {
  try {
    print('🔍 Getting SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final taskerId = prefs.getString('taskerId');
    print('🆔 Retrieved taskerId: $taskerId');

    if (taskerId == null) {
      print('❌ taskerId not found in SharedPreferences');
      throw Exception('Tasker ID not found in SharedPreferences');
    }

    final url = 'http://10.93.89.181:5000/api/bookings/next-job';
    print('🌐 Sending POST request to $url with taskerId in body...');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'taskerId': taskerId}),
    );

    print('📬 Response status: ${response.statusCode}');
    print('📨 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Next job found: ${data['nextJob']}');
      print('🛠 Parsing booking data: ${data['nextJob']}');

      return Booking.fromJson(data['nextJob']);
    } else if (response.statusCode == 404) {
      print('⚠️ No upcoming job found');
      return null;
    } else {
      print('❌ Unexpected status code: ${response.statusCode}');
      throw Exception('Failed to load next job');
    }
  } catch (e) {
    print('🔥 Exception in fetchNextJob: $e');
    throw Exception('Error fetching next job: $e');
  }
}

}
