# Trip Planning Feature Specification

**Version**: 1.0  
**Date**: January 27, 2026  
**Status**: ✅ Implementation In Progress  
**Priority**: 🔴 CRITICAL - Core feature

---

## Executive Summary

The **Trip Planning Feature** enables users to create custom itineraries and manage their travel plans within MAPORIA. Users can create trips, add destinations, set dates, and track trip status through a timeline interface.

**Core Value**: Complete trip lifecycle management from creation to completion tracking.

---

## Feature Overview

### Trip Model

```dart
id: String                    // Unique identifier
userId: String                // Owner of trip
title: String                 // Trip name (required)
description: String?          // Optional description
startDate: DateTime           // When trip starts
endDate: DateTime             // When trip ends
locations: List<String>?      // Destination place names/IDs
startingLocation: String?     // Starting point
transportationMode: String?   // train, public, vehicle, bike, walking, flying
status: String?               // 'scheduled', 'planned', 'completed'
timelineStatus: TripStatus    // Derived enum for UI
createdAt: DateTime           // When created
updatedAt: DateTime           // Last modified
isCloned: bool                // Was it cloned from template?
originalTemplateId: String?   // If cloned, original template
```

### Trip Status Lifecycle

```
Create Trip
    ↓
status = 'scheduled'      (if startDate > now) - EDITABLE
    ↓
status = 'planned'        (if now between startDate & endDate) - EDITABLE
    ↓
status = 'completed'      (if endDate < now) - READ-ONLY
```

---

## Core Features

### 1. Trip Creation (CreateTripPage)

**User Input Form**:
- Trip title (required)
- Trip description (optional)
- Start date (required, must be >= today)
- End date (required, must be >= start date)
- Starting location selector
- Transportation mode dropdown:
  - Train
  - Public Transportation
  - Vehicle (Car)
  - Bike
  - Walking
  - Flying
- Destination management (add/remove multiple places)

**Validation Rules**:
- Title is required (non-empty)
- At least one destination required
- End date must be >= start date
- All date fields filled

**Key Methods**:
```dart
_pickStartDate()        // DatePicker for start date
_pickEndDate()          // DatePicker for end date
_addPlace()             // Add destination to trip
_removePlace(int)       // Remove destination
_saveTrip()             // Validate and upsert trip
```

### 2. Trip Editing

**Edit Mode**:
- Open CreateTripPage with existing trip data pre-filled
- All form fields editable
- User can modify dates, destinations, title, description
- Save updates through upsert flow
- Changes reflected immediately in timeline

**Restrictions**:
- Only Scheduled/Planned trips editable
- Completed trips read-only

### 3. Trip Deletion

**Deletion Flow**:
- Confirmation dialog (prevent accidental deletion)
- User confirms with "Delete" button
- Trip removed from database
- Removed from Memory Lane timeline
- Cannot undo (archived instead in production)

### 4. Memory Lane Timeline View

**MemoryLanePage Components**:
- **Two tabs**:
  - Quests Tab (placeholder for future quest feature)
  - Trips Tab (shows all user trips organized by status)

**Trip Organization by Status**:
- **Scheduled** (editable): Trips starting in future
- **Planned** (editable): Trips currently in progress
- **Completed** (read-only): Past trips

**Per-Status Section Display**:
- Status icon & label
- Trip count badge
- Trip cards showing:
  - Title & date range (e.g., "Jan 15-20, 2026")
  - Duration (calculated from dates)
  - Description (if available)
  - Destination chips (first 3 with "more" indicator)
  - Action buttons: View, Edit (if editable), Delete

**Trip Card Actions**:
- **View**: Open trip detail page (read-only)
- **Edit**: Navigate to CreateTripPage in edit mode
- **Delete**: Show confirmation dialog

### 5. Trip Details View

**Display Information**:
- Full trip title & description
- Complete date range with duration calculation
- All destinations in order with place details
- Starting location
- Transportation mode
- Trip status with visual indicator
- Creation/update timestamps

**Interactions**:
- For Scheduled/Planned: Edit & Delete buttons
- For Completed: View only
- Link to related Places for each destination
- Map view of all destinations (future enhancement)

---

## Data Flow & Architecture

### State Management (Riverpod)

**Provider Hierarchy**:
```
dioProvider (HTTP client)
    ↓
    └→ tripsApiProvider (API calls)
            ↓
            └→ tripsRepositoryProvider (data layer)
                    ↓
                    └→ tripsProvider (StateNotifierProvider)
                            ↓
                            └→ TripsNotifier (state management)
```

**TripsState**:
```dart
class TripsState {
  List<TripModel> trips      // All user trips
  bool isLoading             // Fetching data?
  String? error              // Error message
  int currentPage            // Pagination
  bool hasMore               // More trips to load?
}
```

**TripsNotifier Methods**:
```dart
loadTrips(refresh)       // Fetch trips from backend
addTrip(trip)            // Add new or update existing (upsert)
loadMore()               // Load next page
createTrip(dto)          // Create via DTO
updateTrip(id, dto)      // Update via DTO
deleteTrip(id)           // Delete by ID
clearError()             // Clear error message
```

### User Interaction Flow

**Creating a Trip**:
```
TripsScreen
  ↓ [Tap "Create Custom Trip"]
  ↓
CreateTripPage (no trip param)
  ↓ [Fill form + Tap "Create Trip"]
  ↓
_saveTrip() → validate
  ↓
ref.read(tripsProvider.notifier).addTrip(trip)
  ↓
Navigator.pop() → TripsScreen
  ↓
MemoryLanePage → Trips tab shows new trip (Scheduled status)
```

**Editing a Trip**:
```
MemoryLanePage (Trips tab)
  ↓ [Trip card, Tap "Edit"]
  ↓
CreateTripPage(trip: selectedTrip) // pre-filled form
  ↓ [Modify + Tap "Save Changes"]
  ↓
_saveTrip() → validate & copyWith()
  ↓
ref.read(tripsProvider.notifier).addTrip(updatedTrip) // upsert
  ↓
Navigator.pop() → MemoryLanePage
  ↓
Trips tab updates with edited trip
```

**Deleting a Trip**:
```
MemoryLanePage (Trips tab)
  ↓ [Trip card, Tap "Delete"]
  ↓
_showDeleteConfirm() → Confirmation dialog
  ↓ [Tap "Delete" button]
  ↓
ref.read(tripsProvider.notifier).deleteTrip(tripId)
  ↓
Trip removed from UI
```

---

## Navigation Structure

```
TripsScreen (Trip Planning Hub)
    ├── [Create Custom Trip] → CreateTripPage
    │   ├── [Create Trip] → TripsScreen
    │   └── [Cancel] → TripsScreen
    │
    └── [Memory Lane] → MemoryLanePage
            ├── Quests Tab (placeholder)
            │
            └── Trips Tab
                ├── [View Trip] → TripDetailPage (read-only)
                ├── [Edit Trip] → CreateTripPage (pre-filled, edit mode)
                └── [Delete Trip] → Confirmation dialog
```

---

## Implementation Status

### Completed ✅
- CreateTripPage (form-based trip creation & editing)
- MemoryLanePage (timeline view with status tabs)
- TripsPage (hub for trip management)
- TripModel (data structure with status fields)
- Riverpod state management setup
- Form validation (dates, destinations, title)
- Upsert flow for edits

### In Progress 🔄
- Backend API integration for persistence
- Auto-status transitions based on dates
- Trip detail page implementation
- Map view of destinations

### Future Enhancements ⏳
- Quest system (placeholder in Quests tab)
- Trip collaboration (share with other users)
- Trip statistics (completion rate, avg duration)
- AI-powered trip suggestions
- Daily itinerary builder
- Budget tracking per trip
- Weather integration for trip dates

---

## UI Components

### CreateTripPage Widget
- Form fields with validation
- DatePicker integration
- Destination multi-select interface
- Submit/Cancel buttons
- Error messaging

### MemoryLanePage Widget
- TabController for Quests/Trips
- Status-based trip grouping
- Trip cards with action buttons
- Empty state messaging

### TripDetailPage Widget (In Development)
- Read-only trip information display
- Destination list with place links
- Status indicator
- Edit/Delete buttons (for Scheduled/Planned)

---

## API Endpoints

**Base**: `/api/trips`

### User Endpoints (Authentication Required)

**GET** `/api/trips` - List user's trips
- Query: `skip`, `limit`, `status`, `sortBy`
- Returns: paginated trips array

**GET** `/api/trips/:id` - Get single trip
- Returns: complete trip object

**POST** `/api/trips` - Create new trip
- Body: trip data
- Returns: created trip with ID

**PATCH** `/api/trips/:id` - Update trip
- Body: updatable fields
- Returns: updated trip

**DELETE** `/api/trips/:id` - Delete trip
- Returns: success message

---

## Database Schema (MongoDB)

```javascript
{
  _id: ObjectId,
  userId: ObjectId (required, indexed),
  title: String (required),
  description: String,
  startDate: Date (required),
  endDate: Date (required),
  locations: [String], // place IDs or names
  startingLocation: String,
  transportationMode: String,
  status: String, // 'scheduled', 'planned', 'completed'
  isCloned: Boolean (default: false),
  originalTemplateId: ObjectId,
  createdAt: Date (default: now, indexed),
  updatedAt: Date (default: now),
  deletedAt: Date (soft delete support)
}

Indexes:
- { userId: 1, createdAt: -1 }  // For user trip history
- { userId: 1, status: 1 }      // For filtering by status
- { startDate: 1 }              // For timeline queries
```

---

## Files

### Frontend (Dart/Flutter)
- `lib/features/trips/pages/create_trip_page.dart` - Trip creation/editing form
- `lib/features/trips/pages/memory_lane_page.dart` - Timeline view
- `lib/features/trips/pages/trip_detail_page.dart` - Trip details (in dev)
- `lib/features/trips/models/trip_model.dart` - Data model
- `lib/features/trips/providers/trips_provider.dart` - Riverpod state management
- `lib/features/trips/services/trips_service.dart` - API service

### Backend (Node.js)
- `backend/src/models/Trip.js` - MongoDB model
- `backend/src/routes/trips.js` - API routes
- `backend/src/controllers/tripController.js` - Business logic
- `backend/seed-preplanned-trips.js` - Pre-planned trips data

---

## Testing Checklist

- [ ] Create trip with valid data
- [ ] Create trip validation (missing title, destination, etc.)
- [ ] Edit trip updates correctly
- [ ] Delete trip with confirmation
- [ ] Trip status changes based on dates
- [ ] Timeline displays trips in correct status sections
- [ ] Cannot edit completed trips
- [ ] Cannot delete without confirmation
- [ ] Pagination works with multiple trips
- [ ] API integration persists changes

---

## Success Metrics

- Users can create custom trips in < 2 minutes
- Memory Lane timeline displays all trips correctly grouped by status
- Trip editing preserves all data and updates immediately
- Trip deletion is prevented accidentally (requires confirmation)
- 95%+ of trips display correct status based on dates
- Trip creation form never loses data on navigation

---

## References

- Feature: This document
- Database Schema: `docs/03_architecture/DATABASE_SCHEMA.md`
- API Reference: `docs/04_api/API_REFERENCE.md`
- Riverpod Patterns: `docs/06_implementation/...`
