# District Places Assignment System - Implementation Guide

**Date**: February 23, 2026  
**Status**: ✅ Complete

## Overview

The district map exploration feature now assigns real, ever-growing places from a database for users to visit in order to unlock each district. As new places are added to the database, new users (or those who reroll) will get dynamically assigned places based on what's available.

## Architecture

### Backend Components

#### 1. **Place Model** (`backend/src/models/Place.js`)
New MongoDB model for the ever-growing places catalog with fields:
- `name`, `description`, `category`
- `district`, `province`, `address`
- `latitude`, `longitude`, `location` (GeoJSON for geospatial queries)
- `googleMapsUrl`, `type`, `photos`
- `rating`, `reviewCount`
- `source` (system, user-contributed, migrated)
- `accessibility` (difficulty, duration, entryFee)
- `isActive`, `verified`, `tags`

#### 2. **Exploration Controller** (updated `backend/src/controllers/explorationController.js`)
Modified to:
- Accept assignments from **either** Place **or** UnlockLocation collections
- Dynamically fetch active places for each district when assigning
- Fall back to UnlockLocation for backward compatibility
- Support both old and new location data sources

Key functions:
- `assignExplorationForUser()` - Dynamically assigns places from Place collection
- `getAssignments()` - Fetches assigned places with all metadata
- `visitLocation()` - Verifies GPS location visits
- `getAssignments()` returns: `id`, `name`, `type`, `latitude`, `longitude`, `description`, `category`, `photos`, `visited`

#### 3. **Places Controller** (`backend/src/controllers/placeController.js`)
New endpoints for place discovery:
- `GET /api/places` - List all places with pagination & filtering
- `GET /api/places/:id` - Get single place
- `GET /api/places/district/:district` - Get places by district
- `GET /api/places/search?q=query` - Search places
- `GET /api/places/nearby?latitude=X&longitude=Y` - Geospatial query
- `GET /api/places/stats` - Statistics by district & category

#### 4. **Updated Routes** (`backend/src/routes/placeRoutes.js`)
```javascript
router.get('/', getPlaces);                    // All places
router.get('/stats', getPlacesStats);          // Statistics
router.get('/search', searchPlaces);           // Search
router.get('/nearby', getNearbyPlaces);        // Nearby
router.get('/district/:district', getPlacesByDistrict);  // By district
router.get('/:id', getPlaceById);              // Single place
```

#### 5. **Seeding Script** (`backend/seed-places.js`, updated)
Now seeds **both**:
- **Place collection** - New model with full metadata
- **Destination collection** - Legacy system compatibility

Run: `node backend/seed-places.js`

### Frontend Components

#### 1. **Updated Models** (`mobile/lib/features/exploration/data/models/exploration_models.dart`)
`ExplorationLocation` now includes:
```dart
final String? description;
final String? category;
final List<String> photos;
```

#### 2. **Existing API** (`mobile/lib/features/exploration/data/exploration_api.dart`)
Already compatible! Automatically receives new fields from backend.

#### 3. **Map Display** (`mobile/lib/features/map/presentation/map_screen.dart`)
- Loads assignments via `explorationProvider`
- Displays assigned locations for each district
- Shows progress (visited/assigned)
- Can display place photos, descriptions, categories

## Data Flow

### 1. User "Starts Exploration"
```
User selects hometown district
    ↓
Backend: assignExplorationForUser(userId, hometown)
    ↓
Query Place collection for each district
    ↓
Randomly select 3-7 places per district (tier-based)
    ↓
Save to UserDistrictAssignment
    ↓
Frontend: loadAssignments()
    ↓
Display assigned places on map
```

### 2. User Visits a Location
```
User taps location marker
    ↓
App collects GPS samples (3+ readings)
    ↓
POST /api/exploration/visit with samples
    ↓
Backend: Verify GPS proximity
    ↓
Mark as visited + award XP
    ↓
Check if all places in district visited → unlock
    ↓
Frontend: Refresh assignments
    ↓
Show district unlocked badge
```

### 3. New Places Added to DB
```
Admin/user adds place to Place collection
    ↓
Place is marked as active & verified
    ↓
Next user signup → gets assigned new places
    ↓
Existing user rerolls → gets new assignment with new places
    ↓
Ever-growing list available to explore
```

## API Response Example

### Assignments Response
```json
{
  "assignments": [
    {
      "district": "Colombo",
      "province": "Western",
      "assignedCount": 5,
      "visitedCount": 2,
      "unlockedAt": null,
      "locations": [
        {
          "id": "507f1f77bcf86cd799439011",
          "name": "Colombo National Museum",
          "type": "museum",
          "latitude": 6.925,
          "longitude": 79.865,
          "description": "Sri Lanka's premier museum",
          "category": "cultural",
          "photos": ["https://..."],
          "visited": true
        },
        {
          "id": "507f1f77bcf86cd799439012",
          "name": "Beira Lake",
          "type": "lake",
          "latitude": 6.915,
          "longitude": 79.860,
          "description": "Historic lake in Colombo",
          "category": "water",
          "photos": ["https://..."],
          "visited": false
        }
      ]
    }
  ]
}
```

## Getting Started

### Step 1: Ensure MongoDB Connection
```bash
# Check .env has MONGODB_URI
echo $MONGODB_URI
```

### Step 2: Seed Initial Places
```bash
cd backend
node seed-places.js
```

Output:
```
Connected to MongoDB
Processing 25 districts...
Inserting 150+ places...
Successfully inserted 150 places to Place collection
Successfully imported 145 places to Destination collection

--- Summary ---
Total districts: 25
Places per district:
  Colombo: 7 places
  Galle: 6 places
  ...
```

### Step 3: Test API Endpoints
```bash
# Get all places
curl http://localhost:5000/api/places?limit=5

# Get places by district
curl http://localhost:5000/api/places/district/Colombo

# Get statistics
curl http://localhost:5000/api/places/stats
```

### Step 4: Test in Mobile App
```bash
cd mobile
flutter run
```

When user clicks "Start Exploration":
- Assignments automatically fetched from backend
- Each district shows assigned places
- Tapping place marker starts GPS verification
- Visited places get checkmarks
- 100% visited = district unlocked!

## Key Features

### ✅ Dynamic Assignment
- Places fetched from database at assignment time
- Randomized selection per district
- Different tiers for hometown vs remote districts
- New places available for new users & rerolls

### ✅ Backward Compatibility
- `UnlockLocation` collection still supported
- Exploration system auto-detects data source
- Old Destination system still works

### ✅ Rich Metadata
- Place descriptions, categories, photos
- Geospatial queries (nearby places)
- Search functionality
- Rating & review counts
- Accessibility info

### ✅ Scalable
- New places can be added anytime
- No redeployment needed
- Supports user-contributed places
- Verified & community feedback

## Monitoring

### Check Places in DB
```bash
# MongoDB shell
db.places.countDocuments({isActive: true})
db.places.aggregate([
  {$match: {isActive: true}},
  {$group: {_id: "$district", count: {$sum: 1}}},
  {$sort: {count: -1}}
])
```

### Check User Assignments
```bash
db.userdistrictassignments.findOne({userId: "user123"})
```

## Future Enhancements

- [ ] User-contributed places with admin approval
- [ ] Place ratings & reviews from users
- [ ] Photo upload from exploration visits
- [ ] Social sharing of visited places
- [ ] Achievements for specific place categories
- [ ] Seasonal place recommendations
- [ ] Difficulty-based place filtering
- [ ] Community moderation of places

## Troubleshooting

### "No places found in either Place or UnlockLocation"
**Solution**: Run `node seed-places.js` to populate collections

### "District not found in places catalog"
**Solution**: 
- Check seed data has that district
- Verify Place collection has entries: `db.places.find({district: "DistrictName"})`

### Places not showing in exploration map
**Solution**:
- Check `/api/exploration/assignments` returns locations
- Verify Place model imported correctly in explorationController
- Check browser console for API errors

### GPS verification always fails
**Solution**:
- Increase MAX_DISTANCE_METERS in explorationController (default: 100m)
- Ensure GPS accuracy < 50m
- Collect 3+ samples with 2-second intervals

## Files Modified

### Backend
- ✅ `backend/src/models/Place.js` - NEW
- ✅ `backend/src/controllers/explorationController.js` - Updated
- ✅ `backend/src/controllers/placeController.js` - Updated
- ✅ `backend/src/routes/placeRoutes.js` - Updated
- ✅ `backend/seed-places.js` - Updated

### Frontend
- ✅ `mobile/lib/features/exploration/data/models/exploration_models.dart` - Updated

## API Endpoints Quick Reference

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/places` | List all places |
| GET | `/api/places/:id` | Get single place |
| GET | `/api/places/stats` | Statistics |
| GET | `/api/places/search?q=X` | Search |
| GET | `/api/places/nearby` | Geospatial |
| GET | `/api/places/district/:name` | By district |
| GET | `/api/exploration/assignments` | User assignments |
| GET | `/api/exploration/districts` | District progress |
| POST | `/api/exploration/visit` | Visit location |
| POST | `/api/exploration/reroll` | Reroll assignments |

---

**Status**: ✅ Implementation Complete  
**Ready for**: User testing, place additions, feedback loop
