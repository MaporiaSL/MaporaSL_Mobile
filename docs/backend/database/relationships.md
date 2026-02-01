# Database Relationships

This document describes how the Mongoose models in MAPORIA relate to each other, including ownership patterns, reference types, and cascade behaviors.

---

## Table of Contents

- [Relationship Overview](#relationship-overview)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Detailed Relationships](#detailed-relationships)
- [Query Patterns](#query-patterns)
- [Data Integrity Considerations](#data-integrity-considerations)

---

## Relationship Overview

MAPORIA uses a hybrid referencing approach:
- **String-based foreign keys** for User references (Auth0 ID)
- **ObjectId references** for document relationships (Travel ↔ Destination)
- **No embedded documents** - all relationships are via references

### Summary Table

| From Model | To Model | Relationship Type | Foreign Key | Cascade Delete |
|------------|----------|-------------------|-------------|----------------|
| Travel | User | Many-to-One | `userId` (String) | No |
| Destination | User | Many-to-One | `userId` (String) | No |
| Destination | Travel | Many-to-One | `travelId` (ObjectId) | No |
| PrePlannedTrip | *(standalone)* | None | - | N/A |

---

## Entity Relationship Diagram

```
┌─────────────────────┐
│       User          │
│  (Auth Provider)    │
├─────────────────────┤
│ auth0Id (PK)        │◄──────────────┐
│ email               │               │
│ name                │               │
│ profilePicture      │               │
│ unlockedDistricts[] │               │
│ unlockedProvinces[] │               │
│ achievements[]      │               │
│ totalPlacesVisited  │               │
└─────────────────────┘               │
                                      │
                                      │ userId (String)
                                      │
          ┌───────────────────────────┼─────────────────────────┐
          │                           │                         │
          │                           │                         │
┌─────────▼───────────┐     ┌─────────▼──────────┐            │
│      Travel         │     │    Destination     │            │
├─────────────────────┤     ├────────────────────┤            │
│ _id (PK)            │◄────┤ travelId (FK)      │            │
│ userId (FK)         │     │ userId (FK)        │────────────┘
│ title               │     │ name               │
│ description         │     │ latitude           │
│ startDate           │     │ longitude          │
│ endDate             │     │ location (GeoJSON) │
│ locations[]         │     │ districtId         │
│                     │     │ visited            │
│                     │     │ visitedAt          │
└─────────────────────┘     └────────────────────┘


┌─────────────────────┐
│   PrePlannedTrip    │
│   (Standalone)      │
├─────────────────────┤
│ _id (PK)            │
│ title               │
│ description         │
│ difficulty          │
│ durationDays        │
│ xpReward            │
│ placeIds[]          │
│ tags[]              │
│ startingPoint       │
└─────────────────────┘
```

---

## Detailed Relationships

### 1. User → Travel (One-to-Many)

**Relationship**: One user can create multiple trips.

**Implementation**:
```javascript
// Travel schema
userId: {
  type: String,      // Auth0 ID, not ObjectId
  required: true,
  index: true
}
```

**Why String instead of ObjectId?**
- User authentication is handled by Auth0 (external provider)
- `auth0Id` is the primary identifier, not MongoDB's `_id`
- Avoids needing to store duplicate user records in MongoDB

**Query Examples**:
```javascript
// Get all trips for a user
const trips = await Travel.find({ userId: 'auth0|123456789' });

// Get user's upcoming trips
const upcoming = await Travel.find({ 
  userId: 'auth0|123456789',
  startDate: { $gte: new Date() }
}).sort({ startDate: 1 });
```

**Navigation**:
- Forward: `User.auth0Id` → `Travel.userId` (requires manual join)
- Backward: `Travel.userId` → `User.auth0Id` (string match)

---

### 2. User → Destination (One-to-Many)

**Relationship**: One user can have multiple destinations across all their trips.

**Implementation**:
```javascript
// Destination schema
userId: {
  type: String,      // Auth0 ID
  required: true,
  index: true
}
```

**Purpose**:
- Track all user destinations for gamification
- Query visited places per user
- Calculate achievement progress

**Query Examples**:
```javascript
// Get all user destinations
const allDests = await Destination.find({ userId: 'auth0|123456789' });

// Get user's visited destinations
const visited = await Destination.find({ 
  userId: 'auth0|123456789',
  visited: true 
});

// Count destinations by district (for achievements)
const colomboVisits = await Destination.countDocuments({
  userId: 'auth0|123456789',
  districtId: 'colombo',
  visited: true
});
```

---

### 3. Travel → Destination (One-to-Many)

**Relationship**: One trip contains multiple destinations.

**Implementation**:
```javascript
// Destination schema
travelId: {
  type: mongoose.Schema.Types.ObjectId,
  required: true,
  ref: 'Travel',
  index: true
}
```

**Why ObjectId here?**
- Travel documents are stored in MongoDB
- Standard MongoDB reference pattern
- Enables `.populate()` for eager loading

**Query Examples**:
```javascript
// Get all destinations for a trip
const destinations = await Destination.find({ travelId: tripId });

// Get destinations with trip details
const dests = await Destination
  .find({ travelId: tripId })
  .populate('travelId'); // Populates trip details

// Get trip with all destinations (manual aggregation)
const tripWithDests = await Travel.findById(tripId);
const destinations = await Destination.find({ travelId: tripId });
```

**Compound Index**:
```javascript
destinationSchema.index({ userId: 1, travelId: 1 });
```
This enables efficient queries like "get all destinations for user X's trip Y".

---

### 4. PrePlannedTrip (Standalone)

**Relationship**: No direct relationships to other models.

**Purpose**:
- Curated trip templates created by admins
- Users browse and clone into their own Travel documents
- Standalone reference data

**Usage Pattern**:
```javascript
// User browses pre-planned trips
const culturalTrips = await PrePlannedTrip.find({ tags: 'culture' });

// User creates personal trip from template (manual copy)
const template = await PrePlannedTrip.findById(templateId);
const newTrip = new Travel({
  userId: currentUserId,
  title: template.title,
  description: template.description,
  // ... copy other fields
});
await newTrip.save();
```

**Not Used For**:
- Direct user ownership tracking
- Foreign key relationships
- Real-time user trip data

---

## Query Patterns

### Pattern 1: User's Complete Travel History

```javascript
const userId = 'auth0|123456789';

// Step 1: Get all user trips
const trips = await Travel.find({ userId }).sort({ startDate: -1 });

// Step 2: Get destinations for each trip
const tripIds = trips.map(t => t._id);
const destinations = await Destination.find({ 
  travelId: { $in: tripIds } 
});

// Step 3: Group destinations by trip
const tripMap = trips.map(trip => ({
  ...trip.toObject(),
  destinations: destinations.filter(d => 
    d.travelId.toString() === trip._id.toString()
  )
}));
```

**Index Usage**: 
- `Travel.userId` (single index)
- `Destination.travelId` (single index)

---

### Pattern 2: District Achievement Progress

```javascript
const userId = 'auth0|123456789';
const districtId = 'colombo';

// Count visited destinations in district
const visitedCount = await Destination.countDocuments({
  userId,
  districtId,
  visited: true
});

// Update user achievement
await User.updateOne(
  { auth0Id: userId },
  { 
    $addToSet: { unlockedDistricts: districtId },
    $inc: { totalPlacesVisited: visitedCount }
  }
);
```

**Index Usage**:
- `Destination.userId` + `Destination.districtId` (requires compound index for optimization)

---

### Pattern 3: Geospatial Proximity with User Context

```javascript
// Find nearby destinations for user's active trip
const nearby = await Destination.find({
  userId: currentUserId,
  travelId: activeTripId,
  location: {
    $near: {
      $geometry: {
        type: 'Point',
        coordinates: [userLng, userLat]
      },
      $maxDistance: 5000 // 5km
    }
  }
});
```

**Index Usage**:
- `Destination.location` (2dsphere index)
- Compound index `{ userId: 1, travelId: 1 }` enhances filtering

---

## Data Integrity Considerations

### 1. No Cascade Deletes

**Current Behavior**: Models do not implement cascade delete middleware.

**Implications**:
- Deleting a `User` does NOT delete their `Travel` or `Destination` records
- Deleting a `Travel` does NOT delete associated `Destination` records
- Orphaned data may accumulate

**Recommended Implementation**:
```javascript
// Add to backend/src/controllers/userController.js
async deleteUser(req, res) {
  const userId = req.user.auth0Id;
  
  // Manual cascade delete
  await Destination.deleteMany({ userId });
  await Travel.deleteMany({ userId });
  await User.deleteOne({ auth0Id: userId });
  
  res.json({ message: 'User and all data deleted' });
}
```

---

### 2. Referential Integrity

**Current State**: No database-level foreign key constraints (MongoDB doesn't support them).

**Risks**:
- A `Destination` can reference a non-existent `travelId`
- A `Travel` can reference a non-existent `userId`

**Mitigation**:
```javascript
// Add validation in controller
const travel = await Travel.findById(req.body.travelId);
if (!travel) {
  return res.status(404).json({ error: 'Travel not found' });
}
if (travel.userId !== req.user.auth0Id) {
  return res.status(403).json({ error: 'Unauthorized' });
}
```

---

### 3. Data Consistency

**Scenario**: User's `totalPlacesVisited` may drift from actual count.

**Solution**: Periodic consistency checks
```javascript
// Cron job or admin endpoint
async function reconcileUserStats(userId) {
  const visitedCount = await Destination.countDocuments({
    userId,
    visited: true
  });
  
  await User.updateOne(
    { auth0Id: userId },
    { totalPlacesVisited: visitedCount }
  );
}
```

---

## Migration Notes

### Adding Relationships

If you need to add new relationships:

1. **Add foreign key field** to schema with index
2. **Create compound indexes** for common query patterns
3. **Implement validation** in controllers
4. **Add cascade delete logic** if needed
5. **Update this documentation**

### Example: Link PrePlannedTrip to User Bookmarks

```javascript
// 1. Add to User schema
bookmarkedTrips: [{
  type: mongoose.Schema.Types.ObjectId,
  ref: 'PrePlannedTrip'
}]

// 2. Create index
userSchema.index({ 'bookmarkedTrips': 1 });

// 3. Query pattern
const user = await User.findOne({ auth0Id: userId })
  .populate('bookmarkedTrips');
```

---

## See Also

- [models.md](./models.md) - Detailed schema documentation
- [indexes-optimization.md](./indexes-optimization.md) - Index performance analysis
- [API Endpoints](../api-endpoints/) - How relationships are exposed via REST API
