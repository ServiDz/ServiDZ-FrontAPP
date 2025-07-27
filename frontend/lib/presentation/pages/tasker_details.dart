import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Make sure the path is correct

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
  final Color primaryColor = const Color(0xFF00386F);
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
        'otherUserId':  widget.taskerId,
        'otherUserName':tasker!['fullName'] ?? 'Tasker',
        'otherUserAvatar': tasker!['profilePic'] ?? '',
      },
    );
  } else {
    print("User ID or tasker data missing.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User ID or tasker data missing.")),
      
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : tasker == null
              ? Center(
                  child: Text(
                    'Failed to load tasker.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(borderRadius * 2),
                              bottomRight: Radius.circular(borderRadius * 2),
                            ),
                          ),
                          child: tasker!['profilePic'] != null &&
                                  tasker!['profilePic'] != ""
                              ? ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(borderRadius * 2),
                                    bottomRight:
                                        Radius.circular(borderRadius * 2),
                                  ),
                                  child: Image.network(
                                    tasker!['profilePic'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(borderRadius * 2),
                                    bottomRight:
                                        Radius.circular(borderRadius * 2),
                                  ),
                                  child: Image.asset(
                                    'images/men.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 50,
                          left: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius:
                                  BorderRadius.circular(borderRadius),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star,
                                    color: primaryColor, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  tasker!['rating'].toString(),
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
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius * 2),
                            topRight: Radius.circular(borderRadius * 2),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tasker!['fullName'] ?? '',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  if (tasker!['certification'] != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(borderRadius),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.verified,
                                              color: Colors.white, size: 16),
                                          SizedBox(width: 5),
                                          Text('Verified',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  border:
                                      Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    _infoRow(Icons.work_outline,
                                        tasker!['profession'] ?? ''),
                                    SizedBox(height: 15),
                                    _infoRow(Icons.location_on,
                                        tasker!['location'] ?? ''),
                                    SizedBox(height: 15),
                                    _infoRow(Icons.phone,
                                        tasker!['phone'] ?? ''),
                                  ],
                                ),
                              ),
                              SizedBox(height: 25),
                              Text(
                                'About Me',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  border:
                                      Border.all(color: Colors.grey[200]!),
                                ),
                                child: Text(
                                  tasker!['description'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  borderRadius),
                                        ),
                                        elevation: 2,
                                      ),
                                      onPressed: () {
                                        // Book Now button logic
                                      },
                                      child: Text(
                                        'Book Now',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: primaryColor,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  borderRadius),
                                          side:
                                              BorderSide(color: primaryColor),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed:
                                          navigateToChatPage, // 👈 Navigate to chat
                                      child: Text(
                                        'Message',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
