import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/custom_text_field.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final url = Uri.parse('http://10.93.89.181:5000/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final user = data['user'];

        // TODO: Store tokens if needed with SharedPreferences

        // Navigate to home
        Navigator.pushReplacementNamed(context, 'homepage');
      } else {
        final errorData = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Login Failed'),
            content: Text(errorData['message'] ?? 'Invalid credentials'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          
          title: const Text('Error'),
          content: const Text('Something went wrong. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
              
            ),
          ],
        ),
        
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Logo & Title
                Column(
                  children: [
                    Image.asset(
                      'images/login.png',
                      height: 200,
                    ),
                    const SizedBox(height: 15),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        children: const [
                          TextSpan(text: "Welcome Back To\n"),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "ServiDz",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // 🔹 Email
                ServiTextInput(
                  controller: emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 20),

                // 🔹 Password
                ServiTextInput(
                  controller: passwordController,
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
                ),

                const SizedBox(height: 8),

                // 🔹 Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: implement forgot password
                    },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFEE2BB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Sign up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.blue[800],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'signup');
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
