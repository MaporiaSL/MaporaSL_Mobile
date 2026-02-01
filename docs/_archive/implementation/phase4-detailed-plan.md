Phase 4 Frontend Implementation Plan - Flutter Map Integration & Gamification

Phase: 4 - Map Integration (Frontend)

Status: 📋 REVISED & APPROVED

Created: January 24, 2026

Target Duration: 16-20 hours

Platform: Flutter (iOS/Android)

Table of Contents

Overview

Prerequisites

Architecture

Step-by-Step Implementation

Dependencies

Testing Strategy

Timeline & Milestones

Success Criteria

Overview

Phase 4 implements the core visual experience of MAPORIA. This is not just a standard map; it is a Gamified Travel Interface. Users will see their unlocked regions ("Fog of War"), view travel destinations, and access offline-ready maps for their trips.

Key Features

Custom Game Map: "Cartoon/Game" style map using Mapbox Studio styles.

Fog of War: Gamified overlay where visited districts are revealed and unvisited ones are clouded.

Destination Markers: Interactive markers for trip locations.

Offline Mode: Full trip download (Data via Hive, Map Tiles via Mapbox).

Navigation Handoff: Seamless one-tap integration with Google/Apple Maps.

Photo Gallery: Geotagged photo management.

Technology Stack

Map Library: Mapbox Maps Flutter

Gamification: GeoJSON Fill Layers & Expressions

Location Services: Geolocator

Navigation: Maps Launcher (External Handoff)

Offline Storage: Hive (Data) + Mapbox OfflineManager (Tiles)

State Management: Riverpod

Prerequisites

Backend Requirements

✅ Phase 3 Backend API complete

✅ Valid JWT authentication working

✅ GeoJSON endpoints operational (/api/travel/:id/geojson)

⚠️ **Missing Backend APIs** (Required for Phase 4):

1. **User Progress Endpoint**:
   ```
   GET /api/users/:userId/progress
   Returns: unlocked districts, provinces, achievements, stats
   ```

2. **Visit Verification Update**:
   ```
   PATCH /api/destinations/:id
   Body: { visited: true, visitedAt: timestamp }
   Should trigger district/province unlock calculations
   ```

3. **District Progress Query**:
   ```
   GET /api/districts/:districtId/progress?userId=...
   Returns: places visited, total places, completion %
   ```

**Action Required**: Implement these 3 endpoints in Phase 3 backend before starting Phase 4 frontend.

Development Environment

Flutter SDK 3.16+

Mapbox Public Access Token (Default)

Mapbox Secret Access Token (for Offline Downloads)

Custom Mapbox Style URL (Created in Mapbox Studio - e.g., mapbox://styles/user/maporia-game-v1)

Architecture

Folder Structure

mobile/lib/
├── features/
│   ├── map/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── geojson_model.dart
│   │   │   │   └── district_status.dart
│   │   │   ├── datasources/
│   │   │   │   ├── map_api.dart
│   │   │   │   └── offline_manager.dart (Mapbox wrapper)
│   │   │   └── repositories/
│   │   │       └── map_repository.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── game_map_screen.dart
│   │       │   └── offline_manager_screen.dart
│   │       ├── widgets/
│   │       │   ├── fog_layer.dart
│   │       │   ├── destination_marker.dart
│   │       │   └── trip_info_card.dart
│   │       └── providers/
│   │           ├── map_state_provider.dart
│   │           └── location_provider.dart
│   ├── photo/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── photo_gallery_popup.dart
├── core/
│   ├── services/
│   │   └── hive_service.dart
│   └── constants/
│       └── map_constants.dart
└── main.dart


Step-by-Step Implementation

Step 10: Setup Mapbox & Custom Style

Objective: Initialize Mapbox with the custom "Game" aesthetic.

Tasks:

Add Mapbox dependencies.

Configure API keys in AndroidManifest and Info.plist.

Create GameMapScreen widget.

Crucial: Load the custom style URL defined in Mapbox Studio (Teal/Amber theme, no roads/labels).

Dependencies:

mapbox_maps_flutter: ^0.5.0 (Check latest)
permission_handler: ^11.0.0


Key Code Structure:

MapWidget(
  styleUri: AppConstants.mapboxGameStyleUri, // Custom Style
  onMapCreated: _onMapCreated,
);


Time: 45 min

---

Step 10.5: Load District Boundaries Asset

Objective: Prepare local GeoJSON data for the Fog of War layer.

Tasks:

1. Copy geoBoundaries-LKA-ADM1_simplified.geojson from project_resources/ to mobile/assets/geojson/.

2. Update pubspec.yaml to include assets:

```yaml
flutter:
  assets:
    - assets/geojson/geoBoundaries-LKA-ADM1_simplified.geojson
```

3. Create GeoJSON parser utility.

4. Load and cache district polygons in memory on app start.

5. Validate GeoJSON structure (25 districts with district_id property).

Files to Create:

- mobile/assets/geojson/geoBoundaries-LKA-ADM1_simplified.geojson (copy)
- mobile/lib/core/utils/geojson_loader.dart

Key Code Structure:

```dart
class GeoJsonLoader {
  static Future<Map<String, dynamic>> loadDistrictBoundaries() async {
    final jsonString = await rootBundle.loadString(
      'assets/geojson/geoBoundaries-LKA-ADM1_simplified.geojson'
    );
    return json.decode(jsonString);
  }
}
```

Time: 30 min

---

Step 11: Display Destinations (Data Layer)

Objective: Fetch and render trip markers.

Tasks:

Fetch GeoJSON from Phase 3 API (/api/travel/:id/geojson).

Parse into DestinationModel.

Add PointAnnotation (Markers) to the map.

Color code: Green (Visited) vs Red (Pending).

Files to Create:

mobile/lib/features/map/data/datasources/map_api.dart

mobile/lib/features/map/presentation/providers/map_provider.dart

Time: 60 min

---

Step 11.5: GPS Visit Verification

Objective: Enable location-based visit confirmation (core gamification mechanic).

Tasks:

1. Request GPS permission on destination detail view.

2. Get current user location using geolocator.

3. Calculate distance between user and destination coordinates.

4. Enable "Mark as Visited" button only when within proximity radius (100m).

5. Show distance indicator in popup (e.g., "You are 245m away").

6. On successful verification, call backend API to mark visited.

7. Update local state and trigger fog layer refresh.

Files to Create:

- mobile/lib/core/utils/location_utils.dart
- mobile/lib/features/map/presentation/widgets/visit_verification_button.dart

Key Code Structure:

```dart
class LocationUtils {
  static const double VISIT_RADIUS_METERS = 100.0;
  
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude, point1.longitude,
      point2.latitude, point2.longitude
    );
  }
  
  static bool isWithinVisitRadius(LatLng userLocation, LatLng destination) {
    return calculateDistance(userLocation, destination) <= VISIT_RADIUS_METERS;
  }
}
```

Backend API Call:

```dart
// PATCH /api/destinations/:id
// Body: { visited: true, visitedAt: "2026-01-24T10:30:00Z" }
```

Testing:

- Mock GPS location in emulator.
- Verify button is disabled when > 100m away.
- Verify button enables when within radius.
- Verify API call and UI update on success.

Time: 60 min

---

Step 12: The "Fog of War" (Gamification)

Objective: Render the core gamification layer where visited districts are clear and unvisited are "fogged".

Tasks:

Load a local GeoJSON asset containing Sri Lanka's district boundaries.

Fetch User Progress (List of unlocked district IDs).

Add a GeoJsonSource to the map containing the districts.

Add a FillLayer linked to that source.

Use Mapbox Expressions to dynamically style opacity.

Logic (Expression):

fillColor: [
  'match',
  ['get', 'district_id'],
  unlockedIdsList, // Passed from Provider
  'rgba(0,0,0,0)',     // Transparent (Unlocked/Revealed)
  'rgba(0,0,0,0.6)'    // Dark Grey (Locked/Fog)
]


Testing:

Verify map starts "cloudy".

Verify unlocked districts are "clear".

Time: 90 min

---

Step 12.5: User Progress Sync

Objective: Fetch and sync user's unlocked districts for fog layer.

⚠️ **Backend Dependency**: This step requires a new API endpoint from Phase 3 backend.

**Required Backend API** (Add to Phase 3):

```
GET /api/users/:userId/progress
Authorization: Bearer {jwt}

Response:
{
  "userId": "...",
  "unlockedDistricts": ["colombo", "galle", "kandy"],
  "unlockedProvinces": ["western"],
  "totalPlacesVisited": 45,
  "completionPercentage": 18,
  "achievements": [
    {
      "districtId": "colombo",
      "progress": 100,
      "unlockedAt": "2025-12-15T10:00:00Z"
    }
  ]
}
```

Tasks:

1. Create ProgressModel to parse API response.

2. Create ProgressRepository and API datasource.

3. Create ProgressProvider (Riverpod) to manage state.

4. Fetch progress on app launch and after each visit.

5. Pass unlockedDistricts list to fog layer expression.

6. Cache progress in Hive for offline access.

Files to Create:

- mobile/lib/features/progress/data/models/progress_model.dart
- mobile/lib/features/progress/data/repositories/progress_repository.dart
- mobile/lib/features/progress/presentation/providers/progress_provider.dart

Key Code Structure:

```dart
class ProgressProvider extends StateNotifier<ProgressState> {
  Future<void> fetchProgress() async {
    final progress = await _repository.getUserProgress();
    state = ProgressState.loaded(progress);
    
    // Update fog layer
    _mapController.updateFogLayer(
      unlockedDistricts: progress.unlockedDistricts
    );
  }
}
```

Testing:

- Verify fog updates after fetching progress.
- Verify offline mode uses cached progress.
- Verify refresh after marking destination as visited.

Time: 75 min

---

Step 13: Map Interactions

Objective: Handle user taps and popups.

Tasks:

Handle onTap on Markers → Show Destination Popup.

Handle onTap on Map → Dismiss Popup.

Handle onTap on District Polygon → Show District Panel.

Destination Popup includes:

- Name, Description, Notes
- Photo Thumbnail
- Visited Status (Badge/Checkmark)
- Distance from current location
- "Navigate" button
- "Mark as Visited" button (if within radius)

District Panel includes:

- District Name & Description
- Progress Bar (e.g., "3/12 places visited")
- Achievement Badge (if 100% complete)
- List of places (achievement-style timeline)
- Cloud opacity indicator

Files to Create:

- mobile/lib/features/map/presentation/widgets/destination_popup.dart
- mobile/lib/features/map/presentation/widgets/district_panel.dart
- mobile/lib/features/map/presentation/widgets/achievement_badge.dart

Time: 60 min

Step 14: Offline Mode (Hybrid)

Objective: Allow users to download an entire trip for offline use.

Tasks:

Data Sync: Fetch all JSON (Trip details, Destinations) and save to Hive.

Visual Sync: Use MapboxMap.offlineManager.

Input: The Trip's Bounding Box (from Phase 3 Stats API).

Action: Download tiles for that region.

UI: Show download progress bar.

Files to Create:

mobile/core/services/hive_service.dart

mobile/features/map/data/datasources/offline_manager.dart

Dependencies:

hive: ^2.2.3
hive_flutter: ^1.1.0
connectivity_plus: ^5.0.0


Time: 90 min

Step 15: Navigation Handoff

Objective: Simple, reliable navigation using the user's trusted app.

Tasks:

Add "Navigate" button to Destination Popup.

Use MapsLauncher to trigger Google/Apple Maps.

Dependencies:

maps_launcher: ^3.0.0


Code:

onPressed: () => MapsLauncher.launchCoordinates(
  dest.lat, dest.lng, dest.name
),


Time: 30 min

Step 16: Photo Gallery

Objective: View and add photos to locations.

Tasks:

Display photo count on markers.

Full-screen photo viewer (using photo_view).

Integration with image_picker to take new photos.

Time: 45 min

Dependencies

pubspec.yaml

# Map & Location
mapbox_maps_flutter: ^0.5.0
geolocator: ^10.1.0
permission_handler: ^11.0.0
maps_launcher: ^3.0.0  # NEW: External Navigation

# Data & Offline
hive: ^2.2.3
hive_flutter: ^1.1.0
connectivity_plus: ^5.0.0
dio: ^5.3.0

# UI & Media
image_picker: ^1.0.0
cached_network_image: ^3.3.0
photo_view: ^0.14.0

# State Management
flutter_riverpod: ^2.4.9
