# Database Schema Documentation

**Database**: MongoDB (Atlas)  
**ORM**: Mongoose  
**Last Updated**: January 24, 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Collections](#collections)
3. [Relationships](#relationships)
4. [Indexes](#indexes)
5. [Data Flow](#data-flow)

---

## Overview

The database follows a document-based NoSQL structure with three main collections:
- **users** - Authenticated user profiles
- **travels** - User's travel/trip records
- **destinations** - Places within travels (nested resources)

All data is isolated by `userId` to ensure users can only access their own data.

---

## Collections

### User Collection

**Collection Name**: `users`

**Schema**:
```javascript
{
  _id: ObjectId,
  firebaseUid: String,    // Unique identifier from Firebase Auth
  email: String,          // User's email address
  name: String,           // User's display name
  profilePicture: String, // URL to profile image
  createdAt: Date,        // Account creation timestamp
  updatedAt: Date         // Last update timestamp
}
```

**Field Details**:

| Field | Type | Required | Unique | Indexed | Description |
|-------|------|----------|--------|---------|-------------|
| _id | ObjectId | Yes | Yes | Yes (auto) | MongoDB document ID |
| firebaseUid | String | Yes | Yes | Yes | Firebase user identifier (e.g., "firebase-uid-123456") |
| email | String | Yes | Yes | Yes | User's email address |
| name | String | Yes | No | No | User's full name |
| profilePicture | String | No | No | No | URL to profile photo |
| createdAt | Date | Yes | No | No | Account creation timestamp |
| updatedAt | Date | Yes | No | No | Last modification timestamp |

**Constraints**:
- `firebaseUid` must be unique (Firebase Auth enforces uniqueness)
- `email` must be unique and valid email format
- Timestamps auto-managed by Mongoose

**Indexes**:
- `firebaseUid` (unique) - Fast lookup by Firebase UID
- `email` (unique) - Fast lookup by email

**Example Document**:
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "firebaseUid": "firebase-uid-123456789abcdef",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "profilePicture": "https://example.com/avatar.jpg",
  "createdAt": "2026-01-24T10:00:00.000Z",
  "updatedAt": "2026-01-24T10:00:00.000Z"
}
```

---

### Travel Collection

**Collection Name**: `travels`

**Schema**:
```javascript
{
  _id: ObjectId,
  userId: ObjectId,       // Reference to User._id
  title: String,          // Travel title (min 3 chars)
  description: String,    // Optional travel description
  startDate: Date,        // Trip start date
  endDate: Date,          // Trip end date (must be > startDate)
  locations: [String],    // Array of location names
  createdAt: Date,        // Record creation timestamp
  updatedAt: Date         // Last update timestamp
}
```

**Field Details**:

| Field | Type | Required | Indexed | Validation | Description |
|-------|------|----------|---------|------------|-------------|
| _id | ObjectId | Yes | Yes (auto) | - | MongoDB document ID |
| userId | ObjectId | Yes | Yes | Must exist in users | Owner's user ID |
| title | String | Yes | No | Min 3 characters | Travel/trip title |
| description | String | No | No | - | Detailed description |
| startDate | Date | Yes | Yes (compound) | ISO8601 format | Trip start date |
| endDate | Date | Yes | No | Must be > startDate | Trip end date |
| locations | Array<String> | No | No | - | List of location names |
| createdAt | Date | Yes | No | - | Record creation timestamp |
| updatedAt | Date | Yes | No | - | Last modification timestamp |

**Constraints**:
- `title` minimum 3 characters
- `endDate` must be after `startDate`
- All queries must filter by `userId`

**Indexes**:
- `userId` (single) - Filter travels by user
- `{ userId: 1, startDate: -1 }` (compound) - Efficient sorted queries by user

**Pre-save Hook**:
- Updates `updatedAt` on every save operation

**Example Document**:
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "userId": "507f191e810c19729de860ea",
  "title": "Sri Lanka Adventure",
  "description": "Two week trip exploring the beautiful island nation",
  "startDate": "2024-03-01T00:00:00.000Z",
  "endDate": "2024-03-15T00:00:00.000Z",
  "locations": ["Colombo", "Kandy", "Galle", "Ella"],
  "createdAt": "2026-01-24T10:00:00.000Z",
  "updatedAt": "2026-01-24T10:00:00.000Z"
}
```

---

### Destination Collection

**Collection Name**: `destinations`

**Schema**:
```javascript
{
  _id: ObjectId,
  userId: ObjectId,       // Reference to User._id
  travelId: ObjectId,     // Reference to Travel._id
  name: String,           // Destination name (min 2 chars)
  latitude: Number,       // Latitude coordinate (-90 to 90)
  longitude: Number,      // Longitude coordinate (-180 to 180)
  notes: String,          // Optional notes about destination
  visited: Boolean,       // Whether user has visited (default: false)
  createdAt: Date,        // Record creation timestamp
  updatedAt: Date         // Last update timestamp
}
```

**Field Details**:

| Field | Type | Required | Indexed | Validation | Description |
|-------|------|----------|---------|------------|-------------|
| _id | ObjectId | Yes | Yes (auto) | - | MongoDB document ID |
| userId | ObjectId | Yes | Yes | Must exist in users | Owner's user ID |
| travelId | ObjectId | Yes | Yes | Must exist in travels | Parent travel ID |
| name | String | Yes | No | Min 2 characters | Destination name |
| latitude | Number | Yes | No | -90 to 90 | Latitude coordinate |
| longitude | Number | Yes | No | -180 to 180 | Longitude coordinate |
| notes | String | No | No | - | Additional notes |
| visited | Boolean | No | No | - | Visited status (default: false) |
| createdAt | Date | Yes | No | - | Record creation timestamp |
| updatedAt | Date | Yes | No | - | Last modification timestamp |

**Constraints**:
- `name` minimum 2 characters
- `latitude` must be between -90 and 90 (valid geographic range)
- `longitude` must be between -180 and 180 (valid geographic range)
- All queries must filter by `userId` and optionally `travelId`

**Indexes**:
- `userId` (single) - Filter destinations by user
- `travelId` (single) - Filter destinations by travel
- `{ userId: 1, travelId: 1 }` (compound) - Efficient nested queries

**Pre-save Hook**:
- Updates `updatedAt` on every save operation

**Example Document**:
```json
{
  "_id": "507f1f77bcf86cd799439022",
  "userId": "507f191e810c19729de860ea",
  "travelId": "507f1f77bcf86cd799439011",
  "name": "Sigiriya Rock Fortress",
  "latitude": 7.9570,
  "longitude": 80.7603,
  "notes": "Ancient rock fortress with stunning frescoes. Best visited at sunrise.",
  "visited": true,
  "createdAt": "2026-01-24T10:15:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

---

## Relationships

### Entity Relationship Diagram

```
┌─────────────────┐
│     User        │
│  firebaseUid (UK)   │
│  email (UK)     │
│  name           │
└────────┬────────┘
         │ 1
         │
         │ has many
         │
         ┼ N
┌────────┴────────┐
│     Travel      │
│  userId (FK)    │
│  title          │
│  startDate      │
│  endDate        │
└────────┬────────┘
         │ 1
         │
         │ has many
         │
         ┼ N
┌────────┴────────┐
│  Destination    │
│  userId (FK)    │
│  travelId (FK)  │
│  name           │
│  latitude       │
│  longitude      │
└─────────────────┘
```

### Relationship Details

**User → Travel** (One-to-Many)
- One user can have multiple travels
- Each travel belongs to exactly one user
- Foreign Key: `Travel.userId` references `User._id`
- Cascade: Deleting user does NOT auto-delete travels (handle in application logic if needed)

**Travel → Destination** (One-to-Many)
- One travel can have multiple destinations
- Each destination belongs to exactly one travel
- Foreign Key: `Destination.travelId` references `Travel._id`
- Cascade: Deleting travel DOES auto-delete all associated destinations

**User → Destination** (One-to-Many)
- Destinations also store `userId` for direct user filtering
- This denormalization improves query performance
- Allows efficient "all my destinations" queries without joining through travels

---

## Indexes

### User Collection Indexes

```javascript
users.createIndex({ firebaseUid: 1 }, { unique: true })
users.createIndex({ email: 1 }, { unique: true })
```

**Purpose**:
- Fast authentication lookup by Firebase UID
- Fast email-based queries
- Enforce uniqueness constraints

---

### Travel Collection Indexes

```javascript
travels.createIndex({ userId: 1 })
travels.createIndex({ userId: 1, startDate: -1 })
```

**Purpose**:
- Single index: Filter all travels by user
- Compound index: Efficient sorted queries (newest/oldest first by start date)

**Query Examples**:
```javascript
// Uses userId index
Travel.find({ userId: "507f191e810c19729de860ea" })

// Uses compound index
Travel.find({ userId: "507f191e810c19729de860ea" })
      .sort({ startDate: -1 })
```

---

### Destination Collection Indexes

```javascript
destinations.createIndex({ userId: 1 })
destinations.createIndex({ travelId: 1 })
destinations.createIndex({ userId: 1, travelId: 1 })
```

**Purpose**:
- Single userId index: Get all destinations for a user
- Single travelId index: Get all destinations for a travel
- Compound index: Most efficient for nested resource queries

**Query Examples**:
```javascript
// Uses userId index
Destination.find({ userId: "507f191e810c19729de860ea" })

// Uses compound index (most efficient)
Destination.find({ 
  userId: "507f191e810c19729de860ea",
  travelId: "507f1f77bcf86cd799439011" 
})
```

---

## Data Flow

### User Registration Flow

```
1. User authenticates with Firebase Auth → Receives ID token
2. Frontend calls POST /api/auth/register with JWT
3. Backend extracts firebaseUid from ID token
4. Check if User with firebaseUid exists
   - YES: Return existing user (200)
   - NO: Create new User document (201)
5. Return user data to frontend
```

### Travel Creation Flow

```
1. User calls POST /api/travel with JWT
2. Backend extracts userId from JWT
3. Validate input (title, dates, etc.)
4. Create Travel document with userId
5. Return created travel (201)
```

### Destination Creation Flow

```
1. User calls POST /api/travel/:travelId/destinations with JWT
2. Backend extracts userId from JWT
3. Verify Travel exists and belongs to user
   - NO: Return 404
   - YES: Continue
4. Validate input (name, coordinates, etc.)
5. Create Destination document with userId AND travelId
6. Return created destination (201)
```

### Cascade Delete Flow

```
When Travel is deleted:

1. User calls DELETE /api/travel/:travelId
2. Backend verifies Travel belongs to user
3. Delete all Destinations where travelId matches
   → Destination.deleteMany({ travelId: travelId })
4. Delete the Travel document
5. Return success (200)
```

---

## Data Isolation Strategy

All data is isolated by `userId`:

**Authentication Layer**:
1. JWT middleware extracts `sub` claim from token
2. `extractUserId` middleware attaches `req.userId`
3. Controllers use `req.userId` to filter ALL queries

**Query Pattern**:
```javascript
// Always filter by userId
Travel.find({ userId: req.userId })
Destination.find({ userId: req.userId, travelId: travelId })
```

**Security Guarantee**:
- Users can ONLY access their own data
- Attempting to access another user's resource returns 404
- No cross-user data leakage possible

---

## Storage Estimates

Based on typical document sizes:

| Collection | Avg Size | 1K Users | 10K Users | 100K Users |
|------------|----------|----------|-----------|------------|
| User | 300 bytes | 300 KB | 3 MB | 30 MB |
| Travel | 500 bytes | 10 MB* | 100 MB* | 1 GB* |
| Destination | 400 bytes | 40 MB** | 400 MB** | 4 GB** |

*Assuming 20 travels per user  
**Assuming 100 destinations per user

**MongoDB Atlas Free Tier**: 512 MB storage (suitable for ~25K users with avg usage)

---

## Backup Strategy

**MongoDB Atlas Automatic Backups**:
- Atlas provides continuous backups
- Point-in-time recovery available
- Retention: 7 days (free tier), customizable (paid tiers)

**Export Strategy**:
```bash
# Manual backup using mongodump
mongodump --uri="mongodb+srv://..." --out=backup/

# Restore from backup
mongorestore --uri="mongodb+srv://..." backup/
```

---

## Schema Evolution

### Version History

**v1.0.0** (Current - January 24, 2026):
- Initial schema with User, Travel, Destination collections
- Basic indexes for performance
- Cascade delete for Travel → Destination

### Future Considerations

**Potential Additions**:
- `photos` array in Destination for image URLs
- `tags` array in Travel for categorization
- `sharedWith` array in Travel for collaboration
- `rating` field in Destination (1-5 stars)
- `budget` fields in Travel for expense tracking

**Migration Strategy**:
- MongoDB schema-less nature allows gradual additions
- New optional fields can be added without breaking existing documents
- Use Mongoose schema versioning for major changes

---

## Performance Optimization

**Current Optimizations**:
- ✅ Indexes on frequently queried fields
- ✅ Compound indexes for sorted queries
- ✅ Denormalized userId in Destination for direct filtering
- ✅ Pre-save hooks for automatic updatedAt

**Future Optimizations**:
- Add indexes on `visited` field for filtering visited/unvisited destinations
- Consider aggregation pipeline for statistics (total travels, visited count)
- Implement pagination on all list endpoints (currently on travels only)
- Add `select()` projection to reduce document size in list queries

---

## Validation Rules Summary

| Collection | Field | Rules |
|------------|-------|-------|
| User | firebaseUid | Required, unique, string |
| User | email | Required, unique, email format |
| User | name | Required, string |
| Travel | title | Required, min 3 chars |
| Travel | startDate | Required, ISO8601 date |
| Travel | endDate | Required, > startDate |
| Destination | name | Required, min 2 chars |
| Destination | latitude | Required, -90 to 90 |
| Destination | longitude | Required, -180 to 180 |

All validation enforced at:
1. **API Layer**: express-validator middleware
2. **Application Layer**: Mongoose schema validators
3. **Database Layer**: MongoDB unique constraints

---

## Querying Best Practices

**DO**:
```javascript
// Always filter by userId
Travel.find({ userId: req.userId })

// Use compound indexes
Travel.find({ userId: req.userId }).sort({ startDate: -1 })

// Project only needed fields
Travel.find({ userId: req.userId }).select('title startDate endDate')
```

**DON'T**:
```javascript
// Never query without userId filtering
Travel.find({}) // ❌ Security risk!

// Avoid fetching large arrays without pagination
Travel.find({ userId: req.userId }) // ❌ Use limit/skip
```
