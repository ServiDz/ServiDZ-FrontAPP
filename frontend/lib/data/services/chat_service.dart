import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  String userId;
  final String taskerId;
  late IO.Socket socket;

  ChatService({required this.userId, required this.taskerId});

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final res = await http.post(
      Uri.parse('http://10.93.89.181:5000/api/chat/getMessages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'taskerId': taskerId}),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } else {
      throw Exception("Failed to fetch messages");
    }
  }

  void connectSocket({
    required Function(Map<String, dynamic>) onReceive,
    required Function(String, String) onEdit,
    required Function(String) onDelete,
  }) {
    socket = IO.io('http://10.93.89.181:5000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      socket.emit('joinRoom', {'userId': userId, 'otherUserId': taskerId});
    });

    socket.on('receiveMessage', (data) => onReceive(Map<String, dynamic>.from(data)));

    socket.on('messageEdited', (data) {
      onEdit(data['messageId'], data['newText']);
    });

    socket.on('messageDeleted', (data) {
      onDelete(data['messageId']);
    });
  }

  void sendMessage(String message) {
    socket.emit('sendMessage', {
      'senderId': userId,
      'receiverId': taskerId,
      'message': message,
    });
  }

  Future<void> editMessage(String messageId, String newText) async {
    final res = await http.put(
      Uri.parse('http://10.93.89.181:5000/api/chat/editMessage/$messageId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newText': newText,
        'userId': userId,
        'taskerId': taskerId,
      }),
    );

    if (res.statusCode == 200) {
      socket.emit('messageEdited', {'messageId': messageId, 'newText': newText});
    } else {
      throw Exception("Failed to edit message");
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final res = await http.delete(
      Uri.parse('http://10.93.89.181:5000/api/chat/deleteMessage/$messageId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'taskerId': taskerId,
      }),
    );

    if (res.statusCode == 200) {
      socket.emit('messageDeleted', {'messageId': messageId});
    } else {
      throw Exception("Failed to delete message");
    }
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }


  Future<List<Map<String, dynamic>>> loadUserIdAndFetchChats() async {
  final prefs = await SharedPreferences.getInstance();
  final storedUserId = prefs.getString('userId');
  userId = storedUserId ?? "";

  if (storedUserId != null) {
    final response = await http.post(
      Uri.parse('http://10.93.89.181:5000/api/chat/chat-list'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': storedUserId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      print("❌ Failed to fetch chats: ${response.statusCode}");
    }
  }
  return [];
}

Future<void> markAsRead(String otherUserId, String chatId) async {
  if (userId.isEmpty) return;

  final res = await http.put(
    Uri.parse('http://10.93.89.181:5000/api/chat/mark-read'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'otherUserId': otherUserId,
    }),
  );

  if (res.statusCode == 200) {
    print("✅ Marked as read: $otherUserId");
  } else {
    print("❌ Failed to mark as read: ${res.statusCode}");
  }
}

// ✅ Static helper to load userId and fetch chats
  static Future<String?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<List<Map<String, dynamic>>> fetchChatList(String userId) async {
    final response = await http.post(
      Uri.parse('http://10.93.89.181:5000/api/chat/chat-list'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      print("❌ Failed to fetch chats: ${response.statusCode}");
      return [];
    }
  }


Future<List<Map<String, dynamic>>> searchUsers(String query) async {
  print("Searching users for query: $query");

  final url = 'http://10.93.89.181:5000/api/chat/search-users?query=$query';
  print("Sending GET request to: $url");

  final response = await http.get(Uri.parse(url));

  print("Received status code: ${response.statusCode}");

  if (response.statusCode == 200) {
    print("Response body: ${response.body}");

    final List<dynamic> users = jsonDecode(response.body);

    final results = users.map((user) => {
      'userId': user['_id'],
      'name': user['fullName'],
      'avatar': user['profilePic'],
    }).toList();

    print("Parsed ${results.length} users.");
    return results;
  } else {
    print("Error: ${response.statusCode}, Body: ${response.body}");
    throw Exception('Failed to search users');
  }
}




  
}
