import 'package:flutter/material.dart';
import 'package:frontend/data/models/tasker_model.dart';
import 'package:frontend/presentation/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskerRegisterPage extends StatelessWidget {
  const TaskerRegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? 'tasker';

    // Controllers
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final professionController = TextEditingController();
    final locationController = TextEditingController();
    final aboutController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register To ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[800],
                    ),
                  ),
                  Image.asset(
                    'images/logo.png',
                    height: 50,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Create your professional account here!",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // Input Fields
              ServiTextInput(
                controller: fullNameController,
                hintText: "Enter your full name",
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              ServiTextInput(
                controller: emailController,
                hintText: "Enter your email",
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 16),
              ServiTextInput(
                controller: passwordController,
                hintText: "Enter your password",
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ServiTextInput(
                controller: phoneController,
                hintText: "Enter your phone",
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 16),
              ServiTextInput(
                controller: professionController,
                hintText: "Enter your profession",
                prefixIcon: Icons.work,
              ),
              const SizedBox(height: 16),
              ServiTextInput(
                controller: locationController,
                hintText: "Enter your Location",
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              ServiTextInput(
                controller: aboutController,
                hintText: "About you ....",
                prefixIcon: Icons.info,
              ),

              const SizedBox(height: 25),

              // Signup Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final body = {
                      'fullName': fullNameController.text.trim(), // ✅ correct key
                      'email': emailController.text.trim(),
                      'password': passwordController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'profession': professionController.text.trim(),
                      'location': locationController.text.trim(),
                      'about': aboutController.text.trim(),
                      'role': role,
                    };

                    try {
                      final response = await http.post(
                        Uri.parse('http://10.93.89.181:5000/api/tasker/auth/register'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(body),
                      );

                      final data = jsonDecode(response.body);

                      if (response.statusCode == 200) {
                        final tempTaskerId = data['tempTaskerId'];

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('role', role);

                        Navigator.pushNamed(
                          context,
                          'otpVerification',
                          arguments: {
                            'tempUserId': tempTaskerId,
                            'role': role,
                          },
                        );
                      } else {
                        final message = data['message'] ?? 'Registration failed.';
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Signup Failed"),
                            content: Text(message),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Error"),
                          content: Text("Something went wrong: $e"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Signup",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
