# Map Screen Refactoring: Code Reference

## Code Snippets - Copy-Paste Ready

### 1. Import Addition
```dart
import '../../exploration/data/models/district_assignment_model.dart';
```

### 2. New Helper Method: Calculate Bounds from GeoJSON

```dart
/// Calculate bounding box from GeoJSON geometry coordinates
/// Returns [minLat, minLng, maxLat, maxLng] or null if geometry is invalid
List<double>? _calculateBoundsFromGeometry(Map<String, dynamic>? geometry) {
  if (geometry == null) return null;

  final type = geometry['type']?.toString();
  final coordinates = geometry['coordinates'];
  if (coordinates is! List || coordinates.isEmpty) return null;

  final allCoords = <List<double>>[];

  try {
    if (type == 'Polygon') {
      final polygon = coordinates.first;
      if (polygon is List) {
        for (final coord in polygon) {
          if (coord is List && coord.length >= 2) {
            allCoords.add([
              (coord[1] as num).toDouble(), // lat
              (coord[0] as num).toDouble(), // lng
            ]);
          }
        }
      }
    } else if (type == 'MultiPolygon') {
      for (final polygon in coordinates) {
        if (polygon is! List) continue;
        for (final ring in polygon) {
          if (ring is! List) continue;
          for (final coord in ring) {
            if (coord is List && coord.length >= 2) {
              allCoords.add([
                (coord[1] as num).toDouble(), // lat
                (coord[0] as num).toDouble(), // lng
              ]);
            }
          }
        }
      }
    }

    if (allCoords.isEmpty) return null;

    double minLat = allCoords.first[0];
    double maxLat = allCoords.first[0];
    double minLng = allCoords.first[1];
    double maxLng = allCoords.first[1];

    for (final coord in allCoords) {
      minLat = math.min(minLat, coord[0]);
      maxLat = math.max(maxLat, coord[0]);
      minLng = math.min(minLng, coord[1]);
      maxLng = math.max(maxLng, coord[1]);
    }

    return [minLat, minLng, maxLat, maxLng];
  } catch (_) {
    return null;
  }
}
```

### 3. Improved _fitToDistrict Method

```dart
/// Fit the camera to the district bounds with interactive constraints
/// Uses GeoJSON geometry to calculate precise bounds with padding
Future<void> _fitToDistrict(mapbox.MapboxMap map) async {
  // Try to calculate bounds from GeoJSON geometry first (most accurate)
  List<double>? geomBounds;
  if (_selectedDistrictGeoJson != null) {
    try {
      final geoJsonData = jsonDecode(_selectedDistrictGeoJson!);
      final features = geoJsonData['features'] as List?;
      if (features != null && features.isNotEmpty) {
        final geometry = (features.first as Map<String, dynamic>)['geometry'];
        geomBounds = _calculateBoundsFromGeometry(geometry);
      }
    } catch (_) {
      // Fall through to assignment bounds if parsing fails
    }
  }

  // Use assignment bounds as fallback
  final bounds = geomBounds != null
      ? CoordinateBounds(
          minLat: geomBounds[0],
          minLng: geomBounds[1],
          maxLat: geomBounds[2],
          maxLng: geomBounds[3],
        )
      : widget.assignment.bounds;

  if (bounds != null) {
    final sw = mapbox.Point(
      coordinates: mapbox.Position(bounds.minLng, bounds.minLat),
    );
    final ne = mapbox.Point(
      coordinates: mapbox.Position(bounds.maxLng, bounds.maxLat),
    );

    try {
      // Set camera bounds to constrain panning within district area
      // Add a small buffer (10% of bounds) to prevent edge clipping
      final bufferLat = (bounds.maxLat - bounds.minLat) * 0.1;
      final bufferLng = (bounds.maxLng - bounds.minLng) * 0.1;

      await map.setBounds(
        mapbox.CameraBoundsOptions(
          bounds: mapbox.CoordinateBounds(
            southwest: mapbox.Point(
              coordinates: mapbox.Position(
                bounds.minLng - bufferLng,
                bounds.minLat - bufferLat,
              ),
            ),
            northeast: mapbox.Point(
              coordinates: mapbox.Position(
                bounds.maxLng + bufferLng,
                bounds.maxLat + bufferLat,
              ),
            ),
            infiniteBounds: false,
          ),
          // Allow viewing full district at once while permitting detailed zooms
          minZoom: 8.0,   // Can see full district
          maxZoom: 16.0,  // Can zoom in to see street details
        ),
      );

      // Calculate optimal camera position to fit entire district with padding
      final camera = await map.cameraForCoordinateBounds(
        mapbox.CoordinateBounds(
          southwest: sw,
          northeast: ne,
          infiniteBounds: false,
        ),
        // Generous padding creates comfortable "frame" effect around district
        // Top: leave room for header bar; Bottom: leave room for detail cards
        mapbox.MbxEdgeInsets(top: 80, left: 80, bottom: 120, right: 80),
        null,
        null,
        9.0, // min zoom for fitted view
        null,
      );

      // Smooth animated flight transition (1000ms for elegant UX)
      // Gesture interactions enabled by GesturesConfiguration in build()
      await map.easeTo(
        camera,
        mapbox.MapAnimationOptions(duration: 1000),
      );
      return;
    } catch (e) {
      // Fall back to center-based zoom if bounds fit fails
      debugPrint('⚠️ Bounds fit failed: $e, falling back to center zoom');
    }
  }

  // Fallback: zoom to center with reasonable zoom level
  if (widget.assignment.center != null) {
    await map.easeTo(
      mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(
            widget.assignment.center!.longitude,
            widget.assignment.center!.latitude,
          ),
        ),
        zoom: 11.0,
      ),
      mapbox.MapAnimationOptions(duration: 1000),
    );
  }
}
```

### 4. Updated MapWidget Build Method

```dart
@override
Widget build(BuildContext context) {
  return mapbox.MapWidget(
    key: ValueKey(
      'district-mapbox-${widget.assignment.district.toLowerCase()}',
    ),
    // Vector streets map for better performance, clarity, and interactivity
    // Compared to satellite: lighter data, easier to read, supports better overlays
    styleUri: 'mapbox://styles/mapbox/streets-v12',
    cameraOptions: _initialCamera(),
    onMapCreated: (map) async {
      _mapboxMap = map;
      // Gesture interactions are enabled below in gesturesConfiguration
      // Pinch-to-zoom and pan within bounds are fully supported
      await _reloadDistrictData();
    },
    // Handle taps on map for location marker selection
    onTapListener: _handleMapTap,
    // Enable smooth gesture interactions within camera bounds
    // Users can pinch-to-zoom, double-tap to zoom, rotate, and pan
    // The setBounds() call in _fitToDistrict constrains panning to the district area
    gesturesConfiguration: const mapbox.GesturesConfiguration(
      doubleTapToZoomInEnabled: true,
      pinchToZoomEnabled: true,
      pinchToZoomDecelerationEnabled: true,
      rotateEnabled: true,
      scrollEnabled: true,
    ),
  );
}
```

---

## Before vs After: Side-by-Side

### Style Change
```dart
// BEFORE
styleUri: 'mapbox://styles/mapbox/satellite-streets-v12'

// AFTER
styleUri: 'mapbox://styles/mapbox/streets-v12'
```

### Animation Duration
```dart
// BEFORE
await map.easeTo(camera, mapbox.MapAnimationOptions(duration: 700));

// AFTER
await map.easeTo(camera, mapbox.MapAnimationOptions(duration: 1000));
```

### Zoom Constraints
```dart
// BEFORE
minZoom: 7.5,
maxZoom: 13.5,

// AFTER
minZoom: 8.0,
maxZoom: 16.0,
```

### Padding Configuration
```dart
// BEFORE
mapbox.MbxEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)

// AFTER
mapbox.MbxEdgeInsets(top: 80, left: 80, bottom: 120, right: 80)
```

### Gesture Handling
```dart
// BEFORE
onTapListener: _handleMapTap,
// (No gesture configuration - uses defaults)

// AFTER
onTapListener: _handleMapTap,
gesturesConfiguration: const mapbox.GesturesConfiguration(
  doubleTapToZoomInEnabled: true,
  pinchToZoomEnabled: true,
  pinchToZoomDecelerationEnabled: true,
  rotateEnabled: true,
  scrollEnabled: true,
),
```

---

## Configuration Parameters Reference

### Camera Bounds
```dart
CameraBoundsOptions(
  bounds: CoordinateBounds(
    southwest: mapbox.Point(
      coordinates: mapbox.Position(minLng, minLat),
    ),
    northeast: mapbox.Point(
      coordinates: mapbox.Position(maxLng, maxLat),
    ),
    infiniteBounds: false,  // Enforce bounds strictly
  ),
  minZoom: 8.0,   // Minimum zoom level (full district view)
  maxZoom: 16.0,  // Maximum zoom level (street detail)
)
```

### Camera Padding
```dart
mapbox.MbxEdgeInsets(
  top: 80,      // AppBar space (60px height + 20px margin)
  left: 80,     // Horizontal margins
  bottom: 120,  // Detail card space (100px height + 20px margin)
  right: 80,    // Horizontal margins
)
```

### Animation Options
```dart
mapbox.MapAnimationOptions(
  duration: 1000,  // 1 second smooth transition
  // Mapbox uses ease-out cubic by default
)
```

### Buffer Calculation
```dart
final bufferLat = (bounds.maxLat - bounds.minLat) * 0.1;  // ±10%
final bufferLng = (bounds.maxLng - bounds.minLng) * 0.1;  // ±10%
```

---

## Testing Scenarios

### Test 1: Camera Fit on Load
```
1. Select a district
2. Observe:
   ✓ Map animates smoothly (1000ms)
   ✓ District fills screen with proper margins
   ✓ Header bar has 80px clearance
   ✓ Detail cards have 120px clearance
   ✓ Entire district shape visible
```

### Test 2: Zoom Constraints
```
1. From district view, pinch to zoom out
2. Expected: Cannot zoom below 8.0 (full district visible)
3. Pinch to zoom in
4. Expected: Can zoom to 16.0 (street level readable)
```

### Test 3: Pan Constraints
```
1. From district view, drag to pan around
2. Expected: Cannot pan past 10% buffer zone
3. Verify: Darkened vignette area outside district
```

### Test 4: Gesture Responsiveness
```
1. Start pinch gesture
2. Expected: Immediate response, smooth momentum
3. Verify: No jank or frame drops
```

### Test 5: Fallback Logic
```
1. Corrupt or delete GeoJSON data
2. Verify: Still zooms to center point with zoom 11.0
3. Check: No crashes or error screens
```

---

## Performance Checklist

- [ ] District loads in < 500ms
- [ ] Camera animation smooth at 60 FPS
- [ ] Pinch-zoom responsive (< 50ms input lag)
- [ ] Pan smooth with momentum (no stuttering)
- [ ] No memory leaks after repeated district switches
- [ ] Battery usage acceptable (similar to satellite view)

---

## Rollback Plan

If issues arise, revert to satellite view:
```dart
// Simply change this line:
styleUri: 'mapbox://styles/mapbox/streets-v12'
// Back to:
styleUri: 'mapbox://styles/mapbox/satellite-streets-v12'

// And revert _fitToDistrict to previous implementation
```

All other changes are additive and won't break existing functionality if the bounds calculation fails (graceful fallback to center-based zoom).
