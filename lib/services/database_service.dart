import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dive.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dives.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database schema
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dives (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        country TEXT,
        dive_site_name TEXT,
        latitude REAL,
        longitude REAL,
        max_depth REAL NOT NULL,
        duration INTEGER NOT NULL,
        water_temperature REAL,
        visibility TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'completed',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        CHECK(max_depth >= 0),
        CHECK(duration >= 0),
        CHECK(latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),
        CHECK(longitude IS NULL OR (longitude >= -180 AND longitude <= 180)),
        CHECK(status IN ('in_progress', 'completed'))
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_dives_date ON dives(date DESC, time DESC)');
    await db.execute('CREATE INDEX idx_dives_status ON dives(status)');
    await db.execute('CREATE INDEX idx_dives_country ON dives(country)');
    await db
        .execute('CREATE INDEX idx_dives_site_name ON dives(dive_site_name)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will go here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE dives ADD COLUMN buddy_name TEXT');
    // }
  }

  /// Insert a new dive
  Future<int> insertDive(Dive dive) async {
    final db = await database;

    // Validate dive data
    final validationError = dive.validate();
    if (validationError != null) {
      throw Exception('Validation error: $validationError');
    }

    // Allow multiple in-progress dives (removed check)
    // Users can have multiple unfinished dives started

    return await db.insert('dives', dive.toMap());
  }

  /// Get all completed dives (sorted by date, most recent first)
  Future<List<Dive>> getAllDives() async {
    final db = await database;
    final result = await db.query(
      'dives',
      where: 'status = ?',
      whereArgs: ['completed'],
      orderBy: 'date DESC, time DESC',
    );

    return result.map((map) => Dive.fromMap(map)).toList();
  }

  /// Get dive by ID
  Future<Dive?> getDive(int id) async {
    final db = await database;
    final result = await db.query(
      'dives',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Dive.fromMap(result.first);
    }
    return null;
  }

  /// Get the currently active dive (in_progress status)
  Future<Dive?> getActiveDive() async {
    final db = await database;
    final result = await db.query(
      'dives',
      where: 'status = ?',
      whereArgs: ['in_progress'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Dive.fromMap(result.first);
    }
    return null;
  }

  /// Update an existing dive
  Future<int> updateDive(Dive dive) async {
    final db = await database;

    // Validate dive data
    final validationError = dive.validate();
    if (validationError != null) {
      throw Exception('Validation error: $validationError');
    }

    if (dive.id == null) {
      throw Exception('Cannot update dive without an ID');
    }

    return await db.update(
      'dives',
      dive.toMap(),
      where: 'id = ?',
      whereArgs: [dive.id],
    );
  }

  /// Delete a dive
  Future<int> deleteDive(int id) async {
    final db = await database;
    return await db.delete(
      'dives',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Search dives by location (country or dive site name)
  Future<List<Dive>> searchDivesByLocation(String searchTerm) async {
    final db = await database;
    final result = await db.query(
      'dives',
      where: '(country LIKE ? OR dive_site_name LIKE ?) AND status = ?',
      whereArgs: ['%$searchTerm%', '%$searchTerm%', 'completed'],
      orderBy: 'date DESC, time DESC',
    );

    return result.map((map) => Dive.fromMap(map)).toList();
  }

  /// Get dives by date range
  Future<List<Dive>> getDivesByDateRange(String startDate, String endDate) async {
    final db = await database;
    final result = await db.query(
      'dives',
      where: 'date BETWEEN ? AND ? AND status = ?',
      whereArgs: [startDate, endDate, 'completed'],
      orderBy: 'date DESC, time DESC',
    );

    return result.map((map) => Dive.fromMap(map)).toList();
  }

  /// Get dive statistics
  Future<Map<String, dynamic>> getDiveStatistics() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_dives,
        MAX(max_depth) as deepest_dive,
        SUM(duration) as total_dive_time,
        AVG(max_depth) as avg_depth
      FROM dives
      WHERE status = 'completed'
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }
    return {
      'total_dives': 0,
      'deepest_dive': 0.0,
      'total_dive_time': 0,
      'avg_depth': 0.0,
    };
  }

  /// Get dives grouped by country
  Future<List<Map<String, dynamic>>> getDivesByCountry() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        country,
        COUNT(*) as dive_count,
        AVG(max_depth) as avg_depth
      FROM dives
      WHERE status = 'completed' AND country IS NOT NULL
      GROUP BY country
      ORDER BY dive_count DESC
    ''');

    return result;
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
