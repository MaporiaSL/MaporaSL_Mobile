# Database Models Documentation

This document provides comprehensive documentation for all Mongoose models used in MAPORIA. Each model is documented with its purpose, schema structure, validation rules, and usage examples.

---

## Table of Contents

- [User Model](#user-model)
- [Travel Model](#travel-model)
- [Destination Model](#destination-model)
- [PrePlannedTrip Model](#preplannedtrip-model)

---

## User Model

**File Location:** `backend/src/models/User.js`

### Purpose
Stores user account information and gamification progress. Integrated with Firebase Auth for authentication and tracks district/province exploration progress.

### Schema Structure

| Field | Type | Required | Default | Indexed | Description |
|-------|------|----------|---------|---------|-------------|
| `firebaseUid` | String | ✓ | - | ✓ (unique) | Firebase user identifier |
| `email` | String | ✓ | - | ✓ (unique) | User email (lowercase) |
| `name` | String | ✓ | - | - | User's display name |
| `profilePicture` | String | - | null | - | URL to profile image |
| `unlockedDistricts` | [String] | - | [] | - | Array of unlocked district IDs |
| `unlockedProvinces` | [String] | - | [] | - | Array of unlocked province IDs |
| `achievements` | [Object] | - | [] | - | Achievement progress tracking |
| `achievements.districtId` | String | ✓ | - | - | District identifier |
| `achievements.progress` | Number | - | 0 | - | Progress percentage (0-100) |
| `achievements.unlockedAt` | Date | - | null | - | Unlock timestamp |
| `totalPlacesVisited` | Number | - | 0 | - | Total visited destinations counter |
| `createdAt` | Date | - | Date.now | - | Account creation timestamp |
| `updatedAt` | Date | - | Date.now | - | Last update timestamp |

### Validation Rules

- **firebaseUid**: Must be unique across all users
- **email**: Must be unique, automatically converted to lowercase
- **name**: Required for user identification

### Indexes

```javascript
// Single field indexes
firebaseUid: unique, indexed  // Fast Firebase UID lookup
email: unique, indexed     // Fast email lookup
```

### Middleware

**Pre-save Hook**: Automatically updates `updatedAt` timestamp on every save operation.

```javascript
userSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});
```

### Usage Examples

**Create a new user:**
```javascript
const user = new User({
  firebaseUid: 'firebase-uid-123456789',
  email: 'john@example.com',
  name: 'John Doe',
  profilePicture: 'https://example.com/profile.jpg'
});
await user.save();
```

**Update gamification progress:**
```javascript
const user = await User.findOne({ firebaseUid: 'firebase-uid-123456789' });
user.unlockedDistricts.push('colombo');
user.totalPlacesVisited += 1;
await user.save(); // updatedAt automatically set
```

**Track achievement progress:**
```javascript
const user = await User.findOne({ firebaseUid: 'firebase-uid-123456789' });
user.achievements.push({
  districtId: 'colombo',
  progress: 75,
  unlockedAt: null
});
await user.save();
```

### Related Models
- Referenced by: [Travel](#travel-model) (via userId)
- Referenced by: [Destination](#destination-model) (via userId)

---

## Travel Model

**File Location:** `backend/src/models/Travel.js`

### Purpose
Represents a travel trip or journey planned by a user. Contains trip metadata and associated locations.

### Schema Structure

| Field | Type | Required | Default | Indexed | Description |
|-------|------|----------|---------|---------|-------------|
| `userId` | String | ✓ | - | ✓ | Firebase UID (foreign key) |
| `title` | String | ✓ | - | - | Trip title (min 3 chars) |
| `description` | String | - | null | - | Optional trip description |
| `startDate` | Date | ✓ | - | ✓ (compound) | Trip start date |
| `endDate` | Date | ✓ | - | - | Trip end date |
| `locations` | [String] | - | [] | - | Array of location names |
| `createdAt` | Date | - | Date.now | - | Record creation timestamp |
| `updatedAt` | Date | - | Date.now | - | Last update timestamp |

### Validation Rules

- **title**: Minimum length of 3 characters
- **startDate**: Required for trip planning
- **endDate**: Required for trip planning

### Indexes

```javascript
// Single field index
userId: indexed  // Fast user-specific queries

// Compound index
{ userId: 1, startDate: 1 }  // Optimized for chronological trip listing
```

### Middleware

**Pre-save Hook**: Automatically updates `updatedAt` timestamp.

```javascript
travelSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});
```

### Usage Examples

**Create a new trip:**
```javascript
const travel = new Travel({
  userId: 'firebase-uid-123456789',
  title: 'Sri Lanka Cultural Triangle',
  description: 'Exploring ancient cities of Anuradhapura, Polonnaruwa, and Sigiriya',
  startDate: new Date('2024-07-01'),
  endDate: new Date('2024-07-07'),
  locations: ['Anuradhapura', 'Polonnaruwa', 'Sigiriya']
});
await travel.save();
```

**Query user's trips chronologically:**
```javascript
const trips = await Travel.find({ userId: 'firebase-uid-123456789' })
  .sort({ startDate: -1 }); // Uses compound index
```

**Update trip details:**
```javascript
const trip = await Travel.findById(tripId);
trip.title = 'Updated Trip Title';
trip.locations.push('Dambulla');
await trip.save(); // updatedAt automatically updated
```

### Related Models
- References: [User](#user-model) (via userId)
- Referenced by: [Destination](#destination-model) (via travelId)

---

## Destination Model

**File Location:** `backend/src/models/Destination.js`

### Purpose
Represents individual destinations/places within a trip. Supports geospatial queries and visit tracking for gamification.

### Schema Structure

| Field | Type | Required | Default | Indexed | Description |
|-------|------|----------|---------|---------|-------------|
| `userId` | String | ✓ | - | ✓ (compound) | Firebase UID |
| `travelId` | ObjectId | ✓ | - | ✓ (compound) | Reference to Travel document |
| `name` | String | ✓ | - | - | Destination name (min 2 chars) |
| `latitude` | Number | ✓ | - | - | Latitude coordinate (-90 to 90) |
| `longitude` | Number | ✓ | - | - | Longitude coordinate (-180 to 180) |
| `notes` | String | - | null | - | Optional user notes |
| `visited` | Boolean | - | false | - | Visit status flag |
| `visitedAt` | Date | - | null | - | Visit timestamp |
| `districtId` | String | - | null | ✓ | District identifier for gamification |
| `location` | Object | - | - | 2dsphere | GeoJSON point for geospatial queries |
| `location.type` | String | - | 'Point' | - | GeoJSON type (always 'Point') |
| `location.coordinates` | [Number] | ✓ | - | 2dsphere | [longitude, latitude] array |
| `createdAt` | Date | - | Date.now | - | Record creation timestamp |
| `updatedAt` | Date | - | Date.now | - | Last update timestamp |

### Validation Rules

- **name**: Minimum length of 2 characters
- **latitude**: Must be between -90 and 90
- **longitude**: Must be between -180 and 180
- **location.type**: Must be 'Point' (GeoJSON standard)

### Indexes

```javascript
// Single field indexes
userId: indexed
travelId: indexed
districtId: indexed  // For gamification queries

// Compound index
{ userId: 1, travelId: 1 }  // Optimized for fetching trip destinations

// Geospatial index
location: '2dsphere'  // Enables proximity searches
```

### Middleware

**Pre-save Hook**: Automatically updates timestamp and syncs GeoJSON location from lat/lng.

```javascript
destinationSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  if (this.isModified('latitude') || this.isModified('longitude')) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude]
    };
  }
  next();
});
```

### Usage Examples

**Create a new destination:**
```javascript
const destination = new Destination({
  userId: 'firebase-uid-123456789',
  travelId: ObjectId('60a7b8c9d1e2f3g4h5i6j7k8'),
  name: 'Sigiriya Rock Fortress',
  latitude: 7.9570,
  longitude: 80.7603,
  districtId: 'matale',
  notes: 'Visit early morning for best views'
});
await destination.save(); // location field auto-populated
```

**Mark destination as visited:**
```javascript
const dest = await Destination.findById(destId);
dest.visited = true;
dest.visitedAt = new Date();
await dest.save();
```

**Geospatial proximity query:**
```javascript
// Find destinations within 10km of coordinates
const nearby = await Destination.find({
  location: {
    $near: {
      $geometry: {
        type: 'Point',
        coordinates: [80.7603, 7.9570] // [lng, lat]
      },
      $maxDistance: 10000 // meters
    }
  }
});
```

**Query destinations by district:**
```javascript
const districtDests = await Destination.find({ 
  districtId: 'colombo',
  visited: true 
});
```

### Related Models
- References: [User](#user-model) (via userId)
- References: [Travel](#travel-model) (via travelId)

---

## PrePlannedTrip Model

**File Location:** `backend/src/models/PrePlannedTrip.js`

### Purpose
Stores curated trip templates for users to browse and adopt. Used for trip suggestions and gamification challenges.

### Schema Structure

| Field | Type | Required | Default | Indexed | Description |
|-------|------|----------|---------|---------|-------------|
| `title` | String | ✓ | - | - | Trip template name |
| `description` | String | ✓ | - | - | Detailed trip description |
| `difficulty` | String | ✓ | - | - | Trip difficulty (Easy/Moderate/Hard) |
| `durationDays` | Number | ✓ | - | - | Trip duration (min 1 day) |
| `xpReward` | Number | - | 100 | - | Experience points reward |
| `placeIds` | [String] | - | [] | - | Array of place identifiers |
| `tags` | [String] | - | [] | - | Category tags (culture, nature, etc) |
| `startingPoint` | String | - | null | - | Recommended starting location |
| `createdAt` | Date | - | Date.now | - | Record creation timestamp |
| `updatedAt` | Date | - | Date.now | - | Last update timestamp |

### Validation Rules

- **difficulty**: Must be one of: 'Easy', 'Moderate', 'Hard'
- **durationDays**: Minimum value of 1

### Indexes

No custom indexes defined. Default `_id` index only.

### Middleware

**Pre-save Hook**: Automatically updates `updatedAt` timestamp.

```javascript
preplannedTripSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});
```

### Usage Examples

**Create a pre-planned trip:**
```javascript
const trip = new PrePlannedTrip({
  title: 'Cultural Triangle Explorer',
  description: 'Visit the ancient kingdoms of Sri Lanka',
  difficulty: 'Moderate',
  durationDays: 5,
  xpReward: 500,
  placeIds: ['sigiriya', 'polonnaruwa', 'anuradhapura'],
  tags: ['culture', 'history', 'unesco'],
  startingPoint: 'Dambulla'
});
await trip.save();
```

**Query trips by difficulty:**
```javascript
const easyTrips = await PrePlannedTrip.find({ difficulty: 'Easy' });
```

**Query trips by tags:**
```javascript
const cultureTrips = await PrePlannedTrip.find({ tags: 'culture' });
```

**Calculate total XP for user journey:**
```javascript
const selectedTrips = await PrePlannedTrip.find({
  _id: { $in: userSelectedTripIds }
});
const totalXP = selectedTrips.reduce((sum, trip) => sum + trip.xpReward, 0);
```

### Related Models
- Standalone model (no direct references to other collections)
- Used as templates for creating [Travel](#travel-model) instances

---

## Common Patterns

### Timestamps
All models use `createdAt` and `updatedAt` fields with automatic timestamp management via pre-save hooks.

### User Ownership
Three models (`User`, `Travel`, `Destination`) use `userId` (Firebase UID string) for user association. This enables multi-tenant data isolation and fast user-specific queries.

### Soft References
- `Travel.userId` → `User.firebaseUid` (string reference)
- `Destination.userId` → `User.firebaseUid` (string reference)
- `Destination.travelId` → `Travel._id` (ObjectId reference)

### Geospatial Data
`Destination` model uses GeoJSON Point format for location storage, enabling MongoDB's geospatial query operators (`$near`, `$geoWithin`, etc.).

---

## Next Steps

- **See [relationships.md](./relationships.md)** for detailed model relationship diagrams
- **See [indexes-optimization.md](./indexes-optimization.md)** for index performance analysis
- **See [API Endpoints](../api-endpoints/)** for how these models are accessed via REST API
