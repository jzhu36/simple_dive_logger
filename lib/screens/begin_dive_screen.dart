import 'package:flutter/material.dart';

class BeginDiveScreen extends StatelessWidget {
  const BeginDiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Begin Dive'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Begin Dive Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
