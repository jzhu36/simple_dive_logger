import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_dive_logger/screens/home_screen.dart';

void main() {
  group('HomeScreen Tests', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Assert
      expect(find.text('Simple Dive Logger'), findsOneWidget);
    });

    testWidgets('should display all three navigation buttons',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Assert
      expect(find.text('Begin Dive'), findsOneWidget);
      expect(find.text('End Dive'), findsOneWidget);
      expect(find.text('Edit Dive'), findsOneWidget);
    });

    testWidgets('Begin Dive button should navigate to BeginDiveScreen',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
          routes: {
            '/begin-dive': (context) => const Scaffold(
                  body: Center(child: Text('Begin Dive Screen')),
                ),
          },
        ),
      );

      // Act
      await tester.tap(find.text('Begin Dive'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Begin Dive Screen'), findsOneWidget);
    });

    testWidgets('End Dive button should navigate to EndDiveScreen',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
          routes: {
            '/end-dive': (context) => const Scaffold(
                  body: Center(child: Text('End Dive Screen')),
                ),
          },
        ),
      );

      // Act
      await tester.tap(find.text('End Dive'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('End Dive Screen'), findsOneWidget);
    });

    testWidgets('Edit Dive button should navigate to EditDiveScreen',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
          routes: {
            '/edit-dive': (context) => const Scaffold(
                  body: Center(child: Text('Edit Dive Screen')),
                ),
          },
        ),
      );

      // Act
      await tester.tap(find.text('Edit Dive'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Dive Screen'), findsOneWidget);
    });

    testWidgets('buttons should be properly styled and accessible',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Assert - Check that buttons exist and are tappable
      final beginDiveButton = find.ancestor(
        of: find.text('Begin Dive'),
        matching: find.byType(ElevatedButton),
      );
      final endDiveButton = find.ancestor(
        of: find.text('End Dive'),
        matching: find.byType(ElevatedButton),
      );
      final editDiveButton = find.ancestor(
        of: find.text('Edit Dive'),
        matching: find.byType(ElevatedButton),
      );

      expect(beginDiveButton, findsOneWidget);
      expect(endDiveButton, findsOneWidget);
      expect(editDiveButton, findsOneWidget);
    });
  });
}
