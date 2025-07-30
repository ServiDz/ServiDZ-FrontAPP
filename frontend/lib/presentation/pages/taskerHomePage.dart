import 'package:flutter/material.dart';

class TaskerHomePage extends StatelessWidget {
  const TaskerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasker Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Tasker Home Page'),
      ),
    );
  }
}
