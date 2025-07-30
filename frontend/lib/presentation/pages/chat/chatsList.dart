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
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  // Updated color scheme
  final Color _primaryColor = const Color(0xFF2563EB);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _cardColor = Colors.white;
  final Color _unreadColor = const Color(0xFF2563EB);
  final Color _subtitleColor = const Color(0xFF64748B);
  final Color _searchBackground = const Color(0xFFF1F5F9);

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
      });
      _fetchChats(id);
    }
  }

  Future<void> _fetchChats(String id) async {
    try {
      final chats = await ChatService(userId: id, taskerId: '').loadUserIdAndFetchChats();
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
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    try {
      final users = await ChatService(userId: '', taskerId: '').searchUsers(query);
      setState(() {
        isSearching = true;
        searchResults = users;
      });
    } catch (e) {
      print("Search error: $e");
    }
  }

  void _navigateToChatPage(Map<String, dynamic> user) {
    Navigator.pushNamed(
      context,
      'chatDetails',
      arguments: {
        'userId': userId,
        'otherUserId': user['userId'],
        'otherUserName': user['name'],
        'otherUserAvatar': user['avatar'],
      },
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildChatList() {
    if (chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading conversations...',
              style: TextStyle(color: _subtitleColor),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: chatList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final chat = chatList[index];
        final latestMessage = chat["messages"].isNotEmpty ? chat["messages"][0] : {};
        final hasUnread = chat["messages"].any(
          (msg) => msg["isRead"] == false && msg["receiverId"] == userId,
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                image: chat["avatar"] != null 
                    ? DecorationImage(
                        image: NetworkImage(chat["avatar"]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: chat["avatar"] == null 
                  ? Icon(Icons.person, size: 24, color: Colors.grey.shade600)
                  : null,
            ),
            title: Text(
              chat["name"],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: hasUnread ? _primaryColor : Colors.black,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                latestMessage["message"] ?? "No messages yet",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasUnread ? _primaryColor : _subtitleColor,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(latestMessage["timestamp"]),
                  style: TextStyle(
                    color: hasUnread ? _primaryColor : _subtitleColor,
                    fontSize: 12,
                  ),
                ),
                if (hasUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _primaryColor,
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
        child: Text(
          "No users found",
          style: TextStyle(color: _subtitleColor),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = searchResults[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                image: user['avatar'] != null 
                    ? DecorationImage(
                        image: NetworkImage(user['avatar']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user['avatar'] == null 
                  ? Icon(Icons.person, size: 24, color: Colors.grey.shade600)
                  : null,
            ),
            title: Text(
              user['name'] ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => _navigateToChatPage(user),
          ),
        );
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
        color: Colors.blue[900], // Fixed color
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.blue[900],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue[900]),
            onPressed: () {
              // Add your edit functionality here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: _searchBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: _subtitleColor),
                  prefixIcon: Icon(Icons.search, color: _subtitleColor),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: _searchUsers,
              ),
            ),
          ),
          Expanded(
            child: isSearching ? _buildSearchResults() : _buildChatList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}