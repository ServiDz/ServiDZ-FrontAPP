import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TaskerChatService {
  final String baseUrl = "http://10.93.89.181:5000/api";
  final String socketUrl = "http://10.93.89.181:5000";

  late IO.Socket _socket;
  late String taskerId;
  final String userId;

  bool _isSocketConnected = false;

  TaskerChatService({
    required this.userId,
    required String taskerId,
  }) {
    this.taskerId = taskerId;
  }

  Future<void> loadTaskerId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("taskerId");
    print("🧠 Loaded taskerId from SharedPreferences: $id");

    if (id == null) {
      throw Exception("Tasker ID not found in SharedPreferences");
    }

    taskerId = id;
  }

  void connectSocket({
    required Function(Map<String, dynamic>) onReceive,
    required Function(String id, String newText) onEdit,
    required Function(String id) onDelete,
  }) {
    if (_isSocketConnected) {
      print("⚠️ Socket is already connected.");
      return;
    }

    print("⚡ Connecting to Socket.IO at $socketUrl...");
    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print("✅ Socket connected!");
      _isSocketConnected = true;

      print("📤 Emitting joinTaskerRoom: taskerId=$taskerId, userId=$userId");
      _socket.emit('joinRoom', {
  'userId': taskerId,       // tasker joins the room as `userId`
  'otherUserId': userId,    // the other party is the original user
});

    });

    _socket.on('connect_error', (err) {
      print("❌ Socket connection error: $err");
      _isSocketConnected = false;
    });

    _socket.on('disconnect', (_) {
      print("🔌 Socket disconnected");
      _isSocketConnected = false;
    });

    _socket.on('message', (data) {
      print("📥 Received message: $data");
      onReceive(Map<String, dynamic>.from(data));
    });

    _socket.on('editMessage', (data) {
      onEdit(data['_id'], data['newText']);
    });

    _socket.on('deleteMessage', (data) {
      onDelete(data['_id']);
    });
  }

Future<void> sendMessage(String message) async {
  if (!_isSocketConnected) {
    print("❌ Cannot send message: socket not connected");
    throw Exception("Socket not connected");
  }

  print("📤 Sending message: $message");

  _socket.emit('sendMessage', {
    'senderId': taskerId,     
    'receiverId': userId,    
    'message': message,
  });
}



  void editMessage(String messageId, String newText) {
    if (!_isSocketConnected) return;
    _socket.emit('editTaskerMessage', {
      '_id': messageId,
      'newText': newText,
    });
  }

  void deleteMessage(String messageId) {
    if (!_isSocketConnected) return;
    _socket.emit('deleteTaskerMessage', {
      '_id': messageId,
    });
  }

  void dispose() {
    print("🔌 Disconnecting socket...");
    _socket.dispose();
    _isSocketConnected = false;
  }

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    print("🌐 Fetching messages between taskerId=$taskerId and userId=$userId");

    final url = '$baseUrl/tasker-messages/getMessagesWithUser';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'taskerId': taskerId, 'userId': userId}),
      );

      print("📡 HTTP status: ${response.statusCode}");
      print("📦 Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          print("✅ Loaded ${data.length} messages");
          return List<Map<String, dynamic>>.from(data);
        } else {
          print("❌ Unexpected data format");
          throw Exception("Invalid format");
        }
      } else {
        throw Exception("Failed to fetch messages");
      }
    } catch (e) {
      print("💥 Exception while fetching messages: $e");
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> loadTaskerChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final taskerId = prefs.getString("taskerId");

    print("🧠 Loading tasker chat list, taskerId: $taskerId");

    if (taskerId == null) {
      throw Exception("Tasker ID not found in SharedPreferences");
    }

    final response = await http.post(
      Uri.parse('http://10.93.89.181:5000/api/tasker-messages/chatList'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"taskerId": taskerId}),
    );

    print("📡 HTTP status: ${response.statusCode}");
    print("📦 Response body: ${response.body}");

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch tasker chat list");
    }
  }
}
