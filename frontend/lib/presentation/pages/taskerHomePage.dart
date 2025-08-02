import 'package:flutter/material.dart';

class TaskerHomePage extends StatefulWidget {
  const TaskerHomePage({super.key});

  @override
  State<TaskerHomePage> createState() => _TaskerHomePageState();
}

class _TaskerHomePageState extends State<TaskerHomePage> {
  final TextEditingController _searchController = TextEditingController();

  int _currentIndex = 0; // NEW

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: _buildBottomNavigationBar(), // UPDATED
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('images/profile.jpg'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hi Ahmed!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 4),
            Text(
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
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for jobs...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: Icon(Icons.tune, color: Colors.blue),
          onPressed: () {},
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
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



  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            if (index == _currentIndex) return;

            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}

