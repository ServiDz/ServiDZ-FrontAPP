import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/category_card.dart';
import '../widgets/professional_card.dart';
import '../../data/models/tasker_model.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _primaryColor = Color(0xFF00386F);
  static const _secondaryColor = Color(0xFFFFF6EB);
  static const _cardBackground = Color(0xFFF8F8F8);
  static const _hintTextColor = Color(0xFFB3B3B3);
  static const _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final List<Map<String, String>> categories = [
    {'image': 'images/icons/plumber.png', 'title': 'Plumber'},
    {'image': 'images/icons/electrecian.png', 'title': 'Electrician'},
    {'image': 'images/icons/painter.png', 'title': 'Painter'},
    {'image': 'images/icons/carpenter.png', 'title': 'Carpenter'},
  ];

  List<Tasker> taskers = [];

  @override
  void initState() {
    super.initState();
    fetchTaskers();
  }

  Future<void> fetchTaskers() async {
    final url = Uri.parse('http://10.93.89.181:5000/api/taskers/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          taskers = data.map((e) => Tasker.fromJson(e)).toList();
        });
      } else {
        print("Failed to load taskers: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 35),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 25),
                    _buildCategoriesSection(),
                    const SizedBox(height: 28),
                    _buildProfessionalsSection(),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for service...',
          hintStyle: TextStyle(color: _hintTextColor, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFB3B3B3)),
          filled: true,
          fillColor: _primaryColor.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categories',
              style: _sectionTitleStyle.copyWith(color: _primaryColor)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                imagePath: category['image']!,
                title: category['title']!,
                backgroundColor: _secondaryColor,
                textColor: _primaryColor,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Professionals',
                  style: _sectionTitleStyle.copyWith(color: _primaryColor)),
              const Text('View more', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        taskers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: taskers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pro = taskers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        'taskerDetails',
                        arguments: {'id': pro.id},
                      );
                    },
                    child: ProfessionalCard(
                      name: pro.fullName,
                      job: pro.profession,
                      location: pro.location,
                      image: pro.profilePic,
                      available: pro.isAvailable,
                      rating: pro.rating,
                      backgroundColor: _cardBackground,
                    ),
                  );
                },
              ),
      ],
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
          color: _primaryColor,
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
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag), label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}
