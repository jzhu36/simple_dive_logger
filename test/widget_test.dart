// Basic app smoke test for Simple Dive Logger

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_dive_logger/main.dart';

void main() {
  testWidgets('App launches and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen is displayed with the app title
    expect(find.text('Simple Dive Logger'), findsOneWidget);

    // Verify that all four main buttons are present
    expect(find.text('Begin Dive'), findsOneWidget);
    expect(find.text('End Dive'), findsOneWidget);
    expect(find.text('Dive Log'), findsOneWidget);
    expect(find.text('Edit Dive'), findsOneWidget);
  });
}
