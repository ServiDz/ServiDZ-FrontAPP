import 'package:flutter/material.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/presentation/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TaskerRegisterPage extends StatefulWidget {
  const TaskerRegisterPage({Key? key}) : super(key: key);

  @override
  State<TaskerRegisterPage> createState() => _TaskerRegisterPageState();
}

class _TaskerRegisterPageState extends State<TaskerRegisterPage> {
  final _authService = AuthService();

  // Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final professionController = TextEditingController();
  final locationController = TextEditingController();
  final aboutController = TextEditingController();

  Future<void> _handleSignup(String role) async {
    final body = {
      'fullName': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'phone': phoneController.text.trim(),
      'profession': professionController.text.trim(),
      'location': locationController.text.trim(),
      'about': aboutController.text.trim(),
      'role': role,
    };

    final result = await _authService.registerTasker(body);

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', role);

      Navigator.pushNamed(context, 'otpVerification', arguments: {
        'tempUserId': result['tempTaskerId'],
        'role': role,
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Signup Failed"),
          content: Text(result['message']),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? 'tasker';

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
                  Image.asset('images/logo.png', height: 50),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Create your professional account here!",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // Fields
              ServiTextInput(controller: fullNameController, hintText: "Enter your full name", prefixIcon: Icons.person),
              const SizedBox(height: 16),
              ServiTextInput(controller: emailController, hintText: "Enter your email", prefixIcon: Icons.email),
              const SizedBox(height: 16),
              ServiTextInput(controller: passwordController, hintText: "Enter your password", prefixIcon: Icons.lock, obscureText: true),
              const SizedBox(height: 16),
              ServiTextInput(controller: phoneController, hintText: "Enter your phone", prefixIcon: Icons.phone),
              const SizedBox(height: 16),
              ServiTextInput(controller: professionController, hintText: "Enter your profession", prefixIcon: Icons.work),
              const SizedBox(height: 16),
              ServiTextInput(controller: locationController, hintText: "Enter your Location", prefixIcon: Icons.location_on),
              const SizedBox(height: 16),
              ServiTextInput(controller: aboutController, hintText: "About you ....", prefixIcon: Icons.info),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handleSignup(role),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Colors.blue[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Signup", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
