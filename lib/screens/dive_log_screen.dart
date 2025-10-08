import 'package:flutter/material.dart';

class DiveLogScreen extends StatelessWidget {
  const DiveLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dive Log'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Dive Log Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
