import 'package:flutter_test/flutter_test.dart';
import 'package:simple_dive_logger/models/dive.dart';

void main() {
  group('Dive Model Tests', () {
    late Dive testDive;

    setUp(() {
      testDive = Dive(
        id: 1,
        date: '2025-10-10',
        time: '14:30',
        country: 'Indonesia',
        diveSiteName: 'Blue Corner',
        latitude: -8.3405,
        longitude: 115.0920,
        maxDepth: 25.5,
        duration: 45,
        waterTemperature: 28.0,
        visibility: 'Excellent',
        notes: 'Saw manta rays',
        status: 'completed',
        createdAt: '2025-10-10T14:30:00Z',
        updatedAt: '2025-10-10T15:15:00Z',
      );
    });

    test('should create Dive with all fields', () {
      expect(testDive.id, 1);
      expect(testDive.date, '2025-10-10');
      expect(testDive.time, '14:30');
      expect(testDive.country, 'Indonesia');
      expect(testDive.diveSiteName, 'Blue Corner');
      expect(testDive.latitude, -8.3405);
      expect(testDive.longitude, 115.0920);
      expect(testDive.maxDepth, 25.5);
      expect(testDive.duration, 45);
      expect(testDive.waterTemperature, 28.0);
      expect(testDive.visibility, 'Excellent');
      expect(testDive.notes, 'Saw manta rays');
      expect(testDive.status, 'completed');
    });

    test('should create Dive with minimal required fields', () {
      final minimalDive = Dive(
        date: '2025-10-10',
        time: '10:00',
        maxDepth: 15.0,
        duration: 30,
        status: 'in_progress',
        createdAt: '2025-10-10T10:00:00Z',
        updatedAt: '2025-10-10T10:00:00Z',
      );

      expect(minimalDive.id, null);
      expect(minimalDive.country, null);
      expect(minimalDive.diveSiteName, null);
      expect(minimalDive.latitude, null);
      expect(minimalDive.longitude, null);
      expect(minimalDive.waterTemperature, null);
      expect(minimalDive.visibility, null);
      expect(minimalDive.notes, null);
    });

    group('Serialization', () {
      test('toMap() should convert Dive to Map correctly', () {
        final map = testDive.toMap();

        expect(map['id'], 1);
        expect(map['date'], '2025-10-10');
        expect(map['time'], '14:30');
        expect(map['country'], 'Indonesia');
        expect(map['dive_site_name'], 'Blue Corner');
        expect(map['latitude'], -8.3405);
        expect(map['longitude'], 115.0920);
        expect(map['max_depth'], 25.5);
        expect(map['duration'], 45);
        expect(map['water_temperature'], 28.0);
        expect(map['visibility'], 'Excellent');
        expect(map['notes'], 'Saw manta rays');
        expect(map['status'], 'completed');
        expect(map['created_at'], '2025-10-10T14:30:00Z');
        expect(map['updated_at'], '2025-10-10T15:15:00Z');
      });

      test('fromMap() should create Dive from Map correctly', () {
        final map = {
          'id': 2,
          'date': '2025-10-11',
          'time': '09:00',
          'country': 'Thailand',
          'dive_site_name': 'Richelieu Rock',
          'latitude': 9.5833,
          'longitude': 98.2167,
          'max_depth': 30.0,
          'duration': 50,
          'water_temperature': 27.0,
          'visibility': 'Good',
          'notes': 'Whale shark spotted',
          'status': 'completed',
          'created_at': '2025-10-11T09:00:00Z',
          'updated_at': '2025-10-11T09:50:00Z',
        };

        final dive = Dive.fromMap(map);

        expect(dive.id, 2);
        expect(dive.date, '2025-10-11');
        expect(dive.time, '09:00');
        expect(dive.country, 'Thailand');
        expect(dive.diveSiteName, 'Richelieu Rock');
        expect(dive.latitude, 9.5833);
        expect(dive.longitude, 98.2167);
        expect(dive.maxDepth, 30.0);
        expect(dive.duration, 50);
        expect(dive.waterTemperature, 27.0);
        expect(dive.visibility, 'Good');
        expect(dive.notes, 'Whale shark spotted');
        expect(dive.status, 'completed');
      });

      test('fromMap() should handle missing optional fields', () {
        final map = {
          'id': 3,
          'date': '2025-10-12',
          'time': '11:00',
          'max_depth': 20.0,
          'duration': 35,
          'status': 'in_progress',
          'created_at': '2025-10-12T11:00:00Z',
          'updated_at': '2025-10-12T11:00:00Z',
        };

        final dive = Dive.fromMap(map);

        expect(dive.country, null);
        expect(dive.diveSiteName, null);
        expect(dive.latitude, null);
        expect(dive.longitude, null);
        expect(dive.waterTemperature, null);
        expect(dive.visibility, null);
        expect(dive.notes, null);
      });

      test('fromMap() should default status to "completed" if missing', () {
        final map = {
          'id': 4,
          'date': '2025-10-13',
          'time': '12:00',
          'max_depth': 18.0,
          'duration': 40,
          'created_at': '2025-10-13T12:00:00Z',
          'updated_at': '2025-10-13T12:40:00Z',
        };

        final dive = Dive.fromMap(map);
        expect(dive.status, 'completed');
      });

      test('should maintain data through serialization round-trip', () {
        final map = testDive.toMap();
        final reconstructed = Dive.fromMap(map);

        expect(reconstructed.id, testDive.id);
        expect(reconstructed.date, testDive.date);
        expect(reconstructed.time, testDive.time);
        expect(reconstructed.country, testDive.country);
        expect(reconstructed.diveSiteName, testDive.diveSiteName);
        expect(reconstructed.latitude, testDive.latitude);
        expect(reconstructed.longitude, testDive.longitude);
        expect(reconstructed.maxDepth, testDive.maxDepth);
        expect(reconstructed.duration, testDive.duration);
        expect(reconstructed.waterTemperature, testDive.waterTemperature);
        expect(reconstructed.visibility, testDive.visibility);
        expect(reconstructed.notes, testDive.notes);
        expect(reconstructed.status, testDive.status);
      });
    });

    group('copyWith()', () {
      test('should create copy with updated fields', () {
        final updated = testDive.copyWith(
          maxDepth: 30.0,
          duration: 50,
          status: 'completed',
        );

        expect(updated.maxDepth, 30.0);
        expect(updated.duration, 50);
        expect(updated.status, 'completed');
        // Other fields should remain unchanged
        expect(updated.id, testDive.id);
        expect(updated.country, testDive.country);
      });

      test('should keep original values when no updates provided', () {
        final copy = testDive.copyWith();

        expect(copy.id, testDive.id);
        expect(copy.date, testDive.date);
        expect(copy.maxDepth, testDive.maxDepth);
        expect(copy.status, testDive.status);
      });
    });

    group('getLocationDisplay()', () {
      test('should display dive site and country when both present', () {
        final dive = Dive(
          date: '2025-10-10',
          time: '10:00',
          country: 'Egypt',
          diveSiteName: 'SS Thistlegorm',
          maxDepth: 30.0,
          duration: 45,
          status: 'completed',
          createdAt: '2025-10-10T10:00:00Z',
          updatedAt: '2025-10-10T10:45:00Z',
        );

        expect(dive.getLocationDisplay(), 'SS Thistlegorm, Egypt');
      });

      test('should display only dive site when country missing', () {
        final dive = Dive(
          date: '2025-10-10',
          time: '10:00',
          diveSiteName: 'Local Reef',
          maxDepth: 15.0,
          duration: 30,
          status: 'completed',
          createdAt: '2025-10-10T10:00:00Z',
          updatedAt: '2025-10-10T10:30:00Z',
        );

        expect(dive.getLocationDisplay(), 'Local Reef');
      });

      test('should display only country when dive site missing', () {
        final dive = Dive(
          date: '2025-10-10',
          time: '10:00',
          country: 'Maldives',
          maxDepth: 20.0,
          duration: 35,
          status: 'completed',
          createdAt: '2025-10-10T10:00:00Z',
          updatedAt: '2025-10-10T10:35:00Z',
        );

        expect(dive.getLocationDisplay(), 'Maldives');
      });

      test('should display GPS coordinates when location names missing', () {
        final dive = Dive(
          date: '2025-10-10',
          time: '10:00',
          latitude: 7.2906,
          longitude: 134.2347,
          maxDepth: 25.0,
          duration: 40,
          status: 'completed',
          createdAt: '2025-10-10T10:00:00Z',
          updatedAt: '2025-10-10T10:40:00Z',
        );

        expect(dive.getLocationDisplay(), '7.2906, 134.2347');
      });

      test('should display "Location not specified" when no location data', () {
        final dive = Dive(
          date: '2025-10-10',
          time: '10:00',
          maxDepth: 10.0,
          duration: 25,
          status: 'completed',
          createdAt: '2025-10-10T10:00:00Z',
          updatedAt: '2025-10-10T10:25:00Z',
        );

        expect(dive.getLocationDisplay(), 'Location not specified');
      });
    });

    group('validate()', () {
      test('should return null for valid dive', () {
        expect(testDive.validate(), null);
      });

      test('should reject negative max depth', () {
        final invalidDive = testDive.copyWith(maxDepth: -5.0);
        expect(
          invalidDive.validate(),
          'Max depth must be between 0 and 300 meters',
        );
      });

      test('should reject max depth over 300 meters', () {
        final invalidDive = testDive.copyWith(maxDepth: 350.0);
        expect(
          invalidDive.validate(),
          'Max depth must be between 0 and 300 meters',
        );
      });

      test('should accept max depth of 0', () {
        final validDive = testDive.copyWith(maxDepth: 0.0);
        expect(validDive.validate(), null);
      });

      test('should accept max depth of 300', () {
        final validDive = testDive.copyWith(maxDepth: 300.0);
        expect(validDive.validate(), null);
      });

      test('should reject negative duration', () {
        final invalidDive = testDive.copyWith(duration: -10);
        expect(
          invalidDive.validate(),
          'Duration must be between 0 and 999 minutes',
        );
      });

      test('should reject duration over 999 minutes', () {
        final invalidDive = testDive.copyWith(duration: 1000);
        expect(
          invalidDive.validate(),
          'Duration must be between 0 and 999 minutes',
        );
      });

      test('should reject water temperature below -2°C', () {
        final invalidDive = testDive.copyWith(waterTemperature: -3.0);
        expect(
          invalidDive.validate(),
          'Water temperature must be between -2 and 40°C',
        );
      });

      test('should reject water temperature above 40°C', () {
        final invalidDive = testDive.copyWith(waterTemperature: 45.0);
        expect(
          invalidDive.validate(),
          'Water temperature must be between -2 and 40°C',
        );
      });

      test('should accept water temperature of -2°C (ice diving)', () {
        final validDive = testDive.copyWith(waterTemperature: -2.0);
        expect(validDive.validate(), null);
      });

      test('should accept water temperature of 40°C', () {
        final validDive = testDive.copyWith(waterTemperature: 40.0);
        expect(validDive.validate(), null);
      });

      test('should reject latitude below -90', () {
        final invalidDive = testDive.copyWith(latitude: -95.0);
        expect(
          invalidDive.validate(),
          'Latitude must be between -90 and 90',
        );
      });

      test('should reject latitude above 90', () {
        final invalidDive = testDive.copyWith(latitude: 95.0);
        expect(
          invalidDive.validate(),
          'Latitude must be between -90 and 90',
        );
      });

      test('should reject longitude below -180', () {
        final invalidDive = testDive.copyWith(longitude: -185.0);
        expect(
          invalidDive.validate(),
          'Longitude must be between -180 and 180',
        );
      });

      test('should reject longitude above 180', () {
        final invalidDive = testDive.copyWith(longitude: 185.0);
        expect(
          invalidDive.validate(),
          'Longitude must be between -180 and 180',
        );
      });

      test('should reject invalid status', () {
        final invalidDive = testDive.copyWith(status: 'invalid_status');
        expect(
          invalidDive.validate(),
          'Status must be either "in_progress" or "completed"',
        );
      });

      test('should accept "in_progress" status', () {
        final validDive = testDive.copyWith(status: 'in_progress');
        expect(validDive.validate(), null);
      });

      test('should accept "completed" status', () {
        final validDive = testDive.copyWith(status: 'completed');
        expect(validDive.validate(), null);
      });
    });

    group('toString()', () {
      test('should produce readable string representation', () {
        final str = testDive.toString();

        expect(str, contains('id: 1'));
        expect(str, contains('date: 2025-10-10'));
        expect(str, contains('time: 14:30'));
        expect(str, contains('location: Blue Corner, Indonesia'));
        expect(str, contains('maxDepth: 25.5'));
        expect(str, contains('duration: 45'));
        expect(str, contains('status: completed'));
      });
    });
  });
}
