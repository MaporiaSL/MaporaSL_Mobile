# Flutter Project Structure Analysis
**Project:** Gemified Travel Portfolio  
**Location:** `mobile/`  
**Date:** March 18, 2026

---

## 📁 Project Hierarchy

```
lib/
├── core/                          # Shared utilities, services, theme
│   ├── config/
│   │   └── app_config.dart        # API endpoints, configuration
│   ├── constants/
│   │   ├── app_colors.dart        # Color palette
│   │   └── map_constants.dart     # Map-related constants
│   ├── providers/                 # Core state management
│   │   ├── accessibility_provider.dart
│   │   ├── security_provider.dart
│   │   └── theme_provider.dart
│   ├── services/                  # API and data services
│   │   ├── api_client.dart        # HTTP client wrapper (Dio)
│   │   ├── auth_api.dart
│   │   ├── auth_interceptor.dart
│   │   ├── auth_service.dart      # Firebase authentication
│   │   ├── google_places_service.dart
│   │   ├── location_service.dart  # Geolocator service
│   │   ├── permission_service.dart
│   │   └── local_prefs.dart       # SharedPreferences wrapper
│   ├── theme/
│   │   └── app_theme.dart         # Material design theme
│   └── utils/
│       ├── geojson_loader.dart    # Load GeoJSON assets
│       └── ds_checker.dart        # District validation
├── data/
│   └── geojson/                   # GeoJSON geographic data
├── models/                         # Global shared models
│   ├── ds_division_model.dart
│   └── user_progress_model.dart
├── providers/                      # Global Riverpod providers
│   ├── progress_provider.dart
│   └── theme_provider.dart
├── features/
│   ├── album/                      # Photo album feature
│   │   ├── data/
│   │   │   └── models/
│   │   ├── presentation/
│   │   │   ├── album_page.dart
│   │   │   ├── album_detail_page.dart
│   │   │   ├── camera_page.dart
│   │   │   └── photo_viewer_page.dart
│   │   └── widgets/
│   ├── auth/                       # Authentication feature 🔐
│   │   ├── presentation/
│   │   │   ├── app_lock_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── email_verification_screen.dart
│   │   └── services/
│   ├── exploration/                # Exploration/district assignment feature 🗺️
│   │   ├── data/
│   │   │   ├── exploration_api.dart
│   │   │   ├── districts_data.dart
│   │   │   └── models/
│   │   │       └── exploration_models.dart
│   │   │           ├── ExplorationLocation
│   │   │           ├── DistrictAssignment
│   │   │           ├── DistrictSummary
│   │   │           ├── GeoPoint
│   │   │           └── GeoBounds
│   │   ├── presentation/
│   │   │   └── exploration_onboarding_screen.dart
│   │   └── providers/
│   │       └── exploration_provider.dart
│   │           ├── ExplorationState
│   │           └── ExplorationNotifier
│   ├── home/                       # Home/dashboard feature 🏠
│   │   ├── presentation/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   ├── map/                        # Map display feature 🗺️ [User is here]
│   │   ├── controllers/
│   │   ├── data/
│   │   │   ├── regions_data.dart
│   │   │   └── map_data.dart
│   │   ├── models/
│   │   │   └── map_models.dart
│   │   │       ├── TripGeoJson
│   │   │       ├── TripGeoJsonProperties
│   │   │       ├── TripBoundary
│   │   │       ├── TripStats
│   │   │       ├── TripStatsGeography
│   │   │       ├── DestinationDetail
│   │   │       └── MapStyle enum
│   │   ├── presentation/
│   │   │   ├── map_screen.dart                     # Main map display
│   │   │   ├── map_screen_refactored.dart
│   │   │   ├── mapbox_map_screen.dart
│   │   │   ├── game_map_screen.dart
│   │   │   ├── painters/
│   │   │   ├── theme/
│   │   │   │   └── map_visual_theme.dart
│   │   │   └── widgets/
│   │   │       └── cartoon_map_canvas.dart
│   │   ├── providers/
│   │   │   └── map_provider.dart
│   │   │       ├── MapState
│   │   │       └── MapNotifier
│   │   ├── services/
│   │   │   └── map_api_service.dart
│   │   └── widgets/
│   │       ├── map_overlay.dart
│   │       └── tracking_toggle.dart
│   ├── onboarding/                 # Onboarding flow
│   ├── places/                     # Places/destinations feature 📍
│   │   ├── data/
│   │   │   ├── places_repository.dart
│   │   │   ├── place_visit_repository.dart
│   │   │   ├── models/
│   │   │   │   └── place_visit.dart
│   │   │   └── datasources/
│   │   ├── models/
│   │   │   └── place.dart
│   │   │       ├── Place class (id, name, coords)
│   │   │       └── Place.fromJson, toJson
│   │   ├── presentation/
│   │   │   └── add_destination_page.dart
│   │   ├── providers/
│   │   │   └── place_visit_provider.dart
│   │   │       ├── PlaceVisitState
│   │   │       ├── PlaceVisitNotifier
│   │   │       └── Multiple FutureProviders
│   │   ├── screens/
│   │   │   └── places_list_screen.dart
│   │   └── widgets/
│   │       ├── place_card.dart
│   │       ├── achievement_card.dart
│   │       ├── destination_picker.dart
│   │       ├── mark_visit_modal.dart
│   │       ├── visit_status_badge.dart
│   │       └── visit_verification_error_screen.dart
│   ├── profile/                    # User profile
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── settings/                   # Settings
│   │   └── presentation/
│   ├── shop/                       # Shop/in-app purchases
│   ├── trips/                      # Trip management feature 🚗
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   │   ├── trip_model.dart
│   │   │   │   ├── trip_stats_model.dart
│   │   │   │   ├── preplanned_trip_model.dart
│   │   │   │   ├── trip_dto.dart
│   │   │   │   └── Generated .g.dart files (JSON serialization)
│   │   │   └── repositories/
│   │   │       ├── trips_repository.dart
│   │   │       └── preplanned_trips_repository.dart
│   │   ├── presentation/
│   │   │   ├── trips_page.dart
│   │   │   ├── create_trip_page.dart
│   │   │   ├── trip_detail_page.dart
│   │   │   ├── memory_lane_page.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   └── utils/
│   ├── visits/                     # Visit tracking feature ✅
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── visit_model.dart
│   │   │   └── visit_repository.dart
│   │   ├── presentation/
│   │   │   ├── widgets/
│   │   │   └── dynamic_visit_sheet.dart
│   │   └── providers/
│   │       └── visit_provider.dart
│   │           ├── VisitState
│   │           ├── VisitNotifier
│   │           └── markVisitWithDeviceLocation()
│   └── splash/                     # Splash screen
└── main.dart                       # App entry point

```

---

## 🔑 Key Providers (Riverpod State Management)

### Global Providers (`lib/providers/`)
| Provider | Type | Purpose |
|----------|------|---------|
| `progressProvider` | StateNotifier | User progress tracking |
| `themeProvider` | StateNotifier | App theme state |

### Core Providers (`lib/core/providers/`)
| Provider | Type | Purpose |
|----------|------|---------|
| `accessibilityProvider` | StateNotifier | Accessibility settings |
| `securityProvider` | StateNotifier | Security/encryption state |
| `themeProvider` | StateProvider | Theme management |

### Feature Providers

#### Map Feature
- **`mapProvider`** - StateNotifier<MapState>
  - Manages: current trip, GeoJSON, destinations, user location, zoom level, route/boundary visibility
  - Key methods: `completionPercentage`, `totalDistanceKm`, `hasData`

#### Visits Feature
- **`visitRepositoryProvider`** - Provider<VisitRepository>
- **`visitProvider`** - StateNotifier<VisitState> (async operations)
  - Key method: `markVisitWithDeviceLocation(placeId, lat, lng)`
  - Tracks: verification step, location validation, device positioning

#### Exploration Feature
- **`explorationProvider`** - StateNotifier<ExplorationState>
  - Manages: district assignments, locations, verification status
  - Key method: `loadAssignments()`
  - Tracks: isLoading, isVerifying, assignments, districts

#### Places Feature
- **`placeVisitRepositoryProvider`** - Provider.family with token
- **`placeVisitProvider`** - StateNotifier.family<PlaceVisitNotifier, PlaceVisitState, userId>
  - Manages: place visits, achievements, verification progress
- **`userVisitStatsProvider`** - FutureProvider.family
- **`placeVisitHistoryProvider`** - FutureProvider.family (by placeId)

#### Authentication
- Services in `core/services/auth_service.dart`
  - Not Riverpod-based (uses Firebase directly)
  - Stream: `authStateChanges()`
  - Methods: `signInWithEmail()`, `signUpWithEmail()`, `signInWithGoogle()`, `signOut()`

---

## 📄 Models & Data Classes

### Trip Models (`features/trips/data/models/`)
```dart
TripModel {
  id, name, description, startDate, endDate, 
  destinations[], status, geojson, stats
}

TripStatsModel {
  destinationCount, completionPercentage, 
  geography { routeDistanceKm }
}

PreplannedTripModel {
  id, name, description, destinations[], 
  recommendedDuration, difficulty
}
```

### Map Models (`features/map/models/map_models.dart`)
```dart
TripGeoJson {
  type: 'FeatureCollection'
  properties: TripGeoJsonProperties
  features: Array<GeoJSON Feature>
}

TripStats {
  geography: TripStatsGeography { routeDistanceKm }
  extra: Map<String, dynamic>
}

DestinationDetail {
  id, name, coordinates, visited, 
  placeId, category, descriptions
}

MapStyle enum {
  streets, satellite, dark, light
}
```

### Place Models (`features/places/models/place.dart`)
```dart
Place {
  id, name, description, category, province, 
  district, latitude, longitude, googleMapsUrl,
  address, rating, reviewCount, photos[], 
  accessibility, tags[], visitCount, isSystemPlace
}
```

### Visit Models (`features/visits/data/models/visit_model.dart`)
```dart
VisitModel {
  id, userId, placeId, latitude, longitude,
  visitedAt: DateTime, isVerified, rejectionReason
}
```

### Exploration Models (`features/exploration/data/models/`)
```dart
ExplorationLocation {
  id, name, type, latitude, longitude, visited,
  description, category, photos[]
}

DistrictAssignment {
  district, province, assignedCount, visitedCount,
  unlockedAt: DateTime?, isUnlocked, center: GeoPoint?,
  bounds: GeoBounds?, locations[]
}

DistrictSummary {
  district, province, assignedCount, visitedCount,
  unlockedAt, isUnlocked
}

GeoPoint { latitude, longitude }
GeoBounds { northeast: GeoPoint, southwest: GeoPoint }
```

---

## 🔧 Services & Data Repositories

### Authentication Service
**Location:** `core/services/auth_service.dart`
```dart
class AuthService {
  // Firebase + GoogleSignIn integration
  Stream<User?> authStateChanges()
  User? currentUser
  bool isEmailVerified
  Future<String?> getIdToken()
  Future<UserCredential> signInWithEmail(email, password)
  Future<UserCredential> signUpWithEmail(email, password)
  Future<UserCredential> signInWithGoogle()
  Future<void> signOut()
  Future<void> sendEmailVerification()
  Future<void> sendPasswordResetEmail(email)
  Future<void> reloadUser()
}
```

### Visit Repository
**Location:** `features/visits/data/visit_repository.dart`
```dart
class VisitRepository {
  Future<VisitModel> markVisit({
    required String placeId,
    required double latitude,
    required double longitude,
  })
  Future<List<VisitModel>> getUserVisits()
}
```

### Places Repository
**Location:** `features/places/data/places_repository.dart`
```dart
class PlacesRepository {
  Future<List<Place>> getPlaces({
    int page, int limit, 
    String? search, String? category
  })
}
```

### Place Visit Repository
**Location:** `features/places/data/place_visit_repository.dart`
```dart
class PlaceVisitRepository {
  Future<PlaceVisit> recordVisit(placeId, lat, lng, metadata)
  Future<List<PlaceVisit>> getRecentVisits(userId)
  Future<PlaceAchievement?> checkForUnlockedAchievement(userId)
  Future<VisitStats> getUserVisitStats(userId)
  Future<List<PlaceVisit>> getVisitHistory(placeId)
}
```

### Exploration API
**Location:** `features/exploration/data/exploration_api.dart`
```dart
class ExplorationApi {
  Future<List<DistrictAssignment>> fetchAssignments()
  // Fallback: _generateSampleAssignmentsForDevelopment()
}
```

### Location Service
**Location:** `core/services/location_service.dart`
```dart
// Uses Geolocator package
// Methods: getCurrentPosition(), getLocationStream()
```

### API Client
**Location:** `core/services/api_client.dart`
```dart
// Dio wrapper with auth interceptor
// Methods: get(), post(), put(), delete()
```

---

## 📦 Key Utility Functions & Helpers

### GeoJSON Utilities (`core/utils/geojson_loader.dart`)
```dart
GeoJsonLoader {
  static Future<Map<String, dynamic>> loadDistrictBoundaries()
  static bool _isValidGeoJSON(Map geojson)
  static List<String> extractDistrictIds(Map geojson)
}
```

### District Validation (`core/utils/ds_checker.dart`)
```dart
// Validates district names and codes
```

### AppConfig (`core/config/app_config.dart`)
```dart
// API base URLs, endpoints, feature flags
```

---

## 🎨 Widgets Requiring Testing

### Map Feature Widgets
| Widget | File | Purpose |
|--------|------|---------|
| `MapScreen` | `map_screen.dart` | Main map display (CustomPainter-based) |
| `CartoonMapCanvas` | `cartoon_map_canvas.dart` | Stylized district map painter |
| `MapOverlay` | `map_overlay.dart` | Overlay controls |
| `TrackingToggle` | `tracking_toggle.dart` | Toggle user tracking on/off |

### Places Feature Widgets
| Widget | File | Purpose |
|--------|------|---------|
| `PlaceCard` | `place_card.dart` | Place display card |
| `DestinationPicker` | `destination_picker.dart` | Select destination |
| `MarkVisitModal` | `mark_visit_modal.dart` | Mark location as visited |
| `AchievementCard` | `achievement_card.dart` | Achievement display |
| `VisitStatusBadge` | `visit_status_badge.dart` | Visit verification badge |
| `VisitVerificationErrorScreen` | `visit_verification_error_screen.dart` | Error display |

### Visits Feature Widgets
| Widget | File | Purpose |
|--------|------|---------|
| `DynamicVisitSheet` | `dynamic_visit_sheet.dart` | Bottom sheet for visit details |

### Authentication Screens
| Screen | File | Purpose |
|--------|------|---------|
| `LoginScreen` | `login_screen.dart` | Email/password login |
| `SignupScreen` | `signup_screen.dart` | Account registration |
| `ForgotPasswordScreen` | `forgot_password_screen.dart` | Password reset |
| `EmailVerificationScreen` | `email_verification_screen.dart` | Verify email |
| `AppLockScreen` | `app_lock_screen.dart` | Biometric lock |

### Home & Album
| Screen | File | Purpose |
|--------|------|---------|
| `HomeScreen` | `home_screen.dart` | Dashboard |
| `AlbumPage` | `album_page.dart` | Photo gallery |
| `CameraPage` | `camera_page.dart` | Photo capture |
| `PhotoViewerPage` | `photo_viewer_page.dart` | Full-screen photos |

---

## 🧪 Unit Testing Priority (By Feature)

### 1. **Map Feature** (High Priority)
- [ ] `MapState.copyWith()` - state updates
- [ ] `MapState.completionPercentage` - percentage calculation
- [ ] `MapProvider` - trip data loading
- [ ] `CartoonMapCanvas.paint()` - district rendering
- [ ] `MapStyle` enum - style selection

### 2. **Visits Feature** (High Priority)
- [ ] `VisitState.copyWith()` - state transitions
- [ ] `VisitNotifier.markVisitWithDeviceLocation()` - GPS validation, location verification steps
- [ ] `VisitRepository.markVisit()` - API call, error handling
- [ ] `VisitRepository.getUserVisits()` - list fetching

### 3. **Exploration Feature** (High Priority)
- [ ] `ExplorationState.copyWith()` - state updates
- [ ] `ExplorationProvider.loadAssignments()` - fetch and fallback logic
- [ ] `DistrictAssignment` - data parsing
- [ ] Progress calculations for districts

### 4. **Places Feature** (Medium Priority)
- [ ] `Place.fromJson()` - JSON deserialization
- [ ] `PlacesRepository.getPlaces()` - API calls, filtering
- [ ] `PlaceVisitNotifier` - visit recording
- [ ] Achievement unlock logic

### 5. **Authentication** (Medium Priority)
- [ ] `AuthService.signInWithEmail()` - Firebase integration
- [ ] `AuthService.signUpWithEmail()` - user creation, email verification
- [ ] `AuthService.signInWithGoogle()` - OAuth flow
- [ ] Token/credential management

### 6. **Trips Feature** (Medium Priority)
- [ ] `TripModel` - JSON serialization
- [ ] `TripsRepository` - CRUD operations
- [ ] Trip stats calculations

### 7. **Utilities** (Low Priority)
- [ ] `GeoJsonLoader.loadDistrictBoundaries()` - asset loading
- [ ] `GeoJsonLoader._isValidGeoJSON()` - structure validation
- [ ] `GeoJsonLoader.extractDistrictIds()` - data extraction

---

## 🏗️ Architecture Overview

**Pattern:** Clean Architecture with Riverpod state management

```
Presentation Layer:
  - Screens (Pages)
  - Widgets
  - Providers (UI state)
       ↓
Business Logic Layer:
  - NotifierProviders (StateNotifier)
  - Future/Stream Providers
       ↓
Data Layer:
  - Repositories
  - DataSources (APIs, local storage)
  - Models (JSON serialization with Freezed/build_runner)
       ↓
Core Layer:
  - Services (Auth, Location, API Client)
  - Utils (GeoJSON, validation)
  - Config & Constants
```

---

## 📊 Feature Dependencies

```
Home Screen
  ├─ Trips Feature
  ├─ Map Feature
  │   ├─ Exploration Feature (district assignments)
  │   └─ Map Models (GeoJSON)
  └─ User Authentication

Map Screen
  ├─ Exploration Provider (district data)
  ├─ Visits Provider (mark locations)
  ├─ Location Service (GPS)
  └─ GeoJSON Loader

Places Screen
  ├─ Places Repository (fetch places)
  ├─ Place Visit Notifier (record visits)
  └─ Achievement system

Visits Feature
  ├─ Geolocator (location)
  ├─ Permission Service
  └─ Visit Repository (API)
```

---

## 🚀 Key Testing Scenarios

### Map Feature
1. Load GeoJSON boundaries correctly
2. Calculate district progress from assignments
3. Display cartoons for visited/unvisited districts
4. Network error fallback to sample data

### Visits Feature
1. Verify location within accuracy threshold
2. Multi-step verification (GPS → metadata → submission)
3. Handle location permission denial
4. API error during visit recording

### Exploration Feature
1. Load assignments from API
2. Update assignment progress
3. Unlock new districts based on progress
4. Fallback to sample data in development

### Places Feature
1. Search and filter places
2. Record place visits with verification
3. Unlock achievements after specific visit counts
4. Display visit history

### Authentication
1. Email/password sign up and sign in
2. Email verification flow
3. Google OAuth sign in
4. Session persistence with tokens
5. Sign out and cleanup

---

## 📈 File Statistics

| Category | Count | Files |
|----------|-------|-------|
| Features | 12 | album, auth, exploration, home, map, onboarding, places, profile, settings, shop, trips, visits |
| Screens | 15+ | Various presentation files |
| Providers | 6+ | State management |
| Services | 8+ | API, Auth, Location, etc. |
| Models | 15+ | Trip, Visit, Place, Exploration, etc. |
| Widgets | 20+ | Custom UI components |

