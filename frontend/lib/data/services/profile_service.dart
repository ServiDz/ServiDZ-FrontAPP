import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  static const String _baseUrl = 'http://192.168.1.16:5000';

 static Future<Map<String, dynamic>?> fetchUserProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    print('❗ Token not found');
    return null;
  }

  final url = Uri.parse('$_baseUrl/api/profile');
  print('🌐 Sending GET to $url with token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    } else {
      print('❌ Failed to load user profile: ${response.body}');
      return null;
    }
  } catch (e) {
    print('❌ Exception in fetchUserProfile: $e');
    return null;
  }
}


static Future<bool> uploadAvatar(File imageFile) async {
  print('📦 Starting avatar upload...');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    print('❗ Token not found in SharedPreferences');
    return false;
  }

  print('🔐 Retrieved token: $token');
  print('📁 Image path: ${imageFile.path}');

  final uri = Uri.parse("$_baseUrl/api/profile/upload-avatar");
  print('🌐 Upload URL: $uri');

  final request = http.MultipartRequest("POST", uri);

  request.headers['Authorization'] = 'Bearer $token';

  try {
    final multipartFile = await http.MultipartFile.fromPath('avatar', imageFile.path);
    print('📤 Prepared multipart file: ${multipartFile.filename} (${multipartFile.length} bytes)');
    request.files.add(multipartFile);
  } catch (e) {
    print('❌ Failed to prepare file: $e');
    return false;
  }

  try {
    print('🚀 Sending multipart request...');
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('📥 Status: ${response.statusCode}');
    print('📦 Response: $responseBody');

    if (response.statusCode == 200) {
      print('✅ Avatar upload success');
      return true;
    } else {
      print('❌ Avatar upload failed with status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('❌ Exception during request: $e');
    return false;
  }
}



  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) return File(image.path);
    return null;
  }

static Future<bool> updateProfile(String name, String email) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  print("🟡 userId from SharedPreferences: $userId");

  if (userId == null) return false;

  final url = Uri.parse("http://192.168.1.16:5000/api/profile/edit");
  print("📤 Sending update to: $url");

  try {
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "name": name,
        "email": email,
      }),
    );

     print("🟢 Status Code: ${response.statusCode}");
  print("📦 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Failed to update: ${response.body}");
      return false;
    }
  } catch (e) {
    print("❌ Exception during updateProfile: $e");
    return false;
  }
}


}
