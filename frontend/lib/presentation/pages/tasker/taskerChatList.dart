import 'package:flutter/material.dart';
import 'package:frontend/data/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/data/services/tasker_chat_service.dart';

class TaskerChatsListPage extends StatefulWidget {
  const TaskerChatsListPage({Key? key}) : super(key: key);

  @override
  State<TaskerChatsListPage> createState() => _TaskerChatsListPageState();
}

class _TaskerChatsListPageState extends State<TaskerChatsListPage> {
  List<Map<String, dynamic>> chatList = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  String taskerId = "";
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  // Color scheme
  final Color _primaryColor = Colors.blue;
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _cardColor = Colors.white;
  final Color _unreadColor = const Color(0xFF2563EB);
  final Color _subtitleColor = const Color(0xFF64748B);
  final Color _searchBackground = const Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    _loadTaskerIdAndChats();
  }

  Future<void> _loadTaskerIdAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("taskerId") ?? "";
    if (id.isNotEmpty) {
      setState(() {
        taskerId = id;
      });
      _fetchChats(id);
    }
  }

  Future<void> _fetchChats(String id) async {
    try {
      final chats = await TaskerChatService.loadTaskerChatList();
      setState(() {
        chatList = chats;
      });
    } catch (e) {
      print("Error fetching tasker chats: $e");
    }
  }

  // Future<void> _searchUsers(String query) async {
  //   if (query.isEmpty) {
  //     setState(() {
  //       isSearching = false;
  //       searchResults = [];
  //     });
  //     return;
  //   }

  //   try {
  //     final users = await TaskerChatService().searchUsers(query);
  //     setState(() {
  //       isSearching = true;
  //       searchResults = users;
  //     });
  //   } catch (e) {
  //     print("Search error: $e");
  //   }
  // }

void _navigateToChatPage(Map<String, dynamic> user) {
  final String otherUserId = user['userId'] ?? '';
  final String otherUserName = user['name'] ?? '';
  final String otherUserAvatar = user['avatar'] ?? user['profilePic'] ?? '';

  // 🔍 Debug Prints
  print('🟡 Navigating to Chat Page with:');
  print('   ✅ taskerId: $taskerId');
  print('   ✅ otherUserId: $otherUserId');
  print('   ✅ otherUserName: $otherUserName');
  print('   ✅ otherUserAvatar: $otherUserAvatar');

  if (taskerId == null || otherUserId.isEmpty || otherUserName.isEmpty) {
    print('❌ Missing required chat parameters!');
  }

  Navigator.pushNamed(
    context,
    'taskerChatDetails',
    arguments: {
      'taskerId': taskerId,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserAvatar': otherUserAvatar,
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
          (msg) => msg["isRead"] == false && msg["receiverId"] == taskerId,
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
  image: (chat["avatar"] != null && chat["avatar"].toString().isNotEmpty)
      ? DecorationImage(
          image: NetworkImage(chat["avatar"]),
          fit: BoxFit.cover,
        )
      : DecorationImage(
          image: AssetImage('assets/images/default_avatar.png'),
          fit: BoxFit.cover,
        ),
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
            color: Colors.blue,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
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
                // onChanged: _searchUsers,
              ),
            ),
          ),
          Expanded(
            child: isSearching ? _buildSearchResults() : _buildChatList(),
          ),
        ],
      ),
    );
  }
}