# Custom Trip Feature - Data Flow & Architecture

## Data Model

### TripModel Fields
```dart
- id: String                 // Unique identifier
- userId: String             // Owner of trip
- title: String              // Trip name (required)
- description: String?       // Optional description
- startDate: DateTime        // When trip starts
- endDate: DateTime          // When trip ends
- locations: List<String>?   // Destination names
- status: String?            // 'scheduled', 'planned', 'completed'
- createdAt: DateTime        // When created
- updatedAt: DateTime        // Last modified
- isCloned: bool             // Was it cloned from template?
- originalTemplateId: String? // If cloned, original template
```

## User Interaction Flow

### Creating a Trip

```
TripsScreen
  ↓ [Tap "Create Custom Trip"]
  ↓
CreateTripPage (no trip param)
  ↓ [Fill form + Tap "Create Trip"]
  ↓
_saveTrip()
  ↓
ref.read(tripsProvider.notifier).addTrip(trip)
  ↓
TripsNotifier.addTrip() → state = [newTrip, ...oldTrips]
  ↓
Navigator.pop() → Returns to TripsScreen
  ↓
MemoryLanePage → Trips tab shows new trip (Scheduled status)
```

### Editing a Trip

```
MemoryLanePage (Trips tab)
  ↓ [Trip card, Tap "Edit"]
  ↓
CreateTripPage(trip: selectedTrip) // trip param is set
  ↓ [Modify form + Tap "Save Changes"]
  ↓
_saveTrip()
  ↓
selectedTrip.copyWith(...updated fields...)
  ↓
ref.read(tripsProvider.notifier).addTrip(updatedTrip)
  ↓
TripsNotifier.addTrip() → state = [updatedTrip, ...other trips]
  ↓
Navigator.pop() → Returns to MemoryLanePage
  ↓
Trips tab updates with edited trip
```

### Deleting a Trip

```
MemoryLanePage (Trips tab)
  ↓ [Trip card, Tap "Delete"]
  ↓
_showDeleteConfirm() → Dialog
  ↓ [Tap "Delete" in dialog]
  ↓
ref.read(tripsProvider.notifier).deleteTrip(tripId)
  ↓
TripsNotifier.deleteTrip()
  ↓
state = state.trips.filter(t => t.id != deleted.id)
  ↓
Trip removed from UI
```

## State Management Architecture

### Riverpod Provider Hierarchy

```
dioProvider
    ↓
    └→ tripsApiProvider
            ↓
            └→ tripsRepositoryProvider
                    ↓
                    └→ tripsProvider (StateNotifierProvider)
                            ↓
                            └→ TripsNotifier (manages TripsState)
```

### TripsState Structure

```dart
class TripsState {
  List<TripModel> trips        // All user trips
  bool isLoading               // Fetching data?
  String? error                // Error message
  int currentPage              // Pagination
  bool hasMore                 // More trips to load?
}
```

### TripsNotifier Methods

```dart
loadTrips(refresh)     // Fetch trips from backend
addTrip(trip)          // Add new or update existing
loadMore()             // Load next page
createTrip(dto)        // Create via DTO
updateTrip(id, dto)    // Update via DTO
deleteTrip(id)         // Delete by ID
clearError()           // Clear error message
```

## Trip Status Lifecycle

### Current (Manual)
User manually creates trip with status 'scheduled' or 'planned'

### Ideal (Future)
```
Create Trip
    ↓
status = 'scheduled'  (if startDate > now)
    ↓
status = 'planned'    (if now between startDate & endDate)
    ↓
status = 'completed'  (if endDate < now)
```

## Navigation Graph

```
TripsScreen (Trip Planning)
    ├── [Create Custom Trip] → CreateTripPage
    │   ├── [Save] → TripsScreen
    │   └── [Cancel] → TripsScreen
    │
    └── [Memory Lane] → MemoryLanePage
            ├── Quests Tab (placeholder)
            │
            └── Trips Tab
                ├── Scheduled Section
                │   ├── Trip Card
                │   │   ├── [View] → TripDetailPage
                │   │   ├── [Edit] → CreateTripPage(trip)
                │   │   └── [Delete] → Delete Confirmation
                │   │
                ├── Planned Section
                │   └── (same as Scheduled)
                │
                └── Completed Section
                    └── Trip Card (read-only, View only)
```

## Component Responsibility Matrix

| Component | Responsibility |
|-----------|-----------------|
| `CreateTripPage` | Form UI, input validation, navigation |
| `MemoryLanePage` | Display trips, group by status, provide edit/delete UI |
| `TripsScreen` | Trip planning hub, navigate to create/memory lane |
| `TripsNotifier` | State updates, trip CRUD operations |
| `TripsRepository` | API communication |
| `TripsApi` | HTTP requests |

## Data Flow Timing

### Initial Load
1. MemoryLanePage.initState() calls `loadTrips()`
2. TripsNotifier sets `isLoading = true`
3. TripsRepository fetches from API
4. TripsNotifier receives list, updates state
5. Widget rebuilds with trips

### Add Trip
1. CreateTripPage validates form
2. Creates TripModel instance
3. Calls `ref.read(tripsProvider.notifier).addTrip(trip)`
4. TripsNotifier inserts at beginning of list
5. Notifies listeners → UI updates immediately
6. (Optional) Backend sync in background

## Performance Considerations

### Optimization Opportunities
- [ ] Paginate trips list (load 20 at a time)
- [ ] Cache trips state persistently
- [ ] Lazy load destination details
- [ ] Debounce search/filter operations
- [ ] Memoize trip status calculations

### Current Approach
- Simple in-memory list management
- All trips loaded upfront
- Instant UI updates via Riverpod
- No persistence between app sessions

