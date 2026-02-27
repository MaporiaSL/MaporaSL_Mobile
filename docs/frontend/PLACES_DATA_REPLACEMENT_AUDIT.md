# Places Data Replacement Audit & Plan
**Status**: Ready to Replace All Temporary Data  
**Date**: February 17, 2026

---

## 📊 TEMPORARY DATA SOURCES IDENTIFIED

### **1. Mobile Assets - Hardcoded Seed Data**

| Location | File | Type | Purpose | Records |
|----------|------|------|---------|---------|
| **Primary** | `mobile/assets/data/places_seed_data_2026.json` | JSON (Local) | Dev/fallback places for exploration feature | ~25-42 per district |
| **Fallback** | `project_resorces/places_seed_data_2026.json` | JSON (Asset) | Backup seed data | Same as above |
| **Legacy** | `project_resorces/places_seed_data.json` | JSON (Archive) | Original seed file | Deprecated |
| **Real Places** | `project_resorces/sri_lanka_real_places_100.json` | JSON (Resource) | 100 real Sri Lankan places | 100 places |

---

## 🎯 WHERE TEMPORARY DATA IS CURRENTLY BEING USED

### **A. EXPLORATION FEATURE (Map District Quest System)**

**File**: `mobile/lib/features/exploration/providers/exploration_provider.dart`  
**Lines**: 59-133  
**Dev Flag**: `_devSeedAssignments = true`

**Current Flow**:
```
1. loadAssignments() → _api.fetchAssignments() 
2. If empty OR error → _loadDevAssignmentsFromAsset() [FALLBACK TO SEED]
3. Loads: 'assets/data/places_seed_data_2026.json'
4. Parses districts → attractions → ExplorationLocation objects
5. Hard-coded visited logic: "district == 'Colombo' && index == 0"
```

**What Gets Created**:
- `ExplorationLocation` objects with:
  - ID: `'seed-{district}-{index}'`
  - Name, Type, Latitude, Longitude
  - Visited status (hardcoded for demo)
- `DistrictAssignment` per district:
  - Lists of locations per district
  - Assignment count (locations.length)
  - Visited count (locations visited)

**Replacement Strategy**:
- ✅ Remove `_devSeedAssignments` flag
- ✅ Call API: `_api.fetchAssignments()` (backend returns real DB assignments)
- ✅ If no API assignments: fetch places from `/api/places` by district
- ✅ Create `ExplorationLocation` from DB Place objects
- ✅ Remove hardcoded visited logic

---

### **B. TRIPS FEATURE (Create Trip - Add Places)**

**Files**: 
- `mobile/lib/features/trips/presentation/create_trip_page.dart` (lines 240-273)
- `mobile/lib/features/trips/models/trip_model.dart` (fields: `destinationCount`)

**Current Implementation**:
```dart
late List<String> _places;  // Currently: empty or placeholder
// UI shows: "Destinations (${_places.length})"
// No actual place fetching from DB
```

**Missing Pieces**:
- No integration with `/api/places` endpoint
- Places list hard-coded as empty
- No place selection UI
- Destinations count calculated locally (not from DB)

**Replacement Strategy**:
- ✅ Create provider: `placesProvider` (fetch all places)
- ✅ Show places list in trip creation (searchable/filterable)
- ✅ Users select places → stored as `destinationIds` in Trip
- ✅ Update `destinationCount` from selected places

---

### **C. SHOP FEATURE (See Product Details with Location)**

**Files**:
- `backend/src/data/realStoreSampleProducts.json` (seed data)
- `backend/seed-real-store.js` (seeding script)

**Real Store Items Include**:
```json
{
  "productName": "...",
  "districtId": "colombo",  ← Linked to district
  "provinceId": "western",  ← Linked to province
  "location": "..."         ← Generic text location
}
```

**Missing**: 
- No actual place ID linking
- Location is just text, not real place from DB
- No photos from place DB
- No place metadata (coordinates, category, etc.)

**Replacement Strategy**:
- ✅ Add `placeId` field to products (FK to Place)
- ✅ Fetch place details from `/api/places/:id` when showing product
- ✅ Display place photos, coordinates, description
- ✅ Link to place in map/exploration
- ✅ Update seed script to use real place IDs from DB

---

### **D. ALBUM FEATURE (Photos Associated with District/Place)**

**Files**:
- `backend/src/controllers/albumController.js`
- `backend/src/models/Album.js`

**Current Album Model**:
```javascript
{
  districtId: String,      // Just the ID
  provinceId: String,      // Just the ID
  photos: [{
    caption: String,
    location: String,      // Generic text location
    url: String
  }]
}
```

**Missing**:
- No `placeId` field (reference to specific place in DB)
- Location is just text, not actual place DB entry
- Can't fetch place details (category, coordinates, etc.)
- Photos not linked to real places

**Replacement Strategy**:
- ✅ Add optional `placeId` field to Album schema
- ✅ When user creates album with place context → store `placeId`
- ✅ Fetch place details from API when displaying album
- ✅ Show richer metadata: place name, category, coordinates, etc.

---

### **E. USER PROFILE (Contributed Places & Statistics)**

**Files**:
- `backend/src/models/User.js` (contributedPlaces stats)
- `backend/src/controllers/userController.js` (getProfile)

**Current Implementation**:
```javascript
contributedPlaces: {
  total: Number,
  approved: Number,
  pending: Number,
  places: Array<ObjectId>  // References to Place IDs (placeholder)
}
```

**Issue**:
- Seed contributions are placeholders
- No real data from Place submissions
- Statistics not updated when places approved

**Replacement Strategy**:
- ✅ When place is approved (admin) → update User.contributedPlaces
- ✅ Fetch actual contributed places from `/api/places?contributor=userId`
- ✅ Display real place cards in profile
- ✅ Calculate stats from actual DB places

---

### **F. SHARING CARDS (Share Place/Trip Progress)**

**Location**: To be implemented 

**Current State**: Not yet using places data

**Replacement Strategy**:
- ✅ When creating share card → fetch place details from DB
- ✅ Include place metadata: name, photo, district, category
- ✅ Link card to actual place in system
- ✅ Generate rich share preview

---

### **G. PHOTO ALBUM & GENERAL SETTINGS**

**Locations**:
- Photo albums: Can optionally reference place
- Settings: Can have default "favorite places"

**Current**: Generic district/province references only

**Replacement Strategy**:
- ✅ Add place selection to album creation
- ✅ Add "My Favorite Places" to user settings (from `/api/places`)
- ✅ Use place data for context everywhere

---

## 📋 DATABASE PLACES I NEED

### **Required Fields in DB Place Object**:
```javascript
{
  _id: ObjectId,
  name: String,                         // "Sigiriya Rock"
  description: String,                  // Long description
  category: String,                     // "mountain", "temple", etc.
  districtId: String,                   // "matale"
  district: String,                     // "Matale"
  province: String,                     // "Central Province"
  location: {
    latitude: Number,
    longitude: Number,
    address: String,
    googleMapsUrl: String
  },
  photos: [String],                     // URLs to photos
  rating: Number,
  reviewCount: Number,
  accessibility: {
    season: String,
    difficulty: String,
    estimatedDuration: String,
    entryFee: String
  },
  tags: [String],
  source: String,                       // "system" or "user"
  contributor: ObjectId,                // User who submitted
  verified: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🛠️ IMPLEMENTATION ROADMAP

### **Phase 1: Backend Setup**
- [ ] Ensure `/api/places` endpoint returns paginated places
- [ ] Ensure places seeded in DB (use `sri_lanka_real_places_100.json`)
- [ ] Add placeId support to Product model
- [ ] Add placeId support to Album model
- [ ] Update User model to track contributed places
- [ ] Create `/api/places?district=X` endpoint

### **Phase 2: Frontend - Exploration**
- [ ] Remove `_devSeedAssignments` flag from exploration provider
- [ ] Update `loadAssignments()` to fetch real DB assignments
- [ ] If no assignments exist → fetch places from `/api/places?district=X`
- [ ] Create `ExplorationLocation` from DB Place objects
- [ ] Test with all 25 districts

### **Phase 3: Frontend - Trips**
- [ ] Create `placesProvider` using PlacesRepository
- [ ] Add place search/filter UI in trip creation
- [ ] Users select places → store as `destinationIds`
- [ ] Calculate `destinationCount` from selected places

### **Phase 4: Frontend - Shop**
- [ ] Update product model to include `placeId`
- [ ] Fetch place details when showing product
- [ ] Display place photos, coordinates, description
- [ ] Link to place in map

### **Phase 5: Frontend - Album**
- [ ] Add place selector to album creation
- [ ] Store `placeId` when album is created with place context
- [ ] Fetch place details when displaying album
- [ ] Show place metadata in album view

### **Phase 6: Frontend - Profile & Sharing**
- [ ] Display contributed places from `/api/places?contributor=userId`
- [ ] Update stats from real DB contributions
- [ ] Add place cards to sharing features
- [ ] Add "Favorite Places" setting

---

## 🗂️ FILES TO MODIFY

### **Frontend (Dart/Flutter)**

| Priority | File | Change | Impact |
|----------|------|--------|--------|
| 🔴 High | `exploration/providers/exploration_provider.dart` | Remove seed fallback, use API | Exploration feature |
| 🔴 High | `places/data/places_repository.dart` | Complete API implementation | All place fetching |
| 🟠 Medium | `trips/presentation/create_trip_page.dart` | Integrate places UI | Trip creation |
| 🟠 Medium | `shop/providers/real_store_providers.dart` | Add place linking | Shop feature |
| 🟠 Medium | `album/presentation/album_creation.dart` | Add place selector | Album feature |
| 🟡 Low | `profile/providers/profile_provider.dart` | Fetch contributed places | Profile view |
| 🟡 Low | Create: `sharing/providers/sharing_provider.dart` | Share place cards | Sharing feature |

### **Backend (Node.js)**

| Priority | File | Change | Impact |
|----------|------|--------|--------|
| 🔴 High | `routes/placeRoutes.js` | Ensure all endpoints working | Place API |
| 🔴 High | `controllers/placeController.js` | Test all CRUD operations | Place management |
| 🟠 Medium | `models/RealStoreItem.js` | Add placeId field | Shop linking |
| 🟠 Medium | `models/Album.js` | Add placeId field | Album linking |
| 🟠 Medium | `models/User.js` | Update contributedPlaces tracking | User stats |

### **Asset Files to Remove**

```
❌ mobile/assets/data/places_seed_data_2026.json
❌ project_resorces/places_seed_data_2026.json
❌ project_resorces/places_seed_data.json

✅ Keep: project_resorces/sri_lanka_real_places_100.json (for initial seeding ONCE)
```

---

## ✅ SUCCESS CRITERIA

- [ ] All 25 districts load places from `/api/places`
- [ ] Exploration shows real DB places, not seed data
- [ ] Users can select real places when creating trips
- [ ] Shop products link to actual places in DB
- [ ] Albums can associate with real places
- [ ] User profiles show real contributed places
- [ ] No hardcoded/seed place data in app code
- [ ] All API calls hit `/api/places` endpoint
- [ ] Sharing cards show real place metadata

---

## 📌 GROWING PLACES LIST NOTE

The `sri_lanka_real_places_100.json` file contains the **"growing places list"** that:
- Starts with 100 verified Sri Lankan attractions
- Can be seeded ONCE into production DB
- Users can submit NEW places via `/api/places/request`
- Admin approves → automatically added as verified places
- Over time, list grows organically via user contributions

**THIS IS NOT A DEPENDENCY** - users can always use their own places, but these are curated/verified attractions in all districts.

---

## 🚀 NEXT STEPS

1. **Confirm DB Seeding**: Ensure `sri_lanka_real_places_100.json` is imported into MongoDB
2. **Test API**: Run `GET /api/places` → should return paginated places
3. **Pick First Feature**: Start with Exploration (most critical)
4. **Update Sequentially**: Follow roadmap phases above
5. **Remove Fallbacks**: Delete seed data files once all features use real DB
6. **QA**: Test each feature end-to-end with real places
