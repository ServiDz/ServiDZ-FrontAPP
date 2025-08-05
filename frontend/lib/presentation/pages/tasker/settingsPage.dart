import 'package:flutter/material.dart';
import 'package:frontend/data/services/tasker_service.dart';
import 'package:frontend/data/services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _tasker;
  bool _isLoading = true;
  final Color _primaryColor = Colors.blue;
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3436);

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

 void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;
    bool _isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isUpdating ? null : () => Navigator.pop(context),
                          child: Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isUpdating
                              ? null
                              : () async {
                                  if (newPasswordController.text != 
                                      confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Passwords do not match'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isUpdating = true);

                                  try {
                                    final response = await SettingsService.changePassword(
                                      currentPasswordController.text,
                                      newPasswordController.text,
                                    );

                                    if (response['success'] == true) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(response['message']),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(response['message']),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isUpdating = false);
                                    }
                                  }
                                },
                          child: _isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('SAVE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  

  Widget _buildProfileAvatar(String imageUrl, String name) {
    final firstName = name.isNotEmpty ? name.split(" ").first : '?';
    final firstLetter = firstName.substring(0, 1).toUpperCase();

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: imageUrl.isEmpty
            ? LinearGradient(
                colors: [_primaryColor, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: imageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    final name = _tasker?['fullName'] ?? 'Guest';
    final imageUrl = _tasker?['profilePic'] ?? '';
    final rating = _tasker?['rating'] ?? 0.0;
    final jobsCompleted = _tasker?['jobsCompleted'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildProfileAvatar(imageUrl, name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi ${name.split(" ").first}!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$rating • $jobsCompleted jobs',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, 'notification');
            },
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
    Color? iconColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
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
                color: (iconColor ?? _primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? _primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption('English', true),
                _buildLanguageOption('Spanish', false),
                _buildLanguageOption('French', false),
                _buildLanguageOption('German', false),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(language),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _primaryColor)
          : Icon(Icons.circle_outlined, color: Colors.grey.shade300),
      onTap: () {
        // Implement language change
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildThemeOption('Light', true),
                _buildThemeOption('Dark', false),
                _buildThemeOption('System Default', false),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(String theme, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(theme),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _primaryColor)
          : Icon(Icons.circle_outlined, color: Colors.grey.shade300),
      onTap: () {
        // Implement theme change
      },
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, 
                    color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Deactivate Account?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your profile will be hidden and you won\'t receive new job offers. You can reactivate anytime by logging back in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: _textColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // Implement account deactivation
                        },
                        child: const Text('Deactivate'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingsItem(
          icon: Icons.person_outline,
          title: 'Profile Settings',
          subtitle: 'Update your personal information',
          onTap: () {
            // Profile settings
          },
          iconColor: Colors.blue,
        ),
        _buildSettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Customize your notifications',
          onTap: () {
            // Notification settings
          },
          iconColor: Colors.orange,
        ),
        _buildSettingsItem(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'English',
          onTap: _showLanguageDialog,
          iconColor: Colors.green,
        ),
        _buildSettingsItem(
          icon: Icons.color_lens_outlined,
          title: 'Theme',
          subtitle: 'Light',
          onTap: _showThemeDialog,
          iconColor: Colors.purple,
        ),
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: _showChangePasswordDialog,
          iconColor: Colors.indigo,
        ),
        _buildSettingsItem(
          icon: Icons.security_outlined,
          title: 'Privacy & Security',
          subtitle: 'Manage your data and security',
          onTap: () {
            // Privacy settings
          },
          iconColor: Colors.indigo,
        ),
        _buildSettingsItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQ, Contact us',
          onTap: () {
            // Help center
          },
          iconColor: Colors.teal,
        ),
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version 1.0.0',
          onTap: () {
            // About page
          },
          iconColor: Colors.blueGrey,
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () {
            // Logout logic
          },
          showArrow: false,
          iconColor: Colors.red,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showDeactivateDialog,
          child: const Text(
            'Deactivate Account',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            Text(
              'Preferences',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}