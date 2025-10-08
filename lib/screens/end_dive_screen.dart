import 'package:flutter/material.dart';

class EndDiveScreen extends StatelessWidget {
  const EndDiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('End Dive'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'End Dive Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
