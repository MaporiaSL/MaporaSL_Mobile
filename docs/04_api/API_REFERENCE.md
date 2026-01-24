# API Reference - Gemified Travel Portfolio

**Base URL**: `http://localhost:5000` (Development)  
**Version**: 1.0.0  
**Last Updated**: January 24, 2026

---

## Table of Contents

1. [Authentication](#authentication)
2. [Auth Endpoints](#auth-endpoints)
3. [Travel Endpoints](#travel-endpoints)
4. [Destination Endpoints](#destination-endpoints)
5. [Map Endpoints](#map-endpoints)
6. [Geospatial Query Endpoints](#geospatial-query-endpoints)
7. [Error Responses](#error-responses)
8. [Status Codes](#status-codes)

---

## Authentication

All endpoints except `POST /api/auth/register` require JWT authentication via Auth0.

### Headers Required

```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### Getting a Token

Use Auth0 Client Credentials flow:

```bash
curl --request POST \
  --url https://YOUR_AUTH0_DOMAIN/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "audience": "YOUR_API_AUDIENCE",
    "grant_type": "client_credentials"
  }'
```

---

## Auth Endpoints

### Register
**Endpoint**: `POST /api/auth/register`  
**Auth**: Not required

**Request**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response** (200):
```json
{
  "message": "Registration successful",
  "user": {
    "email": "user@example.com"
  }
}
```

### Get Current User
**Endpoint**: `GET /api/auth/me`  
**Auth**: Required (JWT)

**Response** (200):
```json
{
  "sub": "auth0|user123",
  "email": "user@example.com",
  "email_verified": true,
  "name": "John Doe"
}
```

### Logout
**Endpoint**: `POST /api/auth/logout`  
**Auth**: Required (JWT)

**Response** (200):
```json
{
  "message": "Logged out successfully"
}
```

---

## Travel Endpoints

### Create Travel
**Endpoint**: `POST /api/travel`  
**Auth**: Required (JWT)

**Request**:
```json
{
  "name": "Sri Lanka Adventure",
  "description": "Two week tropical island adventure",
  "startDate": "2025-12-01T00:00:00Z",
  "endDate": "2025-12-15T00:00:00Z"
}
```

**Response** (201):
```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8c",
  "userId": "auth0|user123",
  "name": "Sri Lanka Adventure",
  "description": "Two week tropical island adventure",
  "startDate": "2025-12-01T00:00:00.000Z",
  "endDate": "2025-12-15T00:00:00.000Z",
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

### List Travels
**Endpoint**: `GET /api/travel`  
**Auth**: Required (JWT)

**Query Parameters**:
- `page` (optional) - Page number for pagination
- `limit` (optional) - Results per page

**Response** (200):
```json
{
  "travels": [
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8c",
      "name": "Sri Lanka Adventure",
      "startDate": "2025-12-01T00:00:00.000Z",
      "endDate": "2025-12-15T00:00:00.000Z",
      "createdAt": "2026-01-24T10:30:00.000Z"
    }
  ],
  "totalCount": 1,
  "page": 1
}
```

### Get Travel
**Endpoint**: `GET /api/travel/:travelId`  
**Auth**: Required (JWT)

**Response** (200):
```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8c",
  "userId": "auth0|user123",
  "name": "Sri Lanka Adventure",
  "description": "Two week tropical island adventure",
  "startDate": "2025-12-01T00:00:00.000Z",
  "endDate": "2025-12-15T00:00:00.000Z",
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

### Update Travel
**Endpoint**: `PATCH /api/travel/:travelId`  
**Auth**: Required (JWT)

**Request**:
```json
{
  "name": "Updated Sri Lanka Adventure",
  "description": "Updated description"
}
```

**Response** (200): Updated travel object

### Delete Travel
**Endpoint**: `DELETE /api/travel/:travelId`  
**Auth**: Required (JWT)

**Response** (200):
```json
{
  "message": "Travel deleted successfully"
}
```

---

## Destination Endpoints

### Create Destination
**Endpoint**: `POST /api/travel/:travelId/destinations`  
**Auth**: Required (JWT)

**Request**:
```json
{
  "name": "Colombo Fort",
  "description": "Historic colonial fort",
  "latitude": 6.9271,
  "longitude": 79.8612,
  "notes": "Amazing views at sunset",
  "visited": false
}
```

**Response** (201):
```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8d",
  "userId": "auth0|user123",
  "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
  "name": "Colombo Fort",
  "latitude": 6.9271,
  "longitude": 79.8612,
  "visited": false,
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

### List Destinations
**Endpoint**: `GET /api/travel/:travelId/destinations`  
**Auth**: Required (JWT)

**Response** (200):
```json
{
  "destinations": [
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8d",
      "name": "Colombo Fort",
      "latitude": 6.9271,
      "longitude": 79.8612,
      "visited": false
    }
  ],
  "totalCount": 1
}
```

### Get Destination
**Endpoint**: `GET /api/travel/:travelId/destinations/:destId`  
**Auth**: Required (JWT)

### Update Destination
**Endpoint**: `PATCH /api/travel/:travelId/destinations/:destId`  
**Auth**: Required (JWT)

### Delete Destination
**Endpoint**: `DELETE /api/travel/:travelId/destinations/:destId`  
**Auth**: Required (JWT)

---

## Map Endpoints

### Get Travel GeoJSON

Get complete GeoJSON representation of a travel with all destinations, routes, and boundaries.

**Endpoint**: `GET /api/travel/:travelId/geojson`  
**Auth**: Required (JWT)

**Query Parameters**:
- `includeRoute` (boolean, default: true) - Include route LineString
- `includeBoundary` (boolean, default: true) - Include boundary Polygon
- `lightweight` (boolean, default: false) - Minimal properties only

**Response** (200):
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
        "visited": true,
        "order": 1,
        "marker-color": "#10b981"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [[79.8612, 6.9271], [80.6350, 7.2906]]
      },
      "properties": {
        "type": "route",
        "distance": 89.45,
        "stroke": "#8b5cf6"
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

**cURL Example**:
```bash
curl -X GET "http://localhost:5000/api/travel/TRAVEL_ID/geojson?includeRoute=true&includeBoundary=true" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Get Travel Boundary

Get convex hull boundary polygon enclosing all destinations in a travel.

**Endpoint**: `GET /api/travel/:travelId/boundary`  
**Auth**: Required (JWT)  
**Min Destinations**: 3

**Response** (200):
```json
{
  "type": "Feature",
  "geometry": {
    "type": "Polygon",
    "coordinates": [[[79.8612, 6.9271], [80.6350, 7.2906], [81.0188, 7.8742], [79.8612, 6.9271]]]
  },
  "properties": {
    "type": "boundary",
    "area": 2847.32,
    "destinations": 12,
    "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
    "travelName": "Sri Lanka Adventure"
  }
}
```

---

### Get Travel Terrain

Get terrain/elevation data for destinations in a travel.

**Endpoint**: `GET /api/travel/:travelId/terrain`  
**Auth**: Required (JWT)  
**Status**: Placeholder (elevation API integration pending)

**Response** (200):
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

---

### Get Travel Statistics

Get comprehensive statistics for a travel including distances, areas, and completion metrics.

**Endpoint**: `GET /api/travel/:travelId/stats`  
**Auth**: Required (JWT)

**Response** (200):
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
  "media": {
    "totalPhotos": 143,
    "averagePhotosPerDestination": 11.9
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

---

## Geospatial Query Endpoints

### Find Nearby Destinations

Find destinations near a specific point using MongoDB $near geospatial query.

**Endpoint**: `GET /api/destinations/nearby`  
**Auth**: Required (JWT)

**Query Parameters**:
- `lat` (number, required) - Latitude of center point
- `lng` (number, required) - Longitude of center point
- `radius` (number, optional) - Search radius in kilometers (default: 10)
- `travelId` (string, optional) - Filter by specific travel

**Response** (200):
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
        "travelId": {
          "_id": "679f5e8d3c2a1b4e5f6a7b8c",
          "name": "Sri Lanka Adventure"
        }
      },
      "distanceKm": 42.15,
      "bearing": "SE"
    }
  ],
  "geojson": {
    "type": "FeatureCollection",
    "features": [],
    "properties": {
      "queryPoint": {"latitude": 6.9271, "longitude": 79.8612},
      "radiusKm": 50,
      "resultsCount": 8
    }
  }
}
```

**cURL Example**:
```bash
curl -X GET "http://localhost:5000/api/destinations/nearby?lat=6.9271&lng=79.8612&radius=50" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Find Destinations Within Bounds

Find destinations within a bounding box using MongoDB $geoWithin geospatial query.

**Endpoint**: `GET /api/destinations/within-bounds`  
**Auth**: Required (JWT)

**Query Parameters**:
- `swLat` (number, required) - Southwest corner latitude
- `swLng` (number, required) - Southwest corner longitude
- `neLat` (number, required) - Northeast corner latitude
- `neLng` (number, required) - Northeast corner longitude
- `travelId` (string, optional) - Filter by specific travel

**Response** (200):
```json
{
  "query": {
    "bounds": {
      "southwest": {"latitude": 6.0, "longitude": 79.0},
      "northeast": {"latitude": 7.0, "longitude": 81.0}
    },
    "travelId": null
  },
  "count": 15,
  "destinations": [],
  "geojson": {
    "type": "FeatureCollection",
    "features": [],
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

**cURL Example**:
```bash
curl -X GET "http://localhost:5000/api/destinations/within-bounds?swLat=6.0&swLng=79.0&neLat=7.0&neLng=81.0" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Error Responses

### 400 Bad Request
```json
{
  "error": "Missing required parameters: lat and lng"
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized"
}
```

### 404 Not Found
```json
{
  "error": "Travel not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Failed to retrieve travel GeoJSON"
}
```

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Missing or invalid JWT token |
| 404 | Not Found - Resource not found |
| 500 | Internal Server Error - Server error |

---

## Rate Limiting

Currently no rate limiting is implemented. This may be added in future versions.

---

## Versioning

API version is currently 1.0.0. Future versions may be introduced with breaking changes under different URL paths (e.g., `/api/v2/`).

---

## Support

For issues or questions, please refer to the project documentation or open an issue in the GitHub repository.
