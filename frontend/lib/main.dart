import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/login.dart';
import 'package:frontend/auth/otpVerification.dart';
import 'package:frontend/auth/signup.dart';
import 'package:frontend/presentation/pages/RoleSelection.dart';
import 'package:frontend/presentation/pages/getStarted.dart';
import 'package:frontend/presentation/pages/homePage.dart';
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart';
import 'package:frontend/presentation/pages/profile/profile_page.dart';
import 'package:frontend/presentation/pages/tasker_details.dart';
import 'package:frontend/data/services/auth_service.dart'; // <-- make sure this path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');
  final userId = prefs.getString('userId');

  String initialRoute = '/';

  // If tokens exist, try to refresh
  if (accessToken != null && refreshToken != null && userId != null) {
    final authService = AuthService();
    bool refreshed = await authService.refreshAccessToken();

    if (refreshed) {
      initialRoute = 'homepage';
    } else {
      // If refresh fails, go to login
      initialRoute = 'login';
    }
  } else {
    initialRoute = 'login';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => GetStartedPage(),
        'roleSelection': (context) => const RoleSelectionPage(),
        'login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        'otpVerification': (context) => const OtpVerificationPage(),
        'homepage': (context) => HomePage(),
        'taskerDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return TaskerPage(taskerId: args['id']);
        },
        'profile': (context) => ProfilePage(),
        'editProfile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return EditProfilePage(user: args['user']);
        },
      },
    );
  }
}



