# Tourist Attractions & Places Feature Specification

**Date Created**: January 27, 2026  
**Status**: 📋 Planning Phase  
**Priority**: 🔴 CRITICAL - Core system foundation

---

## Executive Summary

The **Places System** is a foundational feature that enables users to discover, organize, and contribute to a curated list of tourist attractions and locations across Sri Lanka. While not a dedicated UI page, it is the **central data source** that powers trip planning throughout MAPORIA.

**Key insight**: Every time a user creates or plans a trip, they select destinations from this Places list. This feature is essential infrastructure.

---

## Problem Statement

- Users need curated, verified locations to plan trips in Sri Lanka
- Existing crowd-sourced location data (Google Maps, etc.) lacks travel-specific context
- No system to track new discoveries by locals and tourists
- No way to verify location legitimacy, safety, or accessibility
- No gamification to incentivize community contributions

---

## Feature Scope

### 1. Core Places Data Model

Each place stores:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | ObjectId | Unique identifier | `67a1b2c3d4e5f6g7h8i9j0k1` |
| `name` | String | Official place name | "Sigiriya Rock Fortress" |
| `description` | String | Detailed description | "Ancient fortress and UNESCO site..." |
| `category` | Enum | Place type | `["waterfall", "mountain", "city", "temple", "forest", "beach", "historical", "park"]` |
| `province` | String | Administrative province | "Central Province" |
| `district` | String | District name | "Matara" |
| `latitude` | Number | Geographic coordinate | 6.9271 |
| `longitude` | Number | Geographic coordinate | 79.8612 |
| `googleMapsUrl` | String | Direct link to open the place pin in Google Maps | `https://www.google.com/maps?q=6.9271,79.8612` |
| `address` | String | Physical address | "Sigiriya, Dambulla 21100" |
| `rating` | Number | Avg user rating (1-5) | 4.8 |
| `reviewCount` | Number | Total reviews | 342 |
| `photos` | Array<String> | URLs to photos | `["https://...", "https://..."]` |
| `source` | Enum | Where it came from | `"system"` (curated) or `"user"` (contributed) |
| `addedBy` | Object | Contributor info | `{ userId, username, date }` |
| `verified` | Boolean | Admin-approved | `true` |
| `accessibility` | Object | Access info | `{ season: "year-round", difficulty: "easy", bestTime: "Oct-Mar" }` |
| `tags` | Array<String> | Search keywords | `["hiking", "photography", "scenic"]` |
| `visitCount` | Number | Times added to trips | 1250 |
| `createdAt` | Date | System timestamp | 2026-01-01 |
| `updatedAt` | Date | Last modification | 2026-01-27 |

---

### 2. User Contributions Workflow

```
User Submits Place
    ↓
Form Validation
    ↓
Place Request Created (status: pending)
    ↓
Admin Review Dashboard
    ├─ View photos, location, details
    ├─ Check for duplicates
    ├─ Verify legitimacy (Google Maps, etc.)
    ├─ Check restrictions/accessibility
    └─ Approve or Reject with reason
    ↓
If Approved:
    ├─ Place added to main list
    ├─ User gets achievement badge
    ├─ Place shows contributor in metadata
    ├─ User profile updated with stat
    └─ Notification sent to user
    ↓
If Rejected:
    └─ User notified with reason
```

---

### 3. Place Submission Form (User)

**Required Fields**:
- Place name
- Description (min 50 chars)
- Category (single select)
- Province (dropdown)
- District (dropdown, filtered by province)
- Exact location (map pin + lat/lon) → generates `googleMapsUrl`
- At least 2 photos (min 500KB each)

**Optional Fields**:
- Best visiting season
- Difficulty/accessibility level
- Estimated visit duration
- Entry fee (if applicable)
- Contact info/website

**Validation**:
- Prevent duplicate submissions (check name + location)
- Validate coordinates are within Sri Lanka bounds
- Require clear, unblurred photos
- Check file sizes (2-10MB per photo)

---

### 4. Admin Verification System

**Dashboard Features**:
- List of pending submissions with counts
- Filters: status, date range, category
- Photo gallery view
- Quick approve/reject with preset reasons
- Bulk actions (approve multiple, reject spam)

**Verification Checklist**:
- ✅ Place name matches known location
- ✅ Coordinates map to actual location
- ✅ Photos show recognizable place
- ✅ No duplicate of existing place
- ✅ Not a private residence/restricted area
- ✅ No offensive/inappropriate content
- ✅ Legal to visit (not national security)

**Rejection Reasons** (preset):
- "Duplicate of existing place"
- "Location coordinates incorrect"
- "Not a public tourist attraction"
- "Photos don't match claimed location"
- "Restricted/private property"
- "Legal/safety concerns"
- "Insufficient information"

---

### 5. Gamification & User Achievements

**Badges**:
- 🏅 **Explorer** (Added 1 place)
- 🎖️ **Local Guide** (Added 5 places)
- 👑 **Place Curator** (Added 10+ places)
- 🌟 **Community Legend** (Added 20+ places)

**Profile Stats**:
- Total places contributed
- Approval rate (approved / submitted)
- Places added by others using their suggestions
- Impact score (how many trips used their places)

**Incentives**:
- Public recognition on place contributor card
- Leaderboard (Top 10 contributors)
- Special badge on user profile
- Optional: Future rewards (discount codes, featured content)

---

### 6. Search & Discovery

**Frontend Features**:
- Search by name, category, district
- Filter by:
  - Category (waterfall, mountain, etc.)
  - Province
  - Accessibility level
  - Rating
  - User ratings
- Sorting: rating, popularity, newly added, distance

**Integration with Trip Planning**:
- Places searchable when creating/editing trips
- Suggested places based on trip dates/region
- One-click add place to trip itinerary

---

## Data Flow

### Add Place from System (Admin/Developer)

```
1. Developer manually curates places list (offline)
2. Creates JSON file with all metadata
3. Places are bulk-imported into MongoDB
4. Source = "system", Verified = true
```

### Add Place from User

```
1. User taps "Suggest a Place" → Form opens
2. User fills form + uploads photos
3. Form validates and submits to backend
4. Backend creates PlaceRequest document (status: pending)
5. Photo files uploaded to cloud storage
6. Admin gets notification
7. Admin reviews in dashboard
8. If approved:
   - New Place document created
   - Photos linked to place
   - User achievement updated
   - User notification sent
```

---

## Database Schema

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
    userId: ObjectId (if user-submitted),
    username: String,
    date: Date,
    status: String // "pending", "approved", "rejected"
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
    media: { photos: Array<String> },
    metadata: { accessibility, tags, etc }
  },
  adminReview: {
    reviewedBy: ObjectId (admin user),
    reviewedAt: Date,
    decision: String, // "approved", "rejected"
    reason: String, // reason for rejection if applicable
    notes: String // admin notes
  },
  createdAt: Date,
  updatedAt: Date
}
```

### User Contributions Stats (embedded in User model)

```javascript
{
  contributedPlaces: {
    total: Number,
    approved: Number,
    pending: Number,
    rejected: Number,
    places: Array<ObjectId>, // IDs of approved places
    badges: Array<String> // ["Explorer", "Local Guide", etc]
  }
}
```

---

## Implementation Phases

### Phase 1: Seed Curated Places (Offline)
**Duration**: 2-3 days (manual research)
- Research 50-100 major tourist attractions in Sri Lanka
- Gather metadata: location, description, category, photos
- Create JSON file with all places
- Format validation before import

### Phase 2: Backend Infrastructure
**Duration**: 1 week
- Create Places model + schema
- Create PlaceRequest model (submissions)
- CRUD endpoints for places
- Place submission endpoint
- Admin approval endpoint
- Photo upload to cloud storage

### Phase 3: Frontend - Place Discovery UI
**Duration**: 1 week
- Places search/filter interface
- Place detail card/page
- Integration with trip creation

### Phase 4: Frontend - User Contribution
**Duration**: 1 week
- Place submission form
- Photo upload UI
- Form validation & UX
- Submission tracking

### Phase 5: Admin Dashboard
**Duration**: 1 week
- Pending submissions list
- Review interface with photos
- Approve/reject UI
- Bulk actions

### Phase 6: Gamification
**Duration**: 3-4 days
- Badge system implementation
- Profile stats display
- Leaderboard

---

## API Endpoints (Planned)

### Public (No Auth)
- `GET /api/places` - List all verified places (paginated, filterable)
- `GET /api/places/:id` - Get single place details
- `GET /api/places/search?q=name` - Search places

### User (Auth Required)
- `POST /api/places/request` - Submit new place
- `GET /api/places/requests/:userId` - View user's submissions

### Admin (Auth + Admin Role)
- `GET /api/admin/places/requests` - List pending submissions
- `PATCH /api/admin/places/requests/:id/approve` - Approve place
- `PATCH /api/admin/places/requests/:id/reject` - Reject place
- `POST /api/admin/places` - Manually add place (bulk import)
- `PATCH /api/admin/places/:id` - Edit place

---

## Security Considerations

1. **Photo Validation**:
   - Scan for inappropriate content
   - Verify photos are actual locations (consider manual review)
   - Prevent spam/duplicate photos

2. **Location Validation**:
   - Verify coordinates are within Sri Lanka
   - Check against known restricted areas
   - Prevent private property submissions

3. **Rate Limiting**:
   - Limit submissions per user per day
   - Prevent spam submissions

4. **Admin Verification**:
   - All user submissions require manual approval
   - Logged audit trail of approvals

5. **Data Privacy**:
   - Don't expose user IDs for contributors
   - Show only username on public profiles

---

## Success Metrics

- ✅ Seed database with 50-100 curated places
- ✅ System handles 1000+ places without performance issues
- ✅ User submissions processed within 24 hours
- ✅ 90%+ approval rate for legitimate places
- ✅ 50%+ of new trips use system places
- ✅ 100+ user contributions in first 3 months

---

## Open Questions / Future Enhancements

1. **Photo validation**: Manual review vs automated ML detection?
2. **Rating system**: Should it sync from Google Maps or be separate?
3. **Seasonal data**: Should places be seasonal/closed during periods?
4. **Accessibility metadata**: Should we include wheelchair access, parking, etc?
5. **User permissions**: Can users edit other's submitted places?
6. **Moderation**: Reputation system for contributor reliability?
7. **Internationalization**: Future support for place names in multiple languages?

---

## Documentation References

- Feature Spec: This document
- Implementation Plan: [PLACES_IMPLEMENTATION_PLAN.md](./PLACES_IMPLEMENTATION_PLAN.md) (coming)
- Curated Places Data: [places_seed_data.json](../../project_resorces/places_seed_data.json) (coming)
- API Reference: [API_REFERENCE.md](../04_api/API_REFERENCE.md) (to be updated)

