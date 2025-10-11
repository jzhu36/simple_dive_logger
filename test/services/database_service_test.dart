import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simple_dive_logger/models/dive.dart';
import 'package:simple_dive_logger/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseService Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      // Use in-memory database for testing
      dbService = DatabaseService.instance;
      final db = await dbService.database;

      // Clean up any existing data
      await db.delete('dives');
    });

    tearDown(() async {
      // Clean up after each test
      final db = await dbService.database;
      await db.delete('dives');
    });

    group('Database Initialization', () {
      test('should create database with correct schema', () async {
        final db = await dbService.database;

        // Check if dives table exists
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='dives'",
        );

        expect(tables.length, 1);
        expect(tables.first['name'], 'dives');
      });

      test('should create all indexes', () async {
        final db = await dbService.database;

        final indexes = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='dives'",
        );

        final indexNames = indexes.map((idx) => idx['name'] as String).toList();
        expect(indexNames, contains('idx_dives_date'));
        expect(indexNames, contains('idx_dives_status'));
        expect(indexNames, contains('idx_dives_country'));
        expect(indexNames, contains('idx_dives_site_name'));
      });
    });

    group('Insert Operations', () {
      test('should insert dive successfully', () async {
        final dive = Dive(
          date: '2025-10-10',
          time: '14:30',
          country: 'Indonesia',
          diveSiteName: 'Blue Corner',
          latitude: -8.3405,
          longitude: 115.0920,
          maxDepth: 25.5,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        );

        final id = await dbService.insertDive(dive);
        expect(id, greaterThan(0));
      });

      test('should fail to insert invalid dive', () async {
        final invalidDive = Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: -10.0, // Invalid: negative depth
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        );

        expect(
          () => dbService.insertDive(invalidDive),
          throwsException,
        );
      });

      test('should allow inserting multiple in_progress dives', () async {
        final dive1 = Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 0.0,
          duration: 0,
          status: 'in_progress',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T14:30:00Z',
        );

        final dive2 = Dive(
          date: '2025-10-11',
          time: '10:00',
          maxDepth: 0.0,
          duration: 0,
          status: 'in_progress',
          createdAt: '2025-10-11T10:00:00Z',
          updatedAt: '2025-10-11T10:00:00Z',
        );

        final id1 = await dbService.insertDive(dive1);
        final id2 = await dbService.insertDive(dive2);

        expect(id1, greaterThan(0));
        expect(id2, greaterThan(0));
        expect(id2, greaterThan(id1));
      });
    });

    group('Read Operations', () {
      test('should get all completed dives', () async {
        // Insert test data
        await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        ));

        await dbService.insertDive(Dive(
          date: '2025-10-11',
          time: '09:00',
          maxDepth: 30.0,
          duration: 50,
          status: 'completed',
          createdAt: '2025-10-11T09:00:00Z',
          updatedAt: '2025-10-11T09:50:00Z',
        ));

        final dives = await dbService.getAllDives();
        expect(dives.length, 2);
        expect(dives[0].date, '2025-10-11'); // Most recent first
        expect(dives[1].date, '2025-10-10');
      });

      test('should exclude in_progress dives from getAllDives', () async {
        await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        ));

        await dbService.insertDive(Dive(
          date: '2025-10-11',
          time: '09:00',
          maxDepth: 0.0,
          duration: 0,
          status: 'in_progress',
          createdAt: '2025-10-11T09:00:00Z',
          updatedAt: '2025-10-11T09:00:00Z',
        ));

        final dives = await dbService.getAllDives();
        expect(dives.length, 1);
        expect(dives[0].status, 'completed');
      });

      test('should get dive by ID', () async {
        final id = await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          country: 'Indonesia',
          diveSiteName: 'Blue Corner',
          maxDepth: 25.5,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        ));

        final dive = await dbService.getDive(id);
        expect(dive, isNotNull);
        expect(dive!.id, id);
        expect(dive.country, 'Indonesia');
        expect(dive.diveSiteName, 'Blue Corner');
      });

      test('should return null for non-existent dive ID', () async {
        final dive = await dbService.getDive(9999);
        expect(dive, isNull);
      });

      test('should get active dive', () async {
        final id = await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 0.0,
          duration: 0,
          status: 'in_progress',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T14:30:00Z',
        ));

        final activeDive = await dbService.getActiveDive();
        expect(activeDive, isNotNull);
        expect(activeDive!.id, id);
        expect(activeDive.status, 'in_progress');
      });

      test('should return null when no active dive', () async {
        final activeDive = await dbService.getActiveDive();
        expect(activeDive, isNull);
      });
    });

    group('Update Operations', () {
      test('should update dive successfully', () async {
        final id = await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 0.0,
          duration: 0,
          status: 'in_progress',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T14:30:00Z',
        ));

        final original = await dbService.getDive(id);
        final updated = original!.copyWith(
          maxDepth: 25.5,
          duration: 45,
          status: 'completed',
          updatedAt: '2025-10-10T15:15:00Z',
        );

        final rowsAffected = await dbService.updateDive(updated);
        expect(rowsAffected, 1);

        final retrieved = await dbService.getDive(id);
        expect(retrieved!.maxDepth, 25.5);
        expect(retrieved.duration, 45);
        expect(retrieved.status, 'completed');
      });

      test('should fail to update with invalid data', () async {
        final id = await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        ));

        final original = await dbService.getDive(id);
        final invalid = original!.copyWith(
          maxDepth: 500.0, // Invalid: over limit
        );

        expect(
          () => dbService.updateDive(invalid),
          throwsException,
        );
      });

      test('should fail to update dive without ID', () async {
        final dive = Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        );

        expect(
          () => dbService.updateDive(dive),
          throwsException,
        );
      });
    });

    group('Delete Operations', () {
      test('should delete dive successfully', () async {
        final id = await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        ));

        final rowsAffected = await dbService.deleteDive(id);
        expect(rowsAffected, 1);

        final deleted = await dbService.getDive(id);
        expect(deleted, isNull);
      });

      test('should return 0 when deleting non-existent dive', () async {
        final rowsAffected = await dbService.deleteDive(9999);
        expect(rowsAffected, 0);
      });
    });

    group('Search and Filter Operations', () {
      setUp(() async {
        // Insert test data
        await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          country: 'Indonesia',
          diveSiteName: 'Blue Corner',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        ));

        await dbService.insertDive(Dive(
          date: '2025-10-11',
          time: '09:00',
          country: 'Thailand',
          diveSiteName: 'Richelieu Rock',
          maxDepth: 30.0,
          duration: 50,
          status: 'completed',
          createdAt: '2025-10-11T09:00:00Z',
          updatedAt: '2025-10-11T09:50:00Z',
        ));

        await dbService.insertDive(Dive(
          date: '2025-10-12',
          time: '11:00',
          country: 'Indonesia',
          diveSiteName: 'Manta Point',
          maxDepth: 20.0,
          duration: 40,
          status: 'completed',
          createdAt: '2025-10-12T11:00:00Z',
          updatedAt: '2025-10-12T11:40:00Z',
        ));
      });

      test('should search dives by country', () async {
        final results = await dbService.searchDivesByLocation('Indonesia');
        expect(results.length, 2);
        expect(results.every((d) => d.country == 'Indonesia'), true);
      });

      test('should search dives by dive site name', () async {
        final results = await dbService.searchDivesByLocation('Richelieu');
        expect(results.length, 1);
        expect(results[0].diveSiteName, 'Richelieu Rock');
      });

      test('should return empty list for no matches', () async {
        final results = await dbService.searchDivesByLocation('Egypt');
        expect(results.length, 0);
      });

      test('should get dives by date range', () async {
        final results = await dbService.getDivesByDateRange(
          '2025-10-10',
          '2025-10-11',
        );
        expect(results.length, 2);
      });
    });

    group('Statistics Operations', () {
      setUp(() async {
        // Insert test data
        await dbService.insertDive(Dive(
          date: '2025-10-10',
          time: '14:30',
          maxDepth: 25.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T14:30:00Z',
          updatedAt: '2025-10-10T15:15:00Z',
        ));

        await dbService.insertDive(Dive(
          date: '2025-10-11',
          time: '09:00',
          maxDepth: 30.0,
          duration: 50,
          status: 'completed',
          createdAt: '2025-10-11T09:00:00Z',
          updatedAt: '2025-10-11T09:50:00Z',
        ));

        await dbService.insertDive(Dive(
          date: '2025-10-12',
          time: '11:00',
          maxDepth: 20.0,
          duration: 40,
          status: 'completed',
          createdAt: '2025-10-12T11:00:00Z',
          updatedAt: '2025-10-12T11:40:00Z',
        ));
      });

      test('should calculate dive statistics correctly', () async {
        final stats = await dbService.getDiveStatistics();

        expect(stats['total_dives'], 3);
        expect(stats['deepest_dive'], 30.0);
        expect(stats['total_dive_time'], 135); // 45 + 50 + 40
        expect((stats['avg_depth'] as double).roundToDouble(), 25.0);
      });

      test('should group dives by country', () async {
        await dbService.insertDive(Dive(
          date: '2025-10-13',
          time: '10:00',
          country: 'Indonesia',
          maxDepth: 28.0,
          duration: 48,
          status: 'completed',
          createdAt: '2025-10-13T10:00:00Z',
          updatedAt: '2025-10-13T10:48:00Z',
        ));

        await dbService.insertDive(Dive(
          date: '2025-10-14',
          time: '11:00',
          country: 'Indonesia',
          maxDepth: 22.0,
          duration: 42,
          status: 'completed',
          createdAt: '2025-10-14T11:00:00Z',
          updatedAt: '2025-10-14T11:42:00Z',
        ));

        final byCountry = await dbService.getDivesByCountry();

        expect(byCountry.length, 1);
        expect(byCountry[0]['country'], 'Indonesia');
        expect(byCountry[0]['dive_count'], 2);
      });
    });
  });
}
