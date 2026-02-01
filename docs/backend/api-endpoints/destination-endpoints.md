# Destination API Endpoints

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1

---

## Overview

Destination endpoints handle individual places/attractions within a trip. Users can add, view, update, and delete destinations while tracking visit status and notes.

---

## Endpoints

### Create Destination

Add a new destination/place to a trip.

**Endpoint**: `POST /api/travel/:travelId/destinations`  
**Auth**: Required (JWT)  
**Controller**: `destinationController.createDestination`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |

#### Request

```json
{
  "name": "Colombo Fort",
  "latitude": 6.9271,
  "longitude": 79.8612,
  "districtId": "colombo",
  "notes": "Historic colonial fort with amazing views",
  "visited": false
}
```

**Field Validation**:
- `name`: Required, minimum 2 characters
- `latitude`: Required, must be between -90 and 90
- `longitude`: Required, must be between -180 and 180
- `districtId`: Optional, for gamification tracking
- `notes`: Optional, user-added information
- `visited`: Optional, defaults to false

#### Response (201 Created)

```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8d",
  "userId": "auth0|user123",
  "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
  "name": "Colombo Fort",
  "latitude": 6.9271,
  "longitude": 79.8612,
  "districtId": "colombo",
  "notes": "Historic colonial fort with amazing views",
  "visited": false,
  "visitedAt": null,
  "location": {
    "type": "Point",
    "coordinates": [79.8612, 6.9271]
  },
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

#### Error Responses

**400 Bad Request**:
```json
{
  "error": "Name must be at least 2 characters"
}
```

**404 Not Found**:
```json
{
  "error": "Travel not found"
}
```

#### cURL Example

```bash
curl -X POST "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/destinations" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Colombo Fort",
    "latitude": 6.9271,
    "longitude": 79.8612,
    "districtId": "colombo",
    "notes": "Amazing views at sunset"
  }'
```

---

### List Destinations

Get all destinations for a trip.

**Endpoint**: `GET /api/travel/:travelId/destinations`  
**Auth**: Required (JWT)  
**Controller**: `destinationController.getAllDestinations`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |

#### Response (200 OK)

```json
{
  "destinations": [
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8d",
      "name": "Colombo Fort",
      "latitude": 6.9271,
      "longitude": 79.8612,
      "districtId": "colombo",
      "visited": false,
      "createdAt": "2026-01-24T10:30:00.000Z"
    },
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8e",
      "name": "Galle Fort",
      "latitude": 6.0278,
      "longitude": 80.2169,
      "districtId": "galle",
      "visited": true,
      "visitedAt": "2026-01-25T14:00:00.000Z",
      "createdAt": "2026-01-24T10:35:00.000Z"
    }
  ],
  "totalCount": 2
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/destinations" \
  -H "Authorization: Bearer TOKEN"
```

---

### Get Destination

Retrieve details of a specific destination.

**Endpoint**: `GET /api/travel/:travelId/destinations/:destId`  
**Auth**: Required (JWT)  
**Controller**: `destinationController.getDestinationById`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |
| `destId` | string | MongoDB ObjectId of destination |

#### Response (200 OK)

```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8d",
  "userId": "auth0|user123",
  "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
  "name": "Colombo Fort",
  "latitude": 6.9271,
  "longitude": 79.8612,
  "districtId": "colombo",
  "notes": "Historic colonial fort with amazing views",
  "visited": false,
  "visitedAt": null,
  "location": {
    "type": "Point",
    "coordinates": [79.8612, 6.9271]
  },
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

#### Error Responses

**404 Not Found**:
```json
{
  "error": "Destination not found"
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/destinations/679f5e8d3c2a1b4e5f6a7b8d" \
  -H "Authorization: Bearer TOKEN"
```

---

### Update Destination

Update destination details (mark as visited, add notes).

**Endpoint**: `PATCH /api/travel/:travelId/destinations/:destId`  
**Auth**: Required (JWT)  
**Controller**: `destinationController.updateDestination`

#### Request

```json
{
  "visited": true,
  "notes": "Updated notes - great location!",
  "name": "Colombo Fort Museum"
}
```

**Note**: All fields are optional. Only include fields you want to update.

#### Response (200 OK)

```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8d",
  "userId": "auth0|user123",
  "travelId": "679f5e8d3c2a1b4e5f6a7b8c",
  "name": "Colombo Fort Museum",
  "latitude": 6.9271,
  "longitude": 79.8612,
  "districtId": "colombo",
  "notes": "Updated notes - great location!",
  "visited": true,
  "visitedAt": "2026-01-25T15:00:00.000Z",
  "location": {
    "type": "Point",
    "coordinates": [79.8612, 6.9271]
  },
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-25T15:00:00.000Z"
}
```

#### cURL Example

```bash
curl -X PATCH "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/destinations/679f5e8d3c2a1b4e5f6a7b8d" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "visited": true,
    "notes": "Great experience!"
  }'
```

---

### Delete Destination

Remove a destination from a trip.

**Endpoint**: `DELETE /api/travel/:travelId/destinations/:destId`  
**Auth**: Required (JWT)  
**Controller**: `destinationController.deleteDestination`

#### Response (200 OK)

```json
{
  "message": "Destination deleted successfully"
}
```

#### Error Responses

**404 Not Found**:
```json
{
  "error": "Destination not found"
}
```

#### cURL Example

```bash
curl -X DELETE "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c/destinations/679f5e8d3c2a1b4e5f6a7b8d" \
  -H "Authorization: Bearer TOKEN"
```

---

## Geospatial Fields

### Location Field (GeoJSON)

Each destination has a `location` field in GeoJSON format for geospatial queries:

```json
{
  "location": {
    "type": "Point",
    "coordinates": [79.8612, 6.9271]
  }
}
```

**Note**: Coordinates are `[longitude, latitude]` (not `[latitude, longitude]`)

This field is automatically synced from `latitude` and `longitude` fields on save.

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Destination created |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Missing/invalid token |
| 404 | Not Found - Resource not found |
| 500 | Server Error |

---

## File Locations

| File | Purpose |
|------|---------|
| `backend/src/controllers/destinationController.js` | Endpoint logic |
| `backend/src/routes/destinationRoutes.js` | Route definitions |
| `backend/src/models/Destination.js` | Data model |

---

## See Also

- [Travel Endpoints](./travel-endpoints.md) - Create and manage trips
- [Geo Query Endpoints](./geo-endpoints.md) - Find nearby destinations
- [Map Endpoints](./map-endpoints.md) - Visualize destinations
- [Destinations Feature Implementation](../../common/feature-implementation/places.md) - Complete implementation guide
- [Destination Model Documentation](../database/models.md#destination-model) - Schema details
