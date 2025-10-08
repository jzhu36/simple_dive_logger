# User Interface Documentation

## Screen Flow Overview

```
Main Screen (Home)
├── Begin Dive → Begin Dive Screen
├── End Dive → End Dive Screen
├── Dive Log → Dive Log Screen
└── Edit Dive → Edit Dive Screen
```

---

## Main Screen (Home)

### Purpose
Landing page that provides quick access to all major features.

### Layout
Four main action buttons arranged vertically or in a grid:

### Buttons
1. **Begin Dive**
   - Action: Navigate to Begin Dive Screen
   - Purpose: Start tracking a new dive session

2. **End Dive**
   - Action: Navigate to End Dive Screen
   - Purpose: Complete and save the current active dive

3. **Dive Log**
   - Action: Navigate to Dive Log Screen
   - Purpose: View all recorded dives

4. **Edit Dive**
   - Action: Navigate to Edit Dive Screen
   - Purpose: Modify existing dive records

### Additional UI Elements
- App title: "Simple Dive Logger"
- Optional: Status indicator showing if a dive is currently active

---

## Begin Dive Screen

### Purpose
Capture initial dive information when starting a dive.

### Fields
- **Date**: Date picker (defaults to today)
- **Time**: Time picker (defaults to now)
- **Location**: Text field for dive site name
- **Planned Max Depth**: Number input (meters or feet)
- **Notes** (optional): Multi-line text field for pre-dive notes

### Buttons
- **Start Dive**: Save initial dive data and mark dive as "active"
- **Cancel**: Return to Main Screen without saving

### Functionality
- Validates all required fields are filled
- Creates a new dive record with status "in_progress"
- Shows success message and returns to Main Screen
- Main Screen should show "dive active" indicator

---

## End Dive Screen

### Purpose
Complete the active dive with final measurements and observations.

### Fields
- **Display Active Dive Info**: Show date, time, location (read-only)
- **Actual Max Depth**: Number input (meters or feet)
- **Duration**: Number input (minutes)
- **Water Temperature** (optional): Number input
- **Visibility** (optional): Text or dropdown (e.g., "Excellent", "Good", "Fair", "Poor")
- **Post-Dive Notes**: Multi-line text field for observations, marine life seen, etc.

### Buttons
- **Complete Dive**: Save all data and mark dive as "completed"
- **Cancel**: Return to Main Screen without completing (dive remains active)

### Functionality
- Only accessible if there's an active dive
- Validates required fields (actual depth, duration)
- Updates the active dive record with completion data
- Shows success message and returns to Main Screen

---

## Dive Log Screen

### Purpose
Browse and view all completed dives.

### Layout
Scrollable list of dive cards, sorted by date (most recent first).

### Each Dive Card Shows
- Date and time
- Location
- Max depth
- Duration
- Summary stats or icon

### Buttons/Actions
- **Tap on any dive card**: View full dive details in a detail view
- **Back button**: Return to Main Screen

### Detail View (when card is tapped)
- Displays all dive information:
  - Date and time
  - Location
  - Max depth
  - Duration
  - Water temperature (if recorded)
  - Visibility (if recorded)
  - All notes
- **Edit button**: Navigate to Edit Dive Screen with this dive pre-loaded
- **Delete button**: Confirm and delete this dive
- **Back button**: Return to Dive Log list

### Additional Features
- Search bar (optional): Filter dives by location or date
- Empty state message: "No dives logged yet. Start diving!"

---

## Edit Dive Screen

### Purpose
Modify existing dive records.

### Layout Options

#### Option 1: List Selection First
1. **Initial view**: Shows list of all dives (same as Dive Log)
2. **User taps a dive**: Loads edit form with dive data

#### Option 2: Direct Form (if accessed from Detail View)
Directly shows edit form with selected dive data pre-filled

### Fields (Pre-filled with existing data)
- **Date**: Date picker
- **Time**: Time picker
- **Location**: Text field
- **Max Depth**: Number input
- **Duration**: Number input
- **Water Temperature**: Number input
- **Visibility**: Text or dropdown
- **Notes**: Multi-line text field

### Buttons
- **Save Changes**: Update dive record in database
- **Cancel**: Return to previous screen without saving
- **Delete Dive**: Remove this dive (with confirmation dialog)

### Functionality
- All fields are editable
- Validates required fields before saving
- Shows confirmation: "Are you sure you want to delete this dive?" before deletion
- Returns to Dive Log or Main Screen after save/delete

---

## Navigation Flow Summary

```
Main Screen
    ↓ Begin Dive
Begin Dive Screen → [Start] → Main Screen
    ↓ End Dive
End Dive Screen → [Complete] → Main Screen
    ↓ Dive Log
Dive Log Screen → [Tap Dive] → Dive Detail View → [Edit] → Edit Dive Screen
    ↓ Edit Dive
Edit Dive Screen (List) → [Select Dive] → Edit Dive Form → [Save] → Dive Log/Main Screen
```

---

## Design Considerations

### Color Scheme
- Primary: Ocean blue
- Accent: Coral or aqua
- Background: White/light gray
- Text: Dark gray/black

### Accessibility
- Large, clear buttons on Main Screen
- Proper labels on all form fields
- Confirmation dialogs for destructive actions (delete)
- Input validation with clear error messages

### User Experience
- Minimal screens to complete a dive log
- Quick access to all functions from Main Screen
- Logical flow: Begin → End → Log → Edit
- Clear visual feedback for active dive status
