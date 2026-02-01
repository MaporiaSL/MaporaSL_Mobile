# Places Feature Implementation

**Feature**: Places & Attractions Discovery  
**Last Updated**: February 1, 2026

---

## Overview

The Places feature allows users to discover Sri Lankan attractions, tourist destinations, and points of interest. Places are pre-seeded data that users can browse, search by district, and add to their trips.

---

## Architecture

```
┌─────────────────┐
│  Places Data    │  ← Pre-seeded JSON with SL attractions
│  (Static)       │
└────────┬────────┘
         │ Seeded into MongoDB
         ▼
┌─────────────────┐
│   Destination   │  ← When user adds to trip
│     Model       │
└─────────────────┘
```

**Note**: Places are currently implemented as part of the Destination model. Future enhancement could separate into a dedicated `Place` model.

---

## Backend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **Destination.js** | Destination/place schema | `backend/src/models/Destination.js` |
| **destinationController.js** | Place CRUD logic | `backend/src/controllers/destinationController.js` |
| **destinationRoutes.js** | Place endpoints | `backend/src/routes/destinationRoutes.js` |
| **geoController.js** | Geospatial queries | `backend/src/controllers/geoController.js` |
| **places_seed_data.json** | Place seed data | `project_resources/places_seed_data.json` |

### 1. Destination Model (`backend/src/models/Destination.js`)

**Key Fields for Places**:
- `name`: Place name (e.g., "Sigiriya Rock Fortress")
- `latitude`, `longitude`: GPS coordinates
- `location`: GeoJSON Point for geospatial queries
- `districtId`: Sri Lankan district (e.g., "matale")
- `notes`: User-added notes
- `visited`: Whether user has visited

**Where to Make Changes**:
- **Add place attributes**: Add fields like `category`, `description`, `photos`
- **Add ratings**: Add `rating`, `reviews` fields
- **Add opening hours**: Add `openingHours` object

**Example: Add place category**:
```javascript
const destinationSchema = new mongoose.Schema({
  // ... existing fields ...
  category: {
    type: String,
    enum: ['temple', 'beach', 'mountain', 'historical', 'wildlife', 'city'],
    default: null
  }
});
```

### 2. Destination Controller (`backend/src/controllers/destinationController.js`)

**Functions**:
- `createDestination(req, res)`: Add place to user's trip
- `getAllDestinations(req, res)`: Get all destinations for a trip
- `getDestinationById(req, res)`: Get single destination
- `updateDestination(req, res)`: Update destination (mark visited, add notes)
- `deleteDestination(req, res)`: Remove from trip

**Where to Make Changes**:
- **Add search by name**: Create `searchDestinations` function
- **Add filtering**: Add query parameter handling
- **Add bulk operations**: Create `bulkAddDestinations` function

**Example: Search destinations**:
```javascript
exports.searchDestinations = async (req, res) => {
  const { query, districtId } = req.query;
  const filter = {
    userId: req.user.auth0Id,
    name: { $regex: query, $options: 'i' }
  };
  if (districtId) filter.districtId = districtId;
  
  const destinations = await Destination.find(filter);
  res.json({ destinations });
};
```

### 3. Geo Controller (`backend/src/controllers/geoController.js`)

**Functions**:
- `findNearbyDestinations(req, res)`: Find places near coordinates
- `findDestinationsWithinBounds(req, res)`: Find places in map bounds

**Where to Make Changes**:
- **Change radius**: Modify default search radius
- **Add filters**: Add category/type filters to geospatial queries
- **Add sorting**: Sort results by distance/rating

**Example: Find nearby with filters**:
```javascript
exports.findNearbyDestinations = async (req, res) => {
  const { lat, lng, radius = 10, category } = req.query;
  
  const query = {
    location: {
      $near: {
        $geometry: { type: 'Point', coordinates: [lng, lat] },
        $maxDistance: radius * 1000
      }
    }
  };
  
  if (category) query.category = category;
  
  const destinations = await Destination.find(query);
  res.json({ destinations });
};
```

---

## Frontend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **places_screen.dart** | Places browser UI | `mobile/lib/features/places/screens/places_screen.dart` |
| **places_provider.dart** | Places state | `mobile/lib/features/places/providers/places_provider.dart` |
| **place_model.dart** | Place data class | `mobile/lib/features/places/models/place_model.dart` |
| **place_card_widget.dart** | Place list item | `mobile/lib/features/places/widgets/place_card_widget.dart` |
| **place_details_screen.dart** | Place details | `mobile/lib/features/places/screens/place_details_screen.dart` |

### 1. Places Screen (`places_screen.dart`)

**Purpose**: Browse and search places.

**Where to Make Changes**:
- **Add search bar**: Add TextField for search
- **Add district filter**: Add dropdown for district selection
- **Add category tabs**: Add TabBar for categories
- **Change list/grid view**: Modify ListView to GridView

**Example: Add search**:
```dart
TextField(
  onChanged: (query) {
    ref.read(placesProvider.notifier).searchPlaces(query);
  },
  decoration: InputDecoration(
    hintText: 'Search places...',
    prefixIcon: Icon(Icons.search),
  ),
)
```

### 2. Places Provider (`places_provider.dart`)

**Purpose**: Manage places state and API calls.

**State**:
- `places`: List of Place objects
- `isLoading`: Loading indicator
- `selectedDistrict`: Current district filter
- `searchQuery`: Current search term

**Where to Make Changes**:
- **Add filters**: Create filter methods
- **Add favorites**: Add favorite toggle logic
- **Add caching**: Implement local caching

**Example: Search method**:
```dart
Future<void> searchPlaces(String query) async {
  state = state.copyWith(isLoading: true);
  final results = await apiClient.get('/api/destinations', queryParameters: {
    'search': query,
  });
  state = state.copyWith(
    places: results.map((e) => Place.fromJson(e)).toList(),
    isLoading: false,
  );
}
```

### 3. Place Model (`place_model.dart`)

**Purpose**: Data class for place objects.

**Fields**:
```dart
class Place {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? districtId;
  final String? notes;
  final bool visited;
  
  // Add these:
  final String? category;
  final String? description;
  final List<String>? photos;
}
```

**Where to Make Changes**:
- **Add new fields**: Add to class and `fromJson`/`toJson`
- **Add computed properties**: Add getters

---

## API Endpoints

See detailed API documentation:
- [Destination Endpoints](../../backend/api-endpoints/destination-endpoints.md)
- [Geo Query Endpoints](../../backend/api-endpoints/geo-endpoints.md)

**Key Endpoints**:
- `POST /api/travel/:travelId/destinations` - Add place to trip
- `GET /api/travel/:travelId/destinations` - Get trip's places
- `GET /api/destinations/nearby?lat=&lng=&radius=` - Find nearby places
- `GET /api/destinations/within-bounds?swLat=&swLng=&neLat=&neLng=` - Places in map bounds

---

## Seeding Places Data

### Current Data

**File**: `project_resources/places_seed_data.json`

Contains Sri Lankan attractions with:
- Name, latitude, longitude
- District information
- Basic descriptions

### How to Seed

**Create seed script** (`backend/seed-places.js`):
```javascript
const mongoose = require('mongoose');
const Destination = require('./src/models/Destination');
const placesData = require('../project_resources/places_seed_data.json');

async function seedPlaces() {
  await mongoose.connect(process.env.MONGODB_URI);
  
  // Create places as "template" destinations (no userId/travelId)
  // Or create a separate Place model
  
  for (const place of placesData) {
    await Destination.create({
      name: place.name,
      latitude: place.latitude,
      longitude: place.longitude,
      districtId: place.district,
      notes: place.description,
      userId: 'system', // System placeholder
      travelId: null,
      visited: false
    });
  }
  
  console.log('Places seeded!');
  process.exit(0);
}

seedPlaces();
```

**Run seed**:
```bash
cd backend
node seed-places.js
```

---

## Common Modifications

### 1. Add Place Categories

**Backend** (`Destination.js`):
```javascript
category: {
  type: String,
  enum: ['temple', 'beach', 'mountain', 'historical', 'wildlife', 'city', 'food'],
  index: true
}
```

**Controller** (add filtering):
```javascript
const filter = { userId: req.user.auth0Id };
if (req.query.category) filter.category = req.query.category;
```

**Frontend** (filter UI):
```dart
DropdownButton<String>(
  value: selectedCategory,
  items: ['All', 'Temple', 'Beach', 'Mountain'].map((cat) {
    return DropdownMenuItem(value: cat, child: Text(cat));
  }).toList(),
  onChanged: (value) {
    ref.read(placesProvider.notifier).filterByCategory(value);
  },
)
```

### 2. Add Place Ratings

**Backend** (`Destination.js`):
```javascript
rating: {
  average: { type: Number, default: 0, min: 0, max: 5 },
  count: { type: Number, default: 0 }
}
```

**Frontend** (display rating):
```dart
Row(
  children: [
    Icon(Icons.star, color: Colors.amber, size: 16),
    Text('${place.rating.average.toStringAsFixed(1)} (${place.rating.count})'),
  ],
)
```

### 3. Add Photos/Gallery

**Backend** (`Destination.js`):
```javascript
photos: {
  type: [String], // Array of URLs
  default: []
}
```

**Frontend** (image carousel):
```dart
CarouselSlider(
  items: place.photos.map((url) {
    return CachedNetworkImage(imageUrl: url);
  }).toList(),
)
```

---

## Gamification Integration

### Unlock Districts by Visiting Places

**Backend** (`destinationController.js` - when marking visited):
```javascript
exports.markVisited = async (req, res) => {
  const dest = await Destination.findByIdAndUpdate(
    req.params.destId,
    { visited: true, visitedAt: new Date() },
    { new: true }
  );
  
  // Update user achievements
  const user = await User.findOne({ auth0Id: req.user.auth0Id });
  if (!user.unlockedDistricts.includes(dest.districtId)) {
    user.unlockedDistricts.push(dest.districtId);
    await user.save();
  }
  
  res.json({ destination: dest, user });
};
```

**Frontend** (show achievement):
```dart
if (response.unlockedNewDistrict) {
  showDialog(
    context: context,
    builder: (ctx) => AchievementDialog(
      title: 'District Unlocked!',
      message: 'You unlocked ${response.districtName}!',
    ),
  );
}
```

---

## Testing

### Backend Testing

```bash
# Get nearby places
curl "http://localhost:5000/api/destinations/nearby?lat=6.9271&lng=79.8612&radius=50" \
  -H "Authorization: Bearer TOKEN"

# Add place to trip
curl -X POST "http://localhost:5000/api/travel/TRIP_ID/destinations" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Sigiriya","latitude":7.9570,"longitude":80.7603,"districtId":"matale"}'
```

### Frontend Testing

```dart
// Test load places
final places = await ref.read(placesProvider.notifier).loadPlaces();
expect(places.length, greaterThan(0));

// Test search
await ref.read(placesProvider.notifier).searchPlaces('Sigiriya');
final results = ref.read(placesProvider).places;
expect(results.first.name, contains('Sigiriya'));
```

---

## See Also

- [Places Feature Spec](../features/places.md)
- [Destination API Endpoints](../../backend/api-endpoints/destination-endpoints.md)
- [Geospatial Queries](../../backend/api-endpoints/geo-endpoints.md)
- [Maps Feature](./maps.md)
- [Gamification](./achievements.md)
