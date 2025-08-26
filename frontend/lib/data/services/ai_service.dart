// lib/data/services/ai_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  static const String _baseUrl = 'http://192.168.1.5:5000/api';

  static Future<Map<String, dynamic>> predictCategory(File image) async {
    try {
      final uri = Uri.parse('$_baseUrl/ai/predict');
      
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        
        // Add null checks for the response structure
        return {
          'category': data['category']?.toString() ?? 'unknown',
          'taskers': List<Map<String, dynamic>>.from(data['taskers'] ?? []),
        };
      } else {
        throw Exception('Failed to predict category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: ${e.toString()}');
    }
  }
}