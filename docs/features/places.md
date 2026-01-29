# Places Feature Specification

**Version**: 1.0  
**Date**: January 27, 2026  
**Status**: 📋 Planning Phase  
**Priority**: 🔴 CRITICAL - Core system foundation

---

## Executive Summary

The **Places System** is a foundational feature that enables users to discover, organize, and contribute to a curated list of tourist attractions and locations across Sri Lanka. Every trip created uses places from this system, making it essential infrastructure for the platform.

**Core Value**: Centralized, verified location data with community contributions and gamification.

---

## Feature Overview

### Data Model

Each place stores complete location metadata:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | ObjectId | Unique identifier | `67a1b2c3d4e5f6g7h8i9j0k1` |
| `name` | String | Official place name | "Sigiriya Rock Fortress" |
| `description` | String | Detailed description | "Ancient fortress and UNESCO site..." |
| `category` | Enum | Place type | waterfall, mountain, city, temple, forest, beach, historical, park |
| `province` | String | Administrative province | "Central Province" |
| `district` | String | District name | "Matara" |
| `latitude` | Number | Geographic coordinate | 6.9271 |
| `longitude` | Number | Geographic coordinate | 79.8612 |
| `googleMapsUrl` | String | Direct Google Maps link | `https://www.google.com/maps?q=6.9271,79.8612` |
| `address` | String | Physical address | "Sigiriya, Dambulla 21100" |
| `rating` | Number | Average user rating (1-5) | 4.8 |
| `reviewCount` | Number | Total reviews | 342 |
| `photos` | Array<String> | Photo URLs | `["https://...", "https://..."]` |
| `source` | Enum | Origin | "system" (curated) or "user" (contributed) |
| `verified` | Boolean | Admin-approved | true/false |
| `accessibility` | Object | Access details | `{ season, difficulty, duration, entryFee }` |
| `tags` | Array<String> | Search keywords | `["hiking", "photography", "scenic"]` |
| `visitCount` | Number | Times added to trips | 1250 |
| `createdAt` | Date | System timestamp | 2026-01-01 |

---

## Core Features

### 1. User Contribution Workflow

**Process Flow**:
```
User Submits Place
    ↓
Form Validation (photos, location, data)
    ↓
Place Request Created (status: pending)
    ↓
Admin Review Dashboard
    ├─ View photos & location
    ├─ Check duplicates
    ├─ Verify legitimacy
    └─ Check restrictions
    ↓
If Approved:
    ├─ Place added to main list
    ├─ User gets achievement badge
    ├─ Notification sent
    └─ Contributor info displayed
```

**Required Fields**:
- Place name
- Description (min 50 chars)
- Category (single select: waterfall, mountain, city, temple, forest, beach, historical, park)
- Province & District (location)
- Map pin location (auto-generates googleMapsUrl)
- At least 2 photos (500KB-10MB each)

**Optional Fields**:
- Best visiting season
- Difficulty/accessibility level
- Estimated visit duration
- Entry fee
- Contact info/website

### 2. Admin Verification System

**Admin Dashboard**:
- List pending submissions with counts
- Filters: status, date range, category
- Photo gallery view
- Quick approve/reject with presets

**Verification Checklist**:
- Place name matches known location
- Coordinates map to actual location
- Photos show recognizable place
- No duplicate of existing place
- Not private residence/restricted area
- No inappropriate content
- Legal to visit

**Rejection Reasons**:
- Duplicate of existing place
- Location coordinates incorrect
- Not a public tourist attraction
- Photos don't match claimed location
- Restricted/private property
- Legal/safety concerns
- Insufficient information

### 3. Search & Discovery

**Frontend Features**:
- Search by name, category, district
- Filters: category, province, accessibility, rating
- Sorting: rating, popularity, newly added, distance
- Integration with trip planning (one-click add)

### 4. Gamification & Achievements

**Badges**:
- 🏅 **Explorer** (Added 1 place)
- 🎖️ **Local Guide** (Added 5 places)
- 👑 **Place Curator** (Added 10+ places)
- 🌟 **Community Legend** (Added 20+ places)

**Profile Stats**:
- Total places contributed
- Approval rate (approved / submitted)
- Impact score (trips using their places)
- Leaderboard ranking (Top 10 contributors)

---

## Database Collections

### Places Collection

```javascript
{
  _id: ObjectId,
  name: String (required, unique with location),
  description: String (required, min 50),
  category: String (enum), // waterfall, mountain, etc
  location: {
    province: String,
    district: String,
    address: String,
    coordinates: {
      type: "Point",
      coordinates: [longitude, latitude] // GeoJSON format
    }
  },
  googleMapsUrl: String, // direct Google Maps pin
  media: {
    photos: Array<String>, // URLs to cloud storage
    mainPhoto: String (first photo)
  },
  metadata: {
    source: String, // "system" or "user"
    verified: Boolean (default: false),
    rating: Number (1-5, default: 0),
    reviewCount: Number (default: 0),
    visitCount: Number (default: 0),
    accessibility: {
      season: String, // "year-round", "Oct-Mar", etc
      difficulty: String, // "easy", "moderate", "hard"
      duration: String, // "1-2 hours", "half day", etc
      entryFee: String, // "Free", "$5 USD", etc
    }
  },
  contributor: {
    userId: ObjectId,
    username: String,
    date: Date
  },
  tags: Array<String>,
  createdAt: Date,
  updatedAt: Date
}
```

### PlaceRequests Collection (User Submissions)

```javascript
{
  _id: ObjectId,
  userId: ObjectId (required),
  username: String,
  status: String, // "pending", "approved", "rejected"
  place: {
    name: String,
    description: String,
    category: String,
    location: { province, district, address, coordinates },
    googleMapsUrl: String,
    media: { photos: Array<String> }
  },
  adminReview: {
    reviewedBy: ObjectId (admin user),
    reviewedAt: Date,
    decision: String,
    reason: String,
    notes: String
  },
  createdAt: Date,
  updatedAt: Date
}
```

### User Contributions Stats (Embedded in User Model)

```javascript
{
  contributedPlaces: {
    total: Number,
    approved: Number,
    pending: Number,
    rejected: Number,
    places: Array<ObjectId>,
    badges: Array<String> // ["Explorer", "Local Guide", etc]
  }
}
```

---

## API Endpoints

### Public (No Authentication)

**GET** `/api/places` - List all verified places
- Query: `skip`, `limit`, `category`, `province`, `search`, `sortBy`
- Returns: paginated places array

**GET** `/api/places/:id` - Get single place details
- Returns: complete place object with contributor info

**GET** `/api/places/search?q=name` - Search places by name
- Returns: matching places array

### User Endpoints (Authentication Required)

**POST** `/api/places/request` - Submit new place
- Body: name, description, category, location, photos, accessibility
- Returns: PlaceRequest with status "pending"

**GET** `/api/places/requests/:userId` - View user's submissions
- Returns: array of user's PlaceRequest submissions with statuses

### Admin Endpoints (Admin Authentication Required)

**GET** `/api/admin/places/requests` - List pending submissions
- Query: `status`, `skip`, `limit`, `sortBy`
- Returns: paginated PlaceRequests array

**PATCH** `/api/admin/places/requests/:id/approve` - Approve place
- Body: notes (optional)
- Creates Place, sends notification

**PATCH** `/api/admin/places/requests/:id/reject` - Reject place
- Body: rejectionReason, notes
- Sends notification to user

**POST** `/api/admin/places` - Manually add place (bulk import)
- Body: place data
- Returns: created place

**PATCH** `/api/admin/places/:id` - Edit place
- Body: updatable fields
- Returns: updated place

---

## Implementation Phases

### Phase 1: Seed Curated Places (2-3 days)
- Research 50-100 major Sri Lankan attractions
- Gather metadata: location, description, category, photos
- Create `places_seed_data.json`
- Bulk import into MongoDB

**Key Attractions** (30-50 core):
- Historical: Sigiriya, Anuradhapura, Polonnaruwa, Temple of the Tooth
- Nature: Sinharaja Forest, Yala National Park, Horton Plains, Pidurutalagala
- Beaches: Mirissa, Unawatuna, Arugambe, Hikkaduwa
- Waterfalls: Ravana, St. Clair, Dambulla
- Cities: Colombo, Kandy, Galle, Nuwara Eliya

### Phase 2: Backend Infrastructure (1 week)
- Create Places & PlaceRequests models
- Implement CRUD endpoints
- Photo upload to cloud storage
- Bulk seed import functionality
- Implement duplicate checking

### Phase 3: Frontend - Place Discovery (1 week)
- Places search/filter interface
- Place detail card/page
- Integration with trip creation
- Search bar with autocomplete

### Phase 4: Frontend - User Contribution (1 week)
- Place submission form
- Photo upload UI
- Form validation & UX
- Submission status tracking

### Phase 5: Admin Dashboard (1 week)
- Pending submissions list
- Review interface with photos
- Approve/reject UI
- Bulk action support

### Phase 6: Gamification (3-4 days)
- Badge system implementation
- Profile stats display
- Leaderboard UI

---

## Security & Validation

**Photo Validation**:
- Scan for inappropriate content
- Verify file sizes (2-10MB per photo)
- Require clear, unblurred images
- Optional: manual review for spam

**Location Validation**:
- Verify coordinates within Sri Lanka bounds
- Check against known restricted areas
- Prevent private property submissions
- Validate using Google Maps API

**Rate Limiting**:
- Limit submissions per user per day (max 5)
- Prevent spam through duplicate checking
- Cooldown period between rejections

**Admin Verification**:
- All user submissions require manual approval
- Audit trail of all admin actions
- Logged approvers and timestamps

---

## Success Metrics

- Seed database with 50-100 curated places
- System handles 1000+ places without performance issues
- User submissions processed within 24 hours
- 90%+ approval rate for legitimate places
- 50%+ of new trips use system places
- 100+ user contributions in first 3 months
- Average place detail retrieval < 100ms
- Search functionality works across 1000+ places

---

## Future Enhancements

1. **Rating System**: Separate user ratings vs Google Maps sync
2. **Seasonal Data**: Mark places closed during certain periods
3. **Accessibility**: Include wheelchair access, parking, facilities
4. **User Permissions**: Allow users to edit community-submitted places
5. **Moderation**: Reputation system for contributor reliability
6. **Internationalization**: Multi-language place names
7. **Reviews**: User-submitted reviews and photos
8. **Trending**: Real-time trending places based on trip additions

---

## References

- Feature Specification: This document
- Curated Places Data: `project_resources/places_seed_data.json`
- API Reference: `docs/04_api/API_REFERENCE.md`
- Database Schema: `docs/03_architecture/DATABASE_SCHEMA.md`
