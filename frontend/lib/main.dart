import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/auth/Tasker_singup.dart';
import 'package:frontend/presentation/pages/chat/chat_page.dart';
import 'package:frontend/presentation/pages/chat/chatsList.dart';
import 'package:frontend/presentation/pages/taskerHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/presentation/pages/auth/login.dart';
import 'package:frontend/presentation/pages/auth/otpVerification.dart';
import 'package:frontend/presentation/pages/auth/signup.dart';
import 'package:frontend/presentation/pages/RoleSelection.dart';
import 'package:frontend/presentation/pages/getStarted.dart';
import 'package:frontend/presentation/pages/homePage.dart';
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart';
import 'package:frontend/presentation/pages/profile/profile_page.dart';
import 'package:frontend/presentation/pages/tasker_details.dart';
import 'package:frontend/presentation/pages/booking/confirmBooking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');
  final userId = prefs.getString('userId');

  String initialRoute = '/';

  // Force start at login page for now
  initialRoute = '/';

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
        'signup': (context) => const SignupPage(),
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
        'chatsList': (context) => ChatsListPage(),
        'chatDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ChatPage(
            otherUserId: args['otherUserId'],
            otherUserName: args['otherUserName'],
            otherUserAvatar: args['otherUserAvatar'],
            userId: args['userId'],
          );
        },
        'bookingConfirmed': (context) => const BookingConfirmedPage(),
        'taskerRegister': (context) => const TaskerRegisterPage(),
        'taskerHomePage': (context) => const TaskerHomePage(), // ✅ Fixed naming
      },
    );
  }
}
