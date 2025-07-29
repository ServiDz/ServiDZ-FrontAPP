import 'package:flutter/material.dart';
import 'package:frontend/data/services/chat_service.dart';

class UserSearchDelegate extends SearchDelegate {
  final String currentUserId;

  UserSearchDelegate(this.currentUserId);

  @override
  String get searchFieldLabel => 'Search users...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Start typing to search users.'));
    }

    final chatService = ChatService(userId: '', taskerId: '');
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: chatService.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['avatar'] ?? ''),
              ),
              title: Text(user['name']),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  'chatDetails',
                  arguments: {
                    'userId': currentUserId,
                    'otherUserId': user['userId'],
                    'otherUserName': user['name'],
                    'otherUserAvatar': user['avatar'],
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
