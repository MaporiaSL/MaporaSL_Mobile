# MAPORIA - Frontend Documentation

> **Purpose**: Frontend implementation guides, UI details, state management  
> **Audience**: Flutter developers (Dart)  
> **Tech Stack**: Flutter + Riverpod + Mapbox + Firebase  
> **Last Updated**: February 1, 2026

---

## 📚 Table of Contents

- [Getting Started](#-getting-started)
- [Feature Implementation](#-feature-implementation)
- [State Management](#-state-management)
- [UI & Design](#-ui--design)
- [API Integration](#-api-integration)
- [Advanced Features](#-advanced-features)
- [Testing & Deployment](#-testing--deployment)

---

## 🚀 Getting Started

**New to the Flutter frontend? Start here!**

### Quick Setup (10 minutes)

1. **Install Flutter** (if not already installed)
   ```bash
   # See https://flutter.dev/docs/get-started/install
   flutter --version
   ```

2. **Get dependencies**
   ```bash
   cd mobile
   flutter pub get
   ```

3. **Set up environment variables**
   - Create `.env` file (or configure in pubspec.yaml)
   - Add API base URL, Mapbox key, Firebase config
   - See [Environment Variables](../common/setup-guides/environment-variables.md)

4. **Run the app**
   ```bash
   flutter run
   ```

App runs on emulator/device, defaults to debug mode

### 📖 Detailed Getting Started
- **[Quick Setup](getting-started/quick-setup.md)** - Installation, dependencies, running app
- **[Project Structure](getting-started/project-structure.md)** - File organization, folder meanings

---

## 🎯 Feature Implementation

**"Where do I make changes?"** → See [Common Feature Implementation](../common/feature-implementation/)

Frontend implementation guides are now consolidated with backend guides in the common documentation.

### 📋 Quick Reference: Frontend Files by Feature

| Feature | Screen/UI | Provider/State | Service | Model |
|---------|-----------|----------------|---------|-------|
| **Authentication** | `login_screen.dart` (Google) | `auth_provider.dart` | `auth_service.dart` | `user_model.dart` |
| **Places & Attractions** | `places_screen.dart`, `place_details_screen.dart` | `places_provider.dart` | - | `place_model.dart` |
| **Trip Planning** | `trips_screen.dart`, `trip_details_screen.dart`, `create_trip_screen.dart` | `trips_provider.dart` | - | `trip_model.dart` |
| **Album & Photos** | *To be created* | *To be created* | - | *To be created* |
| **Shop & E-Commerce** | *Planned* | *Planned* | - | *Planned* |
| **Achievements** | *To be created* | *To be created* | - | - |
| **Maps & Geospatial** | `map_screen.dart` | `map_provider.dart` | `mapbox_controller.dart` | - |

**All frontend files located in**: `mobile/lib/`

### Detailed Implementation Guides

See [Common Feature Implementation](../common/feature-implementation/) for step-by-step guides on:
- [Authentication](../common/feature-implementation/authentication.md)
- [Places](../common/feature-implementation/places.md)
- [Trips](../common/feature-implementation/trips.md)
- [Album](../common/feature-implementation/album.md)
- [Shop](../common/feature-implementation/shop-implementation.md)
- [Achievements](../common/feature-implementation/achievements.md)
- [Maps](../common/feature-implementation/maps.md)

**"Where do I make changes?"** → Find your feature below

Dev note: use `--dart-define=AUTH_BYPASS=true` to bypass login in debug.

Each feature guide tells you **exactly which files to modify**:
- Which screens need changes
- Which providers to create/modify
- Which API calls to make
- What UI widgets to update
- Where state management logic lives

### 📋 Features

| Feature | Screens | Providers | API Calls | Details |
|---------|---------|-----------|-----------|---------|
| **Authentication** | login_screen.dart | authProvider | Google login | [Implementation](feature-implementation/authentication.md) |
| **Places & Attractions** | places_screen.dart, place_detail_screen.dart | placesProvider | places API | [Implementation](feature-implementation/places-attractions.md) |
| **Trip Planning** | trips_screen.dart, trip_detail_screen.dart | tripsProvider | trips API | [Implementation](feature-implementation/trip-planning.md) |
| **Album & Photos** | album_screen.dart, photo_capture_screen.dart | albumProvider, cameraProvider | photos API | [Implementation](feature-implementation/album-photos.md) |
| **Shop & E-Commerce** | shop_screen.dart, checkout_screen.dart | shopProvider, cartProvider | shop API | [Implementation](feature-implementation/shop-ecommerce.md) |
| **Achievements & Gamification** | achievements_screen.dart | userProgressProvider | progress API | [Implementation](feature-implementation/achievements-gamification.md) |
| **Map & Visualization** | map_screen.dart | mapProvider | GeoJSON API | [Implementation](feature-implementation/map-visualization.md) |

### How to Use Feature Guides

Each feature implementation guide includes:

1. **Overview** - What the feature does in UI
2. **Screens** - Which screens involved
   ```
   ✏️ mobile/lib/features/[feature]/screens/[screen].dart
   ```
3. **Providers** - Which state providers needed
   ```
   ✏️ mobile/lib/providers/[feature]_provider.dart
   ```
4. **API Integration** - How to call backend APIs
   ```
   ✏️ mobile/lib/data/api/[feature]_api_client.dart
   ```
5. **UI Widgets** - Which widgets to create/modify
   ```
   ✏️ mobile/lib/features/[feature]/widgets/[widget].dart
   ```
6. **Step-by-Step Implementation** - Code examples
7. **Testing** - Widget tests for this feature
8. **Common Patterns** - Design patterns used

---

## 🔄 State Management

All state management uses **Riverpod** for reactive, testable code.

### Riverpod Fundamentals

- **[Riverpod Overview](state-management/riverpod-overview.md)** - What is Riverpod?
- **[Riverpod Patterns](state-management/riverpod-patterns.md)** - Common patterns
- **[Async Data](state-management/async-data-handling.md)** - Loading data from APIs

### Provider Types Used

| Provider Type | Purpose | Example |
|---------------|---------|---------|
| **StateNotifier** | Mutable state | CartProvider for shopping cart |
| **FutureProvider** | Async data | placesProvider for fetching places |
| **StreamProvider** | Real-time data | locationProvider for GPS updates |
| **ChangeNotifierProvider** | Legacy (avoid) | Use StateNotifier instead |

### Provider Organization

```
mobile/lib/providers/
├── auth_provider.dart           # Login, logout, user state
├── places_provider.dart         # Places list, filtering
├── trips_provider.dart          # Trip data, custom trips
├── user_progress_provider.dart  # Achievements, stats
├── map_provider.dart            # Map state, markers
├── camera_provider.dart         # Photo capture
└── ...
```

---

## 🎨 UI & Design

### Design System

- **[Design System](ui-components/design-system.md)** - Colors, typography, spacing
- **[Custom Widgets](ui-components/custom-widgets.md)** - Reusable UI components
- **[Screen Layouts](ui-components/screen-layouts.md)** - Common layouts (list, grid, etc.)

### Widget Hierarchy

```
mobile/lib/
├── features/
│   ├── auth/
│   │   ├── screens/           # Full page screens
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   └── widgets/           # Feature-specific widgets
│   │       ├── login_form.dart
│   │       └── password_field.dart
│   │
│   ├── places/
│   │   ├── screens/
│   │   │   ├── places_screen.dart
│   │   │   └── place_detail_screen.dart
│   │   └── widgets/
│   │       ├── place_card.dart
│   │       └── place_rating.dart
│   │
│   └── ...
│
├── core/                       # Global widgets & utilities
│   ├── widgets/
│   │   ├── app_bar.dart
│   │   ├── bottom_nav.dart
│   │   └── error_widget.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── constants/
│       └── app_constants.dart
```

---

## 🔌 API Integration

### Making API Calls

- **[Dio Setup](api-integration/dio-client-setup.md)** - HTTP client configuration
- **[API Patterns](api-integration/api-calling-patterns.md)** - How to structure API calls
- **[Error Handling](api-integration/error-handling.md)** - Handling API errors gracefully

### API Client Organization

```
mobile/lib/data/
├── api/
│   ├── api_client.dart          # Base HTTP client setup
│   ├── auth_api_client.dart     # Auth endpoints
│   ├── places_api_client.dart   # Places endpoints
│   ├── trips_api_client.dart    # Trips endpoints
│   └── ...
│
├── models/                       # Data models (DTOs)
│   ├── user_model.dart
│   ├── place_model.dart
│   └── ...
│
└── repositories/                 # Data access layer
    ├── auth_repository.dart
    ├── places_repository.dart
    └── ...
```

### Calling an API from a Provider

Typical pattern:
```dart
// In providers/places_provider.dart
final placesProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final apiClient = ref.watch(placesApiClientProvider);
  return await apiClient.getPlaces();
});
```

---

## 🗺️ Advanced Features

### Location & Maps

- **[Mapbox Integration](location-maps/mapbox-integration.md)** - Map display, markers
- **[GPS & Location](location-maps/gps-location-handling.md)** - Getting user location
- **[Offline Maps](location-maps/offline-maps.md)** - Using maps without internet

### Offline-First Architecture

- **[Local Caching](offline-first/local-caching.md)** - Storing data locally
- **[Sync Strategy](offline-first/sync-strategy.md)** - Syncing with backend
- **[Offline Functionality](offline-first/offline-functionality.md)** - What works offline

### Camera & Photos

- **[Camera Integration](ui-components/camera-integration.md)** - Taking photos
- **[Photo Storage](offline-first/local-caching.md)** - Storing photos locally
- **[Image Compression](ui-components/image-handling.md)** - Optimizing photos

---

## ✅ Testing & Deployment

### Testing

- **[Widget Tests](testing/widget-tests.md)** - Testing individual widgets
- **[Integration Tests](testing/integration-tests.md)** - Testing full features
- **[Test Examples](testing/test-examples.md)** - Code examples

Running tests:
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test
```

### Deployment

- **[Android Build](deployment/android-build.md)** - Build APK/App Bundle
- **[iOS Build](deployment/ios-build.md)** - Build for iOS
- **[Web Deployment](deployment/web-deployment.md)** - Deploy web version
- **[Release Process](deployment/release-process.md)** - Publishing to stores

---

## 📊 Frontend Project Structure

```
mobile/
├── lib/
│   ├── main.dart                # App entry point
│   │
│   ├── core/                    # Global utilities
│   │   ├── theme/               # App theming
│   │   ├── constants/           # App constants
│   │   ├── widgets/             # Global widgets (AppBar, etc.)
│   │   ├── utils/               # Helper functions
│   │   └── errors/              # Error handling
│   │
│   ├── features/                # Feature modules
│   │   ├── auth/
│   │   │   ├── screens/         # Full page screens
│   │   │   ├── widgets/         # Feature-specific widgets
│   │   │   └── models/          # Feature models
│   │   ├── places/
│   │   ├── trips/
│   │   ├── album/
│   │   ├── shop/
│   │   └── ...
│   │
│   ├── data/                    # Data layer
│   │   ├── api/                 # API clients
│   │   ├── models/              # Data models (DTOs)
│   │   └── repositories/        # Repository pattern
│   │
│   ├── models/                  # Shared data models
│   │   └── *.dart
│   │
│   └── providers/               # Riverpod providers
│       ├── auth_provider.dart
│       ├── places_provider.dart
│       └── ...
│
├── test/                        # Tests
│   ├── widget_test.dart
│   └── integration_test/
│
├── android/                     # Android native code
├── ios/                         # iOS native code
├── web/                         # Web deployment
├── windows/, linux/, macos/     # Desktop platforms
│
├── pubspec.yaml                 # Dependencies
└── README.md
```

---

## 🔄 Quick Navigation

### I want to...

| Task | Read This |
|------|-----------|
| **Set up Flutter locally** | [Quick Setup](getting-started/quick-setup.md) |
| **Understand folder structure** | [Project Structure](getting-started/project-structure.md) |
| **Implement a feature** | Feature guide in [Feature Implementation](feature-implementation/) |
| **Build a new screen** | [Screen Layouts](ui-components/screen-layouts.md) |
| **Manage state with Riverpod** | [Riverpod Patterns](state-management/riverpod-patterns.md) |
| **Call a backend API** | [API Calling Patterns](api-integration/api-calling-patterns.md) |
| **Use the map feature** | [Mapbox Integration](location-maps/mapbox-integration.md) |
| **Build the app for release** | [Deployment](deployment/) |
| **Test my code** | [Testing Guides](testing/) |

---

## 🔗 Useful Links

### Within Frontend Docs
- 📋 [Feature Implementation](feature-implementation/) - Where to make UI changes
- 🔄 [State Management](state-management/) - Riverpod patterns
- 🎨 [UI Components](ui-components/) - Widgets & design
- 🔌 [API Integration](api-integration/) - Calling APIs
- 🗺️ [Location & Maps](location-maps/) - Map features
- 📦 [Offline-First](offline-first/) - Caching & sync

### To Other Tiers
- 📌 [Common Features](../common/features/) - What you're implementing
- 🔧 [Backend Implementation](../backend/feature-implementation/) - Backend details
- 🔌 [Backend API Endpoints](../backend/api-endpoints/) - What APIs you can call

### External Resources
- [Flutter Docs](https://flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [Dart Docs](https://dart.dev/)
- [Mapbox Flutter Plugin](https://docs.mapbox.com/flutter/maps/)
- [Firebase Flutter Plugin](https://firebase.flutter.dev/)

---

## ✨ Tips for Success

1. **Read the feature spec first**
   - Go to [Common Features](../common/features/)
   - Understand what users should be able to do
   - Then come back to the frontend feature implementation guide

2. **Follow existing patterns**
   - Look at similar screens/providers
   - Follow the same code organization
   - Use the same widget structure

3. **Use Riverpod properly**
   - See [Riverpod Patterns](state-management/riverpod-patterns.md)
   - Use FutureProvider for async data
   - Use StateNotifierProvider for mutable state

4. **Test your widgets**
   - See [Widget Tests](testing/widget-tests.md)
   - Test UI changes before pushing to backend

5. **Keep documentation updated**
   - When you add a new screen, document it
   - When you create a new provider, explain it
   - When you integrate a new API, link to backend docs

6. **Reference backend APIs**
   - Check [Backend API Endpoints](../backend/api-endpoints/)
   - Understand request/response formats
   - Handle errors appropriately

---

## ❓ FAQ

**Q: How do I run the app?**  
A: `flutter run`  
See [Quick Setup](getting-started/quick-setup.md)

**Q: How do I create a new screen?**  
A:
1. Create file: `mobile/lib/features/[feature]/screens/[screen].dart`
2. Create widget class extending StatelessWidget or StatefulWidget
3. Add to navigation/routing
4. See [Screen Layouts](ui-components/screen-layouts.md) for examples

**Q: How do I fetch data from the backend?**  
A:
1. Create API client method in `mobile/lib/data/api/[feature]_api_client.dart`
2. Create provider in `mobile/lib/providers/[feature]_provider.dart`
3. Use FutureProvider to handle async loading
4. See [API Calling Patterns](api-integration/api-calling-patterns.md)

**Q: How do I update state (e.g., shopping cart)?**  
A: Use StateNotifierProvider  
See [Riverpod Patterns](state-management/riverpod-patterns.md)

**Q: How do I test my widget?**  
A: See [Widget Tests](testing/widget-tests.md)

**Q: How do I handle errors from the API?**  
A: See [Error Handling](api-integration/error-handling.md)

---

## 🚀 Next Steps

### If you're new
1. ✅ You're reading this (Frontend Docs overview)
2. → Read [Quick Setup](getting-started/quick-setup.md) to run the app
3. → Read [Project Structure](getting-started/project-structure.md) to understand organization
4. → Read a feature spec in [Common Features](../common/features/)
5. → Follow the frontend feature implementation guide

### If you're implementing a feature
1. → Go to [Feature Implementation](feature-implementation/)
2. → Find your feature
3. → Follow the step-by-step instructions
4. → Reference [State Management](state-management/) and [API Integration](api-integration/) as needed
5. → Check [UI Components](ui-components/) for widget patterns

### If you need help
1. → Check the [Quick Navigation](#-quick-navigation)
2. → Search [Feature Implementation](feature-implementation/)
3. → Check [FAQ](#-faq)
4. → Review [External Resources](#-useful-links)

---

**Ready to code? Pick your starting point:**

→ [🎯 Quick Setup](getting-started/quick-setup.md) | [📂 Project Structure](getting-started/project-structure.md) | [🎮 Feature Implementation](feature-implementation/)
