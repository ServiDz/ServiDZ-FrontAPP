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
    const apiUrl = 'http://192.168.1.4:5000/api/bookings/create';

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

    final url = 'http://192.168.1.4:5000/api/bookings/next-job';
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


Future<List<Map<String, dynamic>>> fetchTaskerBookings(String taskerId) async {
    final response = await http.get(Uri.parse('http://192.168.1.4:5000/api/bookings/$taskerId/summary'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> upcoming = data['upcoming'] ?? [];
      final List<dynamic> completed = data['completed'] ?? [];

      return [
        ...upcoming.map((b) => {...b, 'status': 'Upcoming'}),
        ...completed.map((b) => {...b, 'status': 'Completed'}),
      ];
    } else {
      throw Exception('Failed to fetch tasker bookings');
    }
  }


  static Future<http.Response> markBookingAsCompleted({
  required String bookingId,
  required double price,
}) async {
  const baseUrl = 'http://192.168.1.4:5000'; // ✅ Use your actual server IP
  final url = Uri.parse('$baseUrl/api/bookings/$bookingId/complete');

  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'price': price}),
  );

  return response;
}


}
