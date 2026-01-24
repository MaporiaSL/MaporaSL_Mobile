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

### POST /api/auth/register

Register a new user or return existing user.

**Authentication**: Required (JWT)

**Request Body**:
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "profilePicture": "https://example.com/avatar.jpg"
}
```

**Success Response** (201 Created):
```json
{
  "message": "User registered successfully",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "auth0Id": "auth0|123456789",
    "email": "user@example.com",
    "name": "John Doe",
    "profilePicture": "https://example.com/avatar.jpg",
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:00:00.000Z"
  }
}
```

**Existing User Response** (200 OK):
```json
{
  "message": "User already exists",
  "user": { /* same as above */ }
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `500 Internal Server Error` - Server error

---

### GET /api/auth/me

Get the authenticated user's profile.

**Authentication**: Required (JWT)

**Success Response** (200 OK):
```json
{
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "auth0Id": "auth0|123456789",
    "email": "user@example.com",
    "name": "John Doe",
    "profilePicture": "https://example.com/avatar.jpg",
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:00:00.000Z"
  }
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - User not found
- `500 Internal Server Error` - Server error

---

### POST /api/auth/logout

Logout user (stateless operation, returns success message).

**Authentication**: Required (JWT)

**Success Response** (200 OK):
```json
{
  "message": "Logged out successfully"
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `500 Internal Server Error` - Server error

---

## Travel Endpoints

### POST /api/travel

Create a new travel/trip.

**Authentication**: Required (JWT)

**Request Body**:
```json
{
  "title": "Sri Lanka Adventure",
  "description": "Two week trip exploring the beautiful island",
  "startDate": "2024-03-01T00:00:00.000Z",
  "endDate": "2024-03-15T00:00:00.000Z",
  "locations": ["Colombo", "Kandy", "Galle"]
}
```

**Field Requirements**:
- `title` (string, required): Minimum 3 characters
- `description` (string, optional): Travel description
- `startDate` (ISO8601 date, required): Trip start date
- `endDate` (ISO8601 date, required): Must be after startDate
- `locations` (array of strings, optional): List of location names

**Success Response** (201 Created):
```json
{
  "message": "Travel created successfully",
  "travel": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "507f191e810c19729de860ea",
    "title": "Sri Lanka Adventure",
    "description": "Two week trip exploring the beautiful island",
    "startDate": "2024-03-01T00:00:00.000Z",
    "endDate": "2024-03-15T00:00:00.000Z",
    "locations": ["Colombo", "Kandy", "Galle"],
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:00:00.000Z"
  }
}
```

**Error Responses**:
- `400 Bad Request` - Validation failed (invalid input)
  ```json
  {
    "errors": [
      {
        "msg": "Title must be at least 3 characters long",
        "param": "title",
        "location": "body"
      }
    ]
  }
  ```
- `401 Unauthorized` - Invalid or missing JWT token
- `500 Internal Server Error` - Server error

---

### GET /api/travel

List all travels for the authenticated user.

**Authentication**: Required (JWT)

**Query Parameters**:
- `sortBy` (optional): Sort field - `startDate` or `createdAt` (default: `createdAt`)
- `order` (optional): Sort order - `asc` or `desc` (default: `desc`)
- `limit` (optional): Results per page (default: 10, max: 100)
- `skip` (optional): Results to skip for pagination (default: 0)

**Example Request**:
```
GET /api/travel?sortBy=startDate&order=desc&limit=20&skip=0
```

**Success Response** (200 OK):
```json
{
  "travels": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "userId": "507f191e810c19729de860ea",
      "title": "Sri Lanka Adventure",
      "description": "Two week trip exploring the beautiful island",
      "startDate": "2024-03-01T00:00:00.000Z",
      "endDate": "2024-03-15T00:00:00.000Z",
      "locations": ["Colombo", "Kandy", "Galle"],
      "createdAt": "2026-01-24T10:00:00.000Z",
      "updatedAt": "2026-01-24T10:00:00.000Z"
    }
  ],
  "total": 1
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `500 Internal Server Error` - Server error

---

### GET /api/travel/:id

Get a single travel by ID.

**Authentication**: Required (JWT)

**URL Parameters**:
- `id` (required): Travel ID

**Example Request**:
```
GET /api/travel/507f1f77bcf86cd799439011
```

**Success Response** (200 OK):
```json
{
  "travel": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "507f191e810c19729de860ea",
    "title": "Sri Lanka Adventure",
    "description": "Two week trip exploring the beautiful island",
    "startDate": "2024-03-01T00:00:00.000Z",
    "endDate": "2024-03-15T00:00:00.000Z",
    "locations": ["Colombo", "Kandy", "Galle"],
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:00:00.000Z"
  }
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel not found or doesn't belong to user
  ```json
  {
    "error": "Travel not found"
  }
  ```
- `500 Internal Server Error` - Server error

---

### PATCH /api/travel/:id

Update a travel.

**Authentication**: Required (JWT)

**URL Parameters**:
- `id` (required): Travel ID

**Request Body** (all fields optional):
```json
{
  "title": "Updated Sri Lanka Adventure",
  "description": "Extended three week trip",
  "startDate": "2024-03-01T00:00:00.000Z",
  "endDate": "2024-03-22T00:00:00.000Z",
  "locations": ["Colombo", "Kandy", "Galle", "Ella"]
}
```

**Field Requirements**:
- `title` (string, optional): Minimum 3 characters if provided
- `description` (string, optional): Travel description
- `startDate` (ISO8601 date, optional): Trip start date
- `endDate` (ISO8601 date, optional): Must be after startDate if provided
- `locations` (array of strings, optional): List of location names

**Success Response** (200 OK):
```json
{
  "message": "Travel updated successfully",
  "travel": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "507f191e810c19729de860ea",
    "title": "Updated Sri Lanka Adventure",
    "description": "Extended three week trip",
    "startDate": "2024-03-01T00:00:00.000Z",
    "endDate": "2024-03-22T00:00:00.000Z",
    "locations": ["Colombo", "Kandy", "Galle", "Ella"],
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:30:00.000Z"
  }
}
```

**Error Responses**:
- `400 Bad Request` - Validation failed
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel not found or doesn't belong to user
- `500 Internal Server Error` - Server error

---

### DELETE /api/travel/:id

Delete a travel and all associated destinations.

**Authentication**: Required (JWT)

**URL Parameters**:
- `id` (required): Travel ID

**Example Request**:
```
DELETE /api/travel/507f1f77bcf86cd799439011
```

**Success Response** (200 OK):
```json
{
  "message": "Travel deleted successfully"
}
```

**Note**: This will cascade delete all destinations associated with this travel.

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel not found or doesn't belong to user
- `500 Internal Server Error` - Server error

---

## Destination Endpoints

All destination endpoints are nested under travel routes and require the travel to belong to the authenticated user.

### POST /api/travel/:travelId/destinations

Create a new destination within a travel.

**Authentication**: Required (JWT)

**URL Parameters**:
- `travelId` (required): Parent travel ID

**Request Body**:
```json
{
  "name": "Sigiriya Rock Fortress",
  "latitude": 7.9570,
  "longitude": 80.7603,
  "notes": "Ancient rock fortress with stunning frescoes",
  "visited": true
}
```

**Field Requirements**:
- `name` (string, required): Minimum 2 characters
- `latitude` (number, required): Between -90 and 90
- `longitude` (number, required): Between -180 and 180
- `notes` (string, optional): Additional notes about destination
- `visited` (boolean, optional): Whether destination has been visited (default: false)

**Success Response** (201 Created):
```json
{
  "message": "Destination created successfully",
  "destination": {
    "_id": "507f1f77bcf86cd799439022",
    "userId": "507f191e810c19729de860ea",
    "travelId": "507f1f77bcf86cd799439011",
    "name": "Sigiriya Rock Fortress",
    "latitude": 7.9570,
    "longitude": 80.7603,
    "notes": "Ancient rock fortress with stunning frescoes",
    "visited": true,
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:00:00.000Z"
  }
}
```

**Error Responses**:
- `400 Bad Request` - Validation failed
  ```json
  {
    "errors": [
      {
        "msg": "Latitude must be between -90 and 90",
        "param": "latitude",
        "location": "body"
      }
    ]
  }
  ```
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel not found or doesn't belong to user
- `500 Internal Server Error` - Server error

---

### GET /api/travel/:travelId/destinations

List all destinations for a travel.

**Authentication**: Required (JWT)

**URL Parameters**:
- `travelId` (required): Parent travel ID

**Example Request**:
```
GET /api/travel/507f1f77bcf86cd799439011/destinations
```

**Success Response** (200 OK):
```json
{
  "destinations": [
    {
      "_id": "507f1f77bcf86cd799439022",
      "userId": "507f191e810c19729de860ea",
      "travelId": "507f1f77bcf86cd799439011",
      "name": "Sigiriya Rock Fortress",
      "latitude": 7.9570,
      "longitude": 80.7603,
      "notes": "Ancient rock fortress with stunning frescoes",
      "visited": true,
      "createdAt": "2026-01-24T10:00:00.000Z",
      "updatedAt": "2026-01-24T10:00:00.000Z"
    },
    {
      "_id": "507f1f77bcf86cd799439023",
      "userId": "507f191e810c19729de860ea",
      "travelId": "507f1f77bcf86cd799439011",
      "name": "Temple of the Tooth",
      "latitude": 7.2931,
      "longitude": 80.6411,
      "notes": "Sacred Buddhist temple in Kandy",
      "visited": false,
      "createdAt": "2026-01-24T10:05:00.000Z",
      "updatedAt": "2026-01-24T10:05:00.000Z"
    }
  ],
  "total": 2
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel not found or doesn't belong to user
- `500 Internal Server Error` - Server error

---

### GET /api/travel/:travelId/destinations/:destId

Get a single destination by ID.

**Authentication**: Required (JWT)

**URL Parameters**:
- `travelId` (required): Parent travel ID
- `destId` (required): Destination ID

**Example Request**:
```
GET /api/travel/507f1f77bcf86cd799439011/destinations/507f1f77bcf86cd799439022
```

**Success Response** (200 OK):
```json
{
  "destination": {
    "_id": "507f1f77bcf86cd799439022",
    "userId": "507f191e810c19729de860ea",
    "travelId": "507f1f77bcf86cd799439011",
    "name": "Sigiriya Rock Fortress",
    "latitude": 7.9570,
    "longitude": 80.7603,
    "notes": "Ancient rock fortress with stunning frescoes",
    "visited": true,
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:00:00.000Z"
  }
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel or destination not found, or doesn't belong to user
- `500 Internal Server Error` - Server error

---

### PATCH /api/travel/:travelId/destinations/:destId

Update a destination.

**Authentication**: Required (JWT)

**URL Parameters**:
- `travelId` (required): Parent travel ID
- `destId` (required): Destination ID

**Request Body** (all fields optional):
```json
{
  "name": "Sigiriya Rock - Updated",
  "latitude": 7.9571,
  "longitude": 80.7604,
  "notes": "Ancient rock fortress - must visit at sunrise!",
  "visited": true
}
```

**Field Requirements**:
- `name` (string, optional): Minimum 2 characters if provided
- `latitude` (number, optional): Between -90 and 90
- `longitude` (number, optional): Between -180 and 180
- `notes` (string, optional): Additional notes
- `visited` (boolean, optional): Visited status

**Success Response** (200 OK):
```json
{
  "message": "Destination updated successfully",
  "destination": {
    "_id": "507f1f77bcf86cd799439022",
    "userId": "507f191e810c19729de860ea",
    "travelId": "507f1f77bcf86cd799439011",
    "name": "Sigiriya Rock - Updated",
    "latitude": 7.9571,
    "longitude": 80.7604,
    "notes": "Ancient rock fortress - must visit at sunrise!",
    "visited": true,
    "createdAt": "2026-01-24T10:00:00.000Z",
    "updatedAt": "2026-01-24T10:30:00.000Z"
  }
}
```

**Error Responses**:
- `400 Bad Request` - Validation failed
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel or destination not found, or doesn't belong to user
- `500 Internal Server Error` - Server error

---

### DELETE /api/travel/:travelId/destinations/:destId

Delete a destination.

**Authentication**: Required (JWT)

**URL Parameters**:
- `travelId` (required): Parent travel ID
- `destId` (required): Destination ID

**Example Request**:
```
DELETE /api/travel/507f1f77bcf86cd799439011/destinations/507f1f77bcf86cd799439022
```

**Success Response** (200 OK):
```json
{
  "message": "Destination deleted successfully"
}
```

**Error Responses**:
- `401 Unauthorized` - Invalid or missing JWT token
- `404 Not Found` - Travel or destination not found, or doesn't belong to user
- `500 Internal Server Error` - Server error

---

## Error Responses

All error responses follow a consistent format.

### Validation Error (400)
```json
{
  "errors": [
    {
      "msg": "Error message describing the validation failure",
      "param": "fieldName",
      "location": "body"
    }
  ]
}
```

### Authentication Error (401)
```json
{
  "error": "UnauthorizedError: No authorization token was found"
}
```

or

```json
{
  "error": "UnauthorizedError: jwt malformed"
}
```

### Not Found Error (404)
```json
{
  "error": "Resource not found"
}
```

Examples:
- `"Travel not found"`
- `"Destination not found"`
- `"User not found"`

### Server Error (500)
```json
{
  "error": "Failed to perform operation"
}
```

Examples:
- `"Failed to create travel"`
- `"Failed to fetch destinations"`
- `"Failed to update destination"`

---

## Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful GET, PATCH, DELETE operations |
| 201 | Created | Successful POST operations (resource created) |
| 400 | Bad Request | Validation failed, invalid input |
| 401 | Unauthorized | Missing or invalid JWT token |
| 404 | Not Found | Resource doesn't exist or doesn't belong to user |
| 409 | Conflict | Resource already exists (rarely used) |
| 500 | Internal Server Error | Unexpected server error |

---

## Data Isolation

All endpoints automatically filter data by the authenticated user's ID (extracted from JWT token's `sub` claim). Users can only:

- View their own travels and destinations
- Update their own resources
- Delete their own resources

Attempting to access another user's resources will result in a `404 Not Found` response.

---

## Pagination

List endpoints support pagination through query parameters:

- `limit`: Number of results per page (default: 10, max: 100)
- `skip`: Number of results to skip (default: 0)

**Example**:
```
GET /api/travel?limit=20&skip=40
```

This retrieves results 41-60 (page 3 with 20 items per page).

---

## Sorting

Travel list endpoint supports sorting:

- `sortBy`: Field to sort by (`startDate` or `createdAt`)
- `order`: Sort order (`asc` or `desc`)

**Example**:
```
GET /api/travel?sortBy=startDate&order=asc
```

---

## Testing with cURL

### Register User
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "Test User"
  }'
```

### Create Travel
```bash
curl -X POST http://localhost:5000/api/travel \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Summer Vacation",
    "description": "Beach trip",
    "startDate": "2024-06-01T00:00:00.000Z",
    "endDate": "2024-06-15T00:00:00.000Z",
    "locations": ["Hawaii", "Maui"]
  }'
```

### List Travels
```bash
curl -X GET http://localhost:5000/api/travel \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Destination
```bash
curl -X POST http://localhost:5000/api/travel/TRAVEL_ID/destinations \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Waikiki Beach",
    "latitude": 21.2793,
    "longitude": -157.8293,
    "visited": false
  }'
```

---

## Map Endpoints

### Get Travel GeoJSON

Retrieve complete GeoJSON representation of a travel with all destinations, routes, and boundaries.

**Endpoint**: `GET /api/travel/:travelId/geojson`  
**Auth**: Required (JWT)

**Query Parameters**:
- `includeRoute` (boolean, default: true) - Include route LineString connecting destinations
- `includeBoundary` (boolean, default: true) - Include boundary Polygon (convex hull)
- `lightweight` (boolean, default: false) - Return minimal properties only

**Response**: GeoJSON FeatureCollection

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
        "id": "679f5e8d3c2a1b4e5f6a7b8c",
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

**PowerShell Example**:
```powershell
$response = Invoke-RestMethod -Uri "http://localhost:5000/api/travel/TRAVEL_ID/geojson" `
  -Headers @{ "Authorization" = "Bearer $env:AUTH_TOKEN" } -Method GET
$response | ConvertTo-Json -Depth 10
```

---

### Get Travel Boundary

Get convex hull boundary polygon enclosing all destinations in a travel.

**Endpoint**: `GET /api/travel/:travelId/boundary`  
**Auth**: Required (JWT)  
**Min Destinations**: 3

**Response**: GeoJSON Polygon Feature

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Polygon",
    "coordinates": [[
      [79.8612, 6.9271],
      [80.6350, 7.2906],
      [81.0188, 7.8742],
      [79.8612, 6.9271]
    ]]
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

**cURL Example**:
```bash
curl -X GET http://localhost:5000/api/travel/TRAVEL_ID/boundary \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Get Travel Terrain

Get terrain/elevation data for destinations in a travel.

**Endpoint**: `GET /api/travel/:travelId/terrain`  
**Auth**: Required (JWT)  
**Status**: Placeholder (elevation API integration pending)

**Response**:

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
  "message": "Elevation data not yet implemented. Requires integration with elevation API (e.g., Open Elevation, Mapbox Terrain)"
}
```

---

### Get Travel Statistics

Get comprehensive statistics for a travel including distances, areas, and completion metrics.

**Endpoint**: `GET /api/travel/:travelId/stats`  
**Auth**: Required (JWT)

**Response**:

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

**cURL Example**:
```bash
curl -X GET http://localhost:5000/api/travel/TRAVEL_ID/stats \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
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

**Response**:

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

**cURL Example**:
```bash
curl -X GET "http://localhost:5000/api/destinations/nearby?lat=6.9271&lng=79.8612&radius=50" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**PowerShell Example**:
```powershell
$response = Invoke-RestMethod -Uri "http://localhost:5000/api/destinations/nearby?lat=6.9271&lng=79.8612&radius=50" `
  -Headers @{ "Authorization" = "Bearer $env:AUTH_TOKEN" } -Method GET
$response | ConvertTo-Json -Depth 10
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

**Response**:

```json
{
  "query": {
    "bounds": {
      "southwest": { "latitude": 6.0, "longitude": 79.0 },
      "northeast": { "latitude": 7.0, "longitude": 81.0 }
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

**PowerShell Example**:
```powershell
$uri = "http://localhost:5000/api/destinations/within-bounds?swLat=6.0&swLng=79.0&neLat=7.0&neLng=81.0"
$response = Invoke-RestMethod -Uri $uri `
  -Headers @{ "Authorization" = "Bearer $env:AUTH_TOKEN" } -Method GET
$response | ConvertTo-Json -Depth 10
```

---

## Rate Limiting

Currently no rate limiting is implemented. This may be added in future versions.

---

## Versioning

API version is currently 1.0.0. Future versions may be introduced with breaking changes under different URL paths (e.g., `/api/v2/`).

---

## Support

For issues or questions, please refer to the project documentation or open an issue in the GitHub repository.
