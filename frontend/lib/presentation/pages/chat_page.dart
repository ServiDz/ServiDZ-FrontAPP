import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String userId;
  final String taskerId;
  final String taskerName;
  final String taskerImage;

  const ChatPage({
    required this.userId,
    required this.taskerId,
    required this.taskerName,
    required this.taskerImage,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  final messageController = TextEditingController();
  final editController = TextEditingController();
  final scrollController = ScrollController();

  int? editingIndex;
  bool isComposing = false;

  final Color userColor = const Color(0xFF00386F);
  final Color accentColor = const Color(0xFF4CAF50);
  final Color otherColor = Colors.grey.shade200;
  final Color background = Colors.grey.shade50;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    connectSocket();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void connectSocket() {
    socket = IO.io('http://10.93.89.181:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      socket.emit('joinRoom', {
        'userId': widget.userId,
        'otherUserId': widget.taskerId,
      });
    });

    socket.on('receiveMessage', (data) {
      setState(() {
        messages.add(data);
      });
      scrollToBottom();
    });

    socket.on('messageEdited', (data) {
      int index = messages.indexWhere((msg) => msg['_id'] == data['messageId']);
      if (index != -1) {
        setState(() {
          messages[index]['message'] = data['newText'];
        });
      }
    });

    socket.on('messageDeleted', (data) {
      messages.removeWhere((msg) => msg['_id'] == data['messageId']);
      setState(() {});
    });
  }

  Future<void> fetchMessages() async {
    final res = await http.post(
      Uri.parse('http://10.93.89.181:5000/api/chat/getMessages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': widget.userId, 'taskerId': widget.taskerId}),
    );
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
      });
      scrollToBottom();
    }
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    socket.emit('sendMessage', {
      'senderId': widget.userId,
      'receiverId': widget.taskerId,
      'message': text,
    });

    setState(() {
      messages.add({
        'senderId': widget.userId,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      messageController.clear();
      isComposing = false;
    });
    scrollToBottom();
  }

  Future<void> editMessage(int index) async {
    final message = messages[index];
    final messageId = message['_id'];
    final newText = editController.text.trim();
    if (newText.isEmpty || message['message'] == newText) return;

    final res = await http.put(
      Uri.parse('http://10.93.89.181:5000/api/chat/editMessage/$messageId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newText': newText,
        'userId': widget.userId,
        'taskerId': widget.taskerId,
      }),
    );

    if (res.statusCode == 200) {
      socket.emit('messageEdited', {'messageId': messageId, 'newText': newText});
      setState(() {
        editingIndex = null;
      });
    }
  }

  Future<void> deleteMessage(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final message = messages[index];
              final messageId = message['_id'];

              final res = await http.delete(
                Uri.parse('http://10.93.89.181:5000/api/chat/deleteMessage/$messageId'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'userId': widget.userId,
                  'taskerId': widget.taskerId,
                }),
              );

              if (res.statusCode == 200) {
                socket.emit('messageDeleted', {'messageId': messageId});
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String formatTime(String iso) {
    final time = DateTime.parse(iso);
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return DateFormat('h:mm a').format(time);
    return DateFormat('MMM d, h:mm a').format(time);
  }

  @override
  void dispose() {
    socket.disconnect();
    messageController.dispose();
    scrollController.dispose();
    editController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.taskerImage.isNotEmpty
                  ? NetworkImage(widget.taskerImage)
                  : const AssetImage('images/men.jpg') as ImageProvider,
              radius: 18,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.taskerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/chat_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final msg = messages[index];
                  final isMe = msg['senderId'] == widget.userId;
                  final isEditing = editingIndex == index;

                  // Check message sequence for better spacing
                  bool isFirstInSequence = index == 0 || 
                      messages[index - 1]['senderId'] != msg['senderId'];
                  bool isLastInSequence = index == messages.length - 1 || 
                      messages[index + 1]['senderId'] != msg['senderId'];

                  return Padding(
                    padding: EdgeInsets.only(
                      top: isFirstInSequence ? 8 : 2,
                      bottom: isLastInSequence ? 8 : 2,
                    ),
                    child: GestureDetector(
                      onLongPress: isMe
                          ? () => showModalBottomSheet(
                                context: context,
                                builder: (_) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit_outlined),
                                      title: const Text('Edit'),
                                      onTap: () {
                                        editController.text = msg['message'];
                                        setState(() => editingIndex = index);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                                      title: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        deleteMessage(index);
                                      },
                                    ),
                                  ],
                                ),
                              )
                          : null,
                      child: isEditing
                          ? _buildEditMessage(index)
                          : Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe && isLastInSequence)
                                  CircleAvatar(
                                    backgroundImage: widget.taskerImage.isNotEmpty
                                        ? NetworkImage(widget.taskerImage)
                                        : const AssetImage('images/men.jpg') as ImageProvider,
                                    radius: 14,
                                  ),
                                if (!isMe) const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe ? userColor : otherColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(isMe ? 16 : 6),
                                        topRight: Radius.circular(isMe ? 6 : 16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg['message'],
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black87,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              formatTime(msg['timestamp']),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isMe ? Colors.white70 : Colors.black54,
                                              ),
                                            ),
                                            if (isMe) const SizedBox(width: 4),
                                            if (isMe)
                                              Icon(
                                                Icons.done_all,
                                                size: 14,
                                                color: Colors.white70,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: messageController,
                      onChanged: (text) => setState(() => isComposing = text.trim().isNotEmpty),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isComposing ? accentColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isComposing ? Icons.send : Icons.mic,
                      color: isComposing ? Colors.white : Colors.grey,
                    ),
                    onPressed: isComposing ? sendMessage : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMessage(int index) {
    final msg = messages[index];
    final isMe = msg['senderId'] == widget.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? userColor.withOpacity(0.1) : otherColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextField(
            controller: editController,
            maxLines: null,
            style: TextStyle(color: isMe ? Colors.black87 : Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => editingIndex = null),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => editMessage(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}