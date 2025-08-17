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
    {'image': 'images/icons/hairdresser.png', 'title': 'Hairdresser'},
  ];

  @override
  void initState() {
    super.initState();
    loadTaskers();
    loadUserProfile();
  }

  Future<void> loadTaskers() async {
    try {
      final result = await _taskerService.getTopRatedTaskers();
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
                  radius: 26,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('images/profile.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text('Hello 👋', style: TextStyle(fontSize: 16)),
                  Text(
                    name,
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
            width: 45,   // set width
            height: 45,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryColor.withOpacity(0.1),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'notification');
              },
              child: const Icon(Icons.notifications_none, color: _primaryColor , size: 28),
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
                  Navigator.pushNamed(context, 'viewMore');
                },
              child: GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, 'viewMore');
  },
  child: Text(
    'View all',
    style: TextStyle(
      color: _primaryColor,
      decoration: TextDecoration.underline,
    ),
  ),
)
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
      color:  Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:  _primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 140,
        child: Row(
          children: [
            // Profile Image - Flush with card edge
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
                right: Radius.circular(12),
              ),
              child: SizedBox(
                width: 120,
                height: double.infinity,
                child: pro.profilePic.isNotEmpty
                    ? Image.network(
                        pro.profilePic,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: _primaryColor,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: _primaryColor.withOpacity(0.05),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: _primaryColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: _primaryColor.withOpacity(0.05),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: _primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
              ),
            ),

            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pro.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pro.profession,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                pro.location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star_rounded,
                                    size: 18,
                                    color: i < pro.rating.round()
                                        ? Colors.amber
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pro.isAvailable ? 'Available' : 'Busy',
                                style: TextStyle(
                                  color: pro.isAvailable ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}