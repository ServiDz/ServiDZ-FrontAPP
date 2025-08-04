// settings_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/data/services/tasker_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _tasker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final taskerData = await TaskerService().fetchTaskerProfile();
      setState(() {
        _tasker = taskerData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileAvatar(String imageUrl, String name) {
    final firstName = name.isNotEmpty ? name.split(" ").first : '?';
    final firstLetter = firstName.substring(0, 1).toUpperCase();

    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildWelcomeSection() {
    final name = _tasker?['fullName'] ?? 'Guest';
    final imageUrl = _tasker?['profilePic'] ?? '';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfileAvatar(imageUrl, name),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${name.split(" ").first}!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English', true),
              _buildLanguageOption('Spanish', false),
              _buildLanguageOption('French', false),
              _buildLanguageOption('German', false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        Navigator.pop(context);
        // Implement language change
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption('Light', true),
              _buildThemeOption('Dark', false),
              _buildThemeOption('System Default', false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(String theme, bool isSelected) {
    return ListTile(
      title: Text(theme),
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        Navigator.pop(context);
        // Implement theme change
      },
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deactivate Account'),
          content: const Text(
              'Are you sure you want to deactivate your account? You can reactivate it later by logging in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement account deactivation
              },
              child: const Text('DEACTIVATE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingsItem(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'English',
          onTap: () {
            _showLanguageDialog();
          },
        ),
        _buildSettingsItem(
          icon: Icons.color_lens,
          title: 'Theme',
          subtitle: 'Light',
          onTap: () {
            _showThemeDialog();
          },
        ),
        _buildSettingsItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Enabled',
          onTap: () {
            // Notification settings
          },
        ),
        _buildSettingsItem(
          icon: Icons.security,
          title: 'Privacy & Security',
          subtitle: 'Manage your data',
          onTap: () {
            // Privacy settings
          },
        ),
        _buildSettingsItem(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'FAQ, Contact us',
          onTap: () {
            // Help center
          },
        ),
        _buildSettingsItem(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version 1.0.0',
          onTap: () {
            // About page
          },
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          child: ElevatedButton(
            onPressed: () {
              _showDeactivateDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Deactivate Account'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }
}