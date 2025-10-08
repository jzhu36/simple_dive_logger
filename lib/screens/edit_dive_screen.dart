import 'package:flutter/material.dart';

class EditDiveScreen extends StatelessWidget {
  const EditDiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dive'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Edit Dive Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
