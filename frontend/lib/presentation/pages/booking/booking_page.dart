import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/booking/location_picker_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class BookingPage extends StatefulWidget {
  final String userName;
  final String userImage;
  final String role;
  final String taskerId;

  const BookingPage(param0, {
    super.key,
    required this.userName,
    required this.userImage,
    required this.role,
    required this.taskerId,
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

  String? get formattedLocation {
    if (selectedLocation == null) return null;
    return '${selectedLocation!.latitude.toStringAsFixed(5)}, ${selectedLocation!.longitude.toStringAsFixed(5)}';
  }


 Future<void> submitBooking() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  final apiUrl = 'http://10.93.89.181:5000/api/bookings/create';
  print("🧠 Loaded userId from SharedPreferences: $userId");

  if (userId == null || widget.taskerId.isEmpty) {
    print("❌ Missing userId or taskerId");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Missing user or tasker info')),
    );
    return;
  }

  try {
    print("📤 Sending booking request with:");
    print("User ID: $userId");
    print("Tasker ID: ${widget.taskerId}");
    print("Date: ${selectedDate!.toIso8601String()}");
    print("Time: ${selectedTime!.format(context)}");
    print("Location: Lat=${selectedLocation!.latitude}, Lng=${selectedLocation!.longitude}, Address=${formattedLocation}");
    print("Description: ${_problemController.text.trim()}");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'taskerId': widget.taskerId,
        'date': selectedDate!.toIso8601String(),
        'time': selectedTime!.format(context),
        'location': {
          'latitude': selectedLocation!.latitude,
          'longitude': selectedLocation!.longitude,
          'address': formattedLocation ?? '',
        },
        'description': _problemController.text.trim(),
      }),
    );

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${response.body}')),
      );
    }
  } catch (e) {
    print("❌ Error while booking: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
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
              primary: Color(0xFF00386F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF00386F),
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
              primary: Color(0xFF00386F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00386F),
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

  @override
  void initState() {
    super.initState();
     print("🔁 BookingPage loaded with taskerId: ${widget.taskerId}");
  }

  Widget _buildInputTile({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool hasValue = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: hasValue ? Color(0xFF00386F) : Colors.grey.shade200,
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasValue 
                  ? const Color(0xFF00386F).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: hasValue ? const Color(0xFF00386F) : Colors.grey.shade600,
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
            // Modern header with curved bottom
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              decoration: BoxDecoration(
                color: const Color(0xFF00386F),
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
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
            ),
            
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
                            color: Color(0xFF00386F),
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
                                color: Color(0xFF4A6FA5),
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
  onPressed: submitBooking,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF00386F),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text(
    "Confirm Booking",
    style: buttonTextStyle(),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  primaryButtonStyle() {
     return const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  }
  
  buttonTextStyle() {}
}