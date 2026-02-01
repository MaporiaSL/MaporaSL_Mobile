# Maps Feature Implementation

**Feature**: Interactive Map Visualization  
**Last Updated**: February 1, 2026

---

## Overview

The Maps feature visualizes trips, destinations, and routes on an interactive map using Mapbox GL. Users can see their travel paths, nearby places, and geographic boundaries.

---

## Architecture

```
Flutter App (Mapbox GL)
         ↓
API requests GeoJSON
         ↓
Backend generates GeoJSON from Destinations
         ↓
Returns FeatureCollection
         ↓
Mapbox renders layers
```

---

## Backend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **mapController.js** | GeoJSON generation | `backend/src/controllers/mapController.js` |
| **geoController.js** | Geospatial queries | `backend/src/controllers/geoController.js` |
| **mapRoutes.js** | Map endpoints | `backend/src/routes/mapRoutes.js` |
| **Destination.js** | Location data | `backend/src/models/Destination.js` |

### 1. Map Controller (`backend/src/controllers/mapController.js`)

**Functions**:
- `getTravelGeoJSON(req, res)`: Generate trip GeoJSON with destinations, routes, and boundaries
- `getTravelBoundary(req, res)`: Calculate convex hull boundary
- `getTravelStats(req, res)`: Get trip statistics (distance, area, etc.)
- `getTravelTerrain(req, res)`: Get elevation data (placeholder)

**Where to Make Changes**:
- **Add custom layers**: Modify GeoJSON feature properties
- **Change route algorithm**: Modify route generation logic
- **Add heatmaps**: Create heatmap data generation
- **Add clustering**: Implement marker clustering

**Example: Customize GeoJSON styling**:
```javascript
exports.getTravelGeoJSON = async (req, res) => {
  const destinations = await Destination.find({ travelId: req.params.travelId });
  
  const features = destinations.map((dest, index) => ({
    type: 'Feature',
    geometry: {
      type: 'Point',
      coordinates: [dest.longitude, dest.latitude]
    },
    properties: {
      id: dest._id,
      name: dest.name,
      visited: dest.visited,
      order: index + 1,
      // Custom Mapbox properties
      'marker-color': dest.visited ? '#10b981' : '#ef4444',
      'marker-size': 'medium',
      'marker-symbol': dest.visited ? 'circle' : 'circle-stroked'
    }
  }));
  
  // Add route LineString
  if (req.query.includeRoute !== 'false') {
    features.push({
      type: 'Feature',
      geometry: {
        type: 'LineString',
        coordinates: destinations.map(d => [d.longitude, d.latitude])
      },
      properties: {
        type: 'route',
        stroke: '#8b5cf6',
        'stroke-width': 3
      }
    });
  }
  
  res.json({
    type: 'FeatureCollection',
    features
  });
};
```

### 2. Geo Controller (`backend/src/controllers/geoController.js`)

**Functions**:
- `findNearbyDestinations(req, res)`: Find destinations near coordinates
- `findDestinationsWithinBounds(req, res)`: Find destinations in bounding box

**Where to Make Changes**:
- **Change search radius**: Modify default radius parameter
- **Add filters**: Filter by category, visited status
- **Add result limits**: Implement pagination

**Example: Nearby with category filter**:
```javascript
exports.findNearbyDestinations = async (req, res) => {
  const { lat, lng, radius = 10, category, visited } = req.query;
  
  const query = {
    location: {
      $near: {
        $geometry: { type: 'Point', coordinates: [parseFloat(lng), parseFloat(lat)] },
        $maxDistance: radius * 1000 // Convert km to meters
      }
    }
  };
  
  if (category) query.category = category;
  if (visited !== undefined) query.visited = visited === 'true';
  
  const destinations = await Destination.find(query).limit(50);
  
  res.json({
    query: { latitude: lat, longitude: lng, radiusKm: radius },
    count: destinations.length,
    destinations
  });
};
```

---

## Frontend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **map_screen.dart** | Main map UI | `mobile/lib/features/map/screens/map_screen.dart` |
| **mapbox_controller.dart** | Mapbox integration | `mobile/lib/features/map/controllers/mapbox_controller.dart` |
| **map_provider.dart** | Map state | `mobile/lib/features/map/providers/map_provider.dart` |
| **map_style_manager.dart** | Map styles | `mobile/lib/features/map/utils/map_style_manager.dart` |

### 1. Map Screen (`map_screen.dart`)

**Purpose**: Display interactive Mapbox map.

**Where to Make Changes**:
- **Change map style**: Modify Mapbox style URL
- **Add custom layers**: Add GeoJSON/symbol layers
- **Add user location**: Enable location tracking
- **Add search**: Add place search on map

**Example: Basic Mapbox setup**:
```dart
MapboxMap(
  accessToken: MAPBOX_ACCESS_TOKEN,
  onMapCreated: (MapboxMapController controller) {
    _mapController = controller;
    _loadTripData();
  },
  initialCameraPosition: CameraPosition(
    target: LatLng(7.8731, 80.7718), // Sri Lanka center
    zoom: 7.0,
  ),
  styleString: MapboxStyles.OUTDOORS,
)
```

### 2. Mapbox Controller (`mapbox_controller.dart`)

**Purpose**: Manage Mapbox map instance and layers.

**Methods**:
- `loadGeoJSON(String geoJsonData)`: Add GeoJSON layer to map
- `addMarkers(List<Destination> destinations)`: Add destination markers
- `drawRoute(List<LatLng> points)`: Draw route line
- `fitBounds(LatLngBounds bounds)`: Zoom to show all points

**Where to Make Changes**:
- **Customize markers**: Change marker icons/colors
- **Add clustering**: Enable marker clustering
- **Add popups**: Show info popups on marker tap

**Example: Load trip GeoJSON**:
```dart
Future<void> loadTripGeoJSON(String travelId) async {
  final geoJson = await apiClient.get('/api/travel/$travelId/geojson');
  
  await mapController.addGeoJsonSource('trip-source', geoJson);
  
  await mapController.addLayer(
    'trip-source',
    'trip-destinations',
    SymbolLayerProperties(
      iconImage: 'marker-15',
      iconSize: 1.5,
      iconColor: [
        'match',
        ['get', 'visited'],
        true, '#10b981',
        '#ef4444'
      ],
    ),
  );
  
  await mapController.addLayer(
    'trip-source',
    'trip-route',
    LineLayerProperties(
      lineColor: '#8b5cf6',
      lineWidth: 3.0,
    ),
    filter: ['==', ['get', 'type'], 'route'],
  );
}
```

### 3. Map Provider (`map_provider.dart`)

**Purpose**: Manage map state and data.

**State**:
- `currentTrip`: Active trip being displayed
- `destinations`: Destinations to show on map
- `userLocation`: User's current location
- `mapStyle`: Current map style

**Where to Make Changes**:
- **Add offline maps**: Implement offline map caching
- **Add filters**: Filter visible destinations
- **Add drawing tools**: Allow route drawing

---

## API Endpoints

See detailed API documentation:
- [Map Endpoints](../../backend/api-endpoints/map-endpoints.md)
- [Geo Query Endpoints](../../backend/api-endpoints/geo-endpoints.md)

**Key Endpoints**:
- `GET /api/travel/:travelId/geojson` - Get trip GeoJSON
- `GET /api/travel/:travelId/boundary` - Get trip boundary polygon
- `GET /api/travel/:travelId/stats` - Get trip statistics
- `GET /api/destinations/nearby?lat=&lng=&radius=` - Find nearby destinations
- `GET /api/destinations/within-bounds?swLat=&swLng=&neLat=&neLng=` - Destinations in bounds

---

## Mapbox Configuration

### Backend Environment

**File**: `backend/.env`

```env
# Not needed on backend (unless generating static maps)
```

### Frontend Environment

**File**: `mobile/lib/core/config/env_config.dart`

```dart
class EnvConfig {
  static const mapboxAccessToken = 'pk.eyJ1IjoieW91ci11c2VybmFtZSIsImEiOiJ4eHh4eHh4In0.xxxx';
  static const mapboxStyleUrl = 'mapbox://styles/mapbox/outdoors-v12';
}
```

**pubspec.yaml**:
```yaml
dependencies:
  mapbox_gl: ^0.16.0
  location: ^5.0.0  # For user location
```

---

## Common Modifications

### 1. Add Custom Map Markers

**Frontend** (add custom marker images):
```dart
// Load custom marker
await mapController.addImage('custom-marker', await _loadMarkerAsset());

// Use in layer
SymbolLayerProperties(
  iconImage: 'custom-marker',
)
```

### 2. Add Marker Clustering

**Frontend** (Mapbox clustering):
```dart
await mapController.addSource(
  'destinations-source',
  GeojsonSourceProperties(
    data: geoJson,
    cluster: true,
    clusterRadius: 50,
    clusterMaxZoom: 14,
  ),
);

// Add cluster count layer
await mapController.addLayer(
  'destinations-source',
  'clusters',
  CircleLayerProperties(
    circleColor: '#8b5cf6',
    circleRadius: [
      'step',
      ['get', 'point_count'],
      20, // radius for count < 10
      10, 30, // radius for count >= 10
      50, 40, // radius for count >= 50
    ],
  ),
  filter: ['has', 'point_count'],
);
```

### 3. Add User Location Tracking

**Frontend**:
```dart
import 'package:location/location.dart';

final location = Location();
final locationData = await location.getLocation();

await mapController.animateCamera(
  CameraUpdate.newLatLng(
    LatLng(locationData.latitude!, locationData.longitude!),
  ),
);

// Add user location layer
await mapController.addSymbol(
  SymbolOptions(
    geometry: LatLng(locationData.latitude!, locationData.longitude!),
    iconImage: 'user-location',
    iconSize: 1.5,
  ),
);
```

### 4. Add Heatmap Layer

**Backend** (generate heatmap data):
```javascript
exports.getVisitHeatmap = async (req, res) => {
  const destinations = await Destination.find({
    userId: req.user.auth0Id,
    visited: true
  });
  
  const features = destinations.map(d => ({
    type: 'Feature',
    geometry: {
      type: 'Point',
      coordinates: [d.longitude, d.latitude]
    },
    properties: {
      weight: 1 // Can be visit count, time spent, etc.
    }
  }));
  
  res.json({ type: 'FeatureCollection', features });
};
```

**Frontend** (heatmap layer):
```dart
await mapController.addLayer(
  'heatmap-source',
  'heatmap-layer',
  HeatmapLayerProperties(
    heatmapIntensity: 1.0,
    heatmapColor: [
      'interpolate',
      ['linear'],
      ['heatmap-density'],
      0, 'rgba(33,102,172,0)',
      0.2, 'rgb(103,169,207)',
      0.4, 'rgb(209,229,240)',
      0.6, 'rgb(253,219,199)',
      0.8, 'rgb(239,138,98)',
      1, 'rgb(178,24,43)'
    ],
  ),
);
```

### 5. Offline Maps

**Frontend** (download offline region):
```dart
import 'package:mapbox_gl/mapbox_gl.dart';

final bounds = LatLngBounds(
  southwest: LatLng(5.9, 79.5),
  northeast: LatLng(9.9, 82.0),
);

await MapboxGlPlatform.instance.downloadOfflineRegion(
  OfflineRegionDefinition(
    bounds: bounds,
    minZoom: 6.0,
    maxZoom: 14.0,
    mapStyleUrl: MapboxStyles.OUTDOORS,
  ),
  metadata: {'name': 'Sri Lanka'},
);
```

---

## Map Styles

### Available Mapbox Styles

```dart
class MapStyles {
  static const streets = MapboxStyles.MAPBOX_STREETS;
  static const outdoors = MapboxStyles.OUTDOORS;
  static const light = MapboxStyles.LIGHT;
  static const dark = MapboxStyles.DARK;
  static const satellite = MapboxStyles.SATELLITE;
  static const satelliteStreets = MapboxStyles.SATELLITE_STREETS;
}
```

### Custom Style

Create custom style in [Mapbox Studio](https://studio.mapbox.com/):
```dart
static const customStyle = 'mapbox://styles/yourusername/your-style-id';
```

---

## Performance Optimization

### 1. Limit Visible Markers

```dart
// Only show markers in current viewport
final visibleBounds = await mapController.getVisibleRegion();

final visibleDests = destinations.where((dest) {
  return visibleBounds.contains(LatLng(dest.latitude, dest.longitude));
}).toList();
```

### 2. Use Vector Tiles

For large datasets, use Mapbox vector tiles instead of GeoJSON:
```dart
await mapController.addVectorSource(
  'destinations-tiles',
  'mapbox://yourusername.tileset-id',
);
```

### 3. Debounce Map Updates

```dart
Timer? _debounce;

void onCameraMove() {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _updateVisibleMarkers();
  });
}
```

---

## Testing

### Backend Testing

```bash
# Get trip GeoJSON
curl "http://localhost:5000/api/travel/TRIP_ID/geojson" \
  -H "Authorization: Bearer TOKEN"

# Find nearby destinations
curl "http://localhost:5000/api/destinations/nearby?lat=7.8731&lng=80.7718&radius=50" \
  -H "Authorization: Bearer TOKEN"
```

### Frontend Testing

```dart
testWidgets('Map loads trip data', (tester) async {
  await tester.pumpWidget(MapScreen(travelId: 'test-trip'));
  await tester.pumpAndSettle();
  
  expect(find.byType(MapboxMap), findsOneWidget);
  // Verify markers loaded
});
```

---

## See Also

- [Map API Endpoints](../../backend/api-endpoints/map-endpoints.md)
- [Geo Query Endpoints](../../backend/api-endpoints/geo-endpoints.md)
- [Mapbox GL Flutter Documentation](https://pub.dev/packages/mapbox_gl)
- [Destination Model](../../backend/database/models.md#destination-model)
