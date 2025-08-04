import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/booking/booking_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskerPage extends StatefulWidget {
  final String taskerId;

  const TaskerPage({super.key, required this.taskerId});

  @override
  State<TaskerPage> createState() => _TaskerPageState();
}

class _TaskerPageState extends State<TaskerPage> {
  Map<String, dynamic>? tasker;
  bool isLoading = true;
  final String apiUrl = 'http://10.93.89.181:5000/api/taskers/getById';
  final Color primaryColor = const Color(0xFF2196F3);
  final Color backgroundColor = const Color(0xFFF8FAFD);
  final double borderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    fetchTaskerDetails();
  }

  Future<void> fetchTaskerDetails() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': widget.taskerId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          tasker = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tasker: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToChatPage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null && tasker != null) {
      Navigator.pushNamed(
        context,
        'chatDetails',
        arguments: {
          'userId': userId,
          'otherUserId': widget.taskerId,
          'otherUserName': tasker!['fullName'] ?? 'Tasker',
          'otherUserAvatar': tasker!['profilePic'] ?? '',
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID or tasker data missing.")),
      );
    }
  }

  void _showCertifications() {
    if (tasker?['certifications'] == null || (tasker!['certifications'] as List).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No certifications available")),
      );
      return;
    }
    
    // Navigation to certification page - implement this route later
    Navigator.pushNamed(
      context,
      'certificationPage',
      arguments: {
        'certifications': tasker!['certifications'],
        'taskerName': tasker!['fullName'] ?? 'Tasker',
      },
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius * 2),
              bottomRight: Radius.circular(borderRadius * 2),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.8),
                primaryColor.withOpacity(0.4),
              ],
            ),
          ),
          child: tasker!['profilePic'] != null && tasker!['profilePic'] != ""
              ? ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(borderRadius * 2),
                    bottomRight: Radius.circular(borderRadius * 2),
                  ),
                  child: Image.network(
                    tasker!['profilePic'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildProfilePlaceholder();
                    },
                  ),
                )
              : _buildProfilePlaceholder(),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  tasker!['rating']?.toString() ?? 'N/A',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius * 2),
          bottomRight: Radius.circular(borderRadius * 2),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 100,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 2,
        ),
        onPressed: _showCertifications,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: Colors.green, size: 20),
            const SizedBox(width: 10),
            const Text(
              'Show Certifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 2,
              ),
              onPressed: () {
                if (tasker != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        tasker?['_id'] ?? '',
                        userName: tasker!['fullName'] ?? 'Tasker',
                        userImage: tasker!['profilePic'] ?? '',
                        role: tasker!['profession'] ?? '',
                        taskerId: tasker!['_id'] ?? '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tasker data not loaded.")),
                  );
                }
              },
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              onPressed: navigateToChatPage,
              child: Text(
                'Message',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : tasker == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load tasker details',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                        onPressed: fetchTaskerDetails,
                        child: const Text(
                          'Try Again',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildProfileHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tasker!['fullName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                if (tasker!['certifications'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(borderRadius),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.verified,
                                            color: Colors.green, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Verified',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tasker!['profession'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoCard(
                                Icons.work_outline, 'Profession', tasker!['profession'] ?? ''),
                            _buildInfoCard(
                                Icons.location_on, 'Location', tasker!['location'] ?? ''),
                            _buildInfoCard(
                                Icons.phone, 'Contact', tasker!['phone'] ?? ''),
                            _buildCertificationButton(),
                            const SizedBox(height: 24),
                            Text(
                              'About Me',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(borderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                tasker!['description'] ?? 'No description provided',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}