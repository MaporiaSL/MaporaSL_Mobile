# Backend API Endpoints - Quick Reference

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1  
**Last Updated**: February 5, 2026

---

## Overview

This document provides a quick reference to all available API endpoints. For detailed documentation, see individual endpoint files.

---

## Authentication

| Method | Endpoint | Description | Auth Required | Docs |
|--------|----------|-------------|---------------|------|
| POST | `/api/auth/register` | Register/sync user from Firebase | Yes | [auth-endpoints.md](./auth-endpoints.md#register-user) |
| GET | `/api/auth/me` | Get current user profile | Yes | [auth-endpoints.md](./auth-endpoints.md#get-current-user) |
| POST | `/api/auth/logout` | Logout user | Yes | [auth-endpoints.md](./auth-endpoints.md#logout) |

---

## Trips (Travel)

| Method | Endpoint | Description | Auth Required | Docs |
|--------|----------|-------------|---------------|------|
| POST | `/api/travel` | Create new trip | Yes | [travel-endpoints.md](./travel-endpoints.md#create-travel) |
| GET | `/api/travel` | Get all user trips (paginated) | Yes | [travel-endpoints.md](./travel-endpoints.md#list-travels) |
| GET | `/api/travel/:travelId` | Get single trip details | Yes | [travel-endpoints.md](./travel-endpoints.md#get-travel) |
| PATCH | `/api/travel/:travelId` | Update trip details | Yes | [travel-endpoints.md](./travel-endpoints.md#update-travel) |
| DELETE | `/api/travel/:travelId` | Delete trip | Yes | [travel-endpoints.md](./travel-endpoints.md#delete-travel) |

---

## Destinations

| Method | Endpoint | Description | Auth Required | Docs |
|--------|----------|-------------|---------------|------|
| POST | `/api/travel/:travelId/destinations` | Add destination to trip | Yes | [destination-endpoints.md](./destination-endpoints.md#create-destination) |
| GET | `/api/travel/:travelId/destinations` | Get trip's destinations | Yes | [destination-endpoints.md](./destination-endpoints.md#list-destinations) |
| GET | `/api/travel/:travelId/destinations/:destId` | Get single destination | Yes | [destination-endpoints.md](./destination-endpoints.md#get-destination) |
| PATCH | `/api/travel/:travelId/destinations/:destId` | Update destination | Yes | [destination-endpoints.md](./destination-endpoints.md#update-destination) |
| DELETE | `/api/travel/:travelId/destinations/:destId` | Delete destination | Yes | [destination-endpoints.md](./destination-endpoints.md#delete-destination) |

---

## Maps & Geospatial

| Method | Endpoint | Description | Auth Required | Docs |
|--------|----------|-------------|---------------|------|
| GET | `/api/travel/:travelId/geojson` | Get trip as GeoJSON for map | Yes | [map-endpoints.md](./map-endpoints.md#get-trip-as-geojson) |
| GET | `/api/travel/:travelId/boundary` | Get trip boundary polygon | Yes | [map-endpoints.md](./map-endpoints.md#get-trip-boundary) |
| GET | `/api/travel/:travelId/stats` | Get trip statistics | Yes | [map-endpoints.md](./map-endpoints.md#get-trip-statistics) |
| GET | `/api/travel/:travelId/terrain` | Get elevation data (placeholder) | Yes | [map-endpoints.md](./map-endpoints.md#get-trip-terrain) |
| GET | `/api/destinations/nearby` | Find destinations near coordinates | Yes | [geo-endpoints.md](./geo-endpoints.md#find-nearby-destinations) |
| GET | `/api/destinations/within-bounds` | Find destinations in bounding box | Yes | [geo-endpoints.md](./geo-endpoints.md#find-destinations-within-bounds) |

---

## Pre-Planned Trips

| Method | Endpoint | Description | Auth Required | Docs |
|--------|----------|-------------|---------------|------|
| GET | `/api/preplannedtrips` | List all trip templates | No | [preplanned-trips-endpoints.md](./preplanned-trips-endpoints.md#list-pre-planned-trips) |
| GET | `/api/preplannedtrips/:templateId` | Get template details | No | [preplanned-trips-endpoints.md](./preplanned-trips-endpoints.md#get-pre-planned-trip-details) |
| POST | `/api/preplannedtrips/:templateId/use` | Create trip from template | Yes | [preplanned-trips-endpoints.md](./preplanned-trips-endpoints.md#create-trip-from-template) |

---

## User Profile

| Method | Endpoint | Description | Auth Required | Docs |
|--------|----------|-------------|---------------|------|
| GET | `/api/user/me` | Get current user's full profile | Yes | [user-endpoints.md](./user-endpoints.md#get-current-user-profile) |
| GET | `/api/user/:userId` | Get public user profile | No | [user-endpoints.md](./user-endpoints.md#get-user-by-id) |
| PATCH | `/api/user/profile` | Update user profile | Yes | [user-endpoints.md](./user-endpoints.md#update-user-profile) |
| PATCH | `/api/user/preferences` | Update user preferences | Yes | [user-endpoints.md](./user-endpoints.md#update-user-preferences) |
| GET | `/api/user/:userId/stats` | Get user achievements and statistics | No | [user-endpoints.md](./user-endpoints.md#get-user-statistics) |

---

## Common Query Parameters

### Pagination

```
?limit=20&skip=0
```

- `limit`: Number of results per page (default: 20)
- `skip`: Offset for pagination (default: 0)

### Geospatial Queries

**Nearby**:
```
?lat=7.8731&lng=80.7718&radius=50
```

- `lat`: Latitude (required)
- `lng`: Longitude (required)
- `radius`: Search radius in kilometers (default: 10)

**Within Bounds**:
```
?swLat=6.0&swLng=79.0&neLat=7.0&neLng=81.0
```

- `swLat`, `swLng`: Southwest corner coordinates (required)
- `neLat`, `neLng`: Northeast corner coordinates (required)

---

## Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid parameters or missing required fields |
| 401 | Unauthorized | Missing or invalid JWT token |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource not found |
| 500 | Internal Server Error | Server error occurred |

---

## Error Response Format

All error responses follow this format:

```json
{
  "error": "Error message describing what went wrong"
}
```

Examples:

```json
{ "error": "Travel not found" }
{ "error": "Missing required parameters: lat and lng" }
{ "error": "Unauthorized - Invalid or missing token" }
```

---

## Authentication

### Getting a JWT Token

Use Auth0 to obtain a JWT token. In the Flutter app:

```dart
final credentials = await auth0.webAuthentication().login();
final token = credentials.accessToken;
```

### Using the Token

Include the token in the `Authorization` header:

```http
Authorization: Bearer <your-jwt-token>
```

Example with cURL:

```bash
curl http://localhost:5000/api/travel \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## Rate Limiting

Currently no rate limiting is implemented. May be added in future versions.

---

## API Versioning

Current version: **1.0.1**

Future breaking changes will be introduced under different URL paths (e.g., `/api/v2/`).

---

## Development Notes

### Dev Mode Auth Bypass

When `NODE_ENV !== 'production'`, JWT validation is bypassed with a mock user:

```javascript
// Injected mock user
req.user = { auth0Id: 'auth0|dev-user-123' };
```

**To enable authentication**: Set `NODE_ENV=production` in `backend/.env`

### Android Emulator Networking

From Android Emulator, use `http://10.0.2.2:5000` to reach `localhost:5000` on the host machine.

---

## Quick Start Examples

### Create a Trip

```bash
curl -X POST http://localhost:5000/api/travel \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sri Lanka Adventure",
    "description": "Island exploration",
    "startDate": "2026-07-01T00:00:00Z",
    "endDate": "2026-07-15T00:00:00Z"
  }'
```

### Add a Destination

```bash
curl -X POST http://localhost:5000/api/travel/TRIP_ID/destinations \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sigiriya",
    "latitude": 7.9570,
    "longitude": 80.7603,
    "districtId": "matale"
  }'
```

### Get Trip Map Data

```bash
curl "http://localhost:5000/api/travel/TRIP_ID/geojson?includeRoute=true" \
  -H "Authorization: Bearer TOKEN"
```

### Find Nearby Places

```bash
curl "http://localhost:5000/api/destinations/nearby?lat=7.8731&lng=80.7718&radius=50" \
  -H "Authorization: Bearer TOKEN"
```

---

## Implementation Details

### Backend Files

| Feature | Controller | Route | Model |
|---------|------------|-------|-------|
| Authentication | `authController.js` | `authRoutes.js` | `User.js` |
| Trips | `travelController.js` | `travelRoutes.js` | `Travel.js` |
| Destinations | `destinationController.js` | `destinationRoutes.js` | `Destination.js` |
| Maps | `mapController.js` | `mapRoutes.js` | - |
| Geospatial | `geoController.js` | `geoRoutes.js` | - |

All files located in `backend/src/`

---

## See Also

- [Auth Endpoints Documentation](./auth-endpoints.md) - Detailed authentication endpoints
- [API Reference](./api-reference.md) - Full API reference with all endpoints
- [Database Models](../database/models.md) - Model schemas and relationships
- [Frontend API Integration](../../frontend/api-integration/README.md) - How to consume APIs in Flutter
- [Feature Implementations](../../common/feature-implementation/) - Feature-specific implementation guides

---

## Support

For issues or questions:
- Check the [documentation](../../README.md)
- Review [implementation guides](../../common/feature-implementation/)
- Open an issue in the GitHub repository
