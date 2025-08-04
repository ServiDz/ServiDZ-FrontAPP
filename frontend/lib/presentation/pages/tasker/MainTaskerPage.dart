// main_tasker_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/tasker/taskerChatList.dart';
import 'package:frontend/presentation/pages/tasker/taskerHomePage.dart';
import 'package:frontend/presentation/pages/tasker/taskerBookingsPage.dart';
import 'package:frontend/presentation/pages/tasker/ratingsPage.dart';
import 'package:frontend/presentation/pages/tasker/settingsPage.dart';

class MainTaskerPage extends StatefulWidget {
  const MainTaskerPage({super.key});

  @override
  State<MainTaskerPage> createState() => _MainTaskerPageState();
}

class _MainTaskerPageState extends State<MainTaskerPage> {
  int _selectedTab = 0;

  final List<Widget> _pages = [
    const TaskerHomePage(),
    const TaskerBookingsPage(taskerId: null, taskerName: null,),
    const TaskerChatsListPage(),
    const RatingsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Ratings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}