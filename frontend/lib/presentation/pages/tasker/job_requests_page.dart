import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Missing import for json.decode
import 'package:geocoding/geocoding.dart'; // Missing import for geocoding

class JobRequestsPage extends StatefulWidget {
  const JobRequestsPage({Key? key}) : super(key: key);
  static const String baseUrl = 'http://192.168.1.4:5000/api/bookings';

  @override
  _JobRequestsPageState createState() => _JobRequestsPageState();
}

class _JobRequestsPageState extends State<JobRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _jobRequests = [];
  List<Map<String, dynamic>> _filteredJobRequests = [];
  
  @override
  void initState() {
    super.initState();
    _loadJobRequests();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobRequests() async {
    try {
      final requests = await fetchJobRequests();
      setState(() {
        _jobRequests = requests;
        _filteredJobRequests = List.from(_jobRequests);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading job requests: ${e.toString()}')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchJobRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final taskerId = prefs.getString('taskerId');

    if (taskerId == null) throw Exception('No tasker ID found in SharedPreferences');

    final response = await http.get(Uri.parse('${JobRequestsPage.baseUrl}/tasker/$taskerId'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return await Future.wait(data.map((booking) async {
        final location = booking['location'];
        String address = await _getAddressFromLatLng(
          location['latitude'],
          location['longitude'],
        );

        return {
          'id': booking['_id'],
          'name': booking['userId']['name'],
          'avatar': booking['userId']['avatar'],
          'location': address,
          'date': '${booking['date']} at ${booking['time']}',
          'status': booking['status'],
        };
      }));
    } else {
      throw Exception('Failed to load job requests');
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredJobRequests = _jobRequests.where((job) {
        return job['name'].toLowerCase().contains(_searchQuery) ||
            job['location'].toLowerCase().contains(_searchQuery) ||
            job['date'].toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> acceptJob(String bookingId) async {
    try {
      final response = await http.patch(Uri.parse('${JobRequestsPage.baseUrl}/$bookingId/accept'));
      if (response.statusCode == 200) {
        await _loadJobRequests(); // Refresh the list after accepting
      } else {
        throw Exception('Failed to accept job');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting job: ${e.toString()}')),
      );
    }
  }

  Future<void> rejectJob(String bookingId) async {
    try {
      final response = await http.patch(Uri.parse('${JobRequestsPage.baseUrl}/$bookingId/reject'));
      if (response.statusCode == 200) {
        await _loadJobRequests(); // Refresh the list after rejecting
      } else {
        throw Exception('Failed to reject job');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting job: ${e.toString()}')),
      );
    }
  }

  /// Reverse geocode latitude & longitude to address string
 static Future<String> _getAddressFromLatLng(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) return 'Unknown location';
    
    Placemark place = placemarks[0];
    
    // Street-level address
    return [
      place.street,
      if (place.subLocality != null && place.subLocality != place.locality) 
        place.subLocality,
      place.locality
    ].where((part) => part != null && part.isNotEmpty).join(', ');
  } catch (e) {
    print('Geocoding error: $e');
    return 'Unknown location';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Job Requests',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _loadJobRequests,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar with modern design
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search job requests...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            // Status filter chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All', () {
                    setState(() {
                      _filteredJobRequests = List.from(_jobRequests);
                    });
                  }),
                  _buildFilterChip('Pending', () {
                    setState(() {
                      _filteredJobRequests = _jobRequests
                          .where((job) => job['status'] == 'pending')
                          .toList();
                    });
                  }),
                  _buildFilterChip('Accepted', () {
                    setState(() {
                      _filteredJobRequests = _jobRequests
                          .where((job) => job['status'] == 'accepted')
                          .toList();
                    });
                  }),
                  _buildFilterChip('Rejected', () {
                    setState(() {
                      _filteredJobRequests = _jobRequests
                          .where((job) => job['status'] == 'rejected')
                          .toList();
                    });
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Job Request List
            Expanded(
              child: _filteredJobRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, size: 60, color: Colors.blue[200]),
                          const SizedBox(height: 16),
                          Text(
                            'No job requests found',
                            style: TextStyle(
                              color: Colors.blue[400],
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredJobRequests.length,
                      itemBuilder: (context, index) {
                        final job = _filteredJobRequests[index];
                        return _buildJobCard(job);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        selected: false,
        onSelected: (bool selected) => onSelected(),
        selectedColor: Colors.blue[700],
        backgroundColor: Colors.blue[400],
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final statusColor = job['status'] == 'accepted'
        ? Colors.green // Green for accepted
        : job['status'] == 'rejected'
            ? Colors.red // Red for rejected
            : Colors.orange; // Orange for pending

    return Card(
      color: Colors.blue[50], // Very light blue background for cards
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: NetworkImage(job['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue[900], // Dark blue text
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['location'],
                        style: TextStyle(
                          color: Colors.blue[800], // Slightly lighter blue
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    job['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  job['date'],
                  style: TextStyle(
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (job['status'] == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => acceptJob(job['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700], // Darker blue button
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => rejectJob(job['id']),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.blue[700]!), // Darker blue border
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.blue[700], // Darker blue text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}