import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  final String userId;
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
}
