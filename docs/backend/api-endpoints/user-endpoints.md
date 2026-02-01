# User Profile API Endpoints

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1

---

## Overview

User endpoints provide access to user profile information, preferences, achievements, and account settings.

---

## Endpoints

### Get Current User Profile

Retrieve the authenticated user's profile information.

**Endpoint**: `GET /api/user/me`  
**Auth**: Required (JWT)  
**Controller**: `userController.getCurrentUser`

#### Response (200 OK)

```json
{
  "_id": "auth0|user123",
  "email": "user@example.com",
  "name": "John Doe",
  "picture": "https://cdn.example.com/avatars/user123.jpg",
  "profile": {
    "bio": "Travel enthusiast exploring the world",
    "location": "Colombo, Sri Lanka",
    "website": "https://johntravel.com",
    "joinDate": "2025-01-10T00:00:00.000Z"
  },
  "achievements": {
    "totalTrips": 5,
    "totalDestinations": 47,
    "countriesVisited": 8,
    "totalDistanceTravelledKm": 2847.32,
    "streakDays": 15
  },
  "gamification": {
    "xpPoints": 1250,
    "level": 5,
    "badges": [
      "first-trip",
      "five-destinations",
      "explorer",
      "map-master"
    ]
  },
  "preferences": {
    "distanceUnit": "km",
    "theme": "light",
    "notifications": true,
    "privateProfile": false
  },
  "createdAt": "2025-01-10T00:00:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/user/me" \
  -H "Authorization: Bearer TOKEN"
```

---

### Get User by ID

Retrieve public profile information for any user.

**Endpoint**: `GET /api/user/:userId`  
**Auth**: Optional (more details if authenticated)  
**Controller**: `userController.getUserById`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `userId` | string | Auth0 user ID |

#### Response (200 OK)

```json
{
  "_id": "auth0|user123",
  "email": "user@example.com",
  "name": "John Doe",
  "picture": "https://cdn.example.com/avatars/user123.jpg",
  "profile": {
    "bio": "Travel enthusiast exploring the world",
    "location": "Colombo, Sri Lanka",
    "website": "https://johntravel.com",
    "joinDate": "2025-01-10T00:00:00.000Z"
  },
  "achievements": {
    "totalTrips": 5,
    "totalDestinations": 47,
    "countriesVisited": 8,
    "totalDistanceTravelledKm": 2847.32
  },
  "gamification": {
    "xpPoints": 1250,
    "level": 5,
    "badges": [
      "first-trip",
      "five-destinations",
      "explorer"
    ]
  }
}
```

**Note**: Email and sensitive settings hidden unless viewing your own profile.

#### cURL Example

```bash
curl "http://localhost:5000/api/user/auth0|user123" \
  -H "Authorization: Bearer TOKEN"
```

---

### Update User Profile

Update authenticated user's profile information.

**Endpoint**: `PATCH /api/user/profile`  
**Auth**: Required (JWT)  
**Controller**: `userController.updateProfile`

#### Request

```json
{
  "name": "John Doe Updated",
  "bio": "Updated bio text",
  "location": "Kandy, Sri Lanka",
  "website": "https://newwebsite.com",
  "picture": "https://new-image-url.jpg"
}
```

**Note**: All fields optional. Only include fields you want to update.

#### Response (200 OK)

```json
{
  "_id": "auth0|user123",
  "email": "user@example.com",
  "name": "John Doe Updated",
  "picture": "https://new-image-url.jpg",
  "profile": {
    "bio": "Updated bio text",
    "location": "Kandy, Sri Lanka",
    "website": "https://newwebsite.com",
    "joinDate": "2025-01-10T00:00:00.000Z"
  },
  "updatedAt": "2026-01-24T10:35:00.000Z"
}
```

#### cURL Example

```bash
curl -X PATCH "http://localhost:5000/api/user/profile" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Travel enthusiast exploring the world",
    "location": "Colombo, Sri Lanka"
  }'
```

---

### Update User Preferences

Update user's app preferences and settings.

**Endpoint**: `PATCH /api/user/preferences`  
**Auth**: Required (JWT)  
**Controller**: `userController.updatePreferences`

#### Request

```json
{
  "distanceUnit": "km",
  "theme": "dark",
  "notifications": true,
  "privateProfile": false,
  "mapProvider": "mapbox"
}
```

**Note**: All fields optional.

#### Valid Values

| Field | Valid Values | Default |
|-------|--------------|---------|
| `distanceUnit` | `km`, `mi` | `km` |
| `theme` | `light`, `dark`, `auto` | `light` |
| `notifications` | `true`, `false` | `true` |
| `privateProfile` | `true`, `false` | `false` |
| `mapProvider` | `mapbox`, `osm`, `google` | `mapbox` |

#### Response (200 OK)

```json
{
  "_id": "auth0|user123",
  "preferences": {
    "distanceUnit": "km",
    "theme": "dark",
    "notifications": true,
    "privateProfile": false,
    "mapProvider": "mapbox"
  },
  "updatedAt": "2026-01-24T10:35:00.000Z"
}
```

#### cURL Example

```bash
curl -X PATCH "http://localhost:5000/api/user/preferences" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "theme": "dark",
    "distanceUnit": "mi"
  }'
```

---

### Get User Statistics

Get comprehensive statistics and achievements for a user.

**Endpoint**: `GET /api/user/:userId/stats`  
**Auth**: Optional  
**Controller**: `userController.getUserStats`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `userId` | string | Auth0 user ID |

#### Response (200 OK)

```json
{
  "userId": "auth0|user123",
  "username": "John Doe",
  "stats": {
    "trips": {
      "total": 5,
      "completed": 3,
      "planned": 2
    },
    "destinations": {
      "total": 47,
      "visited": 32,
      "planned": 15
    },
    "geography": {
      "countriesVisited": 8,
      "provincesVisited": 24,
      "districtsCovered": 47,
      "totalDistanceTravelledKm": 2847.32
    },
    "timeline": {
      "joinDate": "2025-01-10T00:00:00.000Z",
      "lastTripDate": "2026-01-10T00:00:00.000Z",
      "accountAgeDays": 379
    }
  },
  "gamification": {
    "xpPoints": 1250,
    "level": 5,
    "nextLevelXp": 1500,
    "progressToNextLevel": 83,
    "badges": [
      {
        "id": "first-trip",
        "name": "First Trip",
        "description": "Created your first trip",
        "awardedAt": "2025-01-15T00:00:00.000Z"
      },
      {
        "id": "five-destinations",
        "name": "Explorer",
        "description": "Added 5 destinations to a trip",
        "awardedAt": "2025-02-01T00:00:00.000Z"
      },
      {
        "id": "map-master",
        "name": "Map Master",
        "description": "Visited 20 destinations",
        "awardedAt": "2025-11-20T00:00:00.000Z"
      }
    ]
  },
  "leaderboard": {
    "rank": 42,
    "totalPlayers": 5847,
    "percentile": 99
  }
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/user/auth0|user123/stats" \
  -H "Authorization: Bearer TOKEN"
```

---

## User Model Fields

### Profile Object

```json
{
  "bio": "string - User biography",
  "location": "string - Current location",
  "website": "string - Personal website URL",
  "joinDate": "ISO8601 - Account creation date"
}
```

### Achievements Object

```json
{
  "totalTrips": "number - Count of created trips",
  "totalDestinations": "number - Count of all destinations across trips",
  "countriesVisited": "number - Count of unique countries",
  "totalDistanceTravelledKm": "number - Sum of all trip distances",
  "streakDays": "number - Current daily activity streak"
}
```

### Gamification Object

```json
{
  "xpPoints": "number - Total experience points",
  "level": "number - Current level (1-100)",
  "badges": ["array of badge IDs earned"]
}
```

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Missing/invalid token |
| 404 | Not Found - User not found |
| 500 | Server Error |

---

## File Locations

| File | Purpose |
|------|---------|
| `backend/src/controllers/userController.js` | Endpoint logic |
| `backend/src/routes/userRoutes.js` | Route definitions |
| `backend/src/models/User.js` | Data model |

---

## See Also

- [Authentication Endpoints](./auth-endpoints.md) - Register and login
- [Achievements Feature Implementation](../../common/feature-implementation/achievements.md) - Gamification guide
- [User Model Documentation](../database/models.md#user-model) - Schema details
