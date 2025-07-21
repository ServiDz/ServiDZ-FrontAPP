import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  Future<void> handleSignup() async {
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  final url = Uri.parse('http://10.93.89.181:5000/api/auth/register'); // adjust if needed

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'user', // or 'professional'
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tempUserId = data['tempUserId'];

      // Navigate to OTP page with user ID
      Navigator.pushNamed(
      context,
      'otpVerification',
        arguments: {'tempUserId': tempUserId},
    );
    } else {
      final error = jsonDecode(response.body);
      showError(error['message'] ?? 'Signup failed');
    }
  } catch (e) {
    showError('Something went wrong. Try again.');
    print('Signup error: $e');
  }
}

void showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Register To ServiDz',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account here!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 30),

              // Name Input
              ServiTextInput(
                controller: _nameController,
                hintText: 'Enter your name',
                prefixIcon: Icons.person, validator: (String? value) {  },
              ),
              const SizedBox(height: 20),

              // Email Input
              ServiTextInput(
                controller: _emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email, validator: (String? value) {  },
              ),
              const SizedBox(height: 20),

              // Password Input
              ServiTextInput(
                controller: _passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock,
                obscureText: _isObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF7F8EC5),
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ), validator: (String? value) {  },
              ),
              const SizedBox(height: 30),

              // Signup Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Handle signup logic here
                    handleSignup();
                  },
                  child: const Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFEE2BB),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.blue[800],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, 'login');
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
