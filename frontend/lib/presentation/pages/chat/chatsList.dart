import 'package:flutter/material.dart';
import 'package:frontend/data/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({Key? key}) : super(key: key);

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  List<Map<String, dynamic>> chatList = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  String userId = "";
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService(userId: '', taskerId: '');

  // Color scheme
  final Color _primaryBlue = Color(0xFF2196F3); // Modern blue
  final Color _white = Colors.white;
  final Color _lightGrey = Color(0xFFF5F5F5);
  final Color _darkGrey = Color(0xFF757575);
  final Color _unreadBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _loadUserIdAndChats();
  }

  Future<void> _loadUserIdAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("userId") ?? "";
    if (id.isNotEmpty) {
      setState(() {
        userId = id;
        _chatService.userId = id;
      });
      _fetchChats(id);
    }
  }

  Future<void> _fetchChats(String id) async {
    try {
      final chats = await _chatService.loadUserIdAndFetchChats();
      setState(() {
        chatList = chats;
      });
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      final users = await _chatService.searchUsers(query);
      setState(() {
        searchResults = users;
      });
    } catch (e) {
      print("Search error: $e");
    }
  }

  Future<void> _markAsRead(String otherUserId, String chatId) async {
    if (userId.isEmpty) return;

    try {
      await _chatService.markAsRead(otherUserId, chatId);
      
      setState(() {
        for (var chat in chatList) {
          if (chat['chatId'] == chatId) {
            for (var msg in chat['messages']) {
              if (msg['receiverId'] == userId) {
                msg['isRead'] = true;
              }
            }
          }
        }
      });
    } catch (e) {
      print("Failed to mark as read: $e");
    }
  }

  void _navigateToChatPage(Map<String, dynamic> user) async {
    if (user['chatId'] != null) {
      await _markAsRead(user['userId'], user['chatId']);
    }

    Navigator.pushNamed(
      context,
      'chatDetails',
      arguments: {
        'userId': userId,
        'otherUserId': user['userId'],
        'otherUserName': user['name'],
        'otherUserAvatar': user['avatar'],
        'chatId': user['chatId'],
      },
    ).then((_) {
      _fetchChats(userId);
    });
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildUserAvatar(String? avatarUrl, String name) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _primaryBlue.withOpacity(0.1),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null 
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(
                color: _primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildChatList() {
    if (chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 60,
              color: _darkGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                color: _darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: chatList.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: _lightGrey),
      itemBuilder: (context, index) {
        final chat = chatList[index];
        final latestMessage = chat["messages"].isNotEmpty ? chat["messages"][0] : {};
        final hasUnread = chat["messages"].any(
          (msg) => msg["isRead"] == false && msg["receiverId"] == userId,
        );
        final messageText = latestMessage["message"] ?? "No messages yet";
        final timeText = _formatTime(latestMessage["timestamp"]);

        return Container(
          color: hasUnread ? _unreadBlue : _white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: _buildUserAvatar(chat["avatar"], chat["name"]),
            title: Text(
              chat["name"],
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              messageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread ? Colors.black87 : _darkGrey,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    color: hasUnread ? _primaryBlue : _darkGrey,
                    fontSize: 12,
                  ),
                ),
                if (hasUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            onTap: () => _navigateToChatPage(chat),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: _darkGrey,
            ),
            const SizedBox(height: 16),
            Text(
              "No users found",
              style: TextStyle(
                color: _darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: searchResults.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: _lightGrey),
      itemBuilder: (context, index) {
        final user = searchResults[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: _buildUserAvatar(user['avatar'], user['name'] ?? 'User'),
          title: Text(
            user['name'] ?? 'User',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.message_outlined,
            color: _primaryBlue,
            size: 20,
          ),
          onTap: () => _navigateToChatPage(user),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: _white,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: _lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: _darkGrey),
                  prefixIcon: Icon(Icons.search, color: _darkGrey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: _darkGrey),
                          onPressed: () {
                            _searchController.clear();
                            _searchUsers('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: _searchUsers,
              ),
            ),
          ),
          Expanded(
            child: _searchController.text.isEmpty ? _buildChatList() : _buildSearchResults(),
          ),
        ],
      ),
    );
  }
}