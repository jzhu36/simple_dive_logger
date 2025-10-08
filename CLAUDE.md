# Simple Dive Logger

## Project Overview
A local-only mobile application for logging scuba diving activities. All data is stored locally on the device with no server connection required.

## Tech Stack
- **Framework**: Flutter (Dart 3.9.2)
- **Platform**: Android (primary), iOS/macOS/Web/Windows/Linux (supported)
- **Database**: SQLite via sqflite package
- **Local Storage**: path_provider for file system access

## Architecture
Standard Flutter architecture:
```
lib/
  ├── main.dart           # App entry point
  ├── models/             # Data models (Dive, Location, etc.)
  ├── services/           # Business logic (database service)
  ├── screens/            # UI screens
  └── widgets/            # Reusable UI components
```

For detailed architecture documentation, see [docs/architecture.md](docs/architecture.md).

## Development Workflow

### Prerequisites
- Flutter SDK 3.35.5+
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Setup
```bash
# Clone the repository
git clone https://github.com/jzhu36/simple_dive_logger.git
cd simple_dive_logger

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Building
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Key Features (Planned)
- Create, read, update, delete dive logs
- Store dive details: date, time, location, depth, duration, conditions
- Browse dive history
- Local SQLite storage for offline access
- Simple, intuitive UI

## Database Schema
```sql
CREATE TABLE dives (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  location TEXT NOT NULL,
  max_depth REAL NOT NULL,
  duration INTEGER NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL
);
```

## Coding Conventions
- Follow Flutter/Dart style guide
- Use meaningful variable and function names
- Keep widgets small and focused
- Separate business logic from UI
- Use const constructors where possible for performance
- Prefer composition over inheritance

## Dependencies
- **sqflite**: Local SQLite database
- **path_provider**: Access to device file system
- **intl**: Date/time formatting
- **cupertino_icons**: iOS-style icons

## Project Organization
- Keep models in `lib/models/`
- Database operations in `lib/services/database_service.dart`
- UI screens in `lib/screens/`
- Reusable widgets in `lib/widgets/`

## Notes
- This is a local-only app with no network connectivity
- All data persists locally on the device
- No authentication or user accounts required
- Focus on simplicity and ease of use
