# Phase 3: Detailed Implementation Plan - Map Integration with Mapbox

## Status: 📋 READY TO START

**Mapping Library**: Mapbox  
**Scope**: Backend API + Flutter Mobile App  
**Data Format**: GeoJSON  
**Updates**: Static (load once)  
**Scale**: Medium (50-500 destinations per travel)  
**Privacy**: Private only  
**Created**: January 24, 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Feature Breakdown](#feature-breakdown)
3. [Backend Implementation](#backend-implementation)
4. [Frontend Implementation](#frontend-implementation)
5. [Implementation Steps](#implementation-steps)
6. [Testing Plan](#testing-plan)
7. [Dependencies](#dependencies)

---

## Overview

Phase 3 adds map visualization capabilities to the travel portfolio app using Mapbox. Users will be able to:
- View their destinations as markers on an interactive map
- See routes connecting destinations in order
- View travel boundaries and terrain information
- Use device GPS for location services
- Access offline maps
- Navigate turn-by-turn between destinations
- View photos at destination locations

---

## Feature Breakdown

### Core Map Features (Must-Have)
1. **Display Destinations as Markers**
   - Each destination appears as a pin/marker on the map
   - Markers color-coded by visited status (green=visited, red=not visited)
   - Custom marker icons for different destination types

2. **Show Routes Connecting Destinations**
   - Draw polylines connecting destinations in order
   - Show route distance and estimated travel time
   - Display route on map with directional arrows

3. **Click Marker for Details**
   - Tap marker to show destination popup
   - Display: name, notes, visited status, photos
   - Quick actions: Edit, Mark as visited, Navigate

### Geospatial Features
4. **Boundary Support**
   - Draw boundaries/polygons for visited regions
   - Aggregate destinations into geographic areas
   - Show "coverage" of a travel (area explored)

5. **Terrain Data**
   - Display terrain elevation on map
   - Show elevation profile along routes
   - Highlight mountainous vs flat areas

### Mobile Features
6. **Location Services (GPS)**
   - Show user's current location on map
   - Auto-center map on user location
   - Distance from current location to destinations

7. **Offline Maps**
   - Download map tiles for offline access
   - Cache destination data locally
   - Sync when back online

8. **Turn-by-Turn Navigation**
   - Navigate from current location to destination
   - Voice guidance
   - Real-time route updates (if online)

9. **Photo Gallery at Locations**
   - Display photos taken at each destination
   - View photos in grid on map
   - Tap photo to open full-screen view

---

## Backend Implementation

### New API Endpoints

#### 1. GeoJSON Endpoints

**GET /api/travel/:travelId/geojson**
- Returns all destinations in GeoJSON FeatureCollection format
- Includes routes as LineString features
- Includes boundaries as Polygon features

**Response Format**:
```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [80.7603, 7.9570]
      },
      "properties": {
        "id": "507f...",
        "name": "Sigiriya Rock",
        "visited": true,
        "notes": "...",
        "photos": ["url1", "url2"]
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [[80.7603, 7.9570], [80.6411, 7.2931]]
      },
      "properties": {
        "type": "route",
        "distance": 78.5,
        "duration": "1h 45m"
      }
    }
  ]
}
```

---

**GET /api/travel/:travelId/boundary**
- Returns boundary polygon for a travel
- Calculated from convex hull of all destinations
- Includes area in sq km

**Response Format**:
```json
{
  "type": "Feature",
  "geometry": {
    "type": "Polygon",
    "coordinates": [[[lng, lat], [lng, lat], ...]]
  },
  "properties": {
    "area_sq_km": 1250.5,
    "perimeter_km": 185.3
  }
}
```

---

**GET /api/travel/:travelId/terrain**
- Returns terrain/elevation data along travel route
- Samples elevation at regular intervals
- Provides elevation profile

**Response Format**:
```json
{
  "route": {
    "type": "LineString",
    "coordinates": [[lng, lat, elevation], ...]
  },
  "profile": {
    "min_elevation": 5,
    "max_elevation": 1200,
    "total_ascent": 3500,
    "total_descent": 3200
  }
}
```

---

#### 2. Geospatial Query Endpoints

**GET /api/destinations/nearby**
- Find destinations near a point
- Query params: `lat`, `lng`, `radius` (in km)
- Uses MongoDB geospatial indexing

**Query Parameters**:
- `lat` (required): Latitude
- `lng` (required): Longitude
- `radius` (optional): Radius in km (default: 50)
- `limit` (optional): Max results (default: 20)

**Response Format**:
```json
{
  "destinations": [
    {
      "_id": "507f...",
      "name": "Sigiriya Rock",
      "distance_km": 12.5,
      "latitude": 7.9570,
      "longitude": 80.7603
    }
  ],
  "total": 1
}
```

---

**GET /api/destinations/within-bounds**
- Find destinations within a bounding box
- Query params: `swLat`, `swLng`, `neLat`, `neLng`

**Query Parameters**:
- `swLat`: Southwest corner latitude
- `swLng`: Southwest corner longitude
- `neLat`: Northeast corner latitude
- `neLng`: Northeast corner longitude

---

#### 3. Statistics Endpoints

**GET /api/travel/:travelId/stats**
- Returns travel statistics for map visualization
- Total distance, destinations count, visited percentage

**Response Format**:
```json
{
  "total_destinations": 12,
  "visited_count": 8,
  "visited_percentage": 66.7,
  "total_distance_km": 425.3,
  "area_covered_sq_km": 1250.5,
  "duration_days": 14
}
```

---

### Database Changes

#### 1. Add Physical Location Field with Geospatial Index to Destination Model

**IMPORTANT**: MongoDB cannot index virtual fields. The `location` field must be physically stored in the database.

```javascript
// In Destination.js
const destinationSchema = new mongoose.Schema({
  // ... existing fields (userId, travelId, name, latitude, longitude, notes, visited)
  
  // Add physical GeoJSON location field
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true,
      index: '2dsphere' // Geospatial index for proximity queries
    }
  }
}, { timestamps: true });

// Pre-save hook: Auto-populate location from latitude/longitude
destinationSchema.pre('save', function(next) {
  // Update location.coordinates whenever lat/lng changes
  if (this.isModified('latitude') || this.isModified('longitude')) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude] // [lng, lat] order!
    };
  }
  next();
});

// Create 2dsphere index on location field
destinationSchema.index({ location: '2dsphere' });
```

**Key Points**:
- `location` is a **real field**, not virtual
- Coordinates stored as `[longitude, latitude]` (GeoJSON standard order)
- Pre-save hook automatically syncs location when lat/lng changes
- 2dsphere index enables geospatial queries ($near, $geoWithin, etc.)
- No code changes needed in controllers - location updates automatically
```

#### 2. Add Boundary Field to Travel Model (Optional)

```javascript
// In Travel.js
const travelSchema = new mongoose.Schema({
  // ... existing fields
  boundary: {
    type: {
      type: String,
      enum: ['Polygon'],
      default: 'Polygon'
    },
    coordinates: {
      type: [[[Number]]], // Array of array of coordinates
      default: null
    }
  },
  stats: {
    totalDistance: { type: Number, default: 0 },
    areaCovered: { type: Number, default: 0 }
  }
});
```

---

### New Backend Files to Create

1. **controllers/mapController.js** - Map-specific logic
   - `getTravelGeoJSON(req, res)` - Generate GeoJSON for travel
   - `getTravelBoundary(req, res)` - Calculate boundary polygon
   - `getTravelTerrain(req, res)` - Get terrain data
   - `getTravelStats(req, res)` - Calculate travel statistics

2. **controllers/geoController.js** - Geospatial queries
   - `findNearbyDestinations(req, res)` - Proximity search
   - `findDestinationsWithinBounds(req, res)` - Bounding box search

3. **routes/mapRoutes.js** - Map endpoints
   - Mount at `/api/travel/:travelId/map/*`

4. **routes/geoRoutes.js** - Geospatial query endpoints
   - Mount at `/api/destinations/geo/*`

5. **utils/geoUtils.js** - Geospatial utility functions
   - `calculateDistance(point1, point2)` - Haversine distance
   - `calculateBoundary(destinations)` - Convex hull algorithm
   - `calculateRouteDistance(destinations)` - Total route length
   - `orderDestinationsByProximity(destinations)` - Route optimization

6. **utils/geojsonBuilder.js** - GeoJSON formatting
   - `buildFeatureCollection(destinations)` - Create GeoJSON
   - `buildRouteFeature(destinations)` - Create route LineString
   - `buildBoundaryFeature(destinations)` - Create boundary Polygon

---

## Frontend Implementation

### Flutter Dependencies to Add

```yaml
# pubspec.yaml
dependencies:
  # Map rendering
  mapbox_maps_flutter: ^2.0.0  # Official Mapbox SDK
  
  # Location services
  geolocator: ^11.0.0  # GPS and location
  permission_handler: ^11.0.0  # Location permissions
  
  # Offline maps
  flutter_cache_manager: ^3.3.1  # Cache map tiles
  hive: ^2.2.3  # Local database for offline data
  hive_flutter: ^1.1.0
  
  # Navigation
  flutter_polyline_points: ^2.0.0  # Route polylines
  
  # Photo handling
  image_picker: ^1.0.5  # Take/select photos
  cached_network_image: ^3.3.0  # Cache images
  photo_view: ^0.14.0  # Full-screen photo viewer
```

---

### New Flutter Screens

#### 1. MapScreen (`lib/features/map/map_screen.dart`)
- Full-screen map view
- Shows all destinations for selected travel
- Bottom sheet with destination list
- Floating action buttons (GPS, zoom, layers)

**Key Components**:
- `MapboxMap` widget
- `DestinationMarker` custom widget
- `RoutePolyline` overlay
- `BoundaryPolygon` overlay

---

#### 2. DestinationMapDetailSheet (`lib/features/map/destination_detail_sheet.dart`)
- Bottom sheet showing destination details
- Photo carousel
- Quick actions (Navigate, Edit, Mark Visited)
- Distance from current location

---

#### 3. TravelMapOverview (`lib/features/travel/travel_map_tab.dart`)
- Tab in travel detail screen
- Smaller embedded map
- Shows route overview
- Tap to open full-screen map

---

### New Flutter Features

#### 1. MapBox Integration (`lib/features/map/mapbox_service.dart`)

```dart
class MapboxService {
  // Initialize Mapbox with access token
  Future<void> initialize();
  
  // Load map style (terrain, satellite, etc.)
  Future<void> loadStyle(MapStyle style);
  
  // Add markers to map
  Future<void> addDestinationMarkers(List<Destination> destinations);
  
  // Draw route between destinations
  Future<void> drawRoute(List<Destination> destinations);
  
  // Draw boundary polygon
  Future<void> drawBoundary(GeoJsonPolygon boundary);
  
  // Enable terrain layer
  Future<void> enableTerrain();
}
```

---

#### 2. Location Service (`lib/services/location_service.dart`)

```dart
class LocationService {
  // Get current location
  Future<Position> getCurrentLocation();
  
  // Watch location changes
  Stream<Position> watchLocation();
  
  // Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2);
  
  // Request location permissions
  Future<bool> requestPermissions();
}
```

---

#### 3. Offline Map Manager (`lib/services/offline_map_service.dart`)

```dart
class OfflineMapService {
  // Download map region for offline use
  Future<void> downloadRegion(BoundingBox bounds);
  
  // Check if region is downloaded
  Future<bool> isRegionDownloaded(String travelId);
  
  // Delete offline region
  Future<void> deleteRegion(String travelId);
  
  // Get download progress
  Stream<double> getDownloadProgress(String travelId);
}
```

---

#### 4. Navigation Service (`lib/services/navigation_service.dart`)

```dart
class NavigationService {
  // Start turn-by-turn navigation
  Future<void> startNavigation(Destination destination);
  
  // Stop navigation
  Future<void> stopNavigation();
  
  // Get current navigation instructions
  Stream<NavigationInstruction> getInstructions();
  
  // Reroute if user goes off-path
  Future<void> reroute();
}
```

---

#### 5. Photo Service (`lib/services/photo_service.dart`)

```dart
class PhotoService {
  // Pick photo from gallery
  Future<File?> pickFromGallery();
  
  // Take photo with camera
  Future<File?> takePhoto();
  
  // Upload photo to server (or cloud storage)
  Future<String> uploadPhoto(File photo);
  
  // Get photos for destination
  Future<List<String>> getDestinationPhotos(String destinationId);
}
```

---

## Implementation Steps

### Backend Steps (Step 1-8)

#### Step 1: Install Geospatial Dependencies ⏱️ 10 min
```bash
# No new packages needed - Mongoose has built-in geospatial support
# Optionally install for advanced features:
npm install @turf/turf  # Geospatial calculations (convex hull, distance, etc.)
```

**Validation**: 
- Check package.json for @turf/turf
- Run `npm install` successfully

---

#### Step 2: Update Destination Model with Physical Location Field ⏱️ 20 min

**File**: `backend/src/models/Destination.js`

**Tasks**:
- Add `location` field as a physical GeoJSON Point object (NOT virtual)
- Add pre-save hook to auto-populate location from latitude/longitude
- Add 2dsphere index on location field
- Ensure coordinates are in correct order: [longitude, latitude]

**Implementation**:
```javascript
// Add to schema definition
location: {
  type: {
    type: String,
    enum: ['Point'],
    default: 'Point'
  },
  coordinates: {
    type: [Number],
    required: true,
    index: '2dsphere'
  }
}

// Add pre-save hook
destinationSchema.pre('save', function(next) {
  if (this.isModified('latitude') || this.isModified('longitude')) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude]
    };
  }
  next();
});
```

**Validation**:
- Create a test destination with latitude/longitude
- Verify `location` field is auto-populated in MongoDB
- Check indexes: `db.destinations.getIndexes()` - should see `location_2dsphere`
- Query: `db.destinations.findOne()` - location should have `type: 'Point'` and `coordinates: [lng, lat]`

**Migration Note**: Existing destinations will need location field populated:
```javascript
// Run once to backfill existing records
await Destination.updateMany(
  { location: { $exists: false } },
  [{ $set: { 
    'location.type': 'Point',
    'location.coordinates': ['$longitude', '$latitude']
  }}]
);
```

---

#### Step 3: Create Geospatial Utility Functions ⏱️ 45 min

**File**: `backend/src/utils/geoUtils.js`

**Functions to Implement**:
```javascript
// Calculate distance using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) { }

// Calculate convex hull (boundary) from points
function calculateConvexHull(destinations) { }

// Calculate total route distance
function calculateRouteDistance(destinations) { }

// Order destinations by proximity (TSP approximation)
function orderDestinationsByProximity(destinations) { }

// Calculate bounding box
function calculateBoundingBox(destinations) { }
```

**Validation**:
- Unit test each function with sample coordinates
- Verify distance calculations match expected values

---

#### Step 4: Create GeoJSON Builder Utility ⏱️ 30 min

**File**: `backend/src/utils/geojsonBuilder.js`

**Functions to Implement**:
```javascript
// Build GeoJSON FeatureCollection from destinations
function buildFeatureCollection(destinations, includeRoutes = true) { }

// Build Point Feature for destination
function buildDestinationFeature(destination) { }

// Build LineString Feature for route
function buildRouteFeature(destinations) { }

// Build Polygon Feature for boundary
function buildBoundaryFeature(destinations) { }
```

**Validation**:
- Output should be valid GeoJSON (validate at geojson.io)
- Test with sample data

---

#### Step 5: Create Map Controller ⏱️ 60 min

**File**: `backend/src/controllers/mapController.js`

**Functions**:
1. `getTravelGeoJSON(req, res)` - Return GeoJSON FeatureCollection
2. `getTravelBoundary(req, res)` - Return boundary polygon
3. `getTravelTerrain(req, res)` - Return elevation data (stub for now)
4. `getTravelStats(req, res)` - Calculate and return stats

**Error Handling**:
- 404 if travel not found
- 401 if travel doesn't belong to user
- 500 for calculation errors

**Validation**:
- Test each endpoint returns valid GeoJSON
- Verify userId filtering works

---

#### Step 6: Create Geo Controller (Geospatial Queries) ⏱️ 45 min

**File**: `backend/src/controllers/geoController.js`

**Functions**:
1. `findNearbyDestinations(req, res)` - Proximity search
2. `findDestinationsWithinBounds(req, res)` - Bounding box search

**MongoDB Queries**:
```javascript
// Nearby search
Destination.find({
  location: {
    $near: {
      $geometry: { type: 'Point', coordinates: [lng, lat] },
      $maxDistance: radius * 1000 // meters
    }
  },
  userId: req.userId
});
```

**Validation**:
- Test with various radius values
- Verify results are sorted by distance

---

#### Step 7: Create Routes ⏱️ 20 min

**Files**:
- `backend/src/routes/mapRoutes.js`
- `backend/src/routes/geoRoutes.js`

**Map Routes**:
```javascript
GET /api/travel/:travelId/geojson
GET /api/travel/:travelId/boundary
GET /api/travel/:travelId/terrain
GET /api/travel/:travelId/stats
```

**Geo Routes**:
```javascript
GET /api/destinations/nearby
GET /api/destinations/within-bounds
```

**Validation**:
- All routes protected by JWT middleware
- Test each route with valid token

---

#### Step 8: Wire Routes into Server ⏱️ 10 min

**File**: `backend/src/server.js`

**Tasks**:
- Import mapRoutes and geoRoutes
- Mount at appropriate paths
- Test server starts without errors

**Validation**:
- Server runs successfully
- All routes accessible

---

### Frontend Steps (Step 9-16)

#### Step 9: Setup Mapbox SDK ⏱️ 30 min

**Tasks**:
1. Get Mapbox access token from [mapbox.com](https://account.mapbox.com/)
2. Add to `.env` or `assets/config.json`
3. Add dependencies to `pubspec.yaml`
4. Configure Android/iOS with Mapbox token

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="MAPBOX_ACCESS_TOKEN"
    android:value="YOUR_MAPBOX_TOKEN" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>MBXAccessToken</key>
<string>YOUR_MAPBOX_TOKEN</string>
```

**Validation**:
- Run `flutter pub get`
- Build Android/iOS successfully

---

#### Step 10: Create MapBox Service ⏱️ 60 min

**File**: `lib/services/mapbox_service.dart`

**Implementation**: MapboxService class with methods listed above

**Validation**:
- Initialize Mapbox successfully
- Load map style without errors
- Add sample markers to map

---

#### Step 11: Create Location Service ⏱️ 45 min

**File**: `lib/services/location_service.dart`

**Implementation**:
- Request permissions
- Get current location
- Calculate distances

**Validation**:
- Permissions requested on first use
- Current location retrieved successfully
- Distance calculations accurate

---

#### Step 12: Build Map Screen UI ⏱️ 90 min

**File**: `lib/features/map/map_screen.dart`

**Components**:
- Full-screen Mapbox map
- Destination markers
- Route polylines
- Boundary polygon (if exists)
- Floating action buttons (GPS, zoom, layers)
- Bottom sheet with destination list

**Validation**:
- Map loads and displays correctly
- Markers show at correct locations
- Routes drawn between destinations

---

#### Step 13: Implement Offline Maps ⏱️ 60 min

**File**: `lib/services/offline_map_service.dart`

**Implementation**:
- Download map tiles for region
- Store in local cache
- Load from cache when offline

**Validation**:
- Download completes successfully
- Map loads from cache when offline
- Progress indicator shows during download

---

#### Step 14: Implement Turn-by-Turn Navigation ⏱️ 90 min

**File**: `lib/services/navigation_service.dart`

**Implementation**:
- Get route from Mapbox Directions API
- Display route on map
- Provide turn-by-turn instructions
- Voice guidance (optional)

**Validation**:
- Route calculated correctly
- Instructions displayed
- Navigation updates as user moves

---

#### Step 15: Implement Photo Gallery ⏱️ 60 min

**Files**:
- `lib/services/photo_service.dart`
- `lib/widgets/photo_gallery.dart`

**Implementation**:
- Take/pick photos
- Upload to server or cloud storage
- Display in grid at destination location
- Full-screen viewer

**Validation**:
- Photos upload successfully
- Photos display at correct locations
- Gallery swipeable and zoomable

---

#### Step 16: Add Terrain Visualization ⏱️ 45 min

**File**: `lib/features/map/terrain_layer.dart`

**Implementation**:
- Enable Mapbox terrain layer
- Show elevation profile chart
- Highlight elevation changes along route

**Validation**:
- Terrain layer displays correctly
- Elevation profile shows accurate data

---

## Testing Plan

### Backend API Testing

**Test Cases**:
1. GET /api/travel/:id/geojson returns valid GeoJSON
2. GeoJSON includes all destinations as Point features
3. GeoJSON includes route as LineString feature
4. Boundary calculation returns valid Polygon
5. Nearby search returns destinations within radius
6. Bounding box search filters correctly
7. Stats calculation accurate (distance, area, etc.)
8. All endpoints require valid JWT
9. Users can only access their own travels

**Tools**:
- Manual testing with PowerShell/cURL
- Postman collection
- Validate GeoJSON at geojson.io

---

### Frontend Testing

**Test Cases**:
1. Map loads with Mapbox style
2. Markers display at correct coordinates
3. Route draws between destinations in order
4. Tap marker shows destination details
5. GPS button centers map on user location
6. Offline maps download and work offline
7. Navigation starts and provides instructions
8. Photos display at destination locations
9. Terrain layer shows elevation data
10. Boundary polygon displays correctly

**Tools**:
- Flutter widget tests
- Integration tests on emulator/device
- Manual testing with real GPS data

---

## Dependencies

### Backend
- ✅ Express.js (already installed)
- ✅ Mongoose (already installed, has geospatial support)
- 📦 @turf/turf (new) - Geospatial calculations

### Frontend
- 📦 mapbox_maps_flutter - Mapbox SDK
- 📦 geolocator - GPS location
- 📦 permission_handler - Permissions
- 📦 flutter_cache_manager - Cache tiles
- 📦 hive - Local database
- 📦 flutter_polyline_points - Route polylines
- 📦 image_picker - Photos
- 📦 cached_network_image - Image caching
- 📦 photo_view - Photo viewer

### External Services
- **Mapbox Account** - Free tier available
  - Access token required
  - 50,000 free map loads/month
  - Terrain API included
  - Directions API for navigation

---

## Timeline Estimates

**Backend**: ~5-6 hours
- Step 1-8: Map API endpoints and geospatial queries

**Frontend**: ~8-9 hours
- Step 9-16: Map UI, location, offline, navigation, photos

**Total Phase 3**: ~13-15 hours of development

**Plus Testing & Documentation**: +3-4 hours

**Grand Total**: ~16-19 hours

---

## Success Criteria

Phase 3 is complete when:
- ✅ Backend returns valid GeoJSON for travels
- ✅ Flutter app displays destinations on Mapbox map
- ✅ Routes connect destinations in order
- ✅ Boundaries show area covered
- ✅ Terrain layer displays elevation
- ✅ GPS shows user location
- ✅ Offline maps work without internet
- ✅ Navigation provides turn-by-turn directions
- ✅ Photos display at destination locations
- ✅ All features work on Android and iOS
- ✅ Documentation updated (API reference, setup guide)

---

## Next Steps After Phase 3

- Phase 4: Trip Planning (itineraries, budget)
- Phase 5: Social Features (sharing, collaboration)
- Testing Infrastructure (Jest, widget tests)
- Deployment Guide (production setup)

---

## Notes & Considerations

**Mapbox Pricing**:
- Free tier: 50,000 map loads/month
- Directions API: 100,000 requests/month free
- Offline maps: Included in free tier
- Monitor usage in Mapbox dashboard

**Performance**:
- Cache GeoJSON responses for medium-sized travels
- Use clustering for maps with 100+ destinations
- Lazy-load photos in gallery

**Privacy**:
- All map data private by default
- No sharing functionality in Phase 3
- User location never stored on server

**Future Enhancements** (Phase 4+):
- Heatmap visualization
- Real-time location sharing with friends
- Public travel maps
- AR navigation mode
- 3D terrain visualization
