# Frontend - Project Structure

**Understanding the codebase organization**

---

## 📚 Quick Links

- [Main Structure](#-main-structure) - Overview
- [Key Directories](#-key-directories) - Detailed breakdown
- [Feature Organization](#-feature-organization) - How features work
- [Back to Getting Started](README.md)

---

## 🏗️ Main Structure

```
mobile/
├── lib/                         # Application code
│   ├── main.dart                # App entry point (START HERE)
│   ├── core/                    # Global utilities
│   ├── features/                # Feature modules
│   ├── data/                    # Data layer (API, models)
│   ├── models/                  # Shared data models
│   └── providers/               # Riverpod state management
├── test/                        # Tests
├── android/                     # Android native code
├── ios/                         # iOS native code
├── web/, windows/, linux/, macos/  # Other platforms
├── pubspec.yaml                 # Dependencies (IMPORTANT)
├── .env                         # Environment variables
└── README.md
```

---

## 📂 Key Directories

### `main.dart` - Entry Point
**File**: `mobile/lib/main.dart`

Where the app starts:
- App initialization
- Theme setup
- Routing configuration
- Provider setup
- Home screen

**When to edit**: Changing app theme, adding new routes, global setup

---

### `core/` - Global Utilities
**Location**: `mobile/lib/core/`

Shared code used across the app:

```
core/
├── theme/                    # App theming
│   ├── app_colors.dart      # Color palette
│   ├── app_text_styles.dart # Typography
│   └── app_theme.dart       # Theme configuration
├── constants/               # App constants
│   ├── app_constants.dart   # Global constants
│   └── dimensions.dart      # Spacing, sizes
├── widgets/                 # Global widgets
│   ├── app_bar.dart         # Custom AppBar
│   ├── bottom_nav.dart      # Bottom navigation
│   └── error_widget.dart    # Error display
├── utils/                   # Helper functions
│   ├── date_formatter.dart
│   ├── string_utils.dart
│   └── validators.dart
└── errors/                  # Error handling
    └── exceptions.dart      # Custom exceptions
```

**When to edit**: Adding global colors, fonts, reusable widgets

---

### `features/` - Feature Modules
**Location**: `mobile/lib/features/`

Each feature is self-contained:

```
features/
├── auth/                          # Authentication feature
│   ├── screens/                   # Full page screens
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── logout_screen.dart
│   └── widgets/                   # Feature-specific widgets
│       ├── login_form.dart
│       ├── password_field.dart
│       └── ...
│
├── places/                        # Places discovery
│   ├── screens/
│   │   ├── places_screen.dart     # List all places
│   │   ├── place_detail_screen.dart  # Single place
│   │   └── ...
│   └── widgets/
│       ├── place_card.dart        # Place list item
│       ├── place_rating.dart      # Rating widget
│       └── ...
│
├── trips/                         # Trip planning
├── album/                         # Photos
├── shop/                          # E-commerce
├── map/                           # Map visualization
└── ...
```

**File Pattern**:
- `screens/` = Full pages
- `widgets/` = Reusable components in this feature
- `models/` = Feature-specific data models (optional)

**When to edit**: Adding feature screens, widgets, feature logic

---

### `data/` - Data Layer
**Location**: `mobile/lib/data/`

Handles backend communication:

```
data/
├── api/                          # HTTP clients
│   ├── api_client.dart          # Base HTTP setup
│   ├── auth_api_client.dart     # Auth endpoints
│   ├── places_api_client.dart   # Places endpoints
│   ├── trips_api_client.dart    # Trips endpoints
│   └── ...
├── models/                       # Data models (DTOs)
│   ├── user_model.dart
│   ├── place_model.dart
│   ├── trip_model.dart
│   └── ...
└── repositories/                 # Repository pattern
    ├── auth_repository.dart      # Auth data access
    ├── places_repository.dart    # Places data access
    └── ...
```

**When to edit**: Adding API calls, new data models, repositories

---

### `models/` - Shared Data Models
**Location**: `mobile/lib/models/`

Data models used across the app:

```
models/
├── user_model.dart
├── place_model.dart
├── trip_model.dart
└── ...
```

**When to edit**: Changing shared data structures

---

### `providers/` - State Management
**Location**: `mobile/lib/providers/`

Riverpod providers for state:

```
providers/
├── auth_provider.dart            # Login, user state
├── places_provider.dart          # Places list, filtering
├── trips_provider.dart           # Trip data
├── user_progress_provider.dart   # Achievements, stats
├── map_provider.dart             # Map state
├── cart_provider.dart            # Shopping cart
└── ...
```

**File Pattern**:
```dart
// Async data (from API)
final placesProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  // Fetch from API
});

// Mutable state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
```

**When to edit**: Adding state, fetching data, managing state updates

---

## 🎯 Feature Organization

### Anatomy of a Feature

Let's look at the "Places" feature:

```
features/places/
├── screens/
│   ├── places_screen.dart        # List of all places
│   ├── place_detail_screen.dart  # Single place details
│   └── place_search_screen.dart  # Search places
│
└── widgets/
    ├── place_card.dart           # Item in list
    ├── place_image.dart          # Image display
    ├── place_rating.dart         # Star rating
    └── ...

Supporting files (elsewhere):
- Provider: providers/places_provider.dart
- API Client: data/api/places_api_client.dart
- Models: data/models/place_model.dart
- Routes: defined in main.dart or routing.dart
```

### Data Flow in a Feature

```
1. Screen displays (e.g., places_screen.dart)
   ↓
2. Uses provider to get data (placesProvider)
   ↓
3. Provider fetches from repository
   ↓
4. Repository calls API client
   ↓
5. API client makes HTTP request to backend
   ↓
6. Response comes back → parsed into model
   ↓
7. Provider updates with new data
   ↓
8. Screen rebuilds with new data
```

---

## 📋 File Naming Conventions

Follow this pattern:

| Type | Pattern | Example |
|------|---------|---------|
| **Screen** | `[feature]_screen.dart` | `login_screen.dart` |
| **Widget** | `[name]_widget.dart` or `[name].dart` | `place_card.dart` |
| **Provider** | `[feature]_provider.dart` | `places_provider.dart` |
| **Model** | `[entity]_model.dart` | `place_model.dart` |
| **Repository** | `[feature]_repository.dart` | `places_repository.dart` |
| **API Client** | `[feature]_api_client.dart` | `places_api_client.dart` |

---

## 🔄 Request Flow

When a user interacts with the app:

```
1. User taps button on places_screen.dart
   ↓
2. Screen calls ref.watch(placesProvider)
   ↓
3. Provider fetches from repository
   ↓
4. Repository calls api_client.getPlaces()
   ↓
5. API client makes HTTP request to backend
   ↓
6. Backend returns JSON data
   ↓
7. JSON parsed into Place models
   ↓
8. Provider updates with data
   ↓
9. Screen rebuilds automatically
   ↓
10. User sees the list of places
```

---

## 📊 Example: Adding a Feature

Let's say you want to add "Reviews" to places.

### 1. Create Data Model
```
Create: lib/data/models/review_model.dart
Define: Review class with fields
```

### 2. Add API Client Method
```
Edit: lib/data/api/places_api_client.dart
Add: getReviews(placeId), addReview() methods
```

### 3. Create Provider
```
Create: lib/providers/reviews_provider.dart
Define: reviewsProvider, addReviewProvider
```

### 4. Create Widget
```
Create: lib/features/places/widgets/review_card.dart
Display: Single review with rating, text
```

### 5. Create Screen or Update Existing
```
Edit: lib/features/places/screens/place_detail_screen.dart
Add: Reviews section, review form
```

### 6. Add Routes (if new screen)
```
Edit: lib/main.dart or routing.dart
Add: Route for new screen
```

---

## 🛠️ Common Tasks

### Running the app
```bash
flutter run        # On default device/emulator
flutter run -d chrome  # Run on web
```

### Hot reload
```bash
# While app is running:
R key   # Hot reload (fast, preserves state)
```

### Running tests
```bash
flutter test
```

### Adding a package
```bash
flutter pub add package_name
```

### Cleaning the project
```bash
flutter clean
flutter pub get
```

---

## 🔗 Related Documentation

- [Frontend Overview](../README.md) - Full frontend docs
- [Feature Implementation](../feature-implementation/) - Step-by-step guides
- [State Management](../state-management/) - Riverpod patterns
- [Screen Layouts](../ui-components/screen-layouts.md) - Common layouts
- [API Integration](../api-integration/) - Calling APIs

---

## 📚 pubspec.yaml - Key Sections

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State management
  flutter_riverpod: ^2.5.1
  
  # HTTP client
  dio: ^5.3.0
  
  # Models (JSON serialization)
  json_annotation: ^4.8.1
  
  # Maps
  mapbox_maps_flutter: ^0.0.1
  
  # Others...

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
```

**When to edit**: Adding new packages, updating versions

---

**Next: Implement your first feature → [Feature Implementation](../feature-implementation/)**
