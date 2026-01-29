# Phase 2: Detailed Implementation Plan - Travel Data Management

## Status: ✅ COMPLETE (All 9 Steps Done)

**Completion Date:** January 24, 2026  
**Documentation:** See [PHASE2_COMPLETION_SUMMARY.md](../03_completion_logs/PHASE2_COMPLETION_SUMMARY.md)

---

## Overview
Build user-scoped travel and destination management system with full CRUD operations and data isolation.

---

## Feature Breakdown

### Feature 1: Travel Management ✅
- **Goal**: Allow users to create and manage travel/trip records
- **Model**: Travel (userId, title, description, startDate, endDate, locations)
- **Endpoints**: Full CRUD (Create, Read, Update, Delete)
- **Data Isolation**: All travels filtered by userId from JWT token
- **Status**: ✅ COMPLETE

### Feature 2: Destination Management ✅
- **Goal**: Allow users to add destinations within a travel
- **Model**: Destination (userId, travelId, name, latitude, longitude, notes, visited)
- **Endpoints**: Full CRUD nested under travel (e.g., `/api/travel/:travelId/destinations`)
- **Data Isolation**: Filtered by both userId and travelId
- **Status**: ✅ COMPLETE

### Feature 3: Input Validation ✅
- **Goal**: Ensure data quality and prevent invalid inputs
- **Implementation**: express-validator library
- **Coverage**: Travel title/dates, Destination name/coordinates
- **Status**: ✅ COMPLETE

### Feature 4: Nested Route Structure ✅
- **Goal**: Organize endpoints hierarchically
- **Pattern**: `/api/travel/:travelId/destinations/:destId`
- **Benefit**: Clear parent-child relationship
- **Status**: ✅ COMPLETE

---

## Dependencies & Versions

**Additional for Phase 2**
```json
{
  "express-validator": "^7.0.1"
}
```

**All dependencies** (from Phase 1 + Phase 2):
```json
{
  "cors": "^2.8.5",
  "dotenv": "^16.3.1",
  "express": "^4.18.2",
  "helmet": "^7.1.0",
  "mongoose": "^8.0.3",
  "morgan": "^1.10.0",
  "express-jwt": "^8.4.1",
  "jwks-rsa": "^3.1.0",
  "express-validator": "^7.0.1"
}
```

---

## Data Models

### Travel Schema
```javascript
{
  userId: String (required, indexed),
  title: String (required, min 3 chars),
  description: String (optional),
  startDate: Date (required),
  endDate: Date (required, must be > startDate),
  locations: [String] (array of location names),
  createdAt: Date (auto),
  updatedAt: Date (auto)
}
```

**Indexes**: `{ userId }`, `{ userId, startDate }`  
**Validation**: Title min 3 chars, endDate > startDate

---

### Destination Schema
```javascript
{
  userId: String (required, indexed),
  travelId: ObjectId (required, indexed),
  name: String (required, min 2 chars),
  latitude: Number (required, range -90 to 90),
  longitude: Number (required, range -180 to 180),
  notes: String (optional),
  visited: Boolean (default: false),
  createdAt: Date (auto),
  updatedAt: Date (auto)
}
```

**Indexes**: `{ userId }`, `{ travelId }`, `{ userId, travelId }`  
**Validation**: Name required, lat/lon valid ranges, numeric

---

## API Endpoints

### Travel Endpoints

#### 1. Create Travel
**Endpoint**: `POST /api/travel`  
**Auth**: Required (JWT Bearer token)

**Request Body**:
```json
{
  "title": "Summer Europe Trip",
  "description": "2-week adventure across Europe",
  "startDate": "2026-06-01T00:00:00Z",
  "endDate": "2026-06-15T00:00:00Z",
  "locations": ["Paris", "Berlin", "Rome"]
}
```

**Response (201 Created)**:
```json
{
  "message": "Travel created successfully",
  "travel": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "auth0|123456",
    "title": "Summer Europe Trip",
    "description": "2-week adventure across Europe",
    "startDate": "2026-06-01T00:00:00Z",
    "endDate": "2026-06-15T00:00:00Z",
    "locations": ["Paris", "Berlin", "Rome"],
    "createdAt": "2026-01-24T10:00:00Z",
    "updatedAt": "2026-01-24T10:00:00Z"
  }
}
```

**Error Responses**:
- 400: Invalid input (missing required fields, invalid dates)
- 401: Unauthorized (invalid/missing token)

---

#### 2. List User's Travels
**Endpoint**: `GET /api/travel`  
**Auth**: Required

**Query Parameters** (optional):
- `sortBy`: "startDate" (default), "createdAt"
- `limit`: 20 (default)
- `skip`: 0 (default, for pagination)

**Response (200 OK)**:
```json
{
  "travels": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "userId": "auth0|123456",
      "title": "Summer Europe Trip",
      "description": "...",
      "startDate": "2026-06-01T00:00:00Z",
      "endDate": "2026-06-15T00:00:00Z",
      "locations": ["Paris", "Berlin", "Rome"],
      "createdAt": "2026-01-24T10:00:00Z",
      "updatedAt": "2026-01-24T10:00:00Z"
    }
  ],
  "total": 1
}
```

**Error Responses**:
- 401: Unauthorized

---

#### 3. Get Single Travel
**Endpoint**: `GET /api/travel/:travelId`  
**Auth**: Required

**Response (200 OK)**:
```json
{
  "travel": { /* travel object */ }
}
```

**Error Responses**:
- 401: Unauthorized
- 404: Travel not found (or not owned by user)

---

#### 4. Update Travel
**Endpoint**: `PATCH /api/travel/:travelId`  
**Auth**: Required

**Request Body** (partial update):
```json
{
  "title": "Updated Trip Title",
  "endDate": "2026-06-20T00:00:00Z"
}
```

**Response (200 OK)**:
```json
{
  "message": "Travel updated successfully",
  "travel": { /* updated travel object */ }
}
```

**Error Responses**:
- 400: Invalid input
- 401: Unauthorized
- 404: Travel not found

---

#### 5. Delete Travel
**Endpoint**: `DELETE /api/travel/:travelId`  
**Auth**: Required

**Response (200 OK)**:
```json
{
  "message": "Travel deleted successfully"
}
```

**Error Responses**:
- 401: Unauthorized
- 404: Travel not found
- **Note**: Deleting a travel should cascade-delete destinations

---

### Destination Endpoints

#### 1. Create Destination
**Endpoint**: `POST /api/travel/:travelId/destinations`  
**Auth**: Required

**Request Body**:
```json
{
  "name": "Eiffel Tower",
  "latitude": 48.8584,
  "longitude": 2.2945,
  "notes": "Iconic landmark, visited at sunset",
  "visited": true
}
```

**Response (201 Created)**:
```json
{
  "message": "Destination created successfully",
  "destination": {
    "_id": "507f1f77bcf86cd799439012",
    "userId": "auth0|123456",
    "travelId": "507f1f77bcf86cd799439011",
    "name": "Eiffel Tower",
    "latitude": 48.8584,
    "longitude": 2.2945,
    "notes": "Iconic landmark, visited at sunset",
    "visited": true,
    "createdAt": "2026-01-24T10:00:00Z",
    "updatedAt": "2026-01-24T10:00:00Z"
  }
}
```

**Error Responses**:
- 400: Invalid input (invalid coordinates, missing name)
- 401: Unauthorized
- 404: Travel not found

---

#### 2. List Destinations for Travel
**Endpoint**: `GET /api/travel/:travelId/destinations`  
**Auth**: Required

**Response (200 OK)**:
```json
{
  "destinations": [
    { /* destination object */ }
  ],
  "total": 1
}
```

**Error Responses**:
- 401: Unauthorized
- 404: Travel not found

---

#### 3. Get Single Destination
**Endpoint**: `GET /api/travel/:travelId/destinations/:destId`  
**Auth**: Required

**Response (200 OK)**:
```json
{
  "destination": { /* destination object */ }
}
```

**Error Responses**:
- 401: Unauthorized
- 404: Destination or Travel not found

---

#### 4. Update Destination
**Endpoint**: `PATCH /api/travel/:travelId/destinations/:destId`  
**Auth**: Required

**Request Body**:
```json
{
  "name": "Updated Name",
  "visited": false
}
```

**Response (200 OK)**:
```json
{
  "message": "Destination updated successfully",
  "destination": { /* updated destination object */ }
}
```

**Error Responses**:
- 400: Invalid input
- 401: Unauthorized
- 404: Destination or Travel not found

---

#### 5. Delete Destination
**Endpoint**: `DELETE /api/travel/:travelId/destinations/:destId`  
**Auth**: Required

**Response (200 OK)**:
```json
{
  "message": "Destination deleted successfully"
}
```

**Error Responses**:
- 401: Unauthorized
- 404: Destination or Travel not found

---

## Implementation Steps

### Step 1: Install express-validator ✅ COMPLETE
```bash
npm install express-validator
```
**Status**: Package installed v7.3.1, ready for use

---

### Step 2: Create Travel Model ✅ COMPLETE
**File**: `backend/src/models/Travel.js`

**What to do**:
- Define schema with userId, title, description, startDate, endDate, locations
- Add indexes on userId and startDate
- Add pre-save hook for updatedAt

**Validation**:
- Create a test Travel document
- Verify indexes in MongoDB

---

### Step 3: Create Destination Model ✅ COMPLETE
**File**: `backend/src/models/Destination.js`

**What to do**:
- Define schema with userId, travelId, name, latitude, longitude, notes, visited
- Add indexes on userId and travelId
- Add reference to Travel model (optional, for population)

**Validation**:
- Create a test Destination document

---

### Step 4: Create Input Validators ✅ COMPLETE
**File**: `backend/src/validators/travelValidator.js`

**What to do**:
- `validateCreateTravel`: title (required, min 3), dates (valid, endDate > startDate)
- `validateUpdateTravel`: same but optional fields
- Use express-validator `body()`, `validationResult()`

**File**: `backend/src/validators/destinationValidator.js`

**What to do**:
- `validateCreateDestination`: name (required, min 2), lat/lon (required, valid ranges)
- `validateUpdateDestination`: same but optional

---

### Step 5: Create Travel Controller ✅ COMPLETE
**File**: `backend/src/controllers/travelController.js`

**Functions**:
- `createTravel`: Create travel with userId scoping
- `listTravels`: Get all travels for user (paginated)
- `getSingleTravel`: Get one travel by ID (verify ownership)
- `updateTravel`: Update travel (verify ownership)
- `deleteTravel`: Delete travel and cascade-delete destinations

**All must**:
- Filter by `req.userId`
- Handle 404 (not found), 401 (unauthorized), 400 (validation)

---

### Step 6: Create Destination Controller ✅ COMPLETE
**File**: `backend/src/controllers/destinationController.js`

**Functions**:
- `createDestination`: Create destination (verify travel belongs to user)
- `listDestinations`: Get destinations for travel (verify travel owner)
- `getSingleDestination`: Get one destination (verify ownership)
- `updateDestination`: Update destination (verify ownership)
- `deleteDestination`: Delete destination (verify ownership)

**All must**:
- Filter by `req.userId`
- Verify `travelId` belongs to user
- Handle 404, 401, 400

---

### Step 7: Create Routes ✅ COMPLETE
**File**: `backend/src/routes/travelRoutes.js`

**Travel Routes**:
```javascript
POST   /api/travel              → createTravel
GET    /api/travel              → listTravels
GET    /api/travel/:travelId    → getSingleTravel
PATCH  /api/travel/:travelId    → updateTravel
DELETE /api/travel/:travelId    → deleteTravel
```

**File**: `backend/src/routes/destinationRoutes.js`

**Destination Routes** (nested):
```javascript
POST   /api/travel/:travelId/destinations            → createDestination
GET    /api/travel/:travelId/destinations            → listDestinations
GET    /api/travel/:travelId/destinations/:destId    → getSingleDestination
PATCH  /api/travel/:travelId/destinations/:destId    → updateDestination
DELETE /api/travel/:travelId/destinations/:destId    → deleteDestination
```

**All endpoints**:
- Protected with `checkJwt` and `extractUserId` middleware
- Input validated with express-validator

---

### Step 8: Wire Routes into Server ✅ COMPLETE
**File**: `backend/src/server.js`

**What to do**:
- Import travel and destination routes
- Mount at `/api/travel` and `/api/travel/:travelId/destinations`
- Test server starts without errors

---

### Step 9: API Testing ✅ COMPLETE
**How to test**:

**1. Create Travel**
```bash
POST /api/travel
Authorization: Bearer <TOKEN>
Body: { title, description, startDate, endDate, locations }
Expected: 201 Created
```

**2. List Travels**
```bash
GET /api/travel
Authorization: Bearer <TOKEN>
Expected: 200 OK with array
```

**3. Create Destination in Travel**
```bash
POST /api/travel/<TRAVEL_ID>/destinations
Authorization: Bearer <TOKEN>
Body: { name, latitude, longitude, notes, visited }
Expected: 201 Created
```

**4. Update Travel**
```bash
PATCH /api/travel/<TRAVEL_ID>
Authorization: Bearer <TOKEN>
Body: { title } (or any field)
Expected: 200 OK
```

**5. Delete Destination**
```bash
DELETE /api/travel/<TRAVEL_ID>/destinations/<DEST_ID>
Authorization: Bearer <TOKEN>
Expected: 200 OK
```

**6. Verify Data Isolation**
- Create Travel as User A
- Try to access as User B → should get 404
- Verify only User A can see their travels

---

## Project Structure (After Phase 2)

```
backend/
├── src/
│   ├── config/
│   │   └── db.js
│   ├── middleware/
│   │   └── auth.js
│   ├── models/
│   │   ├── User.js           (Phase 1)
│   │   ├── Travel.js         (Phase 2 - NEW)
│   │   └── Destination.js    (Phase 2 - NEW)
│   ├── controllers/
│   │   ├── authController.js          (Phase 1)
│   │   ├── travelController.js        (Phase 2 - NEW)
│   │   └── destinationController.js   (Phase 2 - NEW)
│   ├── routes/
│   │   ├── authRoutes.js             (Phase 1)
│   │   ├── travelRoutes.js           (Phase 2 - NEW)
│   │   └── destinationRoutes.js      (Phase 2 - NEW)
│   ├── validators/
│   │   ├── travelValidator.js        (Phase 2 - NEW)
│   │   └── destinationValidator.js   (Phase 2 - NEW)
│   └── server.js
├── .env
├── .env.example
├── .gitignore
└── package.json
```

---

## Testing Matrix

### Unit Tests (Controllers)
- [ ] createTravel: valid input, missing title, invalid dates
- [ ] listTravels: pagination, sorting, filtering by userId
- [ ] getSingleTravel: found, not found, not owned by user
- [ ] createDestination: valid coords, invalid ranges, missing name
- [ ] updateDestination: partial update, invalid update

### Integration Tests (Endpoints)
- [ ] POST /api/travel → 201
- [ ] GET /api/travel → 200 with user's travels only
- [ ] POST /api/travel/:id/destinations → 201
- [ ] DELETE /api/travel/:id → cascades destinations
- [ ] GET /api/travel/:id with other user's token → 404

### Error Scenarios
- [ ] Missing JWT token → 401 on all protected routes
- [ ] Invalid JWT → 401
- [ ] Travel not owned by user → 404
- [ ] Invalid input (dates, coords) → 400

---

## Success Criteria (Definition of Done)

- [ ] Travel model created with all fields and indexes
- [ ] Destination model created with all fields and indexes
- [ ] 5 Travel endpoints implemented and responding
- [ ] 5 Destination endpoints implemented and responding
- [ ] Input validation working (dates, coords, required fields)
- [ ] Data isolation verified (userId filtering works)
- [ ] All CRUD operations tested manually
- [ ] Error handling correct (401, 404, 400)
- [ ] Cascade delete working (delete travel → delete destinations)
- [ ] Documentation updated

---

## Timeline Estimate

- Step 1 (install): 1 min
- Steps 2-3 (models): 30 min
- Step 4 (validators): 30 min
- Steps 5-6 (controllers): 1.5 hours
- Step 7 (routes): 30 min
- Step 8 (server): 15 min
- Step 9 (testing): 1-2 hours

**Total**: ~4-5 hours

---

## Next Phase (Phase 3)
After Phase 2 completes:
- Mapbox integration for map visualization
- Frontend Auth0 setup (Flutter)
- Frontend API client to consume these endpoints

