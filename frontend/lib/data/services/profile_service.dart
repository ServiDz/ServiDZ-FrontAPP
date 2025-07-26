import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  static const String _baseUrl = 'http://10.93.89.181:5000';

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return null;

    final url = Uri.parse('$_baseUrl/api/profile');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'];
      } else {
        print('❌ Failed to load profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in fetchUserProfile: $e');
      return null;
    }
  }

  static Future<bool> uploadAvatar(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return false;

    final uri = Uri.parse("$_baseUrl/api/profile/upload-avatar");

    final request = http.MultipartRequest("POST", uri)
      ..fields['userId'] = userId
      ..files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('✅ Avatar upload success: $responseBody');
        return true;
      } else {
        print('❌ Avatar upload failed: $responseBody');
        return false;
      }
    } catch (e) {
      print('❌ Exception in uploadAvatar: $e');
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

  final url = Uri.parse("http://10.93.89.181:5000/api/profile/edit");
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
