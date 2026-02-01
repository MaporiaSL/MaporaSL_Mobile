# Geospatial Query API Endpoints

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1

---

## Overview

Geospatial endpoints use MongoDB's geospatial indexes to find destinations based on location. These endpoints enable "nearby places" and "places in current map view" functionality.

---

## Endpoints

### Find Nearby Destinations

Find destinations near a specific point using MongoDB `$near` geospatial operator.

**Endpoint**: `GET /api/destinations/nearby`  
**Auth**: Required (JWT)  
**Controller**: `geoController.findNearbyDestinations`

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `lat` | number | Yes | - | Center latitude (-90 to 90) |
| `lng` | number | Yes | - | Center longitude (-180 to 180) |
| `radius` | number | No | 10 | Search radius in kilometers |
| `travelId` | string | No | - | Filter by specific trip (optional) |

#### Response (200 OK)

```json
{
  "query": {
    "latitude": 6.9271,
    "longitude": 79.8612,
    "radiusKm": 50,
    "travelId": null
  },
  "count": 8,
  "results": [
    {
      "destination": {
        "_id": "679f5e8d3c2a1b4e5f6a7b8d",
        "name": "Galle Fort",
        "latitude": 6.0278,
        "longitude": 80.2169,
        "visited": true,
        "districtId": "galle",
        "travelId": {
          "_id": "679f5e8d3c2a1b4e5f6a7b8c",
          "title": "Sri Lanka Adventure"
        }
      },
      "distanceKm": 42.15,
      "bearing": "SE"
    },
    {
      "destination": {
        "_id": "679f5e8d3c2a1b4e5f6a7b8e",
        "name": "Unawatuna Beach",
        "latitude": 5.9480,
        "longitude": 80.2633,
        "visited": false,
        "districtId": "galle",
        "travelId": {
          "_id": "679f5e8d3c2a1b4e5f6a7b8f",
          "title": "Beach Exploration"
        }
      },
      "distanceKm": 47.32,
      "bearing": "S"
    }
  ],
  "geojson": {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [80.2169, 6.0278]
        },
        "properties": {
          "name": "Galle Fort",
          "distanceKm": 42.15
        }
      }
    ],
    "properties": {
      "queryPoint": {
        "latitude": 6.9271,
        "longitude": 79.8612
      },
      "radiusKm": 50,
      "resultsCount": 8
    }
  }
}
```

#### Use Cases

**Find places near user's current location**:
```bash
curl "http://localhost:5000/api/destinations/nearby?lat=6.9271&lng=79.8612&radius=10" \
  -H "Authorization: Bearer TOKEN"
```

**Find places in specific trip near coordinates**:
```bash
curl "http://localhost:5000/api/destinations/nearby?lat=6.9271&lng=79.8612&radius=25&travelId=679f5e8d3c2a1b4e5f6a7b8c" \
  -H "Authorization: Bearer TOKEN"
```

**Extend search radius**:
```bash
curl "http://localhost:5000/api/destinations/nearby?lat=6.9271&lng=79.8612&radius=100" \
  -H "Authorization: Bearer TOKEN"
```

#### Error Responses

**400 Bad Request**:
```json
{
  "error": "Missing required parameters: lat and lng"
}
```

```json
{
  "error": "Invalid latitude: must be between -90 and 90"
}
```

#### Mapbox Integration

**Display nearby results on map**:
```javascript
const response = await apiClient.get('/api/destinations/nearby', {
  queryParameters: {
    'lat': userLat,
    'lng': userLng,
    'radius': 50
  }
});

// Add nearby places as layer
mapController.addGeoJsonSource('nearby-source', response['geojson']);
```

---

### Find Destinations Within Bounds

Find destinations within a bounding box using MongoDB `$geoWithin` operator. Useful for finding places in current map viewport.

**Endpoint**: `GET /api/destinations/within-bounds`  
**Auth**: Required (JWT)  
**Controller**: `geoController.findDestinationsWithinBounds`

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `swLat` | number | Yes | Southwest corner latitude |
| `swLng` | number | Yes | Southwest corner longitude |
| `neLat` | number | Yes | Northeast corner latitude |
| `neLng` | number | Yes | Northeast corner longitude |
| `travelId` | string | No | Filter by specific trip (optional) |

#### Response (200 OK)

```json
{
  "query": {
    "bounds": {
      "southwest": {
        "latitude": 6.0,
        "longitude": 79.0
      },
      "northeast": {
        "latitude": 7.0,
        "longitude": 81.0
      }
    },
    "travelId": null
  },
  "count": 15,
  "destinations": [
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8d",
      "name": "Colombo Fort",
      "latitude": 6.9271,
      "longitude": 79.8612,
      "visited": false,
      "districtId": "colombo"
    },
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8e",
      "name": "Kandy",
      "latitude": 6.9271,
      "longitude": 80.6350,
      "visited": true,
      "districtId": "kandy"
    }
  ],
  "geojson": {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [79.8612, 6.9271]
        },
        "properties": {
          "name": "Colombo Fort",
          "visited": false
        }
      }
    ],
    "properties": {
      "bounds": {
        "swLat": 6.0,
        "swLng": 79.0,
        "neLat": 7.0,
        "neLng": 81.0
      },
      "resultsCount": 15
    }
  }
}
```

#### Use Cases

**Find places in current map viewport** (on map pan/zoom):
```bash
curl "http://localhost:5000/api/destinations/within-bounds?swLat=6.0&swLng=79.0&neLat=7.0&neLng=81.0" \
  -H "Authorization: Bearer TOKEN"
```

**Find places in bounds for specific trip**:
```bash
curl "http://localhost:5000/api/destinations/within-bounds?swLat=6.0&swLng=79.0&neLat=7.0&neLng=81.0&travelId=679f5e8d3c2a1b4e5f6a7b8c" \
  -H "Authorization: Bearer TOKEN"
```

#### Error Responses

**400 Bad Request**:
```json
{
  "error": "Missing required parameters: swLat, swLng, neLat, neLng"
}
```

```json
{
  "error": "Invalid bounds: northeast must be north of southwest"
}
```

#### Mapbox Integration

**Update map layer on viewport change**:
```dart
mapController.onCameraIdleListener = (mapboxMap) async {
  final bounds = await mapController.getVisibleRegion();
  
  final response = await apiClient.get('/api/destinations/within-bounds', 
    queryParameters: {
      'swLat': bounds.southwest.latitude,
      'swLng': bounds.southwest.longitude,
      'neLat': bounds.northeast.latitude,
      'neLng': bounds.northeast.longitude,
    }
  );
  
  // Update map with results
  await mapController.setGeoJsonSource('viewport-source', response['geojson']);
};
```

---

## MongoDB Indexes

Both endpoints use geospatial indexes for performance:

```javascript
// 2dsphere index on Destination.location
destinationSchema.index({ location: '2dsphere' });

// Compound index for user+location queries
destinationSchema.index({ userId: 1, location: '2dsphere' });
```

---

## Coordinate System

**Important**: GeoJSON uses `[longitude, latitude]` order (not `[latitude, longitude]`):

```json
{
  "type": "Point",
  "coordinates": [79.8612, 6.9271]
}
```

Query parameters use standard `lat`, `lng` naming for clarity.

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Destinations found |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Missing/invalid token |
| 500 | Server Error |

---

## Performance

- **Nearby queries**: O(log n) with 2dsphere index
- **Bounds queries**: O(log n + k) where k = results
- Results limited to 50 destinations by default

---

## File Locations

| File | Purpose |
|------|---------|
| `backend/src/controllers/geoController.js` | Endpoint logic |
| `backend/src/routes/geoRoutes.js` | Route definitions |
| `backend/src/models/Destination.js` | Contains geospatial indexes |

---

## See Also

- [Map Endpoints](./map-endpoints.md) - Visualize trips as GeoJSON
- [Destination Endpoints](./destination-endpoints.md) - CRUD operations on destinations
- [Maps Feature Implementation](../../common/feature-implementation/maps.md) - Complete implementation guide
- [Destination Model](../database/models.md#destination-model) - Geospatial schema details
- [MongoDB Geospatial Queries](https://docs.mongodb.com/manual/geospatial-queries/)
