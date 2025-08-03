import 'package:flutter/material.dart';
import 'package:frontend/data/services/booking_service.dart';
import 'package:frontend/presentation/pages/booking/location_picker_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BookingPage extends StatefulWidget {
  final String userName;
  final String userImage;
  final String role;
  final String taskerId;
  final List<String> certifications; // Added certifications list

  const BookingPage(param0, {
    super.key,
    required this.userName,
    required this.userImage,
    required this.role,
    required this.taskerId,
    this.certifications = const [], // Default empty list
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final prefs = SharedPreferences.getInstance();
  String? userId;
  final _problemController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  LatLng? selectedLocation;
  bool _isLoading = false;
  int? _expandedCertificationIndex; // Track which certification is expanded

  String? get formattedLocation {
    if (selectedLocation == null) return null;
    return '${selectedLocation!.latitude.toStringAsFixed(5)}, ${selectedLocation!.longitude.toStringAsFixed(5)}';
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> submitBooking() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || widget.taskerId.isEmpty || selectedDate == null || selectedTime == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await BookingService.createBooking(
        userId: userId,
        taskerId: widget.taskerId,
        date: selectedDate!,
        time: selectedTime!.format(context),
        location: selectedLocation!,
        address: formattedLocation ?? '',
        description: _problemController.text.trim(),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking successful')),
        );
        Navigator.pushNamed(context, 'bookingConfirmed');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF2196F3),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );
    
    if (result != null && result is LatLng) {
      setState(() {
        selectedLocation = result;
      });
    }
  }

  void _setupFirebaseMessagingListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = notification?.android;

      if (notification != null && android != null) {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings initializationSettings =
            InitializationSettings(android: initializationSettingsAndroid);

        flutterLocalNotificationsPlugin.initialize(initializationSettings);

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'booking_channel',
              'Booking Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print("🔁 BookingPage loaded with taskerId: ${widget.taskerId}");
    _setupFirebaseMessagingListener();
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile avatar with fallback for empty image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: widget.userImage.isEmpty
                    ? CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(widget.userImage),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.role,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Book a Service",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Fill in the details below to book your service",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationSection() {
    if (widget.certifications.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Tasker Certifications",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "View the tasker's qualifications and certifications",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.certifications.asMap().entries.map((entry) {
          final index = entry.key;
          final cert = entry.value;
          return _buildCertificationCard(cert, index);
        }).toList(),
      ],
    );
  }

  Widget _buildCertificationCard(String certification, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ExpansionTile(
        key: Key('cert_$index'),
        initiallyExpanded: _expandedCertificationIndex == index,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedCertificationIndex = expanded ? index : null;
          });
        },
        leading: const Icon(Icons.verified, color: Colors.blue),
        title: Text(
          certification,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Here you would display the certification details/image
                // For now, we'll use a placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, size: 48, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          'Certification Details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This would display the actual certification image or details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTile({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool hasValue = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: hasValue ? Colors.blue : Colors.grey.shade200,
            width: hasValue ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasValue 
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: hasValue ? Colors.blue : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: hasValue ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileSection(),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Problem input section
                    const Text(
                      "Service Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Describe the service you need in detail",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Problem input field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _problemController,
                        maxLines: 4,
                        minLines: 3,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Describe your problem or service needed...",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          labelText: "Description",
                          labelStyle: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.description,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),
                    
                    // Certification section
                    _buildCertificationSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Date and time section
                    const Text(
                      "Service Schedule",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "When would you like the service to be performed?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date and time row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputTile(
                            icon: Icons.calendar_today,
                            text: selectedDate == null
                                ? 'Select Date'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            onTap: _pickDate,
                            hasValue: selectedDate != null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputTile(
                            icon: Icons.access_time,
                            text: selectedTime == null
                                ? 'Select Time'
                                : selectedTime!.format(context),
                            onTap: _pickTime,
                            hasValue: selectedTime != null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Location section
                    const Text(
                      "Service Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Where should the service be performed?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputTile(
                      icon: Icons.location_on,
                      text: formattedLocation ?? 'Select location on map',
                      onTap: _openLocationPicker,
                      hasValue: selectedLocation != null,
                    ),
                    const SizedBox(height: 32),
                    
                    // Book button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                "Confirm Booking",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}