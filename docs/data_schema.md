# Data Schema Documentation

## Overview
This document defines the complete data schema for the Simple Dive Logger application. The app uses SQLite for local storage with no server connectivity.

## Design Philosophy

### Key Principles
1. **Local-Only Storage**: All data persists on device using SQLite
2. **Offline-First**: No network dependency for core functionality
3. **Simple & Scalable**: Start minimal, designed for future extensions
4. **Data Integrity**: Proper constraints, validation, and indexing
5. **User Workflow Support**: Schema supports Begin → End → Log → Edit flow

### Storage Technology
- **Database**: SQLite via `sqflite` package
- **Location**: Local device storage via `path_provider`
- **Version Management**: Database migrations for schema updates
- **Access Pattern**: Singleton DatabaseService for consistency

---

## Database Schema

### Table: `dives`

Primary table storing all dive log information.

```sql
CREATE TABLE dives (
  -- Primary Key
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- Dive Timing
  date TEXT NOT NULL,                    -- ISO 8601 date (YYYY-MM-DD)
  time TEXT NOT NULL,                    -- 24-hour time (HH:MM)

  -- Dive Location (all optional for flexibility)
  country TEXT,                          -- Country name
  dive_site_name TEXT,                   -- Dive site name
  latitude REAL,                         -- GPS latitude (-90 to 90)
  longitude REAL,                        -- GPS longitude (-180 to 180)

  -- Dive Measurements
  max_depth REAL NOT NULL,               -- Maximum depth in meters
  duration INTEGER NOT NULL,             -- Dive duration in minutes

  -- Environmental Conditions (Optional)
  water_temperature REAL,                -- Water temp in Celsius
  visibility TEXT,                       -- Visibility (Excellent/Good/Fair/Poor)

  -- User Notes
  notes TEXT,                            -- User observations and comments

  -- Dive Status
  status TEXT NOT NULL DEFAULT 'completed',  -- 'in_progress' or 'completed'

  -- Metadata
  created_at TEXT NOT NULL,              -- ISO 8601 timestamp
  updated_at TEXT NOT NULL,              -- ISO 8601 timestamp

  -- Constraints
  CHECK(max_depth >= 0),
  CHECK(duration > 0),
  CHECK(status IN ('in_progress', 'completed'))
);
```

### Indexes

Optimize query performance for common access patterns:

```sql
-- Index for sorting dives by date (most recent first)
CREATE INDEX idx_dives_date ON dives(date DESC, time DESC);

-- Index for filtering by status (finding active dive)
CREATE INDEX idx_dives_status ON dives(status);

-- Index for location-based searches
CREATE INDEX idx_dives_country ON dives(country);
CREATE INDEX idx_dives_site_name ON dives(dive_site_name);
```

---

## Field Specifications

### Required Fields

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| `id` | INTEGER | - | PRIMARY KEY, AUTO INCREMENT | Unique identifier |
| `date` | TEXT | YYYY-MM-DD | ISO 8601 | Dive date |
| `time` | TEXT | HH:MM | 24-hour | Dive start time |
| `max_depth` | REAL | Number | ≥ 0, ≤ 300 meters | Maximum depth reached |
| `duration` | INTEGER | Minutes | > 0, ≤ 999 | Total dive time |
| `status` | TEXT | Enum | 'in_progress' or 'completed' | Dive completion state |
| `created_at` | TEXT | ISO 8601 | Timestamp | Record creation time |
| `updated_at` | TEXT | ISO 8601 | Timestamp | Last modification time |

### Optional Fields

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| `country` | TEXT | String | ≤ 100 chars | Country where dive took place |
| `dive_site_name` | TEXT | String | ≤ 200 chars | Name of dive site |
| `latitude` | REAL | Number | -90 to 90 | GPS latitude coordinate |
| `longitude` | REAL | Number | -180 to 180 | GPS longitude coordinate |
| `water_temperature` | REAL | Number | -2 to 40 Celsius | Water temperature |
| `visibility` | TEXT | Enum | Excellent/Good/Fair/Poor | Underwater visibility |
| `notes` | TEXT | String | ≤ 1000 chars | User notes and observations |

---

## Data Validation Rules

### Date & Time
- **Date**: Must be valid ISO 8601 date (YYYY-MM-DD)
- **Time**: Must be valid 24-hour time (HH:MM)
- **Future dates**: Allowed for planned dives, but typically current/past
- **Default values**: Current date and time when creating new dive

### Location Fields

All location fields are optional to provide maximum flexibility:

#### Country
- **Optional**: Can be null or empty
- **Length**: Maximum 100 characters
- **Format**: Free text (country name)
- **Examples**: "Indonesia", "Mexico", "Egypt", "United States"

#### Dive Site Name
- **Optional**: Can be null or empty
- **Length**: Maximum 200 characters
- **Format**: Free text (dive site or location name)
- **Examples**: "Blue Corner", "Catalina Island", "Cenote Dos Ojos", "SS Thistlegorm"

#### Latitude
- **Optional**: Can be null
- **Range**: -90 to 90 (degrees)
- **Precision**: REAL (floating point)
- **Format**: Decimal degrees
- **Example**: 7.2906 (Palau, Blue Corner)

#### Longitude
- **Optional**: Can be null
- **Range**: -180 to 180 (degrees)
- **Precision**: REAL (floating point)
- **Format**: Decimal degrees
- **Example**: 134.2347 (Palau, Blue Corner)

**Business Rules for Location:**
- At least one location field (country, dive_site_name, latitude, or longitude) should be provided for meaningful dive logs
- GPS coordinates (latitude/longitude) should be provided together or not at all
- Validation should warn if no location info is provided, but allow saving

### Max Depth
- **Required**: Must be a positive number
- **Range**: 0 to 300 meters (0 to 984 feet)
- **Precision**: Stored as REAL (floating point)
- **Units**: Always stored in meters (conversion to feet in UI layer)

### Duration
- **Required**: Must be a positive integer
- **Range**: 1 to 999 minutes
- **Format**: Integer (minutes)
- **Display**: Can show as HH:MM in UI (e.g., 65 minutes → 1:05)

### Water Temperature
- **Optional**: Can be null
- **Range**: -2 to 40 Celsius (-2°C for ice diving to 40°C for hot springs)
- **Precision**: REAL (floating point)
- **Units**: Always stored in Celsius (conversion to Fahrenheit in UI)

### Visibility
- **Optional**: Can be null
- **Format**: Text enumeration
- **Valid values**:
  - "Excellent" (> 30 meters)
  - "Good" (15-30 meters)
  - "Fair" (5-15 meters)
  - "Poor" (< 5 meters)

### Notes
- **Optional**: Can be null or empty
- **Length**: Maximum 1000 characters
- **Format**: Multi-line text
- **Content**: Pre-dive plans, marine life observations, equipment notes, etc.

### Status
- **Required**: Must be one of two values
- **Values**:
  - `"in_progress"`: Dive started but not completed (from Begin Dive screen)
  - `"completed"`: Dive finished (from End Dive screen)
- **Business rule**: Only ONE dive can be "in_progress" at a time
- **Default**: "completed" (for direct log entries)

---

## User Workflow Data States

### 1. Begin Dive (Create In-Progress Dive)
```dart
Dive(
  date: "2025-10-10",
  time: "09:30",
  country: "Palau",
  dive_site_name: "Blue Corner",
  latitude: 7.2906,
  longitude: 134.2347,
  max_depth: 0.0,              // Placeholder, updated on completion
  duration: 0,                 // Placeholder, updated on completion
  status: "in_progress",
  created_at: "2025-10-10T09:30:00Z",
  updated_at: "2025-10-10T09:30:00Z",
)
```

### 2. End Dive (Complete Active Dive)
```dart
// Update existing in_progress dive
Dive(
  id: 123,
  date: "2025-10-10",
  time: "09:30",
  country: "Palau",
  dive_site_name: "Blue Corner",
  latitude: 7.2906,
  longitude: 134.2347,
  max_depth: 28.5,             // Actual max depth
  duration: 42,                // Actual duration
  water_temperature: 26.0,     // Optional
  visibility: "Excellent",     // Optional
  notes: "Saw reef sharks...", // Optional
  status: "completed",         // Status changed
  created_at: "2025-10-10T09:30:00Z",
  updated_at: "2025-10-10T10:12:00Z",  // Updated timestamp
)
```

### 3. Direct Log Entry (Create Completed Dive)
```dart
// Add past dive directly
Dive(
  date: "2025-10-08",
  time: "14:00",
  country: "United States",
  dive_site_name: "Catalina Island",
  latitude: 33.3943,
  longitude: -118.4156,
  max_depth: 18.3,
  duration: 38,
  status: "completed",
  created_at: "2025-10-10T15:00:00Z",
  updated_at: "2025-10-10T15:00:00Z",
)
```

---

## Query Patterns

### Common Queries

#### 1. Get All Dives (Chronological)
```sql
SELECT * FROM dives
WHERE status = 'completed'
ORDER BY date DESC, time DESC;
```

#### 2. Find Active Dive
```sql
SELECT * FROM dives
WHERE status = 'in_progress'
LIMIT 1;
```

#### 3. Get Dive by ID
```sql
SELECT * FROM dives
WHERE id = ?;
```

#### 4. Search by Location
```sql
-- Search by country
SELECT * FROM dives
WHERE country LIKE ?
  AND status = 'completed'
ORDER BY date DESC, time DESC;

-- Search by dive site name
SELECT * FROM dives
WHERE dive_site_name LIKE ?
  AND status = 'completed'
ORDER BY date DESC, time DESC;

-- Search by any location field
SELECT * FROM dives
WHERE (country LIKE ? OR dive_site_name LIKE ?)
  AND status = 'completed'
ORDER BY date DESC, time DESC;
```

#### 5. Get Dives by Date Range
```sql
SELECT * FROM dives
WHERE date BETWEEN ? AND ?
  AND status = 'completed'
ORDER BY date DESC, time DESC;
```

### Aggregation Queries (Future Features)

#### Total Dive Statistics
```sql
SELECT
  COUNT(*) as total_dives,
  MAX(max_depth) as deepest_dive,
  SUM(duration) as total_dive_time,
  AVG(max_depth) as avg_depth
FROM dives
WHERE status = 'completed';
```

#### Dives by Location
```sql
-- By country
SELECT
  country,
  COUNT(*) as dive_count,
  AVG(max_depth) as avg_depth
FROM dives
WHERE status = 'completed' AND country IS NOT NULL
GROUP BY country
ORDER BY dive_count DESC;

-- By dive site
SELECT
  dive_site_name,
  country,
  COUNT(*) as dive_count,
  AVG(max_depth) as avg_depth
FROM dives
WHERE status = 'completed' AND dive_site_name IS NOT NULL
GROUP BY dive_site_name, country
ORDER BY dive_count DESC;
```

---

## Database Initialization

### Version 1 Schema Creation

```sql
-- Create dives table
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
  CHECK(duration > 0),
  CHECK(latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),
  CHECK(longitude IS NULL OR (longitude >= -180 AND longitude <= 180)),
  CHECK(status IN ('in_progress', 'completed'))
);

-- Create indexes
CREATE INDEX idx_dives_date ON dives(date DESC, time DESC);
CREATE INDEX idx_dives_status ON dives(status);
CREATE INDEX idx_dives_country ON dives(country);
CREATE INDEX idx_dives_site_name ON dives(dive_site_name);
```

### Migration Strategy

For future schema changes, use versioned migrations:

```dart
// Example migration from version 1 to 2
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add new column example
    await db.execute('ALTER TABLE dives ADD COLUMN buddy_name TEXT');
  }

  if (oldVersion < 3) {
    // Create new table example
    await db.execute('''
      CREATE TABLE dive_sites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        latitude REAL,
        longitude REAL
      )
    ''');
  }
}
```

---

## Data Model (Dart Class)

### Dive Model Structure

```dart
class Dive {
  final int? id;
  final String date;
  final String time;
  final String? country;
  final String? diveSiteName;
  final double? latitude;
  final double? longitude;
  final double maxDepth;
  final int duration;
  final double? waterTemperature;
  final String? visibility;
  final String? notes;
  final String status;
  final String createdAt;
  final String updatedAt;

  // Constructor, copyWith, toMap, fromMap methods
  // See lib/models/dive.dart for implementation
}
```

### Serialization Methods

#### To SQLite Map
```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'date': date,
    'time': time,
    'country': country,
    'dive_site_name': diveSiteName,
    'latitude': latitude,
    'longitude': longitude,
    'max_depth': maxDepth,
    'duration': duration,
    'water_temperature': waterTemperature,
    'visibility': visibility,
    'notes': notes,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
```

#### From SQLite Map
```dart
factory Dive.fromMap(Map<String, dynamic> map) {
  return Dive(
    id: map['id'],
    date: map['date'],
    time: map['time'],
    country: map['country'],
    diveSiteName: map['dive_site_name'],
    latitude: map['latitude'],
    longitude: map['longitude'],
    maxDepth: map['max_depth'],
    duration: map['duration'],
    waterTemperature: map['water_temperature'],
    visibility: map['visibility'],
    notes: map['notes'],
    status: map['status'] ?? 'completed',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
  );
}
```

---

## Future Schema Extensions

### Planned for V2+

#### 1. Dive Sites Table
```sql
CREATE TABLE dive_sites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  latitude REAL,
  longitude REAL,
  description TEXT,
  created_at TEXT NOT NULL
);

-- Add foreign key to dives
ALTER TABLE dives ADD COLUMN dive_site_id INTEGER REFERENCES dive_sites(id);
```

#### 2. Equipment Log
```sql
CREATE TABLE equipment (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dive_id INTEGER NOT NULL,
  item_type TEXT NOT NULL,  -- 'tank', 'suit', 'regulator', etc.
  item_name TEXT NOT NULL,
  FOREIGN KEY (dive_id) REFERENCES dives(id) ON DELETE CASCADE
);
```

#### 3. Dive Buddies
```sql
CREATE TABLE buddies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  certification_level TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE dive_buddies (
  dive_id INTEGER NOT NULL,
  buddy_id INTEGER NOT NULL,
  PRIMARY KEY (dive_id, buddy_id),
  FOREIGN KEY (dive_id) REFERENCES dives(id) ON DELETE CASCADE,
  FOREIGN KEY (buddy_id) REFERENCES buddies(id) ON DELETE CASCADE
);
```

#### 4. Photos/Media
```sql
CREATE TABLE dive_photos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dive_id INTEGER NOT NULL,
  file_path TEXT NOT NULL,
  caption TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (dive_id) REFERENCES dives(id) ON DELETE CASCADE
);
```

---

## Data Integrity & Constraints

### Business Rules

1. **Single Active Dive**: Only one dive can have `status = 'in_progress'` at a time
   - Enforced in application logic (DatabaseService)
   - Check before creating new in-progress dive

2. **Timestamp Management**:
   - `created_at`: Set once on insert, never changed
   - `updated_at`: Updated on every modification

3. **Depth & Duration**: Always positive non-zero values
   - Enforced via CHECK constraints in schema
   - Additional validation in Dart model

4. **Status Transitions**:
   - `in_progress` → `completed`: Normal completion flow
   - Direct `completed`: Manual log entry
   - No transition from `completed` → `in_progress`

### Validation Layers

1. **Database Level**: CHECK constraints for numeric ranges
2. **Model Level**: Dart validation in Dive class
3. **UI Level**: Form validation before submission
4. **Service Level**: Business logic in DatabaseService

---

## Performance Considerations

### Index Strategy
- **Date index**: Optimizes chronological sorting (primary use case)
- **Status index**: Fast lookup for active dive (frequently checked)
- **Country index**: Enables filtering by country
- **Dive site index**: Enables search by dive site name

### Query Optimization
- Use prepared statements for all queries (sqflite does this automatically)
- Limit result sets where appropriate (e.g., LIMIT in active dive query)
- Avoid SELECT * in production (specify needed columns)

### Storage Estimates
- **Average dive record**: ~500 bytes
- **100 dives**: ~50 KB
- **1000 dives**: ~500 KB
- **10,000 dives**: ~5 MB
- Conclusion: Local storage is not a concern for typical users

---

## Sample Data

### Test Dive Records

```sql
-- Sample dive 1: Completed dive with full location
INSERT INTO dives (date, time, country, dive_site_name, latitude, longitude, max_depth, duration, water_temperature, visibility, notes, status, created_at, updated_at)
VALUES ('2025-10-10', '09:30', 'Palau', 'Blue Corner', 7.2906, 134.2347, 28.5, 42, 26.0, 'Excellent', 'Saw reef sharks and barracudas. Strong current at the corner.', 'completed', '2025-10-10T09:30:00Z', '2025-10-10T10:12:00Z');

-- Sample dive 2: Night dive with partial location (no GPS)
INSERT INTO dives (date, time, country, dive_site_name, max_depth, duration, water_temperature, visibility, notes, status, created_at, updated_at)
VALUES ('2025-10-09', '19:45', 'United States', 'Catalina Island', 15.2, 38, 18.5, 'Good', 'Night dive. Spotted octopus and lobsters.', 'completed', '2025-10-09T19:45:00Z', '2025-10-09T20:23:00Z');

-- Sample dive 3: Deep dive with full location
INSERT INTO dives (date, time, country, dive_site_name, latitude, longitude, max_depth, duration, water_temperature, visibility, notes, status, created_at, updated_at)
VALUES ('2025-10-08', '11:00', 'Cayman Islands', 'Grand Cayman Wall', 19.3133, -81.3857, 35.0, 35, 27.0, 'Excellent', 'Deep wall dive. Eagle rays at 30m.', 'completed', '2025-10-08T11:00:00Z', '2025-10-08T11:35:00Z');

-- Sample dive 4: In-progress dive
INSERT INTO dives (date, time, dive_site_name, max_depth, duration, status, created_at, updated_at)
VALUES ('2025-10-11', '10:00', 'Coral Gardens', 0.0, 0, 'in_progress', '2025-10-11T10:00:00Z', '2025-10-11T10:00:00Z');

-- Sample dive 5: Minimal location (country only)
INSERT INTO dives (date, time, country, max_depth, duration, status, created_at, updated_at)
VALUES ('2025-10-07', '14:30', 'Indonesia', 22.0, 45, 'completed', '2025-10-07T14:30:00Z', '2025-10-07T15:15:00Z');
```

---

## Summary

### Schema Highlights
✅ **Single table design** for MVP simplicity
✅ **Extensible structure** ready for V2 features
✅ **Proper indexing** for common queries
✅ **Data integrity** via constraints and validation
✅ **Workflow support** for Begin → End → Log flow
✅ **Performance optimized** for local storage

### Key Design Decisions
1. **ISO 8601 dates/times**: Standard format, easy parsing
2. **Metric storage**: Store in meters/Celsius, convert in UI
3. **Text enums**: Visibility as text for readability
4. **Status field**: Supports active dive workflow
5. **Nullable optionals**: Flexibility for partial data

---

---

## Location Data Design Rationale

### Why All Location Fields Are Optional

1. **Flexibility**: Users may only know the country, or just the dive site name
2. **Privacy**: Some users may not want to record exact GPS coordinates
3. **Retrospective Logging**: Historical dives may have incomplete location data
4. **Progressive Enhancement**: Users can start simple and add details later

### Location Display Logic

When displaying dive locations in the UI, use this priority:
1. If `dive_site_name` exists: Show dive site name
2. If `country` exists: Append country (e.g., "Blue Corner, Palau")
3. If GPS coordinates exist: Show on map or display coordinates
4. If no location data: Show "Location not specified"

### Future Enhancements

- **Reverse Geocoding**: Use GPS coordinates to auto-fill country/site name
- **Dive Site Database**: Pre-populated dive sites with GPS data
- **Map Integration**: Display dive locations on a world map
- **Location Autocomplete**: Suggest dive sites as user types

---

**Document Version**: 2.0
**Last Updated**: 2025-10-10
**Status**: Updated with Structured Location Fields
