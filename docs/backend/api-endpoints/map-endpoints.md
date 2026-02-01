# Map & Geospatial API Endpoints

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1

---

## Overview

Map endpoints provide GeoJSON data and geospatial information for visualizing trips on interactive maps. These endpoints return data formatted for Mapbox and other mapping libraries.

---

## Trip Map Endpoints

### Get Trip as GeoJSON

Get complete GeoJSON representation of a trip with all destinations, routes, and statistics.

**Endpoint**: `GET /api/travel/:travelId/geojson`  
**Auth**: Required (JWT)  
**Controller**: `mapController.getTravelGeoJSON`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `includeRoute` | boolean | true | Include route LineString |
| `includeBoundary` | boolean | true | Include boundary Polygon |
| `lightweight` | boolean | false | Minimal properties only |

#### Response (200 OK)

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
        "id": "679f5e8d3c2a1b4e5f6a7b8d",
        "name": "Colombo Fort",
        "visited": false,
        "order": 1,
        "marker-color": "#ef4444",
        "marker-size": "medium",
        "marker-symbol": "circle-stroked"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [80.6350, 7.2906]
      },
      "properties": {
        "id": "679f5e8d3c2a1b4e5f6a7b8e",
        "name": "Kandy",
        "visited": true,
        "order": 2,
        "marker-color": "#10b981",
        "marker-size": "medium",
        "marker-symbol": "circle"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [79.8612, 6.9271],
          [80.6350, 7.2906]
        ]
      },
      "properties": {
        "type": "route",
        "distance": 89.45,
        "stroke": "#8b5cf6",
        "stroke-width": 3
      }
    }
  ],
  "properties": {
    "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
    "travelName": "Sri Lanka Adventure",
    "destinationCount": 12,
    "visitedCount": 8,
    "unvisitedCount": 4
  }
}
```

#### Mapbox Integration

**Add to Mapbox map**:
```javascript
// Add GeoJSON source
mapController.addGeoJsonSource('trip-source', geoJson);

// Add marker layer
mapController.addLayer('trip-source', 'trip-destinations', {
  type: 'symbol',
  layout: {
    'icon-image': 'marker-15',
    'icon-color': ['get', 'marker-color']
  }
});

// Add route layer
mapController.addLayer('trip-source', 'trip-route', {
  type: 'line',
  paint: {
    'line-color': '#8b5cf6',
    'line-width': 3
  },
  filter: ['==', ['get', 'type'], 'route']
});
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/geojson?includeRoute=true&includeBoundary=true" \
  -H "Authorization: Bearer TOKEN"
```

---

### Get Trip Boundary

Get convex hull boundary polygon enclosing all trip destinations.

**Endpoint**: `GET /api/travel/:travelId/boundary`  
**Auth**: Required (JWT)  
**Controller**: `mapController.getTravelBoundary`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |

#### Requirements

- Trip must have at least 3 destinations

#### Response (200 OK)

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Polygon",
    "coordinates": [
      [
        [79.8612, 6.9271],
        [80.6350, 7.2906],
        [81.0188, 7.8742],
        [79.8612, 6.9271]
      ]
    ]
  },
  "properties": {
    "type": "boundary",
    "area": 2847.32,
    "areaUnit": "km²",
    "destinations": 12,
    "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
    "travelName": "Sri Lanka Adventure"
  }
}
```

#### Error Responses

**400 Bad Request**:
```json
{
  "error": "Trip must have at least 3 destinations to calculate boundary"
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/boundary" \
  -H "Authorization: Bearer TOKEN"
```

---

### Get Trip Statistics

Get comprehensive statistics for a trip including distances, areas, and completion metrics.

**Endpoint**: `GET /api/travel/:travelId/stats`  
**Auth**: Required (JWT)  
**Controller**: `mapController.getTravelStats`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |

#### Response (200 OK)

```json
{
  "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
  "travelName": "Sri Lanka Adventure",
  "destinations": {
    "total": 12,
    "visited": 8,
    "unvisited": 4,
    "completionPercentage": 67
  },
  "geography": {
    "routeDistanceKm": 487.32,
    "boundaryAreaKm2": 2847.32,
    "centerPoint": {
      "latitude": 7.2906,
      "longitude": 80.6350
    },
    "bounds": {
      "swLng": 79.8612,
      "swLat": 6.9271,
      "neLng": 81.0188,
      "neLat": 7.8742
    }
  },
  "timeline": {
    "startDate": "2025-12-01T00:00:00.000Z",
    "endDate": "2025-12-15T00:00:00.000Z",
    "durationDays": 14,
    "firstVisit": "2025-12-02T10:30:00.000Z",
    "lastVisit": "2025-12-14T16:45:00.000Z"
  }
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/stats" \
  -H "Authorization: Bearer TOKEN"
```

---

### Get Trip Terrain

Get elevation/terrain data for trip destinations.

**Endpoint**: `GET /api/travel/:travelId/terrain`  
**Auth**: Required (JWT)  
**Controller**: `mapController.getTravelTerrain`  
**Status**: Placeholder - elevation API integration pending

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |

#### Response (200 OK)

```json
{
  "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
  "travelName": "Sri Lanka Adventure",
  "elevationProfile": [
    {
      "destinationId": "679f5e8d3c2a1b4e5f6a7b8d",
      "name": "Colombo Fort",
      "latitude": 6.9271,
      "longitude": 79.8612,
      "elevation": null,
      "elevationUnit": "meters"
    }
  ],
  "message": "Elevation data not yet implemented. Requires integration with elevation API."
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/terrain" \
  -H "Authorization: Bearer TOKEN"
```

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Data retrieved |
| 400 | Bad Request - Invalid parameters (e.g., <3 destinations for boundary) |
| 401 | Unauthorized - Missing/invalid token |
| 404 | Not Found - Trip not found |
| 500 | Server Error |

---

## File Locations

| File | Purpose |
|------|---------|
| `backend/src/controllers/mapController.js` | Endpoint logic |
| `backend/src/routes/mapRoutes.js` | Route definitions |

---

## See Also

- [Geospatial Query Endpoints](./geo-endpoints.md) - Find nearby/bounded destinations
- [Destination Endpoints](./destination-endpoints.md) - Manage individual destinations
- [Maps Feature Implementation](../../common/feature-implementation/maps.md) - Complete implementation guide
