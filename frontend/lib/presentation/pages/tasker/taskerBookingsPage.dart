import 'package:flutter/material.dart';
import 'package:frontend/data/services/booking_service.dart';
import 'package:frontend/data/services/tasker_service.dart';

class TaskerBookingsPage extends StatefulWidget {
  const TaskerBookingsPage({super.key, required taskerId, required taskerName});

  @override
  State<TaskerBookingsPage> createState() => _TaskerBookingsPageState();
}

class _TaskerBookingsPageState extends State<TaskerBookingsPage> {
  Map<String, dynamic>? _tasker;
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _completedBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final taskerData = await TaskerService().fetchTaskerProfile();
      final taskerId = taskerData?['_id'];
      final bookings = await BookingService().fetchTaskerBookings(taskerId);

      setState(() {
        _tasker = taskerData;
        _upcomingBookings = bookings.where((b) => b['status'] == 'Upcoming').toList();
        _completedBookings = bookings.where((b) => b['status'] == 'Completed').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Failed to load data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileHeader() {
    final name = _tasker?['fullName'] ?? 'Guest';
    final imageUrl = _tasker?['profilePic'] ?? '';

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty 
              ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ))
              : null,
          backgroundColor: Colors.blue[600],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi ${name.split(' ').first}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your bookings',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
          onPressed: () => Navigator.pushNamed(context, 'notification'),
        ),
      ],
    );
  }

  Widget _buildBookingStatusChip(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? Colors.green[100]! : Colors.blue[100]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.access_time,
            size: 16,
            color: isCompleted ? Colors.green[600] : Colors.blue[600],
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? 'Completed' : 'Upcoming',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCompleted ? Colors.green[800] : Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isCompleted) {
    final user = booking['userId'] ?? {};
    final service = booking['description'] ?? 'Service';
    final date = booking['date'] ?? '';
    final time = booking['time'] ?? '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildBookingStatusChip(isCompleted),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  user['name'] ?? 'Customer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Handle mark as complete
                  },
                  child: const Text('Mark as Completed'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsSection(String title, List<Map<String, dynamic>> bookings, bool isCompleted) {
    if (bookings.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...bookings.map((booking) => _buildBookingCard(booking, isCompleted)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get bookings, they\'ll appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading your bookings...',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasBookings = _upcomingBookings.isNotEmpty || _completedBookings.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              const Text(
                'Your Bookings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (!hasBookings) _buildEmptyState(),
              if (hasBookings) ...[
                _buildBookingsSection('Upcoming Bookings', _upcomingBookings, false),
                const SizedBox(height: 8),
                _buildBookingsSection('Completed Bookings', _completedBookings, true),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}