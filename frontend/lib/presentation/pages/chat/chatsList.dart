import 'package:flutter/material.dart';
import 'package:frontend/data/services/chat_service.dart';
import 'package:frontend/data/services/user_search_delegate.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({Key? key}) : super(key: key);
  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  int _currentIndex = 1;
  final Color _primaryColor = const Color(0xFF003366);
  final Color _unreadColor = const Color(0xFF00386F);
  List<Map<String, dynamic>> chatList = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final id = await ChatService.getUserIdFromPrefs();
    if (id == null) return;

    final chats = await ChatService.fetchChatList(id);
    setState(() {
      userId = id;
      chatList = chats;
    });
  }

  Future<void> _markAsRead(String otherUserId) async {
    if (userId != null) {
      final chatService = ChatService(userId: '', taskerId: '');
      await chatService.markAsRead(userId!, otherUserId);
    }
  }

  void _navigateToChatPage(Map<String, dynamic> chat) async {
    await _markAsRead(chat["userId"]);
    if (userId == null) return;

    Navigator.pushNamed(
      context,
      'chatDetails',
      arguments: {
        'userId': userId,
        'otherUserId': chat["userId"],
        'otherUserName': chat["name"] ?? 'User',
        'otherUserAvatar': chat["avatar"] ?? '',
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            if (index == _currentIndex) return;

            setState(() {
              _currentIndex = index;
            });

            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, 'homepage');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, 'chatsList');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, 'profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.blue[800]),
            onPressed: () async {
              final id = await ChatService.getUserIdFromPrefs();
              if (id != null) {
                showSearch(
                  context: context,
                  delegate: UserSearchDelegate(id),
                );
              }
            },
          ),
        ],
      ),
      body: Expanded(
        child: chatList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final chat = chatList[index];
                  final latestMessage = chat["messages"].isNotEmpty
                      ? chat["messages"][0]
                      : {};
                  final hasUnread = chat["messages"].any(
                    (msg) =>
                        msg["isRead"] == false &&
                        msg["receiverId"] == userId,
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: hasUnread ? _unreadColor : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(chat["avatar"] ?? ""),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      title: Text(
                        chat["name"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hasUnread ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        latestMessage["message"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasUnread
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        _formatTime(latestMessage["timestamp"]),
                        style: TextStyle(
                          color: hasUnread ? Colors.white : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => _navigateToChatPage(chat),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return "";
    final date = DateTime.tryParse(iso);
    if (date == null) return "";
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
