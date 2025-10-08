# Simple Dive Logger

A local-only mobile application for scuba divers to log their diving activities. All data is stored locally on your device with no internet connection required.

## Features

- Log dive details (date, location, depth, duration, conditions)
- Browse dive history
- Offline-first: all data stored locally using SQLite
- Simple and intuitive interface

## Prerequisites

- Flutter SDK 3.35.5 or higher
- Dart 3.9.2 or higher
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/jzhu36/simple_dive_logger.git
   cd simple_dive_logger
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   ```bash
   # For development
   flutter run

   # Or select a specific device
   flutter devices
   flutter run -d <device-id>
   ```

## Building

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Project Structure

```
lib/
  ├── main.dart           # App entry point
  ├── models/             # Data models
  ├── services/           # Business logic & database
  ├── screens/            # UI screens
  └── widgets/            # Reusable components
```

## Development

### Running Tests
```bash
flutter test
```

### Code Formatting
```bash
dart format .
```

### Code Analysis
```bash
flutter analyze
```

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **Database**: SQLite (via sqflite)
- **Storage**: Local file system (via path_provider)

## Contributing

This is a personal project. Feel free to fork and customize for your own use.

## License

MIT License - feel free to use this project as you wish.
