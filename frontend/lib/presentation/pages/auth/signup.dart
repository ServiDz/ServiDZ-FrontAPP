import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/data/services/auth_service.dart';


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

  String _selectedRole = 'user'; // default value
  Future<void> handleSignup() async {
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  final authService = AuthService();
  final result = await authService.signup(
    name: name,
    email: email,
    password: password,
    role: _selectedRole,
  );

  if (result['success']) {
    Navigator.pushNamed(
      context,
      'otpVerification',
      arguments: {'tempUserId': result['tempUserId']},
    );
  } else {
    showError(result['message']);
  }
}


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['role'] != null) {
      _selectedRole = args['role'];
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
                prefixIcon: Icons.person,
                validator: (String? value) {},
              ),
              const SizedBox(height: 20),

              // Email Input
              ServiTextInput(
                controller: _emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email,
                validator: (String? value) {},
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
                ),
                validator: (String? value) {},
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
                  onPressed: handleSignup,
                  child: const Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFF6EB),
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
