import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

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
  TextEditingController messageController = TextEditingController();
  final Color userColor = const Color(0xFF00386F);
  final Color accentColor = const Color(0xFF4CAF50);
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    connectToSocket();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: userColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse('http://10.93.89.181:5000/api/chat/getMessages');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'taskerId': widget.taskerId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          messages = data.map((msg) => {
            'senderId': msg['senderId'],
            'message': msg['message'],
            'timestamp': msg['timestamp'],
          }).toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        });
      } else {
        print('❌ Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      print('❗ Error fetching messages: $e');
    }
  }

  void connectToSocket() {
    socket = IO.io('http://10.93.89.181:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit('joinRoom', {
        'userId': widget.userId,
        'otherUserId': widget.taskerId,
      });
    });

    socket.on('receiveMessage', (data) {
      setState(() {
        messages.add({
          'senderId': data['senderId'],
          'message': data['message'],
          'timestamp': data['timestamp']
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });
    });

    socket.onDisconnect((_) => print('❌ Disconnected'));
    socket.onError((e) => print('❗ Socket error: $e'));
  }

  void sendMessage() {
    final msg = messageController.text.trim();
    if (msg.isEmpty) return;

    socket.emit('sendMessage', {
      'senderId': widget.userId,
      'receiverId': widget.taskerId,
      'message': msg,
    });

    setState(() {
      messages.add({
        'senderId': widget.userId,
        'message': msg,
        'timestamp': DateTime.now().toIso8601String()
      });
      messageController.clear();
      _isComposing = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String formatTime(String isoTime) {
    final time = DateTime.parse(isoTime);
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return DateFormat('h:mm a').format(time);
    return DateFormat('MMM d, h:mm a').format(time);
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    messageController.dispose();
    _scrollController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color otherColor = Colors.grey.shade200;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: userColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'tasker-${widget.taskerId}',
              child: CircleAvatar(
                backgroundImage: widget.taskerImage.isNotEmpty
                    ? NetworkImage(widget.taskerImage)
                    : AssetImage('images/men.jpg') as ImageProvider,
                radius: 18,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.taskerName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/chat_bg.png'),
                    fit: BoxFit.cover,
                    opacity: 0.05,
                  ),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    bool isMe = msg['senderId'] == widget.userId;
                    
                    // Check if this is the first message of a sequence from the same sender
                    bool isFirstInSequence = index == 0 || 
                        messages[index - 1]['senderId'] != msg['senderId'];
                    
                    // Check if this is the last message of a sequence from the same sender
                    bool isLastInSequence = index == messages.length - 1 || 
                        messages[index + 1]['senderId'] != msg['senderId'];

                    return AnimatedSize(
                      duration: Duration(milliseconds: 200),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: isFirstInSequence ? 8 : 2,
                          bottom: isLastInSequence ? 8 : 2,
                        ),
                        child: Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isMe && isLastInSequence)
                              CircleAvatar(
                                backgroundImage: widget.taskerImage.isNotEmpty
                                    ? NetworkImage(widget.taskerImage)
                                    : AssetImage('images/men.jpg') as ImageProvider,
                                radius: 12,
                              ),
                            if (!isMe) SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? userColor : otherColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(isMe ? 16 : 4),
                                    topRight: Radius.circular(isMe ? 4 : 16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
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
                                    SizedBox(height: 4),
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
                            if (isMe && isLastInSequence) 
                              Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.done_all,
                                  size: 16,
                                  color: Colors.white70,
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
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: userColor),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: messageController,
                      onChanged: (text) {
                        setState(() {
                          _isComposing = text.trim().isNotEmpty;
                        });
                      },
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isComposing ? accentColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isComposing ? Icons.send : Icons.mic,
                      color: _isComposing ? Colors.white : userColor,
                    ),
                    onPressed: _isComposing ? sendMessage : () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}