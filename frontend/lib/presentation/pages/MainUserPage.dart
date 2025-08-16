// main_user_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/chat/chatsList.dart';
import 'package:frontend/presentation/pages/homepage.dart';
import 'package:frontend/presentation/pages/profile/profile_page.dart';
import 'package:frontend/presentation/pages/booking/user_bookings.dart';
import 'package:frontend/presentation/pages/view_more_page.dart';

class MainUserPage extends StatefulWidget {
  const MainUserPage({super.key});

  @override
  State<MainUserPage> createState() => _MainUserPageState();
}

class _MainUserPageState extends State<MainUserPage> {
  int _selectedTab = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const HomePage(),
    const UserBookingsPage(),
    const ViewMore(),
    const ChatsListPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildBlueBottomNavigationBar(),
    );
  }

  Widget _buildBlueBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          currentIndex: _selectedTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) {
            if (index == _selectedTab) return;
            
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedTab == 0 ? Icons.home_rounded : Icons.home_outlined,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedTab == 1 ? Icons.calendar_month_rounded : Icons.calendar_today_outlined,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedTab == 2
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedTab == 2 ? Icons.search_rounded : Icons.search_outlined,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedTab == 3
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedTab == 3 ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedTab == 4
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedTab == 4 ? Icons.person_rounded : Icons.person_outline_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}