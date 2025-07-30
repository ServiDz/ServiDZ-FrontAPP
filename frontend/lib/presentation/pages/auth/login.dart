import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/presentation/widgets/custom_text_field.dart';
import 'package:frontend/data/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;

  String? role;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is String) {
        print('🔄 Received role from navigation: $args');
        setState(() {
          role = args;
        });
      } else if (args is Map && args['role'] != null) {
        print('🔄 Received role from arguments map: ${args['role']}');
        setState(() {
          role = args['role'];
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        final savedRole = prefs.getString('role');
        print('📦 Retrieved role from SharedPreferences: $savedRole');
        if (savedRole != null) {
          setState(() {
            role = savedRole;
          });
        }
      }
    });
  }

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    print('📤 Attempting login with email: $email, role: $role');

    if (role == null || role!.isEmpty) {
      print('❌ Role is null or empty at login time!');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Error'),
          content: Text('Role is not set. Cannot proceed with login.'),
        ),
      );
      return;
    }

    final authService = AuthService();
    final result = await authService.login(email, password, role!);

    print('📥 Login response: $result');

    if (result['success']) {
      final user = result['user'];
      final userRole = user['role'];
      print('✅ Login success. User role: $userRole');

      if (userRole == 'user') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, 'homepage');
      } else if (userRole == 'tasker') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, 'taskerhomepage');
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, 'homepage');
      }
    } else {
      print('❌ Login failed: ${result['message']}');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(result['message']),
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

                ServiTextInput(
                  controller: emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 20),

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

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: role == null ? null : handleLogin,
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
                        color: Color(0xFFFFF6EB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

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
                        if (role == 'tasker') {
                          Navigator.pushNamed(
                            context,
                            'taskerRegister',
                            arguments: {'role': role},
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            'signup',
                            arguments: {'role': role},
                          );
                        }
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
