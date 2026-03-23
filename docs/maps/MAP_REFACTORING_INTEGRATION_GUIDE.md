# Map Screen Refactoring: Integration Examples

## Quick Start Integration

### 1. Replace Old Import

**Before:**
```dart
import 'features/map/presentation/map_screen.dart';
```

**After:**
```dart
import 'features/map/presentation/map_screen_refactored.dart';

// Keep the same class name by aliasing if needed:
// import 'features/map/presentation/map_screen_refactored.dart' as map_refactored;
// typedef MapScreen = map_refactored.MapScreen;
```

---

### 2. Update Navigation

**Before (Old Route Definition):**
```dart
// routes/app_routes.dart
GoRoute(
  path: 'map',
  builder: (context, state) => MapScreen(
    travelId: state.extra as String,
  ),
)
```

**After (No Changes Needed):**
```dart
// routes/app_routes.dart
GoRoute(
  path: 'map',
  builder: (context, state) => MapScreen(
    travelId: state.extra as String,
  ),
)
```

The refactored `MapScreen` has the same constructor signature, so navigation code works unchanged.

---

### 3. Project Structure Update

```
lib/
├── features/
│   ├── map/
│   │   ├── presentation/
│   │   │   ├── map_screen.dart              (OLD - can delete)
│   │   │   ├── map_screen_refactored.dart   (NEW)
│   │   │   ├── widgets/
│   │   │   │   ├── cartoon_map_canvas.dart  (KEEP - still used)
│   │   │   │   └── ... other widgets
│   │   │   ├── theme/
│   │   │   │   ├── map_visual_theme.dart    (KEEP - still used)
│   │   │   │   └── ...
│   │   │   └── ... other files
│   │   └── data/
│   │       └── regions_data.dart            (KEEP - still used)
│   │
│   └── exploration/
│       └── data/
│           └── models/
│               ├── exploration_models.dart     (EXISTING)
│               └── district_assignment_model.dart  (NEW)
│
└── ... other features ...
```

---

### 4. pubspec.yaml Updates

**Add Missing Assets Section (if not already present):**

```yaml
flutter:
  uses-material-design: true
  
  # Existing assets
  assets:
    - assets/images/
    - assets/images/markers/          # NEW
    - assets/geojson/                 # NEW
    - assets/geojson/boundaries/      # NEW
    # ... keep existing assets ...
```

**Ensure Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing
  flutter_riverpod: ^2.x.x
  mapbox_maps_flutter: ^0.x.x
  freezed_annotation: ^x.x.x
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # For code generation
  build_runner: ^2.x.x
  freezed: ^x.x.x
```

---

### 5. Generate Freezed Files

Run after creating `district_assignment_model.dart`:

```bash
# From project root
dart run build_runner build --delete-conflicting-outputs
```

Or use VS Code command:
```
Ctrl+Shift+P → Dart: Run Build Runner
```

**Expected Output:**
```
[INFO] building:freezed with 1 action
[INFO] building:freezed:build_script_#dacf8a6f took 234ms
[INFO] succeeded after 1s, with 1 outputs (0 actions done)

✓ Created:
  - district_assignment_model.freezed.dart
  - district_assignment_model.g.dart
```

---

## Provider Setup Example

### ExplorationProvider Implementation

Ensure your `explorationProvider` returns `ExplorationState` with these fields:

```dart
// lib/features/exploration/providers/exploration_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/district_assignment_model.dart';

/// State for exploration assignments
class ExplorationState {
  final List<DistrictAssignment> assignments;
  final bool isLoading;
  final bool isVerifying;
  final String? error;
  final bool isLoaded;

  ExplorationState({
    this.assignments = const [],
    this.isLoading = false,
    this.isVerifying = false,
    this.error,
    this.isLoaded = false,
  });

  ExplorationState copyWith({
    List<DistrictAssignment>? assignments,
    bool? isLoading,
    bool? isVerifying,
    String? error,
    bool? isLoaded,
  }) {
    return ExplorationState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

/// Main exploration provider
final explorationProvider = StateNotifierProvider.family<
    ExplorationNotifier,
    ExplorationState,
    String>((ref, travelId) {
  return ExplorationNotifier(travelId);
});

class ExplorationNotifier extends StateNotifier<ExplorationState> {
  final String travelId;

  ExplorationNotifier(this.travelId)
    : super(ExplorationState());

  Future<void> loadAssignments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch from your backend
      final response = await fetchAssignments(travelId);
      
      state = state.copyWith(
        assignments: response,
        isLoading: false,
        isLoaded: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> verifyLocation(String locationId) async {
    state = state.copyWith(isVerifying: true, error: null);
    try {
      // Call verification API
      await verifyExplorationLocation(travelId, locationId);
      
      // Update local state
      final updated = state.assignments.map((assignment) {
        final updatedLocations = assignment.locations.map((loc) {
          return loc.id == locationId
              ? loc.copyWith(visited: true)
              : loc;
        }).toList();
        
        return assignment.copyWith(
          locations: updatedLocations,
          visitedCount: assignment.visitedCount + 1,
        );
      }).toList();
      
      state = state.copyWith(
        assignments: updated,
        isVerifying: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        error: e.toString(),
      );
    }
  }
}
```

---

## Data Model Examples

### Creating a DistrictAssignment

**From JSON Response:**
```dart
final json = {
  'district': 'Colombo',
  'province': 'Western',
  'assignedCount': 50,
  'visitedCount': 23,
  'bounds': {
    'minLat': 6.75,
    'minLng': 80.10,
    'maxLat': 7.10,
    'maxLng': 80.90,
  },
  'center': {
    'latitude': 6.9270,
    'longitude': 80.7580,
  },
  'locations': [
    {
      'id': 'loc_001',
      'name': 'Galle Face Beach',
      'latitude': 6.9271,
      'longitude': 80.7618,
      'type': 'Beach',
      'description': 'Historic seafront promenade',
      'photos': ['https://example.com/galle-face.jpg'],
      'visited': true,
    },
    // ... more locations
  ],
};

final assignment = DistrictAssignment.fromJson(json);
```

**Creating Programmatically:**
```dart
final assignment = DistrictAssignment(
  district: 'Kandy',
  province: 'Central',
  assignedCount: 45,
  visitedCount: 12,
  bounds: CoordinateBounds(
    minLat: 6.89,
    minLng: 80.63,
    maxLat: 7.30,
    maxLng: 81.02,
  ),
  center: Coordinates(
    latitude: 7.2906,
    longitude: 80.6337,
  ),
  locations: [
    ExplorationLocation(
      id: 'loc_kandy_001',
      name: 'Temple of the Tooth',
      latitude: 7.2906,
      longitude: 80.6337,
      type: 'Temple',
      description: 'Sacred Buddhist temple',
      photos: [
        'https://example.com/tooth-temple-1.jpg',
        'https://example.com/tooth-temple-2. Jpg',
      ],
      visited: false,
    ),
    // ... more locations
  ],
);
```

---

## Integration with DynamicVisitSheet

The refactored map passes proper context to `DynamicVisitSheet`:

```dart
// In _PlaceDetailCard.onVerify callback
void _handleVerify() {
  final location = _selectedLocation;
  if (location == null) return;
  
  DynamicVisitSheet.show(
    context,
    placeId: location.id,                    // ← ExplorationLocation.id
    placeName: location.name,                // ← ExplorationLocation.name
    targetLat: location.latitude,            // ← For GPS verification
    targetLng: location.longitude,           // ← For GPS verification
    isExploration: true,                     // ← Enables exploration mode
    explorationLocation: location,           // ← Pass full model
  );
}
```

**What DynamicVisitSheet Does:**
1. Opens camera UI for photo verification
2. Optionally checks GPS coordinates
3. Submits verification to backend
4. Calls `ref.read(explorationProvider.notifier).verifyLocation(id)`
5. Updates visited status in provider
6. Marker updates automatically on rebuild

---

## Testing Integration

### Unit Test Example

```dart
// test/features/exploration/models/district_assignment_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/exploration/data/models/district_assignment_model.dart';

void main() {
  group('DistrictAssignment', () {
    test('fromJson creates instance correctly', () {
      final json = {
        'district': 'Colombo',
        'province': 'Western',
        'assignedCount': 50,
        'visitedCount': 23,
        'bounds': {
          'minLat': 6.75,
          'minLng': 80.10,
          'maxLat': 7.10,
          'maxLng': 80.90,
        },
        'locations': [],
      };

      final assignment = DistrictAssignment.fromJson(json);

      expect(assignment.district, equals('Colombo'));
      expect(assignment.province, equals('Western'));
      expect(assignment.assignedCount, equals(50));
      expect(assignment.visitedCount, equals(23));
    });

    test('toJson serializes correctly', () {
      final assignment = DistrictAssignment(
        district: 'Kandy',
        province: 'Central',
        assignedCount: 45,
        visitedCount: 12,
        bounds: CoordinateBounds(
          minLat: 6.89,
          minLng: 80.63,
          maxLat: 7.30,
          maxLng: 81.02,
        ),
        locations: [],
      );

      final json = assignment.toJson();

      expect(json['district'], equals('Kandy'));
      expect(json['province'], equals('Central'));
      expect(json['assignedCount'], equals(45));
    });
  });

  group('ExplorationLocation', () {
    test('visited status can be toggled', () {
      final original = ExplorationLocation(
        id: 'loc_001',
        name: 'Test Place',
        latitude: 7.0,
        longitude: 80.0,
        type: 'Temple',
        visited: false,
      );

      final updated = original.copyWith(visited: true);

      expect(original.visited, equals(false));
      expect(updated.visited, equals(true));
    });
  });
}
```

### Widget Test Example

```dart
// test/features/map/presentation/map_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/map/presentation/map_screen_refactored.dart';

void main() {
  group('MapScreen', () {
    testWidgets('renders CartoonMapCanvas initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MapScreen(travelId: 'test-travel-id'),
          ),
        ),
      );

      expect(find.byType(CartoonMapCanvas), findsOneWidget);
      expect(find.byType(_DistrictVectorMap), findsNothing);
    });

    testWidgets('exits district focus when tapping exit button', (tester) async {
      // This requires more setup with mocked providers
      // Example structure shown here
      
      // 1. Setup mock explorer provider with one assignment
      // 2. Enter district focus
      // 3. Tap exit button
      // 4. Verify return to initial state
    });
  });
}
```

---

## Debugging Tips

### Enable Mapbox Logging

```dart
// In main.dart or MapScreen initState
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

void main() {
  // Enable detailed logging
  mapbox.MapboxOptions.setAccessToken('YOUR_MAPBOX_TOKEN');
  
  runApp(const MyApp());
}
```

### Debug GeoJSON Loading

```dart
// Add temporary logging in _loadDistrictGeoJson
Future<Map<String, dynamic>> _loadDistrictGeoJson() async {
  if (_districtGeoJsonCache != null) {
    print('✓ Using cached GeoJSON');
    return _districtGeoJsonCache!;
  }

  try {
    final raw = await rootBundle.loadString(
      'assets/geojson/boundaries/LK-districts.geojson',
    );
    print('✓ Loaded GeoJSON: ${raw.length} bytes');
    
    final decoded = jsonDecode(raw);
    print('✓ Decoded: ${(decoded as Map).keys.toList()}');
    
    final features = decoded['features'] as List?;
    print('✓ Features count: ${features?.length}');
    
    if (decoded is! Map<String, dynamic>) {
      throw StateError('District GeoJSON is not a valid object');
    }
    _districtGeoJsonCache = decoded;
    return decoded;
  } catch (e) {
    print('✗ GeoJSON Error: $e');
    rethrow;
  }
}
```

### Monitor State Changes

```dart
// In MapScreen build method
@override
Widget build(BuildContext context) {
  ref.listen<ExplorationState>(explorationProvider, (previous, next) {
    print('🔄 ExplorationState changed');
    print('  - Assignments: ${next.assignments.length}');
    print('  - Loading: ${next.isLoading}');
    print('  - Error: ${next.error}');
    print('  - Loaded: ${next.isLoaded}');
  });
  
  // ... rest of build
}
```

---

## Before/After Code Comparison

### Old Map Selection (Problematic)

```dart
// BEFORE: Confusing double-tap logic with mixed state

void _handleDistrictTap(String? district) {
  if (_tapCount == 0) {
    selectedDistrict = district;
    _tapCount++;
  } else if (_tapCount == 1 && selectedDistrict == district) {
    _tapCount++;
    zoomed = true;
  } else if (_tapCount == 2) {
    _tapCount = 0;
    selectedDistrict = null;
    zoomed = false;
  }
  
  // Confusing and error-prone
}
```

### New Map Selection (Clear Logic)

```dart
// AFTER: Simple, readable toggle logic

void _handleDistrictTap(String? district) {
  final sameDistrict = _normalizeKey(selectedDistrict) == 
                       _normalizeKey(district);
  
  if (sameDistrict && _isDistrictFocused) {
    // Same district, already focused → Exit
    _exitDistrictFocus();
    return;
  }
  
  // Different district or not focused → Enter new district
  setState(() {
    selectedDistrict = district;
    selectedProvince = getProvince(district);
    _isDistrictFocused = true;
    _selectedLocation = null;
  });
}
```

---

## Common Implementation Gotchas

### Gotcha 1: Forgetting Freezed Generation

```bash
# Will fail with: "The getter 'copyWith' isn't defined"
# Solution:
dart run build_runner build --delete-conflicting-outputs
```

### Gotcha 2: Missing Assets

```yaml
# pubspec.yaml is incomplete
assets:
  - assets/images/

# Maps won't have markers
# Solution: Add complete asset paths
assets:
  - assets/images/
  - assets/images/markers/      # ADD THIS
  - assets/geojson/             # ADD THIS
  - assets/geojson/boundaries/  # ADD THIS
```

### Gotcha 3: GeoJSON Field Name Mismatch

```dart
// Your GeoJSON has:
{
  "properties": {
    "name": "Colombo"     // lowercase "name"
  }
}

// But code expects:
const propertyName = 'NAME_1';   // uppercase!

// Solution: Update to match your data
const propertyName = 'name';     // or update GeoJSON
```

### Gotcha 4: Ignoring District Bounds

```dart
// If bounds are null, camera doesn't fit well
DistrictAssignment(
  bounds: null,  // ❌ Will use fallback
  center: Coordinates(...),  // ✓ Fallback works
)

// Solution: Always provide bounds
DistrictAssignment(
  bounds: CoordinateBounds(...),  // ✓ Always provided
  center: Coordinates(...),       // ✓ Also provided
)
```

### Gotcha 5: State Not Updating in Detail Card

```dart
// Problem: Marker visited, but detail card still shows old state
// Cause: _selectedLocation is stale
// Solution: Fetch fresh from state on card display

final location = assignment.locations
    .firstWhere((loc) => loc.id == _selectedLocation!.id);
// Now 'location' has fresh visited status
```

---

## Performance Optimization Tips

### 1. Lazy Load District Data

```dart
// Don't load all districts at once
Future<void> loadAssignments() async {
  // Load only currently visible districts
  final visibleDistricts = getVisibleDistricts();
  final assignments = await fetchAssignments(visibleDistricts);
  // Load others on-demand when selected
}
```

### 2. Cache Markers

```dart
// Reuse marker manager instead of recreating
if (_previousDistrictId == widget.assignment.district) {
  // Update same manager
  await _pointManager?.update(updatedMarkers);
  return;
}

// New district, recreate manager
await _setupMarkers(map);
```

### 3. Throttle Map Events

```dart
// Prevent excessive rebuilds from rapid pans
Timer? _mapGestureDebounce;

void _handleMapGesture() {
  _mapGestureDebounce?.cancel();
  _mapGestureDebounce = Timer(Duration(milliseconds: 200), () {
    // Handle gesture after user stops moving
  });
}
```

---

## Next Steps Checklist

- [ ] Copy `map_screen_refactored.dart` to your project
- [ ] Copy `district_assignment_model.dart` to your project
- [ ] Run `dart run build_runner build`
- [ ] Add assets to `pubspec.yaml`
- [ ] Create marker PNG files (40×40)
- [ ] Add `LK-districts.geojson` file
- [ ] Update `explorationProvider` if needed
- [ ] Test district selection flow
- [ ] Test marker tapping
- [ ] Test verification integration
- [ ] Update documentation
- [ ] Remove old map_screen.dart

