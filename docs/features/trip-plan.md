# Trip Planning Feature Specification

**Version**: 2.0  
**Date**: January 29, 2026  
**Status**: ✅ Implementation In Progress  
**Priority**: 🔴 CRITICAL - Core feature

---

## Executive Summary

The **Trip Planning Feature** is the central hub for users to discover, create, customize, and manage their travel itineraries. MAPORIA offers two complementary trip creation modes:

1. **Pre-Planned Trips**: MAPORIA-curated themed itineraries with preset routes and places (system-created)
2. **Custom Trips**: User-created itineraries built from Places catalog with flexible customization

**Core Value**: Complete trip lifecycle management enabling both guided tourism and flexible personal planning.

---

## Feature Overview

### Two Trip Modes

#### 1. Pre-Planned Trips (System-Curated)

**Purpose**: Provide expertly-designed travel itineraries for users who want guided, proven routes.

**Examples**:
- "Cultural Triangle Heritage Tour" (Sigiriya → Dambulla → Kandy)
- "South Coast Beach Escape" (Mirissa → Unawatuna → Galle)
- "Highland Adventure" (Ella → Horton Plains → Nuwara Eliya)
- "Sacred Temple Circuit" (Temple of Tooth → Thuparama → Kelaniya)
- "Wildlife Safari" (Yala National Park itinerary)

**Pre-Planned Trip Structure**:
```javascript
{
  tripId: String,
  title: String, // "Cultural Triangle Heritage Tour"
  description: String,
  category: String, // "cultural", "adventure", "beach", "wildlife", "spiritual"
  
  // Route details
  places: [
    {
      order: 1,
      placeId: ObjectId,
      name: String,
      description: String,
      estimatedTime: String, // "2 hours"
      suggestedActivities: [String],
      recommendedDates: String, // "October-March"
    }
  ],
  
  // Trip metadata
  totalDays: Number, // 7
  totalDistance: Number, // km
  estimatedDuration: String, // "7 days, 6 nights"
  difficulty: String, // "easy", "moderate", "challenging"
  
  // Itinerary breakdown
  dayByDay: [
    {
      day: 1,
      title: "Arrival in Colombo",
      places: [placeId1],
      suggestedStay: "3-4 hours",
      accommodation: String,
    }
  ],
  
  // Best season
  bestSeason: String, // "October-March"
  seasonalNotes: String,
  
  // Cost estimate
  estimatedCost: {
    currency: "LKR",
    budget: Number,
    midRange: Number,
    luxury: Number,
  },
  
  // Featured
  featured: Boolean,
  imageUrl: String,
  rating: Number,
  reviewCount: Number,
  
  createdAt: Date,
  updatedAt: Date,
}
```

#### 2. Custom Trips (User-Created)

**Purpose**: Enable users to build personalized itineraries from the Places catalog.

**Custom Trip Structure**:
```javascript
{
  tripId: String,
  userId: ObjectId,
  
  title: String,
  description: String,
  
  // Dates
  startDate: DateTime,
  endDate: DateTime,
  
  // Route
  places: [
    {
      order: 1,
      placeId: ObjectId,
      name: String,
      notes: String, // User-added notes
      plannedDuration: String,
    }
  ],
  
  // Trip metadata
  startingLocation: String,
  transportationMode: String, // "train", "public", "vehicle", "bike", "walking", "flying"
  
  // Status
  status: String, // "scheduled", "planned", "completed"
  timelineStatus: String, // Derived: "scheduled" (future), "planned" (in progress), "completed" (past)
  
  // Collaboration
  isCloned: Boolean,
  originalTemplateId: ObjectId, // If cloned from pre-planned
  
  createdAt: Date,
  updatedAt: Date,
}
```

---

## Trip Modes Explained

### Pre-Planned Trip Flow

**User Discovery**:
```
TripsScreen
  ↓
[Browse Pre-Planned Trips] → Trip browsing & discovery
  ↓
[View Trip Details]
  ├─ Full itinerary with day-by-day breakdown
  ├─ Total distance & duration
  ├─ Best season & cost estimates
  ├─ User ratings & reviews
  └─ [Clone Trip] button
  ↓
[Clone Trip] → Creates custom trip with pre-planned data
  ↓
Customize (optional)
  ├─ Change dates
  ├─ Add/remove days
  ├─ Reorder places
  ├─ Add notes
  └─ Change transportation mode
  ↓
[Save Custom Trip] → Now in user's trip list
  ↓
MemoryLane → Trips tab shows new trip
```

**Key Features**:
- Browse curated itineraries by category
- Filter by season, difficulty, duration
- View detailed day-by-day plans
- See estimated costs (budget, mid-range, luxury)
- Read user reviews & ratings
- Clone trip to customize
- Easy adaptation without building from scratch

### Custom Trip Flow

**Trip Creation**:
```
TripsScreen
  ↓
[Create Custom Trip] → CreateTripPage
  ↓
Enter Trip Details:
  ├─ Trip title (required)
  ├─ Description (optional)
  ├─ Start date (required)
  ├─ End date (required, >= start date)
  ├─ Starting location
  └─ Transportation mode
  ↓
Add Destinations:
  ├─ Search places from Places catalog
  ├─ Add multiple places
  ├─ Reorder on map
  ├─ At least 1 place required
  └─ Remove/modify as needed
  ↓
[Save Trip]
  ↓
MemoryLane → Trips tab (Scheduled status)
```

**Trip Management**:
```
MemoryLane > Trips Tab
  ↓
Trip organized by status:
  ├─ Scheduled (editable) - future trips
  ├─ Planned (editable) - in-progress trips
  └─ Completed (read-only) - past trips
  ↓
Per-Trip Actions:
  ├─ [View] - Open trip details
  ├─ [Edit] - Modify trip (if Scheduled/Planned)
  └─ [Delete] - Remove trip (with confirmation)
```

**Editing Trip**:
```
[Edit Trip] → CreateTripPage (pre-filled)
  ↓
Modify:
  ├─ Dates
  ├─ Destinations
  ├─ Title/description
  ├─ Transportation mode
  └─ Other details
  ↓
[Save Changes] → Trip updated
  ↓
MemoryLane refreshes
```

---

## Trip Status Lifecycle

```
Create Trip
    ↓
status = 'scheduled'      (startDate > today) - EDITABLE
    ↓
status = 'planned'        (today between startDate & endDate) - EDITABLE
    ↓
status = 'completed'      (endDate < today) - READ-ONLY
```

**Status Behavior**:
- **Scheduled**: Future trip, user can edit any details
- **Planned**: Currently in progress (we are in trip dates), user can edit but limited
- **Completed**: Past trip, read-only (for memories/archive)

---

## Data Models

### Trip Model

```dart
class Trip {
  String id;                          // Unique ID
  String userId;                      // Trip owner
  
  String title;                       // Trip name
  String description;                 // Optional description
  
  DateTime startDate;                 // When trip starts
  DateTime endDate;                   // When trip ends
  
  List<Place> locations;              // Destinations
  String? startingLocation;           // Starting point
  String? transportationMode;         // How traveling
  
  String status;                      // Raw status
  TripStatus timelineStatus;          // Derived status
  
  bool isCloned;                      // From template?
  String? originalTemplateId;         // Original trip
  
  DateTime createdAt;
  DateTime updatedAt;
  
  // Computed properties
  int getDurationDays() => endDate.difference(startDate).inDays + 1;
  bool isEditable() => timelineStatus != TripStatus.completed;
  String getStatusLabel() => timelineStatus.toString();
}

enum TripStatus { scheduled, planned, completed }
```

### Pre-Planned Trip Model

```javascript
class PrePlannedTrip {
  tripId: String,
  
  title: String,
  description: String,
  category: String,
  
  places: Array<{
    order: Number,
    placeId: ObjectId,
    estimatedTime: String,
    suggestedActivities: [String],
    dayByDay details
  }>,
  
  totalDays: Number,
  totalDistance: Number,
  difficulty: String, // easy, moderate, challenging
  
  dayByDay: Array<{
    day: Number,
    title: String,
    places: [ObjectId],
    suggestedStay: String,
    accommodation: String
  }>,
  
  bestSeason: String,
  estimatedCost: {
    budget: Number,
    midRange: Number,
    luxury: Number
  },
  
  featured: Boolean,
  rating: Number,
  reviewCount: Number,
}
```

---

## UI Components

### TripsScreen (Main Hub)
- **Tab 1: My Trips** - User's custom trips
  - Create button
  - Trip list (upcoming, past)
  - Quick filters (status, month)

- **Tab 2: Pre-Planned Trips** - MAPORIA curated
  - Browse featured trips
  - Filter by category, difficulty, duration
  - Search by name
  - Trip cards (image, title, rating, days, cost)

### CreateTripPage (Custom Trip Form)
- Trip title input (required)
- Trip description textarea (optional)
- Start date picker (required)
- End date picker (required)
- Starting location selector
- Transportation mode dropdown
- Destination manager (add/remove/reorder)
- Save/Cancel buttons
- Validation messages

### PrePlannedTripDetail
- Full trip image
- Title, description, category
- Rating & review count
- Day-by-day itinerary (expandable)
- Cost breakdown (budget, mid-range, luxury)
- Best season & difficulty
- Map with route visualization
- [Clone Trip] button
- [View Reviews] button

### MemoryLanePage (Trip Timeline)
- **Quests Tab** (placeholder)
- **Trips Tab** (organized by status)
  - **Scheduled Section**
    - Status indicator
    - Trip cards (title, dates, places)
    - [View], [Edit], [Delete] buttons
  - **Planned Section**
    - In-progress trips
    - Same card layout
    - [View], [Edit], [Delete] buttons
  - **Completed Section**
    - Past trips (read-only)
    - [View] button only

### TripDetailPage
- Full trip information (read-only or editable)
- Title, dates, duration calculation
- All destinations with details
- Starting location & transportation mode
- Trip status with visual indicator
- Photos from trip (if any)
- [Edit] / [Delete] buttons (if editable)
- [Share] button
- Map view of destinations

---

## Key Differences: Pre-Planned vs Custom

| Aspect | Pre-Planned | Custom |
|--------|------------|--------|
| **Creator** | MAPORIA team | Users |
| **Locations** | Fixed, expertly-selected | User-chosen from catalog |
| **Customization** | Clone & adapt | Build from scratch |
| **Duration** | Predefined (7 days, etc) | User-defined |
| **Route** | Preset optimal route | User decides order |
| **Cost Estimate** | Yes (budget guide) | Manual calculation |
| **Reviews** | Community reviews | None |
| **Best For** | First-time, guided travel | Personalized journeys |
| **Difficulty** | Labeled | No label |
| **Day-by-day Plan** | Included | Optional user notes |

---

## State Management (Riverpod)

**Provider Hierarchy**:
```
dioProvider (HTTP client)
    ↓
    └→ tripsApiProvider (API calls)
            ↓
            └→ tripsRepositoryProvider (data layer)
                    ↓
                    ├→ customTripsProvider (StateNotifierProvider)
                    │       └→ CustomTripsNotifier
                    │
                    └→ prePlannedTripsProvider (FutureProvider)
                            └→ Fetch pre-planned trips
```

**TripsNotifier Methods**:
```dart
// Custom trips
loadCustomTrips(refresh)    // Fetch user's custom trips
createTrip(trip)            // Create new custom trip
updateTrip(id, trip)        // Update custom trip
deleteTrip(id)              // Delete custom trip

// Pre-planned trips
loadPrePlannedTrips()       // Fetch all pre-planned trips
getPrePlannedTrip(id)       // Get specific pre-planned trip
clonePrePlannedTrip(id)     // Clone to custom trip
searchPrePlanned(query)     // Search pre-planned trips
```

---

## API Endpoints

### Pre-Planned Trips (No Authentication)

**GET** `/api/trips/pre-planned` - List all pre-planned trips
- Query: `category`, `difficulty`, `season`, `skip`, `limit`
- Returns: Paginated pre-planned trips array

**GET** `/api/trips/pre-planned/:id` - Get pre-planned trip details
- Returns: Complete pre-planned trip with day-by-day breakdown

**GET** `/api/trips/pre-planned/search?q=name` - Search pre-planned trips
- Returns: Matching trips array

### Custom Trips (Authentication Required)

**GET** `/api/trips` - List user's custom trips
- Query: `skip`, `limit`, `status`, `sortBy`
- Returns: Paginated custom trips array

**GET** `/api/trips/:id` - Get custom trip details
- Returns: Complete custom trip object

**POST** `/api/trips` - Create new custom trip
- Body: trip data (title, dates, places, etc)
- Returns: Created trip with ID

**PATCH** `/api/trips/:id` - Update custom trip
- Body: updatable fields
- Returns: Updated trip

**DELETE** `/api/trips/:id` - Delete custom trip
- Returns: Success message

**POST** `/api/trips/clone/:prePlannedId` - Clone pre-planned to custom
- Body: overrides (dates, title, etc)
- Returns: Created custom trip

---

## Database Schema (MongoDB)

### PrePlannedTrips Collection
```javascript
{
  _id: ObjectId,
  tripId: String (unique, indexed),
  title: String (required),
  description: String,
  category: String (enum),
  
  places: [
    {
      order: Number,
      placeId: ObjectId,
      name: String,
      estimatedTime: String,
      suggestedActivities: [String],
    }
  ],
  
  totalDays: Number,
  totalDistance: Number,
  difficulty: String,
  
  dayByDay: Array,
  bestSeason: String,
  estimatedCost: {
    budget: Number,
    midRange: Number,
    luxury: Number,
  },
  
  featured: Boolean (indexed),
  rating: Number,
  reviewCount: Number,
  
  createdAt: Date,
  updatedAt: Date,
}
```

### CustomTrips Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (required, indexed),
  tripId: String (unique per user),
  
  title: String (required),
  description: String,
  
  startDate: Date (required, indexed),
  endDate: Date (required),
  
  places: [
    {
      order: Number,
      placeId: ObjectId,
      name: String,
      notes: String,
    }
  ],
  
  startingLocation: String,
  transportationMode: String,
  
  status: String (indexed), // scheduled, planned, completed
  
  isCloned: Boolean (default: false),
  originalTemplateId: ObjectId,
  
  createdAt: Date (indexed),
  updatedAt: Date,
  deletedAt: Date, // Soft delete
}

Indexes:
- { userId: 1, createdAt: -1 }
- { userId: 1, status: 1 }
- { startDate: 1 }
```

---

## Implementation Phases

### Phase 1: Pre-Planned Trips Infrastructure (1 week)
- Create PrePlannedTrip model
- Seed initial 10-15 pre-planned trips
- API endpoints for fetching pre-planned trips
- Trip browsing screen UI

### Phase 2: Custom Trip Creation (1.5 weeks)
- Create CustomTrip model
- CreateTripPage form with validation
- API endpoints for CRUD operations
- Trip list display

### Phase 3: Trip Timeline & Memory Lane (1.5 weeks)
- MemoryLanePage with status-based grouping
- Trip detail view (read-only)
- Trip edit functionality
- Trip deletion with confirmation

### Phase 4: Trip Cloning & Integration (1 week)
- Clone pre-planned to custom trips
- Adaptation features (date override, customization)
- Link pre-planned details to custom trips
- UI polish

### Phase 5: Advanced Features (Future)
- Trip collaboration (share with friends)
- Trip statistics & analytics
- Budget tracking per trip
- Weather integration for trip dates
- Photo/memory integration per trip
- AI-powered trip suggestions

---

## Testing Checklist

- [ ] Create custom trip with valid data
- [ ] Create trip validation (missing required fields)
- [ ] Edit trip updates all fields correctly
- [ ] Delete trip with confirmation
- [ ] Trip status changes automatically based on dates
- [ ] Timeline displays trips in correct status sections
- [ ] Cannot edit completed trips
- [ ] Pre-planned trips display correctly
- [ ] Clone pre-planned to custom trip
- [ ] Cannot delete without confirmation
- [ ] Pagination works with many trips
- [ ] API integration persists changes
- [ ] Dates validation (end >= start)

---

## Success Metrics

- Users can create custom trips in < 2 minutes
- Memory Lane timeline displays all trips correctly grouped by status
- Trip editing preserves all data and updates immediately
- 80%+ users browse pre-planned trips
- 50%+ of new trips cloned from pre-planned templates
- Trip deletion prevented accidentally (requires confirmation)
- 95%+ of trips display correct status based on dates
- Average session time on trips: 5+ minutes

---

## References

- Feature: This document
- Places: [places.md](places.md)
- Album: [album.md](album.md)
- Shop: [shop.md](shop.md)
- Core Source: [project-source-of-truth.md](../core/project-source-of-truth.md)
- Database Schema: [database-schema.md](../architecture/database-schema.md)
- API Reference: [api-reference.md](../api/api-reference.md)
