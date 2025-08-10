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

static Future<List<Map<String, dynamic>>> fetchUserBookings() async {
  try {
    print('📌 Fetching user bookings...');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    print('🔑 Retrieved token: $token');

    if (token == null) {
      print('❌ No token found in SharedPreferences');
      throw Exception('No authentication token found');
    }

    final url = 'http://192.168.1.4:5000/api/bookings/userBookings';
    print('🌐 Sending GET request to: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is! List) {
        throw Exception('Unexpected response format: $decoded');
      }

      final List<dynamic> bookings = decoded;
      print('✅ Decoded bookings: $bookings');

      return bookings.map((booking) {
        print('📦 Processing booking: $booking');

        // Handle taskerId which is now always populated with fullName and profilePic
        final tasker = booking['taskerId'] ?? {};
        final name = tasker['fullName'] ?? 'Unknown Tasker';
        final profilePic = tasker['profilePic'] ?? '';

        // Handle rating safely
        var rating = booking['rating'];
        bool isRated = rating != null;
        double? ratingValue;
        String review = '';
        if (isRated) {
          ratingValue = (rating['value'] is num) ? rating['value'].toDouble() : 0;
          review = rating['review'] ?? '';
        }

        return {
          '_id': booking['_id'],
          'taskerId': {
            'name': name,
            'profilePic': profilePic,
          },
          'description': booking['description'] ?? 'No description',
          'date': _formatDate(booking['date']),
          'time': _formatTime(booking['time']),
          'status': booking['status'] ?? 'Unknown',
          'isRated': isRated,
          if (isRated) ...{
            'rating': ratingValue,
            'review': review,
          },
        };
      }).toList();
    } else if (response.statusCode == 401) {
      print('🚫 Authentication failed');
      throw Exception('Authentication failed');
    } else {
      print('⚠️ Failed to load bookings with status: ${response.statusCode}');
      throw Exception('Failed to load bookings: ${response.statusCode}');
    }
  } catch (e, stack) {
    print('❌ Error fetching user bookings: $e');
    print('🛠 Stacktrace: $stack');
    rethrow;
  }
}



  // Helper method to format date
  static String _formatDate(String? dateString) {
    if (dateString == null) return 'No date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Helper method to format time
  static String _formatTime(String? timeString) {
    if (timeString == null) return 'No time';
    try {
      // Assuming time is stored as "HH:MM" in 24-hour format
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : hour;
        return '$displayHour:$minute $period';
      }
      return timeString;
    } catch (e) {
      return 'Invalid time';
    }
  }

  // Add this method to submit ratings to your backend
  static Future<void> submitRating({
    required String bookingId,
    required double rating,
    required String review,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.4:5000/api/bookings/$bookingId/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'value': rating,
          'review': review,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit rating: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting rating: $e');
      rethrow;
    }
  }


}
