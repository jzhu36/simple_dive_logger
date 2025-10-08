# Simple Dive Logger - MVP Engineering Plan

## Overview
This document outlines the MVP (Minimum Viable Product) implementation plan for the Simple Dive Logger Android application. The app is a local-only dive logging solution with UI design provided in Figma.

## Platform
- **Target Platform**: Android (primary)
- **Framework**: Flutter
- **Database**: SQLite (local storage)
- **UI Design**: Figma (link to be added)

---

## MVP Features

### Core Functionality
1. **Dive Log List**
   - View all logged dives in chronological order (newest first)
   - Display key info: date, location, depth, duration
   - Empty state when no dives exist
   - Pull-to-refresh capability

2. **Add Dive Log**
   - Create new dive entry
   - Required fields:
     - Date & time
     - Dive location
     - Maximum depth (meters/feet)
     - Dive duration (minutes)
   - Optional fields:
     - Water temperature
     - Visibility
     - Notes/comments
   - Form validation
   - Save to local database

3. **View Dive Details**
   - Display all dive information
   - Read-only view of complete dive data

4. **Edit Dive Log**
   - Modify existing dive entries
   - Same form as add, pre-populated with existing data
   - Update database

5. **Delete Dive Log**
   - Remove dive from database
   - Confirmation dialog before deletion

### Out of Scope (Future Versions)
- Photo/media attachments
- Dive buddy tracking
- Equipment logging
- Dive site database with coordinates
- Statistics and analytics
- Export/import data
- Cloud sync
- Multi-user support

---

## Database Schema

### `dives` Table
```sql
CREATE TABLE dives (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,                  -- ISO 8601 format
  time TEXT NOT NULL,                  -- HH:MM format
  location TEXT NOT NULL,
  max_depth REAL NOT NULL,             -- in meters
  duration INTEGER NOT NULL,           -- in minutes
  water_temperature REAL,              -- in celsius, optional
  visibility REAL,                     -- in meters, optional
  notes TEXT,                          -- optional
  created_at TEXT NOT NULL,            -- ISO 8601 timestamp
  updated_at TEXT NOT NULL             -- ISO 8601 timestamp
);
```

### Indexes
```sql
CREATE INDEX idx_dives_date ON dives(date DESC);
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── dive.dart                      # Dive model class
├── services/
│   └── database_service.dart          # SQLite operations
├── screens/
│   ├── dive_list_screen.dart          # Home screen - list of dives
│   ├── dive_detail_screen.dart        # View dive details
│   └── dive_form_screen.dart          # Add/edit dive form
└── widgets/
    ├── dive_list_item.dart            # Dive card in list
    └── empty_state.dart               # Empty state widget

docs/
└── mvp_eng_plan.md                    # This document

test/
├── models/
│   └── dive_test.dart
├── services/
│   └── database_service_test.dart
└── widgets/
    └── dive_list_item_test.dart
```

---

## Implementation Plan

### Phase 1: Foundation (Days 1-2)
**Goal**: Set up data layer and core models

1. **Create Dive Model** (`lib/models/dive.dart`)
   - Define Dive class with all properties
   - Add `toMap()` and `fromMap()` methods for SQLite
   - Add validation methods
   - Include `copyWith()` for immutability

2. **Implement Database Service** (`lib/services/database_service.dart`)
   - Initialize SQLite database
   - Create tables and indexes
   - Implement CRUD operations:
     - `Future<int> insertDive(Dive dive)`
     - `Future<List<Dive>> getAllDives()`
     - `Future<Dive?> getDive(int id)`
     - `Future<int> updateDive(Dive dive)`
     - `Future<int> deleteDive(int id)`
   - Add database version management
   - Singleton pattern for database access

3. **Write Unit Tests**
   - Test Dive model serialization/deserialization
   - Test database CRUD operations
   - Test edge cases and validation

### Phase 2: UI Screens (Days 3-5)
**Goal**: Build core screens following Figma design

4. **Dive List Screen** (`lib/screens/dive_list_screen.dart`)
   - Scaffold with AppBar
   - FutureBuilder/StreamBuilder to load dives
   - ListView to display dives
   - FloatingActionButton to add new dive
   - Empty state when no dives
   - Pull-to-refresh
   - Navigate to detail on tap

5. **Dive List Item Widget** (`lib/widgets/dive_list_item.dart`)
   - Card-based design per Figma
   - Display: date, location, depth, duration
   - Tap gesture to open details
   - Implement according to Figma specs

6. **Dive Form Screen** (`lib/screens/dive_form_screen.dart`)
   - Reusable for Add and Edit modes
   - Form with TextFormFields
   - Date/Time pickers
   - Number input for depth/duration
   - Form validation
   - Save button
   - Cancel/back navigation
   - Keyboard handling

7. **Dive Detail Screen** (`lib/screens/dive_detail_screen.dart`)
   - Display all dive information
   - Edit button in AppBar
   - Delete button with confirmation
   - Navigate to edit form
   - Format data for readability

### Phase 3: Polish & Testing (Days 6-7)
**Goal**: Refine UX and ensure quality

8. **UI Polish**
   - Match Figma design precisely
   - Add loading indicators
   - Error handling and user feedback
   - Smooth animations/transitions
   - Responsive design for different screen sizes

9. **Integration Testing**
   - Test complete user flows
   - Add → View → Edit → Delete flow
   - Test form validation
   - Test edge cases (empty states, long text, etc.)

10. **Bug Fixes & Refinement**
    - Address any issues found in testing
    - Performance optimization
    - Code cleanup and documentation

### Phase 4: Figma Integration (TBD)
**Goal**: Implement exact design from Figma

11. **Review Figma Design**
    - Document all screens and components
    - Extract colors, fonts, spacing
    - Note any animations or interactions
    - Create theme constants

12. **Implement Design System**
    - Create `lib/theme/app_theme.dart`
    - Define colors, typography, spacing
    - Set up Material theme
    - Create reusable styled widgets

13. **Apply Design to Screens**
    - Update each screen to match Figma
    - Ensure pixel-perfect implementation
    - Test on actual Android devices

---

## Technical Specifications

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0          # SQLite database
  path_provider: ^2.1.1    # File system paths
  path: ^1.8.3             # Path manipulation
  intl: ^0.19.0            # Date/time formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Data Validation Rules

**Date & Time**
- Must not be in the future
- Default to current date/time

**Location**
- Required, non-empty string
- Max 200 characters

**Max Depth**
- Required, positive number
- Range: 0-300 meters (0-1000 feet)
- Support metric/imperial toggle (future)

**Duration**
- Required, positive integer
- Range: 1-999 minutes
- Display in MM:SS format

**Water Temperature**
- Optional, number
- Range: -2 to 40 celsius

**Visibility**
- Optional, positive number
- Range: 0-100 meters

**Notes**
- Optional, string
- Max 1000 characters

---

## User Flows

### Flow 1: Add New Dive
1. User taps FAB on home screen
2. Navigate to Dive Form Screen (Add mode)
3. User fills in dive details
4. User taps Save
5. Validate form
6. Save to database
7. Navigate back to list
8. Show success message
9. New dive appears at top of list

### Flow 2: View Dive Details
1. User taps dive card in list
2. Navigate to Dive Detail Screen
3. Display all dive information
4. User can tap Edit or Delete

### Flow 3: Edit Dive
1. From detail screen, user taps Edit
2. Navigate to Dive Form Screen (Edit mode)
3. Form pre-populated with existing data
4. User modifies fields
5. User taps Save
6. Validate form
7. Update database
8. Navigate back to detail screen
9. Show updated information

### Flow 4: Delete Dive
1. From detail screen, user taps Delete
2. Show confirmation dialog
3. If confirmed, delete from database
4. Navigate back to list
5. Show success message
6. Dive removed from list

---

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Database CRUD operations
- Validation logic
- Date/time formatting

### Widget Tests
- Dive list item rendering
- Form validation
- Empty state display
- Button interactions

### Integration Tests
- Complete user flows
- Database persistence
- Navigation between screens
- Form submission

---

## Success Criteria

The MVP is considered complete when:

1. ✅ User can add a new dive log with all required fields
2. ✅ User can view a list of all dives in chronological order
3. ✅ User can tap a dive to view full details
4. ✅ User can edit an existing dive
5. ✅ User can delete a dive with confirmation
6. ✅ All data persists locally using SQLite
7. ✅ UI matches Figma design specifications
8. ✅ App runs smoothly on Android devices (API 21+)
9. ✅ No critical bugs or crashes
10. ✅ Form validation works correctly

---

## Future Enhancements (Post-MVP)

### V2 Features
- Search and filter dives
- Sort options (by date, depth, location)
- Dive statistics (total dives, max depth, total time)
- Photo attachments
- GPS coordinates for dive sites

### V3 Features
- Dive buddy management
- Equipment tracking
- Dive certification logging
- Export data (CSV, PDF)
- Backup and restore

### V4 Features
- Cloud sync (optional)
- Share dive logs
- Dive computer integration
- Weather data integration

---

## Notes

### Figma Design Integration
- **ACTION REQUIRED**: Add Figma link/file
- Design review needed before Phase 4
- Extract design tokens (colors, fonts, spacing)
- Document any custom components or animations

### Android Specific Considerations
- Minimum SDK: API 21 (Android 5.0 Lollipop)
- Target SDK: Latest stable (API 34+)
- Test on various screen sizes
- Handle keyboard properly in forms
- Back button navigation

### Performance Considerations
- Use `const` constructors where possible
- Implement lazy loading if list grows large
- Optimize database queries with indexes
- Cache database instance

---

## Timeline Estimate

**Total Estimated Time**: 7-10 days

- Phase 1 (Foundation): 2 days
- Phase 2 (UI Screens): 3 days
- Phase 3 (Polish & Testing): 2 days
- Phase 4 (Figma Integration): 2-3 days

*Note: Timeline assumes full-time development. Adjust based on availability.*

---

## Getting Started

1. Review this plan and Figma designs
2. Confirm MVP scope and features
3. Begin with Phase 1: Create models and database service
4. Follow implementation plan sequentially
5. Test continuously throughout development
6. Review against success criteria before release

---

**Document Version**: 1.0
**Last Updated**: 2025-10-08
**Status**: Draft - Awaiting Figma design review
