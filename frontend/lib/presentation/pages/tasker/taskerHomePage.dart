import 'package:flutter/material.dart';
import 'package:frontend/data/services/booking_service.dart';
import 'package:frontend/data/services/tasker_service.dart';
import 'package:frontend/data/models/booking.dart';

class TaskerHomePage extends StatefulWidget {
  const TaskerHomePage({super.key});


  @override
  State<TaskerHomePage> createState() => _TaskerHomePageState();
}

class _TaskerHomePageState extends State<TaskerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  Map<String, dynamic>? _tasker;
  bool _isLoading = true;
  Booking? _nextJob;
  bool _isLoadingNextJob = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final taskerData = await TaskerService().fetchTaskerProfile();
      final nextJobData = await BookingService().fetchNextJob();

      setState(() {
        _tasker = taskerData;
        _nextJob = nextJobData;
        _isLoading = false;
        _isLoadingNextJob = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingNextJob = false;
      });
      // Handle error as needed
    }
  }

  Widget _buildProfileAvatar(String imageUrl, String name) {
    final firstName = name.isNotEmpty ? name.split(" ").first : '?';
    final firstLetter = firstName.substring(0, 1).toUpperCase();

    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildNextJobCard() {
    if (_isLoadingNextJob) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_nextJob == null) {
      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No upcoming jobs found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final jobDate = DateTime.parse(_nextJob!.date);
    final difference = jobDate.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR NEXT JOB',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Starts in ${hours}h ${minutes}m',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _nextJob?.user?.avatar != null
                      ? Image.network(
                          _nextJob!.user!.avatar!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.person, size: 40),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nextJob?.description ?? 'Service description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            _nextJob?.user?.name ?? 'Customer',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            _nextJob?.address ?? 'No address',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.phone_outlined, size: 18, color: Colors.blue.shade700),
                    label: Text('Call', style: TextStyle(color: Colors.blue.shade700)),
                    onPressed: _nextJob?.user?.phone != null
                        ? () {
                            // Implement call functionality
                            // launchUrl(Uri.parse('tel:${_nextJob!.user!.phone}'));
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.blue.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.message_outlined, size: 18, color: Colors.blue.shade700),
                    label: Text('Message', style: TextStyle(color: Colors.blue.shade700)),
                    onPressed: () {
                      // Implement message functionality
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.blue.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('GET DIRECTIONS'),
                onPressed: _nextJob?.address != null
                    ? () {
                        // Implement directions functionality
                        // final query = Uri.encodeComponent(_nextJob!.address!);
                        // launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'));
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final name = _tasker?['fullName'] ?? 'Guest';
    final imageUrl = _tasker?['profilePic'] ?? '';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfileAvatar(imageUrl, name),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${name.split(" ").first}!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ready for your next job?',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'notification');
          },
          child: const Icon(Icons.notifications_none, color: Colors.blue),
        ),
      ],
    );
  }

Widget _buildSearchBar() {
  const _primaryColor = Colors.blue;
  const _hintTextColor = Color(0xFFB3B3B3);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Container(
          height: 45, // Match the filter button
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Search for service...',
              hintStyle: TextStyle(color: _hintTextColor, fontSize: 14),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: _hintTextColor),
              suffixIcon: Icon(Icons.mic, color: _primaryColor),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () {
          // Filter logic here
        },
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ),
    ],
  );
}



  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionButton(Icons.assignment, 'Job Requests'),
            _buildQuickActionButton(Icons.bar_chart, 'Earnings'),
            _buildQuickActionButton(Icons.calendar_today, 'Schedule'),
            _buildQuickActionButton(Icons.history, 'History'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == 'Job Requests') {
          Navigator.pushNamed(context, 'jobRequests');
        } else if (label == 'Earnings') {
          Navigator.pushNamed(context, 'earnings');
        } else if (label == 'Schedule') {
          Navigator.pushNamed(context, 'schedule');
        } else if (label == 'History') {
          Navigator.pushNamed(context, 'history');
        }
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              _buildNextJobCard(),
            ],
          ),
        ),
      ),
    );
  }
}