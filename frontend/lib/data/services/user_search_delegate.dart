import 'package:flutter/material.dart';
import 'package:frontend/data/services/chat_service.dart';

class UserSearchDelegate extends SearchDelegate {
  final String currentUserId;

  UserSearchDelegate(this.currentUserId);

  @override
  String get searchFieldLabel => 'Search users...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white), // <-- only change here
        border: InputBorder.none,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue[900],
        elevation: 1,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      AnimatedOpacity(
        opacity: query.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () => query = '',
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    final blue900 = Colors.blue[900];

    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: blue900?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Start typing to search users',
              style: theme.textTheme.titleMedium?.copyWith(
                color: blue900?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final chatService = ChatService(userId: '', taskerId: '');
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: chatService.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  blue900 ?? theme.primaryColor,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search,
                  size: 64,
                  color: blue900?.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: blue900?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final results = snapshot.data!;

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: blue900?.withOpacity(0.1),
          ),
          itemBuilder: (context, index) {
            final user = results[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: blue900?.withOpacity(0.1),
                backgroundImage: NetworkImage(user['avatar'] ?? ''),
                child: user['avatar'] == null
                    ? Icon(
                        Icons.person,
                        color: blue900,
                      )
                    : null,
              ),
              title: Text(
                user['name'],
                style: theme.textTheme.titleMedium?.copyWith(
                  color: blue900,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: blue900,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
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
