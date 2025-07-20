import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/getStarted.dart';

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
        // '/second': (context) => const SecondPage(),
      },
    );
  }
}



