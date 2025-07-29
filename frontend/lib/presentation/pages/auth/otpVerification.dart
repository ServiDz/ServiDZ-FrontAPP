import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/data/services/auth_service.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({Key? key}) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());

  String? tempUserId;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      tempUserId = args['tempUserId'];
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 4 || tempUserId == null) {
      showError('Invalid OTP or user ID');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final result = await authService.verifyOtp(userId: tempUserId!, otp: otp);

      if (result.containsKey('accessToken') && result.containsKey('user')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', result['accessToken']);
        await prefs.setString('userId', result['user']['_id']);
        Navigator.pushReplacementNamed(context, 'homepage');
      } else {
        showError(result['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      showError('Something went wrong. Please try again.');
      print('OTP verification error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.all(8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade800),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.blue[800]),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),

              // Title
              Center(
                child: Text(
                  'Email Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  'Please enter your OTP code to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 40),

              // Submit Button
              Center(
                child: SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFFFEE2BB),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Color(0xFFFEE2BB),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
