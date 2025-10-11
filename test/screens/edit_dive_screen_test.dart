import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simple_dive_logger/models/dive.dart';
import 'package:simple_dive_logger/services/database_service.dart';
import 'package:simple_dive_logger/screens/edit_dive_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('EditDiveScreen Tests', () {
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

    group('Dive Picker Mode (no dive provided)', () {
      testWidgets('should display "No Dives Found" when no dives exist',
          (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: EditDiveScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('No Dives Found'), findsOneWidget);
        expect(find.text('You don\'t have any dives yet.\nStart a new dive first!'), findsOneWidget);
        expect(find.text('Go Back'), findsOneWidget);
      });

      testWidgets('should display dive picker when dives exist',
          (WidgetTester tester) async {
        // Arrange - Insert test dives
        final now = DateTime.now();
        await dbService.insertDive(Dive(
          date: '2025-10-11',
          time: '10:00',
          country: 'Indonesia',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ));
        await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:00',
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
            home: EditDiveScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Select Dive to Edit'), findsOneWidget);
        expect(find.textContaining('Indonesia'), findsOneWidget);
        expect(find.textContaining('Thailand'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('In Progress'), findsOneWidget);
      });

      testWidgets('should show dive details in picker cards',
          (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        await dbService.insertDive(Dive(
          date: '2025-10-11',
          time: '14:30',
          country: 'Indonesia',
          diveSiteName: 'Blue Corner',
          maxDepth: 25.5,
          duration: 45,
          status: 'completed',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ));

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: EditDiveScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('2025-10-11 at 14:30'), findsOneWidget);
        expect(find.textContaining('Blue Corner, Indonesia'), findsOneWidget);
        expect(find.textContaining('Depth: 25.5m'), findsOneWidget);
        expect(find.textContaining('Duration: 45 min'), findsOneWidget);
      });
    });

    group('Edit Form Mode (dive provided)', () {
      testWidgets('should display edit form when dive is provided',
          (WidgetTester tester) async {
        // Arrange - Create a dive
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          country: 'Indonesia',
          diveSiteName: 'Blue Corner',
          maxDepth: 25.5,
          duration: 45,
          waterTemperature: 28.0,
          visibility: 'excellent',
          notes: 'Great dive!',
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - form fields should be populated
        expect(find.text('Edit Dive'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '2025-10-11'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '14:30'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Indonesia'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Blue Corner'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '25.5'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '45'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '28.0'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Great dive!'), findsOneWidget);
      });

      testWidgets('should display all form fields', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 0.0,
          duration: 0,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - check for all field labels
        expect(find.text('Date *'), findsOneWidget);
        expect(find.text('Time *'), findsOneWidget);
        expect(find.text('Country'), findsOneWidget);
        expect(find.text('Dive Site Name'), findsOneWidget);
        expect(find.text('Latitude'), findsOneWidget);
        expect(find.text('Longitude'), findsOneWidget);
        expect(find.text('Max Depth (m) *'), findsOneWidget);
        expect(find.text('Duration (min) *'), findsOneWidget);
        expect(find.text('Water Temperature (°C)'), findsOneWidget);
        expect(find.text('Visibility'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Save Dive'), findsOneWidget);
      });

      testWidgets('should validate required fields', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        await dbService.insertDive(dive);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Clear required field
        await tester.enterText(
          find.widgetWithText(TextFormField, '25.0'),
          '',
        );

        // Tap save button
        await tester.tap(find.text('Save Dive'));
        await tester.pumpAndSettle();

        // Assert - validation error should appear
        expect(find.text('Required'), findsOneWidget);
      });

      testWidgets('should validate depth range', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        await dbService.insertDive(dive);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Enter invalid depth
        await tester.enterText(
          find.widgetWithText(TextFormField, '25.0'),
          '500',
        );

        // Tap save button
        await tester.tap(find.text('Save Dive'));
        await tester.pumpAndSettle();

        // Assert - validation error should appear
        expect(find.text('0-300'), findsOneWidget);
      });

      testWidgets('should validate GPS coordinates', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        await dbService.insertDive(dive);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Enter invalid latitude
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Latitude').first,
          '100',
        );

        // Tap save button
        await tester.tap(find.text('Save Dive'));
        await tester.pumpAndSettle();

        // Assert - validation error should appear
        expect(find.text('Invalid'), findsOneWidget);
      });

      testWidgets('should have visibility dropdown', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          visibility: 'good',
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - visibility dropdown should exist
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

        // Tap dropdown to open it
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Verify dropdown items
        expect(find.text('Excellent').hitTestable(), findsOneWidget);
        expect(find.text('Good').hitTestable(), findsNWidgets(2)); // One in dropdown, one selected
        expect(find.text('Fair').hitTestable(), findsOneWidget);
        expect(find.text('Poor').hitTestable(), findsOneWidget);
      });

      testWidgets('should display save button', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final saveButton = find.text('Save Dive');
        expect(saveButton, findsOneWidget);

        // Verify it's an ElevatedButton
        expect(
          find.ancestor(
            of: saveButton,
            matching: find.byType(ElevatedButton),
          ),
          findsOneWidget,
        );
      });
    });

    group('Form Validation', () {
      testWidgets('should validate water temperature range',
          (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        await dbService.insertDive(dive);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Enter invalid temperature
        final tempField = find.widgetWithText(TextFormField, 'Water Temperature (°C)');
        await tester.enterText(tempField, '50');

        // Tap save button
        await tester.tap(find.text('Save Dive'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Must be -2 to 40'), findsOneWidget);
      });

      testWidgets('should validate duration range', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        await dbService.insertDive(dive);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Enter invalid duration
        await tester.enterText(
          find.widgetWithText(TextFormField, '45'),
          '1000',
        );

        // Tap save button
        await tester.tap(find.text('Save Dive'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('0-999'), findsOneWidget);
      });

      testWidgets('should accept valid form data', (WidgetTester tester) async {
        // Arrange
        final now = DateTime.now();
        final dive = Dive(
          id: 1,
          date: '2025-10-11',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'in_progress',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        await dbService.insertDive(dive);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: EditDiveScreen(dive: dive),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all required fields have valid values
        expect(find.widgetWithText(TextFormField, '2025-10-11'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '14:30'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '25.0'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '45'), findsOneWidget);

        // Save button should be enabled
        final saveButton = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Save Dive'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(saveButton.onPressed, isNotNull);
      });
    });
  });
}
