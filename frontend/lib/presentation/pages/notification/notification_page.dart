import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  bool isLoading = true;
  bool _hasError = false;
  bool _ratingDialogShown = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    searchController.addListener(_filterNotifications);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterNotifications() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotifications = notifications.where((notification) {
        final title = notification['title']?.toString().toLowerCase() ?? '';
        final body = notification['body']?.toString().toLowerCase() ?? '';
        return title.contains(query) || body.contains(query);
      }).toList();
    });
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final userId = role == 'tasker'
        ? prefs.getString('taskerId')
        : prefs.getString('userId');

    if (userId == null || role == null) {
      setState(() {
        _hasError = true;
        isLoading = false;
      });
      return;
    }

    final uri = Uri.parse("http://192.168.1.4:5000/api/notifications/$userId?role=$role");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifList = List<Map<String, dynamic>>.from(data['notifications']);
        setState(() {
          notifications = notifList;
          filteredNotifications = List.from(notifList);
          isLoading = false;
        });

        _checkAndShowRatingDialog(notifList);
      } else {
        setState(() {
          _hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        isLoading = false;
      });
    }
  }

  void _checkAndShowRatingDialog(List<Map<String, dynamic>> notifs) async {
    if (_ratingDialogShown) return;
    for (var notif in notifs) {
      if (notif['type'] == 'booking_completed') {
        _ratingDialogShown = true;
        await Future.delayed(Duration(milliseconds: 300));
        _showRatingDialog();
        break;
      }
    }
  }

  void _showRatingDialog() {
    double rating = 3;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rate Your Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How was your experience with the tasker?'),
            const SizedBox(height: 12),
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                rating = value;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reviewController,
              decoration: InputDecoration(
                hintText: 'Write a review (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('userId');
              final taskerId = prefs.getString('lastTaskerId'); // Make sure you save this after booking
              if (userId != null && taskerId != null) {
                await http.post(
                  Uri.parse('http://192.168.1.16:5000/api/tasker/rate'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'userId': userId,
                    'taskerId': taskerId,
                    'value': rating,
                    'review': reviewController.text,
                  }),
                );
              }
              Navigator.pop(context);
            },
            child: Text('Submit'),
          )
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupNotifications() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    Map<String, List<Map<String, dynamic>>> grouped = {
      'Today': [],
      'Yesterday': [],
      'Last Week': [],
      'Older': [],
    };

    for (var notification in filteredNotifications) {
      final date = DateTime.parse(notification['createdAt']);
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        grouped['Today']!.add(notification);
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        grouped['Yesterday']!.add(notification);
      } else if (date.isAfter(lastWeek)) {
        grouped['Last Week']!.add(notification);
      } else {
        grouped['Older']!.add(notification);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
            centerTitle: false,
            pinned: true,
            elevation: 1,
            expandedHeight: 80,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blue),
                onPressed: fetchNotifications,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search notifications...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
            ),
          ),

          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_hasError)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Failed to load notifications'),
                ),
              ),
            )
          else if (filteredNotifications.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    searchController.text.isEmpty
                        ? 'No notifications found.'
                        : 'No results found for "${searchController.text}"',
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final groupKey = groupedNotifications.keys.elementAt(index);
                  final groupItems = groupedNotifications[groupKey]!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                          child: Text(
                            groupKey,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: groupItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final notification = groupItems[i];
                            final date = DateTime.parse(notification['createdAt']);
                            final timeFormat = DateFormat.jm();
                            final isUnread = notification['isUnread'] ?? true;

                            return Card(
                              elevation: 0,
                              color: isUnread ? Colors.blue.shade100 : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.blue.shade100),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: isUnread
                                      ? Colors.blue.shade800
                                      : Colors.blue.shade200,
                                  child: Icon(
                                    isUnread
                                        ? Icons.notifications_active
                                        : Icons.notifications_none,
                                    color: isUnread
                                        ? Colors.white
                                        : Colors.blue.shade800,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  notification['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification['body'] ?? '',
                                      style:
                                          TextStyle(color: Colors.blue.shade700),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 14,
                                            color: Colors.blue.shade400),
                                        const SizedBox(width: 4),
                                        Text(
                                          timeFormat.format(date),
                                          style: TextStyle(
                                              color: Colors.blue.shade400,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    notification['isUnread'] = false;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                childCount: groupedNotifications.length,
              ),
            ),
        ],
      ),
    );
  }
}
