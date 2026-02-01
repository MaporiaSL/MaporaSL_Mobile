# Pre-Planned Trips API Endpoints

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1

---

## Overview

Pre-planned trips endpoints provide access to curated, template-based trip packages created by administrators. Users can browse available templates and use them as starting points for their own trips.

---

## Endpoints

### List Pre-Planned Trips

Get all available pre-planned trip templates with pagination.

**Endpoint**: `GET /api/preplannedtrips`  
**Auth**: Optional (returns more details if authenticated)  
**Controller**: `preplannedTripsController.getAllPrePlannedTrips`

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | number | 20 | Results per page |
| `skip` | number | 0 | Offset for pagination |
| `category` | string | - | Filter by category (e.g., "adventure", "beach", "culture") |
| `duration` | number | - | Filter by trip duration in days |
| `difficulty` | string | - | Filter by difficulty (easy, moderate, hard) |

#### Response (200 OK)

```json
{
  "templates": [
    {
      "_id": "5f8d3c2a1b4e5f6a7b8c9d0e",
      "title": "14 Day Sri Lanka Discovery",
      "description": "A comprehensive two-week journey across Sri Lanka exploring beaches, mountains, and culture",
      "category": "culture",
      "duration": 14,
      "difficulty": "moderate",
      "destinations": 12,
      "previewImage": "https://cdn.example.com/sri-lanka-14d.jpg",
      "highlights": [
        "Colombo Fort",
        "Kandy Temple",
        "Sigiriya Rock",
        "Galle Fort",
        "Mirissa Beach"
      ],
      "createdAt": "2025-06-15T00:00:00.000Z",
      "rating": 4.8,
      "ratingCount": 342
    },
    {
      "_id": "5f8d3c2a1b4e5f6a7b8c9d0f",
      "title": "7 Day Beach Escape",
      "description": "Relaxed beach-focused trip to southern Sri Lanka",
      "category": "beach",
      "duration": 7,
      "difficulty": "easy",
      "destinations": 5,
      "previewImage": "https://cdn.example.com/sri-lanka-beach-7d.jpg",
      "highlights": [
        "Mirissa Beach",
        "Unawatuna",
        "Weligama",
        "Bentota Beach"
      ],
      "createdAt": "2025-07-01T00:00:00.000Z",
      "rating": 4.6,
      "ratingCount": 218
    }
  ],
  "total": 24,
  "limit": 20,
  "skip": 0
}
```

#### cURL Example

```bash
# Get all templates
curl "http://localhost:5000/api/preplannedtrips?limit=10" \
  -H "Authorization: Bearer TOKEN"

# Filter by category and difficulty
curl "http://localhost:5000/api/preplannedtrips?category=beach&difficulty=easy" \
  -H "Authorization: Bearer TOKEN"

# Filter by duration
curl "http://localhost:5000/api/preplannedtrips?duration=7" \
  -H "Authorization: Bearer TOKEN"
```

---

### Get Pre-Planned Trip Details

Retrieve complete details including all destinations for a specific template.

**Endpoint**: `GET /api/preplannedtrips/:templateId`  
**Auth**: Optional  
**Controller**: `preplannedTripsController.getPrePlannedTripById`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | string | MongoDB ObjectId of template |

#### Response (200 OK)

```json
{
  "_id": "5f8d3c2a1b4e5f6a7b8c9d0e",
  "title": "14 Day Sri Lanka Discovery",
  "description": "A comprehensive two-week journey across Sri Lanka exploring beaches, mountains, and culture",
  "category": "culture",
  "duration": 14,
  "difficulty": "moderate",
  "previewImage": "https://cdn.example.com/sri-lanka-14d.jpg",
  "rating": 4.8,
  "ratingCount": 342,
  "createdBy": {
    "_id": "auth0|admin123",
    "name": "Travel Admin"
  },
  "itinerary": [
    {
      "day": 1,
      "title": "Arrival in Colombo",
      "description": "Arrive at Bandaranaike International Airport, transfer to hotel",
      "destinations": ["679f5e8d3c2a1b4e5f6a7b8d"]
    },
    {
      "day": 2,
      "title": "Colombo Exploration",
      "description": "City tour of Colombo's historic sites and museums",
      "destinations": ["679f5e8d3c2a1b4e5f6a7b8d", "679f5e8d3c2a1b4e5f6a7b8e"]
    }
  ],
  "destinations": [
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8d",
      "name": "Colombo Fort",
      "latitude": 6.9271,
      "longitude": 79.8612,
      "description": "Historic colonial-era fort",
      "estimatedDuration": "3 hours",
      "bestTimeToVisit": "early morning or sunset"
    },
    {
      "_id": "679f5e8d3c2a1b4e5f6a7b8e",
      "name": "Kandy",
      "latitude": 6.9271,
      "longitude": 80.6350,
      "description": "Cultural heart of Sri Lanka",
      "estimatedDuration": "2 days",
      "bestTimeToVisit": "any time"
    }
  ],
  "totalDistance": 487.32,
  "estimatedBudget": {
    "min": 800,
    "max": 1500,
    "currency": "USD"
  },
  "highlights": [
    "Colombo Fort",
    "Kandy Temple",
    "Sigiriya Rock",
    "Galle Fort",
    "Mirissa Beach"
  ],
  "createdAt": "2025-06-15T00:00:00.000Z",
  "updatedAt": "2026-01-20T00:00:00.000Z"
}
```

#### cURL Example

```bash
curl "http://localhost:5000/api/preplannedtrips/5f8d3c2a1b4e5f6a7b8c9d0e" \
  -H "Authorization: Bearer TOKEN"
```

---

### Create Trip from Template

Create a user's personal trip by copying a pre-planned trip template.

**Endpoint**: `POST /api/preplannedtrips/:templateId/use`  
**Auth**: Required (JWT)  
**Controller**: `preplannedTripsController.createTripFromTemplate`

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `templateId` | string | MongoDB ObjectId of template |

#### Request (Optional)

```json
{
  "customTitle": "My Sri Lanka Adventure",
  "startDate": "2025-12-01T00:00:00Z",
  "endDate": "2025-12-15T00:00:00Z",
  "adjustDates": true
}
```

**Note**: All fields optional. If not provided, template defaults are used.

#### Response (201 Created)

```json
{
  "_id": "679f5e8d3c2a1b4e5f6a7b8c",
  "userId": "auth0|user123",
  "title": "My Sri Lanka Adventure",
  "description": "A comprehensive two-week journey across Sri Lanka exploring beaches, mountains, and culture",
  "startDate": "2025-12-01T00:00:00.000Z",
  "endDate": "2025-12-15T00:00:00.000Z",
  "sourceTemplate": "5f8d3c2a1b4e5f6a7b8c9d0e",
  "locations": [
    "Colombo",
    "Kandy",
    "Sigiriya",
    "Galle",
    "Mirissa"
  ],
  "createdAt": "2026-01-24T10:30:00.000Z",
  "updatedAt": "2026-01-24T10:30:00.000Z"
}
```

#### cURL Example

```bash
# Use template with default settings
curl -X POST "http://localhost:5000/api/preplannedtrips/5f8d3c2a1b4e5f6a7b8c9d0e/use" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json"

# Use template with custom dates
curl -X POST "http://localhost:5000/api/preplannedtrips/5f8d3c2a1b4e5f6a7b8c9d0e/use" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customTitle": "My Vacation",
    "startDate": "2025-12-01T00:00:00Z",
    "endDate": "2025-12-15T00:00:00Z"
  }'
```

#### Workflow

1. User browses pre-planned trips
2. User selects template to view details
3. User clicks "Use This Template"
4. This endpoint creates a copy of the template as their own trip
5. User can then modify destinations, dates, notes as needed

---

## Categories

Pre-planned trips are organized by category:

| Category | Description | Example |
|----------|-------------|---------|
| `beach` | Beach-focused, relaxation trips | 7 Day Beach Escape |
| `adventure` | Active, outdoor-focused trips | Hiking & Trekking Tours |
| `culture` | Historical sites, museums, cultural landmarks | 14 Day Discovery |
| `wildlife` | Safari, nature, wildlife observation | Wildlife Spotting |
| `food` | Culinary tours, food experiences | Food & Wine Tour |
| `luxury` | High-end accommodations, premium experiences | Luxury Escape |
| `budget` | Low-cost, budget-friendly travel | Backpacker's Route |

---

## Difficulty Levels

| Level | Description | Target Audience |
|-------|-------------|-----------------|
| `easy` | Minimal walking, relaxed pace, accessible | Families, seniors |
| `moderate` | Regular walking, some physical activity | General tourists |
| `hard` | Strenuous activities, challenging terrain | Adventure seekers |

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Trip created from template |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Missing/invalid token (for POST) |
| 404 | Not Found - Template not found |
| 500 | Server Error |

---

## File Locations

| File | Purpose |
|------|---------|
| `backend/src/controllers/preplannedTripsController.js` | Endpoint logic |
| `backend/src/routes/preplannedTripsRoutes.js` | Route definitions |
| `backend/src/models/PrePlannedTrip.js` | Data model |

---

## See Also

- [Travel Endpoints](./travel-endpoints.md) - User trip management
- [Destination Endpoints](./destination-endpoints.md) - Manage trip destinations
- [Trips Feature Implementation](../../common/feature-implementation/trips.md) - Complete implementation guide
- [PrePlannedTrip Model Documentation](../database/models.md#preplannedtrip-model) - Schema details
