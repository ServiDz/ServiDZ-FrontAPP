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
  int _currentIndex = 1; // Highlight the chat tab
  final TextEditingController _searchController = TextEditingController();

  // Colors
  final Color _primaryColor = Colors.blue[900]!;
  final Color _unreadColor = Colors.blue[900]!;
  final Color _readColor = Colors.white;
  final Color _subtitleColor = Colors.grey;
  final Color _searchBackground = Colors.grey[200]!;

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
      itemCount: chatList.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
      itemBuilder: (context, index) {
        final chat = chatList[index];
        final latestMessage = chat["messages"].isNotEmpty ? chat["messages"][0] : {};
        final hasUnread = chat["messages"].any(
          (msg) => msg["isRead"] == false && msg["receiverId"] == userId,
        );

        return Container(
          color: hasUnread ? _unreadColor.withOpacity(0.1) : _readColor,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat["avatar"] ?? ""),
              backgroundColor: Colors.grey.shade300,
              child: chat["avatar"] == null 
                  ? Icon(Icons.person, size: 28, color: Colors.grey[600])
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
                    width: 10,
                    height: 10,
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
      itemCount: searchResults.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
      itemBuilder: (context, index) {
        final user = searchResults[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user['avatar'] ?? ""),
            backgroundColor: Colors.grey[300],
            child: user['avatar'] == null 
                ? Icon(Icons.person, size: 24, color: Colors.grey[600])
                : null,
          ),
          title: Text(
            user['name'] ?? 'User',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () => _navigateToChatPage(user),
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
        // leading: const SizedBox.shrink(),
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: _primaryColor),
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Color(0x1A00386F)
,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: _searchUsers,
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