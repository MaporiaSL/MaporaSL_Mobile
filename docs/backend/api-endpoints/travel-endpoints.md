# Travel API Endpoints

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1

---

## Overview

Travel endpoints handle trip/journey creation, management, and retrieval. Each trip contains multiple destinations and metadata about the journey.

---

## Endpoints

### Create Travel

Create a new trip for the current user.

**Endpoint**: `POST /api/travel`  
**Auth**: Required (Firebase ID token)  
**Controller**: `travelController.createTravel`

#### Request

```json
{
  "title": "Sri Lanka Adventure",
  "description": "Two week tropical island adventure",
  "startDate": "2025-12-01T00:00:00Z",
  "endDate": "2025-12-15T00:00:00Z"
}
```

**Field Validation**:
- `title`: Required, minimum 3 characters
- `startDate`: Required, must be ISO 8601 format
- `endDate`: Required, must be after startDate

#### Response (201 Created)

```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8c",
  "userId": "firebase-uid-user-123",
  "title": "Sri Lanka Adventure",
  "description": "Two week tropical island adventure",
  "startDate": "2025-12-01T00:00:00.000Z",
  "endDate": "2025-12-15T00:00:00.000Z",
  "locations": [],
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

#### Error Responses

**400 Bad Request**:
```json
{
  "error": "Title must be at least 3 characters long"
}
```

**401 Unauthorized**:
```json
{
  "error": "Unauthorized - Invalid or missing token"
}
```

#### cURL Example

```bash
curl -X POST http://localhost:5000/api/travel \
  -H "Authorization: Bearer ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sri Lanka Adventure",
    "description": "Two week exploration",
    "startDate": "2025-12-01T00:00:00Z",
    "endDate": "2025-12-15T00:00:00Z"
  }'
```

---

### List Travels

Get all trips for the current user with pagination.

**Endpoint**: `GET /api/travel`  
**Auth**: Required (Firebase ID token)  
**Controller**: `travelController.getAllTravels`

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | number | 20 | Results per page |
| `skip` | number | 0 | Offset for pagination |

#### Response (200 OK)

```json
{
  "travels": [
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8c",
      "userId": "firebase-uid-user-123",
      "title": "Sri Lanka Adventure",
      "description": "Two week tropical island adventure",
      "startDate": "2025-12-01T00:00:00.000Z",
      "endDate": "2025-12-15T00:00:00.000Z",
      "locations": ["Colombo", "Kandy", "Galle"],
      "createdAt": "2026-01-24T10:30:00.000Z",
      "updatedAt": "2026-01-24T10:30:00.000Z"
    }
  ],
  "total": 5,
  "limit": 20,
  "skip": 0
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel?limit=10&skip=0" \
  -H "Authorization: Bearer ID_TOKEN"
```

---

### Get Travel

Retrieve details of a specific trip.

**Endpoint**: `GET /api/travel/:travelId`  
**Auth**: Required (Firebase ID token)  
**Controller**: `travelController.getTravelById`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `travelId` | string | MongoDB ObjectId of trip |

#### Response (200 OK)

```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8c",
  "userId": "firebase-uid-user-123",
  "title": "Sri Lanka Adventure",
  "description": "Two week tropical island adventure",
  "startDate": "2025-12-01T00:00:00.000Z",
  "endDate": "2025-12-15T00:00:00.000Z",
  "locations": ["Colombo", "Kandy", "Galle"],
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

#### Error Responses

**404 Not Found**:
```json
{
  "error": "Travel not found"
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c" \
  -H "Authorization: Bearer ID_TOKEN"
```

---

### Update Travel

Update trip details (title, description, dates).

**Endpoint**: `PATCH /api/travel/:travelId`  
**Auth**: Required (Firebase ID token)  
**Controller**: `travelController.updateTravel`

#### Request

```json
{
  "title": "Updated Trip Title",
  "description": "Updated description",
  "startDate": "2025-12-02T00:00:00Z",
  "endDate": "2025-12-16T00:00:00Z"
}
```

**Note**: All fields are optional. Only include fields you want to update.

#### Response (200 OK)

```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8c",
  "userId": "firebase-uid-user-123",
  "title": "Updated Trip Title",
  "description": "Updated description",
  "startDate": "2025-12-02T00:00:00.000Z",
  "endDate": "2025-12-16T00:00:00.000Z",
  "locations": ["Colombo", "Kandy", "Galle"],
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:31:00.000Z"
}
```

#### cURL Example

```bash
curl -X PATCH "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c" \
  -H "Authorization: Bearer ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Title",
    "description": "New description"
  }'
```

---

### Delete Travel

Delete a trip and all associated destinations.

**Endpoint**: `DELETE /api/travel/:travelId`  
**Auth**: Required (Firebase ID token)  
**Controller**: `travelController.deleteTravel`

#### Response (200 OK)

```json
{
  "message": "Travel deleted successfully"
}
```

#### Error Responses

**404 Not Found**:
```json
{
  "error": "Travel not found"
}
```

**403 Forbidden**:
```json
{
  "error": "You do not have permission to delete this trip"
}
```

#### cURL Example

```bash
curl -X DELETE "http://localhost:5000/api/travel/679f5e8d3c2a1b4e5f6a7b8c" \
  -H "Authorization: Bearer ID_TOKEN"
```

---

## Common Patterns

### Pagination

All list endpoints support pagination:

```bash
# Get 10 results, skip first 20
GET /api/travel?limit=10&skip=20
```

Returns `total` count to calculate total pages:
```javascript
const totalPages = Math.ceil(response.total / response.limit);
const currentPage = (response.skip / response.limit) + 1;
```

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Trip created |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Missing/invalid token |
| 404 | Not Found - Trip not found |
| 500 | Server Error |

---

## Development Notes

### Dev Mode Auth Bypass

When `NODE_ENV !== 'production'`, authentication is bypassed with a mock user.

### File Locations

| File | Purpose |
|------|---------|
| `backend/src/controllers/travelController.js` | Endpoint logic |
| `backend/src/routes/travelRoutes.js` | Route definitions |
| `backend/src/models/Travel.js` | Data model |

---

## See Also

- [Destination Endpoints](./destination-endpoints.md) - Add/manage destinations in trips
- [Map Endpoints](./map-endpoints.md) - Get trip visualization as GeoJSON
- [Trips Feature Implementation](../../common/feature-implementation/trips.md) - Complete implementation guide
- [Travel Model Documentation](../database/models.md#travel-model) - Schema details
