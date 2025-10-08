# Architecture Documentation

## Directory Structure

```
lib/
  ├── main.dart           # App entry point
  ├── models/             # Data models
  ├── services/           # Business logic
  ├── screens/            # UI screens
  └── widgets/            # Reusable UI components
```

## Module Breakdown

### **main.dart** (Entry Point)
- **Purpose**: Initializes the Flutter app and sets up routing/navigation
- **Usage**: Runs the app, defines theme, and specifies the home screen
- **Contains**: `main()` function and root `MaterialApp` widget

### **models/** (Data Layer)
- **Purpose**: Define data structures and their serialization logic
- **Usage**: Represents dive log entries with all their properties
- **Example**: `Dive` class with fields like `id`, `date`, `location`, `maxDepth`, `duration`, `notes`
- **Why needed**: Type-safe data representation, JSON/SQLite serialization methods (`toMap()`, `fromMap()`)

### **services/** (Business Logic Layer)
- **Purpose**: Handle database operations and business rules
- **Usage**: All SQLite CRUD operations for dive logs
- **Example**: `DatabaseService` - initialize DB, create/read/update/delete dives
- **Why needed**: Separates data persistence logic from UI, makes code testable and reusable

### **screens/** (Presentation Layer)
- **Purpose**: Full-page UI views that users navigate between
- **Usage**: Main app pages
- **Examples**:
  - `DiveListScreen` - displays all dive logs
  - `DiveFormScreen` - add/edit dive entries
- **Why needed**: Organizes major UI flows, handles user navigation

### **widgets/** (Reusable Components)
- **Purpose**: Small, reusable UI pieces used across screens
- **Usage**: Building blocks for screens
- **Example**: `DiveCard` - displays summary of a single dive in the list
- **Why needed**: DRY principle, consistent UI, easier maintenance

## Data Flow Example

1. **User opens app** → `main.dart` launches `DiveListScreen`
2. **DiveListScreen** → Calls `DatabaseService` to fetch all dives
3. **DatabaseService** → Queries SQLite, returns list of `Dive` models
4. **DiveListScreen** → Uses `DiveCard` widgets to display each dive
5. **User taps "Add"** → Navigate to `DiveFormScreen`
6. **DiveFormScreen** → User fills form, taps save
7. **DiveFormScreen** → Calls `DatabaseService.insertDive()` with new `Dive` model
8. **DatabaseService** → Saves to SQLite, returns to `DiveListScreen`

## Architecture Benefits

This separation follows **separation of concerns** - each layer has a single responsibility:

- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes to one layer don't affect others
- **Scalability**: Easy to add new features without refactoring
- **Reusability**: Services and widgets can be used across multiple screens
