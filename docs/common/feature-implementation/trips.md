# Trips Feature Implementation

**Feature**: Trip Planning & Management  
**Last Updated**: February 1, 2026

---

## Overview

The Trips feature allows users to create, manage, and track their travel plans across Sri Lanka. Each trip contains multiple destinations, dates, and trip metadata.

---

## Architecture

```
User ──┬──> Travel (Trip)──┬──> Destination 1
       │                   ├──> Destination 2
       │                   └──> Destination N
       │
       └──> Travel (Trip)──┬──> Destination 1
                           └──> Destination 2
```

---

## Backend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **Travel.js** | Trip model schema | `backend/src/models/Travel.js` |
| **Destination.js** | Destination model | `backend/src/models/Destination.js` |
| **travelController.js** | Trip CRUD logic | `backend/src/controllers/travelController.js` |
| **travelRoutes.js** | Trip endpoints | `backend/src/routes/travelRoutes.js` |
| **mapController.js** | Trip map data | `backend/src/controllers/mapController.js` |

### 1. Travel Model (`backend/src/models/Travel.js`)

**Key Fields**:
- `userId`: Owner (Auth0 ID)
- `title`: Trip name (min 3 chars)
- `description`: Trip description
- `startDate`, `endDate`: Trip dates
- `locations`: Array of location names

**Where to Make Changes**:
- **Add trip status**: Add `status` field (planned/active/completed)
- **Add budget**: Add `budget` object with amount/currency
- **Add trip type**: Add `tripType` enum (solo/family/group)
- **Add cover photo**: Add `coverPhoto` URL field

**Example: Add trip status**:
```javascript
const travelSchema = new mongoose.Schema({
  // ... existing fields ...
  status: {
    type: String,
    enum: ['planned', 'active', 'completed', 'cancelled'],
    default: 'planned',
    index: true
  },
  budget: {
    amount: { type: Number, min: 0 },
    currency: { type: String, default: 'LKR' },
    spent: { type: Number, default: 0 }
  }
});
```

### 2. Travel Controller (`backend/src/controllers/travelController.js`)

**Functions**:
- `createTravel(req, res)`: Create new trip
- `getAllTravels(req, res)`: Get user's trips (with pagination)
- `getTravelById(req, res)`: Get single trip
- `updateTravel(req, res)`: Update trip details
- `deleteTravel(req, res)`: Delete trip

**Where to Make Changes**:
- **Add filtering**: Add query params for status/date range
- **Add sorting**: Add sort by startDate/createdAt
- **Add trip templates**: Create `createFromTemplate` function
- **Add trip statistics**: Create `getTripStats` function

**Example: Filter trips**:
```javascript
exports.getAllTravels = async (req, res) => {
  const { status, startAfter, endBefore, limit = 20, skip = 0 } = req.query;
  
  const filter = { userId: req.user.auth0Id };
  if (status) filter.status = status;
  if (startAfter) filter.startDate = { $gte: new Date(startAfter) };
  if (endBefore) filter.endDate = { $lte: new Date(endBefore) };
  
  const travels = await Travel.find(filter)
    .sort({ startDate: -1 })
    .limit(parseInt(limit))
    .skip(parseInt(skip));
  
  const total = await Travel.countDocuments(filter);
  
  res.json({ travels, total, limit, skip });
};
```

### 3. Map Controller (`backend/src/controllers/mapController.js`)

**Functions for Trips**:
- `getTravelGeoJSON(req, res)`: Get trip as GeoJSON for map
- `getTravelBoundary(req, res)`: Get trip boundary polygon
- `getTravelStats(req, res)`: Get trip statistics

**Where to Make Changes**:
- **Change map styling**: Modify GeoJSON properties
- **Add route optimization**: Implement route ordering
- **Add elevation data**: Integrate elevation API

---

## Frontend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **trips_screen.dart** | Trip list UI | `mobile/lib/features/trips/screens/trips_screen.dart` |
| **trip_details_screen.dart** | Trip details UI | `mobile/lib/features/trips/screens/trip_details_screen.dart` |
| **create_trip_screen.dart** | New trip form | `mobile/lib/features/trips/screens/create_trip_screen.dart` |
| **trips_provider.dart** | Trip state | `mobile/lib/features/trips/providers/trips_provider.dart` |
| **trip_model.dart** | Trip data class | `mobile/lib/features/trips/models/trip_model.dart` |

### 1. Trips Screen (`trips_screen.dart`)

**Purpose**: Display user's trip list.

**Where to Make Changes**:
- **Add filters**: Add status/date filter chips
- **Add tabs**: Separate planned/active/completed trips
- **Add search**: Add trip search by title
- **Change layout**: Switch to grid/card view

**Example: Filter tabs**:
```dart
TabBar(
  tabs: [
    Tab(text: 'Planned'),
    Tab(text: 'Active'),
    Tab(text: 'Completed'),
  ],
)

TabBarView(
  children: [
    TripsList(status: 'planned'),
    TripsList(status: 'active'),
    TripsList(status: 'completed'),
  ],
)
```

### 2. Trip Details Screen (`trip_details_screen.dart`)

**Purpose**: Show trip details and destinations.

**Where to Make Changes**:
- **Add map view**: Show trip route on map
- **Add itinerary**: Daily schedule view
- **Add budget tracker**: Show budget vs spent
- **Add sharing**: Share trip with friends

**Example: Budget widget**:
```dart
BudgetProgress(
  total: trip.budget.amount,
  spent: trip.budget.spent,
  currency: trip.budget.currency,
)
```

### 3. Create Trip Screen (`create_trip_screen.dart`)

**Purpose**: Form to create new trip.

**Where to Make Changes**:
- **Add templates**: Pre-fill from PrePlannedTrip
- **Add date validation**: Ensure endDate > startDate
- **Add location autocomplete**: Suggest SL locations
- **Add cover photo upload**: Upload trip cover

**Example: Date validation**:
```dart
if (endDate.isBefore(startDate)) {
  showError('End date must be after start date');
  return;
}
```

### 4. Trips Provider (`trips_provider.dart`)

**Purpose**: Manage trip state and API calls.

**State**:
- `trips`: List of Trip objects
- `currentTrip`: Selected trip details
- `isLoading`: Loading state
- `filters`: Active filters

**Where to Make Changes**:
- **Add caching**: Cache trips locally
- **Add optimistic updates**: Update UI before API response
- **Add pagination**: Implement infinite scroll

**Example: Load trips**:
```dart
Future<void> loadTrips({String? status}) async {
  state = state.copyWith(isLoading: true);
  
  final response = await apiClient.get('/api/travel', queryParameters: {
    if (status != null) 'status': status,
  });
  
  final trips = (response['travels'] as List)
      .map((e) => Trip.fromJson(e))
      .toList();
  
  state = state.copyWith(trips: trips, isLoading: false);
}
```

---

## API Endpoints

See detailed API documentation:
- [Travel Endpoints](../../backend/api-endpoints/travel-endpoints.md)
- [Map Endpoints](../../backend/api-endpoints/map-endpoints.md)

**Key Endpoints**:
- `POST /api/travel` - Create trip
- `GET /api/travel` - Get all user trips
- `GET /api/travel/:travelId` - Get trip details
- `PATCH /api/travel/:travelId` - Update trip
- `DELETE /api/travel/:travelId` - Delete trip
- `GET /api/travel/:travelId/geojson` - Get trip GeoJSON for map
- `GET /api/travel/:travelId/stats` - Get trip statistics

---

## Common Modifications

### 1. Add Trip Status Workflow

**Backend** (`Travel.js`):
```javascript
status: {
  type: String,
  enum: ['planned', 'active', 'completed', 'cancelled'],
  default: 'planned'
}
```

**Controller** (auto-activate on start date):
```javascript
// Scheduled job or middleware
const today = new Date();
await Travel.updateMany(
  { status: 'planned', startDate: { $lte: today } },
  { status: 'active' }
);
```

**Frontend** (status badge):
```dart
Chip(
  label: Text(trip.status.toUpperCase()),
  backgroundColor: trip.status == 'active' ? Colors.green : Colors.grey,
)
```

### 2. Add Trip Templates from PrePlannedTrips

**Backend** (`travelController.js`):
```javascript
exports.createFromTemplate = async (req, res) => {
  const template = await PrePlannedTrip.findById(req.params.templateId);
  
  const newTrip = new Travel({
    userId: req.user.auth0Id,
    title: template.title,
    description: template.description,
    startDate: req.body.startDate,
    endDate: new Date(req.body.startDate).setDate(
      req.body.startDate.getDate() + template.durationDays
    ),
  });
  
  await newTrip.save();
  res.status(201).json(newTrip);
};
```

**Frontend** (template selector):
```dart
DropdownButton<PrePlannedTrip>(
  hint: Text('Start from template'),
  items: templates.map((t) {
    return DropdownMenuItem(value: t, child: Text(t.title));
  }).toList(),
  onChanged: (template) {
    setState(() {
      titleController.text = template.title;
      descriptionController.text = template.description;
    });
  },
)
```

### 3. Add Trip Sharing

**Backend** (`Travel.js`):
```javascript
sharedWith: [{
  userId: String,
  role: { type: String, enum: ['viewer', 'editor'] },
  sharedAt: Date
}]
```

**Controller** (share trip):
```javascript
exports.shareTrip = async (req, res) => {
  const { targetUserId, role } = req.body;
  
  const trip = await Travel.findById(req.params.travelId);
  trip.sharedWith.push({ userId: targetUserId, role, sharedAt: new Date() });
  await trip.save();
  
  res.json(trip);
};
```

### 4. Add Trip Budget Tracking

**Backend** (`Travel.js`):
```javascript
budget: {
  total: { type: Number, default: 0 },
  currency: { type: String, default: 'LKR' },
  spent: { type: Number, default: 0 },
  categories: [{
    name: String, // 'accommodation', 'food', 'transport'
    budgeted: Number,
    spent: Number
  }]
}
```

**Frontend** (budget tracker):
```dart
Column(
  children: [
    Text('Budget: ${trip.budget.total} ${trip.budget.currency}'),
    LinearProgressIndicator(
      value: trip.budget.spent / trip.budget.total,
    ),
    Text('Spent: ${trip.budget.spent} (${percentage}%)'),
  ],
)
```

---

## Integration with Other Features

### Trips + Destinations

When destinations are added/removed from trip:
```javascript
// After adding destination
const destCount = await Destination.countDocuments({ travelId: tripId });
await Travel.findByIdAndUpdate(tripId, { destinationCount: destCount });
```

### Trips + Maps

Trip route visualization:
```javascript
// Generate route from destinations
const destinations = await Destination.find({ travelId: tripId })
  .sort({ createdAt: 1 });

const route = {
  type: 'LineString',
  coordinates: destinations.map(d => [d.longitude, d.latitude])
};
```

### Trips + Achievements

Complete trip achievement:
```javascript
// When trip status changes to 'completed'
const user = await User.findOne({ auth0Id: userId });
user.achievements.push({
  type: 'trip_completed',
  tripId: tripId,
  unlockedAt: new Date()
});
await user.save();
```

---

## Testing

### Backend Testing

```bash
# Create trip
curl -X POST http://localhost:5000/api/travel \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"SL Adventure","startDate":"2026-07-01","endDate":"2026-07-15"}'

# Get trips
curl http://localhost:5000/api/travel \
  -H "Authorization: Bearer TOKEN"

# Update trip
curl -X PATCH http://localhost:5000/api/travel/TRIP_ID \
  -H "Authorization: Bearer TOKEN" \
  -d '{"status":"active"}'
```

### Frontend Testing

```dart
test('Create trip', () async {
  final trip = await ref.read(tripsProvider.notifier).createTrip(
    title: 'Test Trip',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 7)),
  );
  
  expect(trip.title, 'Test Trip');
  expect(trip.status, 'planned');
});
```

---

## See Also

- [Trip Planning Feature Spec](../features/trip-plan.md)
- [Travel API Endpoints](../../backend/api-endpoints/travel-endpoints.md)
- [Destinations](./places.md)
- [Maps Feature](./maps.md)
- [PrePlanned Trips](../../backend/api-endpoints/preplanned-trips-endpoints.md)
