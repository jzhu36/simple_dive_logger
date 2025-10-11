import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simple_dive_logger/models/dive.dart';
import 'package:simple_dive_logger/services/database_service.dart';
import 'package:simple_dive_logger/screens/end_dive_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('EndDiveScreen Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      dbService = DatabaseService.instance;
      final db = await dbService.database;
      await db.delete('dives');
    });

    tearDown(() async {
      final db = await dbService.database;
      await db.delete('dives');
    });

    testWidgets('should display "No Active Dives" when no in-progress dives exist',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EndDiveScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No Active Dives'), findsOneWidget);
      expect(find.text('You don\'t have any dives in progress.\nStart a new dive first!'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('should display single dive confirmation when one in-progress dive exists',
        (WidgetTester tester) async {
      // Arrange - Insert one in-progress dive
      final now = DateTime.now();
      await dbService.insertDive(Dive(
        date: '2025-10-11',
        time: '14:30',
        maxDepth: 0.0,
        duration: 0,
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EndDiveScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('End This Dive?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('End Dive'), findsOneWidget);
      expect(find.textContaining('2025-10-11'), findsOneWidget);
    });

    testWidgets('should display dive selection list when multiple in-progress dives exist',
        (WidgetTester tester) async {
      // Arrange - Insert multiple in-progress dives
      final now = DateTime.now();
      await dbService.insertDive(Dive(
        date: '2025-10-11',
        time: '10:00',
        country: 'Indonesia',
        maxDepth: 0.0,
        duration: 0,
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));
      await dbService.insertDive(Dive(
        date: '2025-10-11',
        time: '14:30',
        country: 'Thailand',
        maxDepth: 0.0,
        duration: 0,
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EndDiveScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Select Dive to End'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('End Selected Dive'), findsOneWidget);
      expect(find.byType(Radio<int>), findsNWidgets(2));
      expect(find.textContaining('Indonesia'), findsOneWidget);
      expect(find.textContaining('Thailand'), findsOneWidget);
    });

    testWidgets('should auto-select single dive and allow cancellation',
        (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      await dbService.insertDive(Dive(
        date: '2025-10-11',
        time: '14:30',
        maxDepth: 0.0,
        duration: 0,
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EndDiveScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - screen should be popped (no longer visible)
      expect(find.text('End This Dive?'), findsNothing);
    });

    testWidgets('should allow selecting a dive from multiple options',
        (WidgetTester tester) async {
      // Arrange - Insert multiple dives
      final now = DateTime.now();
      await dbService.insertDive(Dive(
        date: '2025-10-11',
        time: '10:00',
        maxDepth: 0.0,
        duration: 0,
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));
      await dbService.insertDive(Dive(
        date: '2025-10-11',
        time: '14:30',
        maxDepth: 0.0,
        duration: 0,
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const EndDiveScreen(),
          routes: {
            '/edit-dive': (context) => const Scaffold(
                  body: Center(child: Text('Edit Dive Screen')),
                ),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the second radio button
      final radios = find.byType(Radio<int>);
      expect(radios, findsNWidgets(2));

      await tester.tap(radios.last);
      await tester.pumpAndSettle();

      // Verify End Selected Dive button is enabled
      final endButton = find.text('End Selected Dive');
      expect(endButton, findsOneWidget);

      // Verify button is enabled (we can try to tap it)
      final buttonWidget = tester.widget<ElevatedButton>(
        find.ancestor(
          of: endButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('should display loading indicator while loading dives',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EndDiveScreen(),
        ),
      );

      // Assert - before pumpAndSettle, loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let it settle
      await tester.pumpAndSettle();

      // After settling, loading should be done
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should only show in-progress dives, not completed ones',
        (WidgetTester tester) async {
      // Arrange - Insert both completed and in-progress dives
      final now = DateTime.now();
      await dbService.insertDive(Dive(
        date: '2025-10-10',
        time: '10:00',
        country: 'Completed Dive',
        maxDepth: 25.0,
        duration: 45,
        status: 'completed',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));
      await dbService.insertDive(Dive(
        date: '2025-10-11',
        time: '14:30',
        country: 'In Progress Dive',
        maxDepth: 0.0,
        duration: 0,
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ));

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EndDiveScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - should show single dive view (only 1 in-progress)
      expect(find.text('End This Dive?'), findsOneWidget);
      expect(find.textContaining('In Progress Dive'), findsOneWidget);
      expect(find.textContaining('Completed Dive'), findsNothing);
    });
  });
}
