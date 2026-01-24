# Phase 4 Frontend Implementation Plan - Flutter Map Integration

**Phase**: 4 - Map Integration (Frontend)  
**Status**: 📋 READY TO START  
**Created**: January 24, 2026  
**Target Duration**: 12-15 hours  
**Platform**: Flutter (iOS/Android)

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Dependencies](#dependencies)
6. [Testing Strategy](#testing-strategy)
7. [Timeline & Milestones](#timeline--milestones)
8. [Success Criteria](#success-criteria)

---

## Overview

Phase 4 Frontend implements map visualization and location-based features in the Flutter mobile app. Users will view their destinations on an interactive Mapbox map, access GPS location services, download offline maps, and navigate between destinations.

### Key Features
- Interactive map with destination markers
- GeoJSON data visualization
- GPS/device location tracking
- Offline map downloads
- Turn-by-turn navigation
- Photo gallery on map locations

### Technology Stack
- **Map Library**: Mapbox GL Flutter
- **Location Services**: Geolocator
- **Navigation**: Mapbox Directions API
- **Offline Storage**: SQLite
- **State Management**: Riverpod (existing)

---

## Prerequisites

### Backend Requirements
- ✅ Phase 3 Backend API complete (6 new endpoints)
- ✅ Valid JWT authentication working
- ✅ Destination model has latitude/longitude fields
- ✅ GeoJSON endpoints operational

### Development Environment
- Flutter SDK 3.0+
- Dart 3.0+
- iOS deployment target: 11.0+
- Android API level: 21+
- Mapbox account with API key

### Test Data
- At least 1 Travel record
- At least 3 Destination records with coordinates
- Valid Auth0 JWT token

---

## Architecture

### Folder Structure

```
mobile/lib/
├── features/
│   ├── map/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── geojson_model.dart
│   │   │   │   ├── destination_map.dart
│   │   │   │   └── route_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── map_api.dart
│   │   │   │   └── location_local.dart
│   │   │   └── repositories/
│   │   │       └── map_repository.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── map_screen.dart
│   │       │   ├── destination_detail.dart
│   │       │   └── navigation_screen.dart
│   │       ├── widgets/
│   │       │   ├── mapbox_widget.dart
│   │       │   ├── marker_popup.dart
│   │       │   ├── location_indicator.dart
│   │       │   └── route_overlay.dart
│   │       └── providers/
│   │           ├── map_provider.dart
│   │           ├── location_provider.dart
│   │           └── offline_provider.dart
│   ├── photo/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── photo_gallery_popup.dart
│   └── navigation/
│       └── providers/
│           └── navigation_provider.dart
├── core/
│   ├── network/
│   │   └── dio_client.dart (already exists)
│   └── constants/
│       └── map_constants.dart
└── main.dart
```

### Data Flow

```
User Action (tap marker)
    ↓
Map Provider (Riverpod)
    ↓
Map Repository
    ↓
Map API / Local Storage
    ↓
Backend API / SQLite
    ↓
Response → UI Update
```

---

## Step-by-Step Implementation

### Step 10: Setup Mapbox in Flutter

**Objective**: Initialize Mapbox in Flutter app and create basic map widget

**Tasks**:
1. Add Mapbox dependencies to pubspec.yaml
2. Configure Mapbox API key (Android & iOS)
3. Request location permissions
4. Create MapScreen widget
5. Initialize map with default location (Colombo, Sri Lanka)
6. Add map controls (zoom, center, layer toggle)

**Files to Create**:
- `mobile/lib/features/map/presentation/pages/map_screen.dart`
- `mobile/lib/features/map/presentation/widgets/mapbox_widget.dart`
- `mobile/core/constants/map_constants.dart`

**Files to Modify**:
- `mobile/pubspec.yaml` - Add dependencies
- `mobile/android/app/build.gradle` - Mapbox configuration
- `mobile/ios/Runner/Info.plist` - Location permissions
- `mobile/lib/main.dart` - Add map route

**Dependencies**:
```yaml
mapbox_gl: ^0.16.0
permission_handler: ^11.4.0
```

**Key Code Structure**:
```dart
// MapScreen: Main map display widget
// - Initialize Mapbox controller
// - Set initial bounds (Sri Lanka)
// - Handle map lifecycle
// - Manage map layers

// MapboxWidget: Reusable map component
// - Takes camera position, markers, routes as params
// - Emits tap events
// - Handles zoom/pan gestures
```

**Testing**:
- App launches with map visible
- Default location (Colombo) centered
- Zoom/pan gestures work
- Location permission request shows

**Time**: 30-45 min

---

### Step 11: Display Destinations on Map

**Objective**: Fetch travel GeoJSON and render destination markers

**Tasks**:
1. Create GeoJSON model for parsing backend response
2. Create Map API client (fetch `/api/travel/:travelId/geojson`)
3. Create Map Repository for data handling
4. Create Map Provider (Riverpod) for state management
5. Parse GeoJSON FeatureCollection
6. Create marker widgets from destinations
7. Color-code markers: green (visited), red (unvisited)
8. Display destination name on marker

**Files to Create**:
- `mobile/lib/features/map/data/models/geojson_model.dart`
- `mobile/lib/features/map/data/models/destination_map.dart`
- `mobile/lib/features/map/data/datasources/map_api.dart`
- `mobile/lib/features/map/data/repositories/map_repository.dart`
- `mobile/lib/features/map/presentation/providers/map_provider.dart`
- `mobile/lib/features/map/presentation/widgets/map_marker.dart`

**Files to Modify**:
- `mobile/lib/features/map/presentation/pages/map_screen.dart` - Integrate markers
- `mobile/lib/main.dart` - Add Riverpod setup if needed

**Key Code Structure**:
```dart
// GeoJSONModel: Parse Feature and FeatureCollection
// DestinationMap: Destination with marker data
// MapAPI: Fetch GeoJSON from backend
// MapRepository: Handle data retrieval and caching
// MapProvider: State management for destinations and markers

// MapScreen modifications:
// - Watch map provider for destinations
// - Build markers from GeoJSON features
// - Use destination visited status for color
```

**GeoJSON Response Expected**:
```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [79.8612, 6.9271]
      },
      "properties": {
        "id": "...",
        "name": "Colombo Fort",
        "visited": true,
        "marker-color": "#10b981"
      }
    }
  ]
}
```

**Testing**:
- Load travel page
- Markers appear on map at correct locations
- Visited markers are green, unvisited are red
- Destination names visible
- Multiple destinations display correctly

**Time**: 45-60 min

---

### Step 12: Implement Map Interactions

**Objective**: Handle user interactions with map (marker taps, details popup)

**Tasks**:
1. Create destination detail popup widget
2. Handle marker tap events
3. Display popup with destination info:
   - Name, description, notes
   - Visited status
   - Photo count
   - Visit date
4. Add quick action buttons:
   - "Mark as Visited" toggle
   - "View Photos" button
   - "Navigate" button
   - "Edit" button (nav to edit screen)
5. Implement popup dismiss on background tap
6. Handle map pan/zoom (dismiss popup when dragging)

**Files to Create**:
- `mobile/lib/features/map/presentation/widgets/marker_popup.dart`
- `mobile/lib/features/map/presentation/widgets/destination_action_buttons.dart`

**Files to Modify**:
- `mobile/lib/features/map/presentation/pages/map_screen.dart` - Add popup logic
- `mobile/lib/features/map/presentation/providers/map_provider.dart` - Add selected destination state

**Key Code Structure**:
```dart
// MarkerPopup: Displays destination details
// - Shows destination name, notes
// - Displays visited toggle with API update
// - Shows action buttons
// - Responsive popup sizing

// MapScreen modifications:
// - Watch selected destination
// - Show/hide popup based on selection
// - Handle marker tap → select destination
// - Handle gesture events → deselect destination
```

**UI Elements**:
- Popup background overlay
- Destination info card
- Toggle switch for visited status
- Action buttons with icons
- Close button (X)

**Testing**:
- Tap marker → popup appears
- Popup shows correct destination info
- Tap "Mark as Visited" → API call + visual update
- Tap background → popup closes
- Scroll map → popup hides

**Time**: 60-90 min

---

### Step 13: Add GPS Location Services

**Objective**: Track user's current location and display on map

**Tasks**:
1. Request location permissions (iOS/Android)
2. Setup Geolocator for GPS tracking
3. Create Location Provider (Riverpod)
4. Get initial location on screen load
5. Display user location indicator on map
6. Auto-center map on user location (toggle button)
7. Calculate distances from user to nearby destinations
8. Update location periodically (15-30 sec intervals)

**Files to Create**:
- `mobile/lib/features/map/presentation/providers/location_provider.dart`
- `mobile/lib/features/map/presentation/widgets/location_indicator.dart`
- `mobile/lib/core/constants/location_constants.dart`

**Files to Modify**:
- `mobile/pubspec.yaml` - Add geolocator
- `mobile/ios/Runner/Info.plist` - Location usage descriptions
- `mobile/android/app/src/main/AndroidManifest.xml` - Location permissions
- `mobile/lib/features/map/presentation/pages/map_screen.dart` - Add location indicator

**Dependencies**:
```yaml
geolocator: ^9.0.0
```

**Permission Strings** (iOS):
```xml
NSLocationWhenInUseUsageDescription: "We need your location to show it on the map"
NSLocationAlwaysAndWhenInUseUsageDescription: "We need your location to show it on the map and calculate distances"
```

**Permission Declarations** (Android):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Key Code Structure**:
```dart
// LocationProvider:
// - Request permission
// - Get current position
// - Stream position updates
// - Calculate distance to destinations

// MapScreen modifications:
// - Add "Center on Location" button
// - Display current location indicator
// - Update marker distances
// - Handle location changes
```

**Location Calculation**:
```dart
// Haversine formula for distance
double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371; // km
  final dLat = (lat2 - lat1) * pi / 180;
  final dLng = (lng2 - lng1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}
```

**Testing**:
- App requests location permission
- User location appears on map
- Location updates periodically
- "Center on Location" button centers map on user
- Distances shown on markers or popup

**Time**: 45-60 min

---

### Step 14: Implement Offline Maps

**Objective**: Enable offline map access and destination caching

**Tasks**:
1. Setup SQLite local database
2. Create offline data model and repository
3. Implement map tile download for region
4. Cache destination GeoJSON locally
5. Create offline mode detection
6. Sync cached data when online
7. Add "Download for Offline" button
8. Show sync status indicator

**Files to Create**:
- `mobile/lib/features/map/data/datasources/location_local.dart`
- `mobile/lib/features/map/presentation/pages/offline_sync_screen.dart`
- `mobile/lib/features/map/presentation/widgets/offline_indicator.dart`
- `mobile/lib/core/services/sync_service.dart`

**Files to Modify**:
- `mobile/pubspec.yaml` - Add sqflite, connectivity_plus
- `mobile/lib/features/map/data/repositories/map_repository.dart` - Add offline support
- `mobile/lib/features/map/presentation/providers/map_provider.dart` - Add connectivity check

**Dependencies**:
```yaml
sqflite: ^2.2.0
path_provider: ^2.0.0
connectivity_plus: ^4.0.0
```

**Local Database Schema**:
```sql
CREATE TABLE destinations (
  id TEXT PRIMARY KEY,
  travelId TEXT,
  name TEXT,
  latitude REAL,
  longitude REAL,
  visited BOOLEAN,
  notes TEXT,
  syncedAt TIMESTAMP,
  updatedAt TIMESTAMP
);

CREATE TABLE map_tiles (
  id INTEGER PRIMARY KEY,
  tileData BLOB,
  coordinates TEXT,
  zoomLevel INTEGER,
  downloadedAt TIMESTAMP
);
```

**Key Code Structure**:
```dart
// OfflineMapService:
// - Download map tiles for region
// - Save destinations to SQLite
// - Detect offline/online status
// - Sync changes when online

// MapRepository modifications:
// - Check local DB first
// - Fallback to API if online
// - Save API responses to local DB

// SyncService:
// - Track sync status
// - Queue offline changes
// - Sync when connectivity restored
```

**Download Strategy**:
- Show bounding box for download region
- User selects region and zoom level
- Download progress indicator
- Resume support for interrupted downloads
- Storage usage display

**Testing**:
- Turn off wifi/data
- Previously downloaded destinations still visible
- Cannot fetch new data (API unavailable)
- Turn on connectivity
- Sync button visible → press → sync completes
- New data appears

**Time**: 60-90 min

---

### Step 15: Add Turn-by-Turn Navigation

**Objective**: Integrate device navigation with route guidance

**Tasks**:
1. Get route from Mapbox Directions API
2. Display route polyline on map
3. Create navigation screen with turn instructions
4. Integrate with device navigation apps:
   - iOS: Apple Maps or Google Maps
   - Android: Google Maps
5. Show real-time navigation status
6. Handle navigation start/stop
7. Display distance and ETA to next waypoint
8. Add waypoint list in navigation view

**Files to Create**:
- `mobile/lib/features/navigation/presentation/pages/navigation_screen.dart`
- `mobile/lib/features/navigation/presentation/providers/navigation_provider.dart`
- `mobile/lib/features/map/presentation/widgets/route_overlay.dart`
- `mobile/lib/core/services/navigation_service.dart`

**Files to Modify**:
- `mobile/pubspec.yaml` - Add maps and url_launcher
- `mobile/lib/features/map/presentation/pages/map_screen.dart` - Add navigate button
- `mobile/lib/main.dart` - Add navigation route

**Dependencies**:
```yaml
maps_launcher: ^2.1.0
url_launcher: ^6.1.0
```

**Mapbox Directions API**:
```
GET https://api.mapbox.com/directions/v5/mapbox/driving/{lng1},{lat1};{lng2},{lat2}
  ?access_token=YOUR_TOKEN
  &steps=true
  &bannerInstructions=true
```

**Key Code Structure**:
```dart
// NavigationProvider:
// - Calculate route using Mapbox API
// - Parse turn-by-turn instructions
// - Track current waypoint
// - Calculate remaining distance/time

// NavigationService:
// - Launch device navigation app
// - Pass coordinates and waypoints
// - Handle success/error callbacks

// NavigationScreen:
// - Shows turn instructions
// - Current waypoint progress
// - List of upcoming turns
// - Cancel navigation button

// RouteOverlay:
// - Display route polyline on map
// - Highlight current segment
```

**Turn Instruction Format**:
```
1. Head northwest on Street Name (0.5 km)
2. Turn right onto Other Street (1.2 km)
3. Arrive at destination
```

**Integration with Native Apps**:
```dart
// iOS & Android
MapLauncher.launchMap(
  coords: [Coords(latitude, longitude)],
  title: "Destination Name",
  way-points: [...]
);
```

**Testing**:
- Tap "Navigate" button on destination
- Route appears on map
- Navigation screen shows turn-by-turn
- Launch native app → works
- Navigation follows correct path
- Distance/ETA updates

**Time**: 45-60 min

---

### Step 16: Photo Gallery on Map

**Objective**: Display and manage photos associated with destination locations

**Tasks**:
1. Display photo count on destination markers
2. Create photo gallery popup widget
3. Implement full-screen photo viewer
4. Add swipe/carousel navigation
5. Show photo metadata (date taken, location tag)
6. Add camera button to take new photo
7. Implement photo geotag feature
8. Cache photo thumbnails locally

**Files to Create**:
- `mobile/lib/features/photo/presentation/widgets/photo_gallery_popup.dart`
- `mobile/lib/features/photo/presentation/widgets/full_screen_viewer.dart`
- `mobile/lib/features/photo/presentation/providers/photo_provider.dart`
- `mobile/lib/core/services/photo_service.dart`

**Files to Modify**:
- `mobile/lib/features/map/presentation/widgets/marker_popup.dart` - Add photo count/button
- `mobile/pubspec.yaml` - Add image_picker, cached_network_image

**Dependencies**:
```yaml
image_picker: ^1.0.0
cached_network_image: ^3.3.0
photo_view: ^0.14.0
```

**Key Code Structure**:
```dart
// PhotoGalleryPopup:
// - Shows photo grid/carousel
// - Displays photo count
// - "View All" button → full screen
// - "Add Photo" button

// FullScreenViewer:
// - Full-screen image display
// - Swipe left/right navigation
// - Photo metadata
// - Share/download buttons
// - Close button

// PhotoService:
// - Upload photo to backend
// - Geotag with current location
// - Cache thumbnails
// - Manage photo URLs
```

**Photo Data Structure**:
```dart
class PhotoModel {
  final String id;
  final String destinationId;
  final String url;
  final String thumbnailUrl;
  final DateTime takenAt;
  final double? latitude;
  final double? longitude;
  final String? caption;
}
```

**Photo Display**:
- Thumbnail grid in popup (3 columns)
- "Show all {count}" link at bottom
- Full-screen carousel with swipe
- Photo date below image
- Location tag if geotagged

**Testing**:
- Tap destination with photos
- Photo count displayed
- Tap "View" → popup shows thumbnails
- Swipe → navigate between photos
- Long-press → share/save options
- Add photo button → camera picker opens
- Photo appears on map

**Time**: 30-45 min

---

## Dependencies

### pubspec.yaml Additions

```yaml
# Map & Location
mapbox_gl: ^0.16.0
geolocator: ^9.0.0
permission_handler: ^11.4.0

# Navigation
maps_launcher: ^2.1.0
url_launcher: ^6.1.0

# Photos
image_picker: ^1.0.0
cached_network_image: ^3.3.0
photo_view: ^0.14.0

# Offline & Storage
sqflite: ^2.2.0
path_provider: ^2.0.0
connectivity_plus: ^4.0.0

# State Management (existing)
riverpod: ^2.4.0
hooks_riverpod: ^2.4.0
```

### Platform-Specific Setup

**iOS** (`ios/Podfile`):
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

**Android** (`android/app/build.gradle`):
```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

---

## Testing Strategy

### Unit Tests
- Distance calculation function
- GeoJSON parsing
- Location permission handling
- Offline data caching

### Widget Tests
- MapScreen rendering
- Marker tap detection
- Popup display/dismiss
- Location indicator visibility

### Integration Tests
- Load travel → fetch GeoJSON → display markers
- Tap marker → popup shows
- Mark as visited → API call succeeds → UI updates
- Download offline data → verify local storage
- Turn off network → offline data loads
- Enable network → sync occurs

### Manual Testing (Real Device)
- Open app on iOS and Android
- Test location permission flow
- Verify GPS accuracy
- Test offline maps download
- Test navigation with native app
- Test photo gallery UX
- Test all gestures and interactions

### Test Data Setup
```dart
// Create test travel with destinations
// Execute on device before testing
final testTravel = {
  "name": "Test Travel",
  "startDate": "2025-12-01T00:00:00Z",
  "endDate": "2025-12-15T00:00:00Z"
};

final testDestinations = [
  {"name": "Colombo", "latitude": 6.9271, "longitude": 79.8612},
  {"name": "Galle", "latitude": 6.0278, "longitude": 80.2169},
  {"name": "Kandy", "latitude": 7.2906, "longitude": 80.6350},
];
```

---

## Timeline & Milestones

| Step | Feature | Duration | Cumulative |
|------|---------|----------|-----------|
| 10 | Setup Mapbox | 30-45 min | 0.5-0.75h |
| 11 | Display Markers | 45-60 min | 1.25-1.75h |
| 12 | Map Interactions | 60-90 min | 2.25-3.75h |
| 13 | GPS Services | 45-60 min | 3.25-4.75h |
| 14 | Offline Maps | 60-90 min | 4.25-6.25h |
| 15 | Navigation | 45-60 min | 5.25-7.25h |
| 16 | Photo Gallery | 30-45 min | 6.25-8.25h |
| **Testing** | **Manual + Integration** | **2-4h** | **8.25-12.25h** |

**Total**: 12-15 hours

### Milestone Checkpoints
- ✅ **Checkpoint 1** (After Step 11): Map displays with markers
- ✅ **Checkpoint 2** (After Step 12): User can interact with destinations
- ✅ **Checkpoint 3** (After Step 13): GPS and location tracking working
- ✅ **Checkpoint 4** (After Step 14): Offline functionality complete
- ✅ **Checkpoint 5** (After Step 15): Navigation integration working
- ✅ **Checkpoint 6** (After Step 16): Photo gallery operational

---

## Success Criteria

### Functional Requirements
- ✅ Map displays with proper zoom/pan controls
- ✅ Destination markers show for all destinations in travel
- ✅ Markers are color-coded (green/red by visited status)
- ✅ Tapping marker shows destination details popup
- ✅ "Mark as Visited" updates backend and UI
- ✅ User location displays and updates periodically
- ✅ Offline maps can be downloaded and used without internet
- ✅ Turn-by-turn navigation integrates with native apps
- ✅ Photos display on map and in full-screen gallery
- ✅ Photo gallery has swipe navigation

### Non-Functional Requirements
- ✅ Map loads within 3 seconds
- ✅ Location updates within 15-30 second intervals
- ✅ Offline tiles load instantly (cached)
- ✅ Navigation transitions smooth (60 FPS)
- ✅ Photo gallery responsive on all screen sizes
- ✅ No crashes or memory leaks during testing
- ✅ Works on iOS 11+ and Android 21+

### Performance Targets
- App launches in < 2 seconds
- Map renders destinations in < 1 second
- Location permission flows smoothly
- Offline sync completes in < 30 seconds
- Photo loads in < 500ms

### Code Quality
- All new code follows existing patterns
- Proper error handling throughout
- Riverpod state management used consistently
- Repository pattern for data access
- Unit tests for business logic

---

## Risk Management

### Potential Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Mapbox API limit exceeded | App unusable | Implement request caching, use offline data |
| Location permission denied | GPS unavailable | Graceful degradation, show message |
| Network timeout on sync | Data sync fails | Queue changes, retry with exponential backoff |
| Memory leak from image loading | App crashes | Use cached_network_image, dispose resources |
| SQLite corruption on crash | Offline data lost | Implement database recovery, versioning |

### Fallback Strategies
1. **No Internet**: Show cached GeoJSON and destinations
2. **No Location**: Use last known location or map center
3. **Mapbox Down**: Show cached map tiles with overlay data
4. **API Failure**: Retry with exponential backoff, show error message

---

## Notes & Considerations

### Mapbox API Token
- Store securely in `.env` file
- Different tokens for dev/prod if needed
- Monitor API usage to avoid rate limits

### Location Privacy
- Only collect location when map screen active
- Stop location updates when app backgrounded
- Allow user to disable location tracking
- Clear location history in settings

### Photo Management
- Implement photo compression before upload
- Limit photo size to 5MB per image
- Cache thumbnails for performance
- Handle upload failures gracefully

### Offline Sync Strategy
- Only sync when WiFi available (configurable)
- Show sync queue and status
- Allow manual sync trigger
- Warn if offline changes risk conflicts

### Device Support
- Test on iOS 11.0+ (older devices may lack some features)
- Test on Android 21+ (minimum required)
- Support landscape/portrait orientations
- Handle notches and safe areas properly

---

## Next Steps

1. **Prepare Environment**
   - Get Mapbox API key
   - Update iOS/Android configs
   - Review existing Riverpod setup

2. **Start Implementation**
   - Begin with Step 10 (Mapbox setup)
   - Follow sequence through Step 16
   - Test after each step

3. **Testing**
   - Manual testing on real devices
   - Integration testing with backend
   - Performance optimization
   - Bug fixes and refinement

4. **Documentation**
   - Update README with new features
   - Document API integration
   - Create user guide for map features

---

**Created**: January 24, 2026  
**Status**: Ready for Implementation  
**Lead**: Frontend Development Team
