# Database Indexes & Optimization

This document analyzes all indexes in MAPORIA's MongoDB database, their performance characteristics, and optimization recommendations.

---

## Table of Contents

- [Index Overview](#index-overview)
- [Model-Specific Indexes](#model-specific-indexes)
- [Performance Analysis](#performance-analysis)
- [Query Optimization Patterns](#query-optimization-patterns)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Recommendations](#recommendations)

---

## Index Overview

### Current Index Count

| Model | Single Indexes | Compound Indexes | Geospatial | Total |
|-------|----------------|------------------|------------|-------|
| User | 2 | 0 | 0 | 2 |
| Travel | 1 | 1 | 0 | 2 |
| Destination | 3 | 1 | 1 | 5 |
| PrePlannedTrip | 0 | 0 | 0 | 0 |
| **TOTAL** | **6** | **2** | **1** | **9** |

*Note: All models have default `_id` index (not counted above)*

### Index Types in Use

- **Single Field**: Fast lookups on one field (e.g., `userId`)
- **Compound**: Optimizes multi-field queries (e.g., `{ userId: 1, travelId: 1 }`)
- **Unique**: Enforces uniqueness (e.g., `auth0Id`, `email`)
- **Geospatial (2dsphere)**: Enables location-based queries
- **Sparse**: No sparse indexes currently used

---

## Model-Specific Indexes

### User Model

**File**: `backend/src/models/User.js`

#### Indexes

```javascript
// 1. Unique auth0Id index
auth0Id: { type: String, unique: true, index: true }

// 2. Unique email index
email: { type: String, unique: true, lowercase: true, index: true }
```

#### Performance Characteristics

| Index | Type | Cardinality | Read Performance | Write Performance |
|-------|------|-------------|------------------|-------------------|
| `auth0Id` | Unique | High (1:1) | O(log n) | O(log n) |
| `email` | Unique | High (1:1) | O(log n) | O(log n) |

#### Common Queries

```javascript
// Query 1: Auth0 login lookup (OPTIMIZED)
User.findOne({ auth0Id: 'auth0|123456789' })
// Uses: auth0Id index

// Query 2: Email verification (OPTIMIZED)
User.findOne({ email: 'john@example.com' })
// Uses: email index (with lowercase transformation)

// Query 3: Achievement leaderboard (NOT OPTIMIZED)
User.find({ totalPlacesVisited: { $gte: 100 } })
// Full collection scan - no index on totalPlacesVisited
```

#### Optimization Notes

- ✅ Auth0 lookup is instant (unique index)
- ✅ Email uniqueness enforced at database level
- ⚠️ No index on `totalPlacesVisited` - leaderboard queries may be slow with large user base

---

### Travel Model

**File**: `backend/src/models/Travel.js`

#### Indexes

```javascript
// 1. Single field index
userId: { type: String, index: true }

// 2. Compound index for chronological queries
travelSchema.index({ userId: 1, startDate: 1 });
```

#### Performance Characteristics

| Index | Type | Cardinality | Read Performance | Write Performance |
|-------|------|-------------|------------------|-------------------|
| `userId` | Single | Low (many trips per user) | O(log n) | O(log n) |
| `{userId, startDate}` | Compound | Medium | O(log n) | O(log n) |

#### Common Queries

```javascript
// Query 1: All user trips (OPTIMIZED)
Travel.find({ userId: 'auth0|123456789' })
// Uses: userId index OR compound index (index prefix)

// Query 2: User's upcoming trips (OPTIMIZED)
Travel.find({ 
  userId: 'auth0|123456789',
  startDate: { $gte: new Date() }
}).sort({ startDate: 1 })
// Uses: compound index { userId: 1, startDate: 1 }

// Query 3: Search by title (NOT OPTIMIZED)
Travel.find({ 
  userId: 'auth0|123456789',
  title: /cultural/i 
})
// Uses: userId index, then regex scan
```

#### Index Efficiency

**Compound Index Coverage**:
```javascript
// Covered queries (most efficient):
{ userId: 1 }                              // ✅ Uses prefix
{ userId: 1, startDate: 1 }                 // ✅ Exact match
{ userId: 1, startDate: 1, endDate: 1 }     // ✅ Extends compound

// Not covered:
{ startDate: 1 }                            // ❌ No userId prefix
{ endDate: 1 }                              // ❌ Not in index
```

#### Optimization Notes

- ✅ Compound index eliminates need for separate `userId` single index
- ✅ Chronological sorting is index-supported
- ⚠️ Text search on `title` requires regex scan (consider MongoDB Text Index)

---

### Destination Model

**File**: `backend/src/models/Destination.js`

#### Indexes

```javascript
// 1. Single field indexes
userId: { type: String, index: true }
travelId: { type: mongoose.Schema.Types.ObjectId, ref: 'Travel', index: true }
districtId: { type: String, index: true }

// 2. Compound index
destinationSchema.index({ userId: 1, travelId: 1 });

// 3. Geospatial index
destinationSchema.index({ location: '2dsphere' });
```

#### Performance Characteristics

| Index | Type | Cardinality | Read Performance | Write Performance | Size Impact |
|-------|------|-------------|------------------|-------------------|-------------|
| `userId` | Single | Low | O(log n) | O(log n) | Small |
| `travelId` | Single | Low | O(log n) | O(log n) | Small |
| `districtId` | Single | Medium | O(log n) | O(log n) | Small |
| `{userId, travelId}` | Compound | Medium | O(log n) | O(log n) | Medium |
| `location` | 2dsphere | High | O(log n) | O(log n) | Large |

#### Common Queries

```javascript
// Query 1: Trip destinations (OPTIMIZED)
Destination.find({ travelId: ObjectId('...') })
// Uses: travelId index OR compound index

// Query 2: User's destinations for specific trip (OPTIMIZED)
Destination.find({ 
  userId: 'auth0|123456789',
  travelId: ObjectId('...')
})
// Uses: compound index { userId: 1, travelId: 1 }

// Query 3: District gamification (OPTIMIZED)
Destination.find({ 
  userId: 'auth0|123456789',
  districtId: 'colombo',
  visited: true 
})
// Uses: userId or districtId index, then filter

// Query 4: Nearby places (OPTIMIZED)
Destination.find({
  location: {
    $near: {
      $geometry: { type: 'Point', coordinates: [lng, lat] },
      $maxDistance: 5000
    }
  }
})
// Uses: 2dsphere index on location

// Query 5: All visited destinations (PARTIALLY OPTIMIZED)
Destination.find({ 
  userId: 'auth0|123456789',
  visited: true 
})
// Uses: userId index, then filter on visited
```

#### Index Efficiency

**Redundant Indexes**:
```javascript
// Single userId index is redundant
userId: { index: true }  // ❌ Redundant

// Compound index covers this
{ userId: 1, travelId: 1 }  // ✅ Use this instead
```

**Recommendation**: Remove single `userId` index to save storage.

**Missing Index Opportunity**:
```javascript
// Add for gamification queries
{ userId: 1, districtId: 1, visited: 1 }  // ⚡ Recommended
```

#### Geospatial Index Details

**2dsphere Index**: Supports spherical geometry for Earth-like coordinates.

```javascript
// Supported operations:
$near         // Find nearest points
$geoWithin    // Find within polygon/radius
$geoIntersects // Find intersecting geometries
```

**Storage Cost**: ~100 bytes per document (depends on coordinate precision)

**Query Performance**:
- Radius query (5km): O(log n + k) where k = results
- Without index: O(n) full scan

---

### PrePlannedTrip Model

**File**: `backend/src/models/PrePlannedTrip.js`

#### Indexes

```javascript
// No custom indexes defined
// Only default _id index exists
```

#### Performance Characteristics

| Index | Type | Status |
|-------|------|--------|
| `_id` | Default | ✅ Present |
| *(none)* | - | ⚠️ No custom indexes |

#### Common Queries

```javascript
// Query 1: Find by difficulty (NOT OPTIMIZED)
PrePlannedTrip.find({ difficulty: 'Easy' })
// Full collection scan

// Query 2: Find by tags (NOT OPTIMIZED)
PrePlannedTrip.find({ tags: 'culture' })
// Full collection scan

// Query 3: Browse all (ACCEPTABLE)
PrePlannedTrip.find().limit(20)
// Full scan but small collection (<100 docs expected)
```

#### Optimization Notes

- ⚠️ **Current State**: No indexes = full collection scans
- ✅ **Acceptable if**: Collection stays small (<1000 documents)
- ⚡ **Recommended indexes**:
  ```javascript
  // Add if collection grows
  { difficulty: 1 }
  { tags: 1 }
  { durationDays: 1 }
  ```

---

## Performance Analysis

### Write Performance Impact

**Index Overhead per Insert/Update**:
- User: 2 indexes to update
- Travel: 2 indexes to update
- Destination: **5 indexes to update** (highest overhead)
- PrePlannedTrip: 0 custom indexes

**Destination Write Latency**:
```
Base write:           ~1ms
+ 3 single indexes:   ~0.5ms
+ 1 compound index:   ~0.3ms
+ 1 geospatial index: ~1.5ms
─────────────────────────────
Total:                ~3.3ms
```

**Recommendation**: Destination write performance is acceptable for typical usage (<100 writes/sec).

---

### Read Performance Gains

#### Scenario 1: User Login

```javascript
// Without index on auth0Id
User.findOne({ auth0Id: 'auth0|123456789' })
// Performance: O(n) - scans all users

// With unique index (current)
// Performance: O(1) - B-tree lookup
// Speed improvement: ~1000x for 10k users
```

#### Scenario 2: Trip Destinations

```javascript
// Without index on travelId
Destination.find({ travelId: ObjectId('...') })
// Performance: O(n) - scans all destinations

// With compound index (current)
{ userId: 1, travelId: 1 }
// Performance: O(log n + k) where k = results
// Speed improvement: ~100x for 100k destinations
```

#### Scenario 3: Nearby Places

```javascript
// Without geospatial index
// Performance: O(n) - calculates distance for every doc
// 10k docs × 1ms each = 10 seconds

// With 2dsphere index (current)
// Performance: O(log n + k)
// Speed improvement: ~10000x
```

---

## Query Optimization Patterns

### Pattern 1: Index Intersection

MongoDB can use multiple indexes simultaneously:

```javascript
// Uses both districtId and userId indexes
Destination.find({ 
  userId: 'auth0|123456789',
  districtId: 'colombo' 
})
```

**Limitation**: Less efficient than compound index covering both fields.

---

### Pattern 2: Covered Queries

Query results entirely from index (no document fetch):

```javascript
// NOT covered (needs document fetch)
Travel.find({ userId: 'auth0|123' }, { title: 1, startDate: 1 })

// To make covered, add projection index:
travelSchema.index({ userId: 1, startDate: 1, title: 1 })
```

**Note**: Current indexes do NOT support covered queries (fields not in index).

---

### Pattern 3: Sort Optimization

```javascript
// Optimized sort (uses compound index)
Travel.find({ userId: 'auth0|123' }).sort({ startDate: 1 })
// Uses: { userId: 1, startDate: 1 } index for sorting

// Unoptimized sort (in-memory)
Travel.find({ userId: 'auth0|123' }).sort({ title: 1 })
// Fetches docs, sorts in RAM (slow for large results)
```

---

## Monitoring & Maintenance

### Analyzing Query Performance

**Enable MongoDB Profiler** (in MongoDB Atlas or local):
```javascript
// Set profiling level
db.setProfilingLevel(1, { slowms: 100 }) // Log queries >100ms
```

**Explain Query Plan**:
```javascript
// In Node.js
const explain = await Travel.find({ userId: '...' }).explain('executionStats');
console.log(explain.executionStats);

// Key metrics:
// - executionTimeMillis: Query duration
// - totalKeysExamined: Index scans
// - totalDocsExamined: Document scans (should be low)
// - stage: 'IXSCAN' (good) vs 'COLLSCAN' (bad)
```

---

### Index Statistics

**Get Index Sizes** (MongoDB shell):
```javascript
db.travels.stats().indexSizes
// Output:
// {
//   "_id_": 32768,
//   "userId_1_startDate_1": 49152
// }
```

**Identify Unused Indexes**:
```javascript
db.travels.aggregate([{ $indexStats: {} }])
// Check 'accesses' field - if 0, index is unused
```

---

### Maintenance Tasks

1. **Rebuild Indexes** (after major data changes):
   ```javascript
   db.destinations.reIndex()
   ```

2. **Drop Redundant Indexes**:
   ```javascript
   // Remove single userId index from Destination
   db.destinations.dropIndex("userId_1")
   ```

3. **Monitor Index Size Growth**:
   ```bash
   # Should be < 10% of total data size
   Total Index Size / Total Data Size < 0.10
   ```

---

## Recommendations

### High Priority ⚡

1. **Remove Redundant Index** (Destination model):
   ```javascript
   // Current (REDUNDANT):
   userId: { index: true }
   
   // Remove since compound index covers it:
   { userId: 1, travelId: 1 }
   ```

2. **Add Gamification Index** (Destination model):
   ```javascript
   // Enable fast achievement queries
   destinationSchema.index({ userId: 1, districtId: 1, visited: 1 });
   ```

3. **Add Leaderboard Index** (User model):
   ```javascript
   // Enable fast leaderboard queries
   userSchema.index({ totalPlacesVisited: -1 }); // Descending order
   ```

---

### Medium Priority 🔶

4. **Add Text Search** (Travel model):
   ```javascript
   // Enable full-text search on trip titles
   travelSchema.index({ title: 'text', description: 'text' });
   
   // Usage:
   Travel.find({ $text: { $search: 'cultural heritage' } })
   ```

5. **Add PrePlannedTrip Indexes**:
   ```javascript
   preplannedTripSchema.index({ difficulty: 1 });
   preplannedTripSchema.index({ tags: 1 });
   preplannedTripSchema.index({ durationDays: 1 });
   ```

6. **Partial Index for Active Trips**:
   ```javascript
   // Only index future/active trips (saves space)
   travelSchema.index(
     { userId: 1, startDate: 1 },
     { partialFilterExpression: { endDate: { $gte: new Date() } } }
   );
   ```

---

### Low Priority 📋

7. **Sparse Index for Visited Destinations**:
   ```javascript
   // Index only visited destinations (saves space)
   destinationSchema.index(
     { visitedAt: 1 },
     { sparse: true }
   );
   ```

8. **TTL Index for Old Trips** (if auto-cleanup needed):
   ```javascript
   // Auto-delete trips 2 years after end date
   travelSchema.index(
     { endDate: 1 },
     { expireAfterSeconds: 63072000 } // 2 years
   );
   ```

---

## Implementation Checklist

To implement recommended changes:

- [ ] Remove `userId` single index from Destination model
- [ ] Add `{ userId: 1, districtId: 1, visited: 1 }` to Destination
- [ ] Add `{ totalPlacesVisited: -1 }` to User model
- [ ] Add text index to Travel model (if search feature needed)
- [ ] Add indexes to PrePlannedTrip (if collection grows >1000 docs)
- [ ] Monitor query performance with `.explain()`
- [ ] Set up MongoDB profiler in production
- [ ] Schedule monthly index statistics review

---

## See Also

- [models.md](./models.md) - Schema definitions
- [relationships.md](./relationships.md) - How models relate
- [MongoDB Index Documentation](https://docs.mongodb.com/manual/indexes/)
- [Query Optimization Guide](https://docs.mongodb.com/manual/tutorial/optimize-query-performance-with-indexes-and-projections/)
