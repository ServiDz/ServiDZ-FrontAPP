import 'package:flutter/material.dart';
import 'package:frontend/auth/login.dart';
import 'package:frontend/auth/otpVerification.dart';
import 'package:frontend/auth/signup.dart';
import 'package:frontend/presentation/pages/RoleSelection.dart';
import 'package:frontend/presentation/pages/getStarted.dart';
import 'package:frontend/presentation/pages/homePage.dart';
import 'package:frontend/presentation/pages/tasker_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) =>  GetStartedPage(),
        'roleSelection': (context) => const RoleSelectionPage(),
        'login':(context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        'otpVerification': (context) => const OtpVerificationPage(),
        'homepage': (context) => HomePage(),
          'taskerDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return TaskerPage(taskerId: args['id']);
        },
        // '/second': (context) => const SecondPage(),
      },
    );
  }
}



