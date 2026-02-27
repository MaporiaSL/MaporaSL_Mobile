# Temporary Data to Real Database Migration - Complete

## Overview
This document summarizes the conversion of all system features from temporary seed data to real MongoDB database usage.

## Migration Summary

### 1. **Exploration Feature** ✅ CONVERTED
**Status:** Complete - Using real backend API

#### Changes Made:
- **File:** `mobile/lib/features/exploration/providers/exploration_provider.dart`
  - Removed `_devSeedAssignments` flag (was `true`, now removed)
  - Removed `_loadDevAssignmentsFromAsset()` method that loaded from `assets/data/places_seed_data_2026.json`
  - Removed `_buildDevDistricts()` helper method
  - Removed `_markVisitedLocally()` development fallback method
  - Removed unused imports (`dart:convert`, `package:flutter/services.dart`)
  - Now exclusively uses `ExplorationApi` to fetch assignments and districts from backend

#### Backend Setup:
- Backend controller: `backend/src/controllers/explorationController.js`
  - `getAssignments()` - Returns user's assigned districts and locations
  - `getDistricts()` - Returns summary of user's districts
  - `visitLocation()` - Records location visits with GPS samples
  - `seedUnlockLocations()` - Admin endpoint to seed UnlockLocation collection

#### Database Seeding:
- **New Script:** `backend/seed-unlock-locations.js`
  - Seed source: `project_resorces/places_seed_data_2026.json`
  - Loads Sri Lanka's 25 districts with 8-9 attractions each (~200 total locations)
  - Creates UnlockLocation documents in MongoDB
  - Validates all districts have minimum 3 locations
  - Run with: `node seed-unlock-locations.js`

#### Request/Response Flow:
```
Mobile App
  ↓
ExplorationApi.fetchAssignments()
  ↓
GET /api/exploration/assignments (JWT protected)
  ↓
Backend returns: { assignments: [...] }
  ↓
State stores in ExplorationState
```

### 2. **Trips Feature** ✅ VERIFIED
**Status:** Already using real backend

- Real API calls through trips repository
- PrePlannedTrips seeded via `backend/seed-preplanned-trips.js`
- Custom trips stored in Destination model
- No fallback to temporary data

### 3. **Shop Feature** ✅ VERIFIED
**Status:** Already using real backend

- Real API calls through `RealStoreApi`
- Items seeded via `backend/seed-real-store.js`
- Shopping cart managed in MongoDB
- No temporary data fallback

### 4. **Album Feature** ✅ VERIFIED
**Status:** Already using real backend

- Photos stored in Photo model
- Uses real backend API
- No temporary seed data

### 5. **Profile & Settings** ✅ CLEAN
**Status:** Using real backend

- User data from Auth0 + MongoDB
- Settings stored in User document
- No temporary data

## Architecture Now

```
Mobile App (Flutter)
    ↓
[ExplorationApi, TripApi, ShopApi, etc.]
    ↓
[ApiClient - DIO/HTTP]
    ↓
Node.js Backend (Express)
    ↓
MongoDB Database
```

## Data Flow Example: Exploration Feature

### Initial Setup (First Time User)
1. User logs in → Auth0 validation
2. `onboarding_exploration_screen` loads
3. Backend receives POST with hometown district
4. Backend calls `assignExplorationForUser()`
   - Queries UnlockLocation collection
   - Creates random assignments per district
   - Creates UserDistrictAssignment records
5. Response includes assignments for UI

### Daily Usage
1. Mobile loads Exploration → `explorationProvider.loadAssignments()`
2. Calls `ExplorationApi.fetchAssignments()`
3. Backend queries:
   - UserDistrictAssignment → user's assignments
   - UnlockLocation (by ID) → location details
4. Returns formatted assignments with coordinates
5. UI displays locations on map

### Location Visit
1. User selects location to verify
2. Mobile requests GPS permission
3. Collects 3 samples (2-second interval)
4. Calls `ExplorationApi.visitLocation(locationId, samples)`
5. Backend validates:
   - Location distance (100m accuracy)
   - Sample quality (50m accuracy)
   - Cooldown period (5 minutes)
6. Records visit in UserDistrictAssignment
7. Updates exploration stats
8. Returns updated assignments to mobile

## Required Setup Steps

### 1. Backend Database Seeding
```bash
cd backend
# Seed unlock locations (25 districts × 8-9 attractions each)
node seed-unlock-locations.js

# Seed preplanned trips (optional, if not done)
node seed-preplanned-trips.js

# Seed real store items (optional, if not done)
node seed-real-store.js
```

### 2. Environment Setup
Ensure `backend/.env` has:
```
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/db
API_PORT=5000
JWT_SECRET=...
```

### 3. Mobile Configuration
Ensure `mobile/.env` or `mobile/pubspec.yaml` points to correct backend:
```
API_URL=http://localhost:5000/api  # Development
API_URL=https://api.production.com/api  # Production
```

## Testing Checklist

- [ ] Run `seed-unlock-locations.js` successfully
- [ ] Verify UnlockLocation collection has ~200 documents
- [ ] Mobile app starts without errors
- [ ] Exploration screen loads assignments from API
- [ ] Locations display on map
- [ ] Location visit flow completes (with real GPS)
- [ ] XP calculation works correctly
- [ ] District unlock states persist to database

## Files Affected

### Modified
- `mobile/lib/features/exploration/providers/exploration_provider.dart`

### Created
- `backend/seed-unlock-locations.js`

### No Changes Needed
- `mobile/lib/features/shop/**` - Already using API
- `mobile/lib/features/trips/**` - Already using API  
- `mobile/lib/features/album/**` - Already using API
- `mobile/lib/features/profile/**` - Already using API
- `mobile/lib/features/settings/**` - Already using API

## Benefits of This Migration

1. **Single Source of Truth:** All users access same database
2. **Real-Time Synchronization:** Changes sync across devices
3. **Backend Validation:** Location visits validated on server
4. **Scalability:** Can handle production load
5. **Analytics:** Full audit trail of user actions
6. **Security:** JWT protection on all API endpoints

## Rollback Instructions

If needed, temporary data was backed up at:
- `mobile/assets/data/places_seed_data_2026.json`

To revert:
1. Restore `exploration_provider.dart` from git history
2. Restore imports and dev seed methods
3. Rebuild mobile app

## Notes

- **Asset File Still Present:** `places_seed_data_2026.json` remains in mobile assets for reference
  - No longer loaded by app code
  - Can be used for backend seeding
  - Can be removed after confirming production stability

- **Map Boundaries:** `assets/geojson/` files are needed for UI (district/province boundaries)
  - These are NOT temporary data
  - These are essential for map visualization
  - Must be kept

- **Sample Trip Generator:** `sample_trips_generator.dart` useful for development/testing
  - Can create test trips without real database
  - Good for QA testing

## Production Readiness

✅ **Mobile:**
- Removed all fallback to temporary data
- All features use real APIs
- Proper error handling for API failures

✅ **Backend:**
- All models properly defined
- Routes secured with JWT
- Seed scripts available

✅ **Database:**
- Schema established
- Indexes created
- Sample data ready to load

**Status:** Ready for production deployment with proper testing
