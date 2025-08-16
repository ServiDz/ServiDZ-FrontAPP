import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasker_model.dart';

class TaskerService {
  final String _baseUrl = 'http://192.168.1.4:5000/api/taskers/all';

  Future<List<Tasker>> getTopRatedTaskers() async {
    final url = Uri.parse('http://192.168.1.4:5000/api/taskers/top-rated');
    print('📡 Fetching top-rated taskers from $url');

    try {
      final response = await http.get(url);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print('✅ Top-rated taskers fetched: ${jsonList.length}');
        return jsonList.map((e) => Tasker.fromJson(e)).toList();
      } else {
        print('❌ Failed to load top-rated taskers');
        throw Exception('Failed to load top-rated taskers');
      }
    } catch (e) {
      print('🔥 Exception during getTopRatedTaskers: $e');
      rethrow;
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

    final url = Uri.parse('http://192.168.1.4:5000/api/tasker/profile');
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
    final url = 'http://192.168.1.4:5000/api/tasker/$taskerId/ratings';
    print('🌐 Fetching ratings from $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('📥 Ratings response: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ Ratings fetched successfully');
        return json.decode(response.body);
      } else {
        print('❌ Failed to load ratings: ${response.body}');
        throw Exception('Failed to load ratings');
      }
    } catch (e) {
      print('🔥 Exception in fetchTaskerRatings: $e');
      rethrow;
    }
  }

 Future<bool> updateTaskerName(String name) async {
  if (name.isEmpty) return false;
  
  print('✏️ Updating tasker name...');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final taskerId = prefs.getString('taskerId');

  if (token == null || taskerId == null) {
    print('❗ Token or taskerId not found.');
    return false;
  }

  final url = Uri.parse('http://192.168.1.4:5000/api/tasker/update-name');
  print('🌐 Sending PUT request to $url with name: $name');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name.trim(),
        'taskerId': taskerId,
      }),
    );

    print('🔄 Update Name Status: ${response.statusCode}');
    print('📥 Body: ${response.body}');
    return response.statusCode == 200;
  } catch (e) {
    print('🔥 Exception in updateTaskerName: $e');
    return false;
  }
}

Future<bool> updateTaskerLocation(String location) async {
  if (location.isEmpty) return false;
  
  print('📍 Updating tasker location...');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final taskerId = prefs.getString('taskerId'); // Changed from userId to taskerId

  if (token == null || taskerId == null) {
    print('❗ Token or taskerId not found.');
    return false;
  }

  final url = Uri.parse('http://192.168.1.4:5000/api/tasker/update-location');
  print('🌐 Sending PUT request to $url with location: $location');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'location': location.trim(),
        'taskerId': taskerId,
      }),
    );

    print('📍 Update Location Status: ${response.statusCode}');
    print('📥 Body: ${response.body}');
    return response.statusCode == 200;
  } catch (e) {
    print('🔥 Exception in updateTaskerLocation: $e');
    return false;
  }
}

Future<bool> updateTaskerPhone(String phoneNumber) async {
  if (phoneNumber.isEmpty) return false;
  
  print('📞 Updating tasker phone number...');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final taskerId = prefs.getString('taskerId'); // Changed from userId to taskerId

  if (token == null || taskerId == null) {
    print('❗ Token or taskerId not found.');
    return false;
  }

  final url = Uri.parse('http://192.168.1.4:5000/api/tasker/update-phone');
  print('🌐 Sending PUT request to $url with phoneNumber: $phoneNumber');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'phoneNumber': phoneNumber.trim(),
        'taskerId': taskerId,
      }),
    );

    print('📞 Update Phone Status: ${response.statusCode}');
    print('📥 Body: ${response.body}');
    return response.statusCode == 200;
  } catch (e) {
    print('🔥 Exception in updateTaskerPhone: $e');
    return false;
  }
}


Future<List<Map<String, dynamic>>> fetchTaskers() async {
  const String baseUrl = 'http://192.168.1.4:5000';
  const String endpoint = '/api/taskers/all'; 

  try {
    print('📡 Sending request to: $baseUrl$endpoint');
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    print('✅ Response status: ${response.statusCode}');
    print('📄 Raw response body: ${response.body}');

    if (response.statusCode == 200) {
      // Parse the JSON response
      final List<dynamic> responseData = json.decode(response.body);
      print('📦 Decoded response: $responseData');

      final taskersList = responseData.map((tasker) {
        print('👤 Processing tasker: $tasker');
        return {
          'name': tasker['name'] ?? tasker['fullName'] ?? 'Unknown',
          'profileImage': tasker['profileImage'] ?? tasker['profilePic'] 
              ?? 'https://randomuser.me/api/portraits/men/1.jpg',
          'rating': tasker['rating']?.toDouble() ?? 0.0,
          'reviews': tasker['reviews'] ?? tasker['ratings']?.length ?? 0,
          'skills': tasker['skills'] ?? tasker['profession'] ?? 'General Services',
          'description': tasker['description'] ?? '',
        };
      }).toList();

      print('📊 Final mapped taskers: $taskersList');
      return taskersList;
    } else {
      print('❌ Failed with status: ${response.statusCode}');
      throw Exception('Failed to load taskers: Status code ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Exception occurred: $e');
    throw Exception('Failed to fetch taskers: ${e.toString()}');
  }
}


Future<bool> updateTaskerAvatar(File imageFile) async {
  print('🖼️ Starting avatar update process...');
  
  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final taskerId = prefs.getString('taskerId');

  // Validate required values
  if (token == null || taskerId == null) {
    print('❗ Missing token or taskerId in SharedPreferences');
    return false;
  }

  print('🔑 Found taskerId: $taskerId');
  
  try {
    // Create multipart request
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://192.168.1.4:5000/api/tasker/update-avatar'),
    );

    // Add the image file
    print('📤 Adding image file to request...');
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    // Add taskerId to the request body
    request.fields['taskerId'] = taskerId;

    // Add authorization header
    print('🔒 Adding authorization headers...');
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Send the request
    print('🚀 Sending request to update avatar...');
    final response = await request.send();

    // Process the response
    final responseData = await response.stream.bytesToString();
    final decodedResponse = json.decode(responseData);
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: $decodedResponse');

    if (response.statusCode == 200 && decodedResponse['success'] == true) {
      print('✅ Avatar updated successfully!');
      return true;
    } else {
      print('❌ Failed to update avatar: ${decodedResponse['message'] ?? 'Unknown error'}');
      return false;
    }
  } catch (e) {
    print('🔥 Exception during avatar update: $e');
    return false;
  }
}

}