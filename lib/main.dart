import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/begin_dive_screen.dart';
import 'screens/end_dive_screen.dart';
import 'screens/dive_log_screen.dart';
import 'screens/edit_dive_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Dive Logger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/begin-dive': (context) => const BeginDiveScreen(),
        '/end-dive': (context) => const EndDiveScreen(),
        '/dive-log': (context) => const DiveLogScreen(),
        '/edit-dive': (context) => const EditDiveScreen(),
      },
    );
  }
}
