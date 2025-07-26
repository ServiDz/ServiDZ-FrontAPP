import 'package:flutter/material.dart';
import 'package:frontend/data/services/profile_service.dart';
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

 Future<void> fetchUserProfile() async {
  print('🟡 fetchUserProfile called');
  final userData = await ProfileService.fetchUserProfile();
  if (userData != null) {
    print('🟢 User fetched: $userData');
    setState(() {
      user = userData;
      isLoading = false;
    });
  } else {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to load profile")),
    );
  }
}

Future<void> pickAndUploadImage() async {
  final imageFile = await ProfileService.pickImage();
  if (imageFile == null) return;

  final success = await ProfileService.uploadAvatar(imageFile);
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile image updated")),
    );
    fetchUserProfile();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update avatar")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF00386F)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF00386F)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Change Language'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.brightness_6),
                          title: const Text('Change Theme'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () async {
                            Navigator.pop(context);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Logged out")),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text("User not found"),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              backgroundImage: (user!['avatar'] != null && user!['avatar'].toString().isNotEmpty)
                                  ? NetworkImage(user!['avatar'].toString())
                                  : null,
                              child: (user!['avatar'] == null || user!['avatar'].toString().isEmpty)
                                  ? Text(
                                      (user!['name'] ?? "U")[0].toUpperCase(),
                                      style: TextStyle(fontSize: 40, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF00386F),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00386F), width: 3),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20),
                              color: Colors.white,
                              onPressed: pickAndUploadImage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        user!['name'] ?? "Unnamed",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user!['email'] ?? "No email",
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 32),
                      _buildProfileInfoCard(context),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfilePage(user: user!)),
                            ).then((_) => fetchUserProfile());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00386F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Edit Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileInfoCard(BuildContext context) {
    final name = user!['name'] ?? "Unnamed";
    final email = user!['email'] ?? "No email";

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildProfileItem(context, icon: Icons.person_outline, title: "Name", value: name),
          const Divider(height: 1, indent: 16),
          _buildProfileItem(context, icon: Icons.email_outlined, title: "Email", value: email),
        ],
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF00386F)),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
