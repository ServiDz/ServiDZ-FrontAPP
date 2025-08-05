import 'package:flutter/material.dart';
import 'package:frontend/data/services/profile_service.dart';
import 'package:frontend/data/services/settings_service.dart';
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart';
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

  final Color _primaryColor = Colors.blue;
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2D3436);

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final userData = await ProfileService.fetchUserProfile();
    if (userData != null) {
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
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      final success = await ProfileService.uploadAvatar(_selectedImage!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated successfully")),
        );
        fetchUserProfile(); // Refresh the profile data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile image")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showChangePhoneDialog() {
  final phoneController = TextEditingController(text: user?['phone'] ?? '');
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
                    'Change Phone Number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                      hintText: 'Enter your new phone number',
                    ),
                    keyboardType: TextInputType.phone,
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
                                if (phoneController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a phone number'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isUpdating = true);

                                try {
                                  final result = await SettingsService.updatePhoneNumber(
                                    phoneController.text,
                                  );
                                  
                                  if (result['success'] == true) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message'] ?? 'Phone number updated successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    fetchUserProfile(); // Refresh the profile data
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message'] ?? 'Failed to update phone number'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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
                                    // Implement your password change logic here
                                    // For example:
                                    // final response = await ProfileService.changePassword(
                                    //   currentPasswordController.text,
                                    //   newPasswordController.text,
                                    // );
                                    
                                    // Simulate success for UI demonstration
                                    await Future.delayed(const Duration(seconds: 1));
                                    
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password changed successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
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

  Widget _buildProfileHeader() {
    final name = user?['name'] ?? 'Guest';
    final email = user?['email'] ?? '';
    final imageUrl = user?['avatar'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile picture with camera button
          GestureDetector(
            onTap: pickAndUploadImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: user!),
                ),
              ).then((_) => fetchUserProfile());
            },
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

  Widget _buildPersonalDetailsSection() {
    final name = user?['name'] ?? 'Unnamed';
    final email = user?['email'] ?? 'No email';
    final phone = user?['phone'] ?? 'Not provided';

    return Column(
      children: [
        _buildSettingsItem(
          icon: Icons.person_outline,
          title: 'Name',
          subtitle: name,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage(user: user!)),
            ).then((_) => fetchUserProfile());
          },
          iconColor: Colors.blue,
        ),
        _buildSettingsItem(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: email,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage(user: user!)),
            ).then((_) => fetchUserProfile());
          },
          iconColor: Colors.orange,
        ),
        _buildSettingsItem(
          icon: Icons.phone,
          title: 'Phone',
          subtitle: phone,
          onTap: () {
            _showChangePhoneDialog();
          },
          iconColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out")),
            );
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              Text("User not found", style: TextStyle(color: _textColor)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            Text(
              'Personal Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildPersonalDetailsSection(),
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
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            Text(
              'Security',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSecuritySection(),
            const SizedBox(height: 24),
            Text(
              'Support',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSupportSection(),
            const SizedBox(height: 24),
            _buildAccountSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}