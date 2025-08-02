import 'package:flutter/material.dart';
import '../../data/models/tasker_model.dart';
import '../../data/services/tasker_service.dart';
import '../../data/services/profile_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _primaryColor = Colors.blue;
  static const _secondaryColor = Color(0xFFFFF6EB);
  static const _cardBackground = Color(0xFFF8F8F8);
  static const _hintTextColor = Color(0xFFB3B3B3);
  static const _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final TaskerService _taskerService = TaskerService();
  List<Tasker> taskers = [];
  bool isLoading = true;
  String? errorMessage;

  int _currentIndex = 0;
  Map<String, dynamic>? userProfile;

  final List<Map<String, dynamic>> categories = [
    {'image': 'images/icons/plumber.png', 'title': 'Plumber'},
    {'image': 'images/icons/electrecian.png', 'title': 'Electrician'},
    {'image': 'images/icons/painter.png', 'title': 'Painter'},
    {'image': 'images/icons/gardener.png', 'title': 'Gardener'},
    {'image': 'images/icons/cleaner.png', 'title': 'Cleaner'},
    {'image': 'images/icons/carpenter.png', 'title': 'Carpenter'},
    {'image': 'images/icons/car_repair.png', 'title': 'Car Repair'},
  ];

  @override
  void initState() {
    super.initState();
    loadTaskers();
    loadUserProfile();
  }

  Future<void> loadTaskers() async {
    try {
      final result = await _taskerService.getAllTaskers();
      setState(() {
        taskers = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> loadUserProfile() async {
    final profile = await ProfileService.fetchUserProfile();
    if (profile != null) {
      setState(() {
        userProfile = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileRow(),
            const SizedBox(height: 20),
            _buildSearchBarWithMenu(),
            const SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
 Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: _sectionTitleStyle.copyWith(color: Colors.blue[800]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == categories.length - 1 ? 0 : 12,
                  ),
                  child: _buildCategoryCard(
                    category['image'],
                    category['title'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String imagePath, String label) {
    return InkWell(
      onTap: () {
        // Add navigation for categories if needed
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.error_outline,
                  color: Colors.grey[400],
                ),
              ),
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


  Widget _buildProfileRow() {
    final name = userProfile?['name'] ?? 'Guest';
    final imageUrl = userProfile?['avatar'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryColor.withOpacity(0.2)),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('images/profile.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hi!', style: TextStyle(fontSize: 14)),
                  Text(
                    name.split(" ").first,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryColor.withOpacity(0.1),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'notification');
              },
              child: const Icon(Icons.notifications_none, color: _primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarWithMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for service...',
                  hintStyle:
                      const TextStyle(color: _hintTextColor, fontSize: 14),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  border: InputBorder.none,
                  prefixIcon:
                      const Icon(Icons.search, color: _hintTextColor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic, color: _primaryColor),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalsSection() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Professionals',
                style: _sectionTitleStyle.copyWith(color: Colors.blue[800]),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'allProfessionals');
                },
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: _primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: taskers.length > 3 ? 3 : taskers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final pro = taskers[index];
            return _buildProfessionalCard(pro);
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalCard(Tasker pro) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          'taskerDetails',
          arguments: {'id': pro.id},
        );
      },
      child: Card(
        color: _cardBackground,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  pro.profilePic,
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 120,
                    color: _primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.build, size: 16, color: _primaryColor),
                        const SizedBox(width: 6),
                        Text(pro.profession),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: _primaryColor),
                        const SizedBox(width: 6),
                        Text(pro.location),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.circle,
                            size: 10,
                            color: pro.isAvailable
                                ? Colors.green
                                : Colors.red),
                        const SizedBox(width: 6),
                        Text(
                          pro.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: pro.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 18,
                          color: i < pro.rating.round()
                              ? Colors.orange
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, 'homepage');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, 'chatsList');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, 'profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}