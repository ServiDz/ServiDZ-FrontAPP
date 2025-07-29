import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
}
