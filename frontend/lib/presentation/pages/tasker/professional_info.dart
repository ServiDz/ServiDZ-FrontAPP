import 'package:flutter/material.dart';
import 'package:frontend/data/services/tasker_service.dart';

class ProfessionalProfilePage extends StatefulWidget {
  const ProfessionalProfilePage({super.key});

  @override
  State<ProfessionalProfilePage> createState() => _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage> {
  String fullName = '';
  String email = '';
  String phone = '';
  String location = '';
  String profileImageUrl = '';
  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TaskerService _taskerService = TaskerService();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    debugPrint('Fetching profile...');
    setState(() => isLoading = true);
    
    try {
      final profileData = await _taskerService.fetchTaskerProfile();
      if (profileData != null && mounted) {
        setState(() {
          fullName = profileData['fullName'] ?? '';
          email = profileData['email'] ?? '';
          phone = profileData['phone'] ?? '';
          location = profileData['location'] ?? '';
          profileImageUrl = profileData['profilePic'] ?? '';

          _nameController.text = fullName;
          _emailController.text = email;
          _phoneController.text = phone;
          _locationController.text = location;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        _showSnackBar('Failed to load profile: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      bool allUpdatesSuccessful = true;
      String errorMessage = '';

      if (_nameController.text.trim() != fullName) {
        final success = await _taskerService.updateTaskerName(_nameController.text.trim());
        if (!success) {
          allUpdatesSuccessful = false;
          errorMessage = 'Failed to update name';
        }
      }

      if (_phoneController.text.trim() != phone) {
        if (_phoneController.text.trim().isEmpty) {
          allUpdatesSuccessful = false;
          errorMessage = 'Phone number cannot be empty';
        } else {
          final success = await _taskerService.updateTaskerPhone(_phoneController.text.trim());
          if (!success) {
            allUpdatesSuccessful = false;
            errorMessage = 'Failed to update phone number';
          }
        }
      }

      if (_locationController.text.trim() != location) {
        final success = await _taskerService.updateTaskerLocation(_locationController.text.trim());
        if (!success) {
          allUpdatesSuccessful = false;
          errorMessage = 'Failed to update location';
        }
      }

      if (mounted) {
        if (allUpdatesSuccessful) {
          await _fetchProfileData();
          _showSnackBar('Profile updated successfully!', isError: false);
        } else {
          _showSnackBar(errorMessage.isNotEmpty ? errorMessage : 'Some updates failed');
        }
      }
    } catch (e) {
      debugPrint('Exception during update: $e');
      if (mounted) {
        _showSnackBar('Update error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _editField(String fieldName, String currentValue, TextEditingController controller) async {
    final dialogController = TextEditingController(text: currentValue);
    
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Edit $fieldName',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        content: TextField(
          controller: dialogController,
          decoration: InputDecoration(
            hintText: 'Enter new $fieldName',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, dialogController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (newValue != null && newValue != currentValue && mounted) {
      controller.text = newValue;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Professional Profile',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 2,
                          ),
                          color: Colors.grey[100],
                        ),
                        child: profileImageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  profileImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                      ),
                      GestureDetector(
                        onTap: () {}, // Add photo upload functionality
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PROFILE INFORMATION',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildEditableInfoRow('Full Name', fullName, _nameController, Icons.person),
                        const Divider(height: 32, thickness: 0.5),
                        _buildEditableInfoRow('Email', email, _emailController, Icons.email, editable: false),
                        const Divider(height: 32, thickness: 0.5),
                        _buildEditableInfoRow('Phone Number', phone, _phoneController, Icons.phone),
                        const Divider(height: 32, thickness: 0.5),
                        _buildEditableInfoRow('Location', location, _locationController, Icons.location_on),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableInfoRow(
    String title,
    String value,
    TextEditingController controller,
    IconData icon, {
    bool editable = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: editable ? () => _editField(title, value, controller) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.text.isNotEmpty ? controller.text : 'Not set',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (editable)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}