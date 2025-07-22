import 'package:flutter/material.dart';
import 'package:frontend/auth/login.dart';
import 'package:frontend/auth/otpVerification.dart';
import 'package:frontend/auth/signup.dart';
import 'package:frontend/presentation/pages/getStarted.dart';
import 'package:frontend/presentation/pages/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) =>  GetStartedPage(),
        'login':(context) => const LoginPage(),
        'signup': (context) => const SignupPage(),
        'otpVerification': (context) => const OtpVerificationPage(),
        'homepage': (context) => HomePage(),
        // '/second': (context) => const SecondPage(),
      },
    );
  }
}



