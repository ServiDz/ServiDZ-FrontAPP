import 'package:flutter/material.dart';
import 'package:frontend/data/services/tasker_chat_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TaskerChatPage extends StatefulWidget {
  final String taskerId;
  final String userId;
  final String userName;
  final String userAvatar;

  const TaskerChatPage({
    required this.taskerId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    super.key,
  });

  @override
  State<TaskerChatPage> createState() => _TaskerChatPageState();
}

class _TaskerChatPageState extends State<TaskerChatPage> {
  late TaskerChatService chatService;
  List<Map<String, dynamic>> messages = [];
  final messageController = TextEditingController();
  final editController = TextEditingController();
  final scrollController = ScrollController();

  int? editingIndex;
  bool isComposing = false;

  final Color taskerColor = const Color(0xFF00386F);
  final Color accentColor = const Color(0xFF4CAF50);
  final Color otherColor = Colors.grey.shade200;
  final Color background = Colors.grey.shade50;

  @override
  void initState() {
    super.initState();
    chatService = TaskerChatService(taskerId: widget.taskerId, userId: widget.userId);
    fetchMessages();
    connectSocket();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> fetchMessages() async {
    try {
      final data = await chatService.fetchMessages();
      setState(() {
        messages = data;
      });
      scrollToBottom();
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  void connectSocket() {
    chatService.connectSocket(
      onReceive: (msg) {
        setState(() => messages.add(msg));
        scrollToBottom();
      },
      onEdit: (id, text) {
        final index = messages.indexWhere((m) => m['_id'] == id);
        if (index != -1) {
          setState(() => messages[index]['message'] = text);
        }
      },
      onDelete: (id) {
        setState(() => messages.removeWhere((m) => m['_id'] == id));
      },
    );
  }

void sendMessage() async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;

  messageController.clear();
  setState(() => isComposing = false);

  final message = {
    'senderId': widget.taskerId,
    'receiverId': widget.userId,
    'message': text,
    'timestamp': DateTime.now().toIso8601String(),
  };

  try {
    await chatService.sendMessage(text); // ✅ Add await

    setState(() {
      messages.add(message);
    });

    scrollToBottom();
  } catch (e) {
    print('❌ Send error: $e');

    // Optional: still show message locally if needed
    setState(() {
      messages.add(message);
    });
  }
}




  Future<void> editMessage(int index) async {
    final msg = messages[index];
    final newText = editController.text.trim();
    if (newText.isEmpty || msg['message'] == newText) return;

    chatService.editMessage(msg['_id'], newText);
    setState(() => editingIndex = null);
  }

  Future<void> deleteMessage(int index) async {
    final msg = messages[index];
    chatService.deleteMessage(msg['_id']);
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
    chatService.dispose();
    messageController.dispose();
    scrollController.dispose();
    editController.dispose();
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
              backgroundImage: widget.userAvatar.isNotEmpty
                  ? NetworkImage(widget.userAvatar)
                  : const AssetImage('images/men.jpg') as ImageProvider,
              radius: 18,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
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
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                final isMe = msg['senderId'] == widget.taskerId;
                final isEditing = editingIndex == index;

                return GestureDetector(
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
                      : Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? taskerColor : otherColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['message'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatTime(msg['timestamp']),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              onChanged: (text) => setState(() => isComposing = text.trim().isNotEmpty),
              decoration: const InputDecoration.collapsed(hintText: 'Type a message...'),
            ),
          ),
          IconButton(
            icon: Icon(
              isComposing ? Icons.send : Icons.mic,
              color: isComposing ? accentColor : Colors.grey,
            ),
            onPressed: isComposing ? sendMessage : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEditMessage(int index) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextField(
            controller: editController,
            maxLines: null,
            decoration: const InputDecoration.collapsed(hintText: 'Edit your message'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => editingIndex = null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => editMessage(index),
                child: const Text('Save'),
              )
            ],
          )
        ],
      ),
    );
  }
}
