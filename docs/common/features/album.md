# Photo Album Feature Specification

**Version**: 1.0  
**Date**: January 27, 2026  
**Status**: 📋 Planning Phase  
**Priority**: 🟡 HIGH - User-generated content core

---

## Executive Summary

The **Photo Album Feature** enables users to capture, organize, and share photos from their travels. Users can take photos with the in-app camera (with branded overlays), organize them by trips, and view geotagged memories on the map.

**Core Value**: Integrated photo capture and management system that bridges camera, location, and trip planning.

---

## Feature Overview

### Key Capabilities

1. **In-App Camera**
   - Instagram-like custom UI
   - App-branded overlays/filters
   - Quick capture during travel
   - Real-time preview

2. **Photo Organization**
   - Auto-organized by trip
   - Chronological timeline view
   - Smart album creation
   - Manual organization options

3. **Metadata Enrichment**
   - Automatic geotagging (coordinates)
   - Trip association
   - Place linkage (Maps Places API)
   - Timestamp capture
   - Optional captions/notes

4. **Map Integration**
   - View geotagged photos on map
   - Cluster photos by location
   - Journey visualization
   - "Photo taken here" markers

---

## Data Model

### Photo Document

```javascript
{
  _id: ObjectId,
  userId: ObjectId (required, indexed),
  tripId: ObjectId, // Associated trip
  
  // Photo metadata
  fileName: String,
  fileSize: Number,
  mimeType: String, // image/jpeg, etc
  
  // Storage
  url: String, // Cloud storage URL
  thumbnailUrl: String,
  originalFileName: String,
  
  // Geolocation
  location: {
    type: "Point",
    coordinates: [longitude, latitude] // GeoJSON
  },
  address: String, // Reverse-geocoded address
  placeId: ObjectId, // Linked Places system place
  
  // Trip metadata
  capturedAt: Date (required, indexed),
  capturedDuring: ObjectId, // Trip reference
  
  // User content
  caption: String, // Optional user caption
  notes: String, // Optional travel notes
  
  // Engagement
  favorite: Boolean (default: false, indexed),
  shared: Boolean (default: false),
  sharedWith: [ObjectId], // User IDs
  
  // System
  createdAt: Date (default: now),
  updatedAt: Date,
  deletedAt: Date, // Soft delete
}
```

### Album Document

```javascript
{
  _id: ObjectId,
  userId: ObjectId (required, indexed),
  tripId: ObjectId, // Which trip is this album for
  
  title: String, // Auto-generated or user-provided
  description: String,
  
  photos: [ObjectId], // References to photo documents
  photoCount: Number,
  
  // Album metadata
  createdAt: Date,
  updatedAt: Date,
  startDate: Date, // Date range of trip
  endDate: Date,
  
  // Statistics
  locations: [{ place, count }], // Top places in album
  mapBounds: { nw, se }, // Bounding box for map view
}
```

---

## Features

### 1. In-App Camera

**Camera Interface**:
- Full-screen camera preview
- Capture button (center bottom)
- Flash toggle
- Camera/video mode switcher
- Settings/options
- Custom app overlay with branding
- Real-time location indicator

**Overlay Options**:
- MAPORIA watermark
- Date/time stamp
- Location name (if available)
- Trip name indicator
- Custom filters (future enhancement)

**Photo Capture Flow**:
```
User opens Camera
    ↓
Requests location permission (if not granted)
    ↓
Gets current GPS coordinates
    ↓
User frames shot
    ↓
Taps capture button
    ↓
Photo saved to device + cloud
    ↓
Geotagged with coordinates
    ↓
Optional: Add caption/notes dialog
    ↓
Linked to current trip (if in trip context)
    ↓
Added to Photo Album
```

### 2. Photo Organization

**Automatic Organization**:
- Photos grouped by trip
- Within trip, organized chronologically
- Auto-created albums per trip
- Smart album title generation

**Manual Organization**:
- Move photos between albums
- Create custom albums
- Rename albums
- Add descriptions

**Album Views**:
- Grid view (thumbnail gallery)
- Timeline view (chronological)
- Map view (geotagged locations)
- Trip-linked view (organize by travel)

### 3. Photo Timeline

**MemoryLane Integration**:
- Photos section in Memory Lane
- Chronological photo feed
- Grouped by trip/date
- Quick access to full trip photos
- Statistics: total photos, avg per trip

**Photo Card Display**:
- Thumbnail image
- Date & time captured
- Location name (if available)
- Trip association
- Caption preview

### 4. Map View

**Geotagged Map**:
- View all photos on map
- Markers at capture locations
- Cluster photos by proximity
- Click marker to view photos from that location
- Show "Photo Journey" route (connecting photos chronologically)

**Interaction**:
- Pan/zoom map
- Click cluster to expand
- Click photo marker to preview
- Get directions to location

### 5. Favorite & Sharing

**Favorite System**:
- Mark favorite photos (heart icon)
- Filter view to favorites only
- Separate favorites album
- Cloud backup for favorites

**Sharing**:
- Share individual photos (social media, messages)
- Share album (create shareable link)
- Share with other users (collaborative albums)
- Generate trip highlights reel

---

## Implementation Phases

### Phase 1: Core Camera & Storage (2 weeks)
- Implement in-app camera with custom UI
- Photo file storage to cloud (Firebase, S3, etc)
- Geotagging with location services
- Auto-album creation per trip
- Basic metadata storage

### Phase 2: Photo Organization & Timeline (1.5 weeks)
- Photo timeline view
- Album management UI
- Trip-based photo organization
- Favorites system
- Photo grid view

### Phase 3: Map Integration (1.5 weeks)
- Geotagged map view
- Location clustering
- Photo markers on map
- Journey visualization
- Location-based photo grouping

### Phase 4: Sharing & Social (1 week)
- Photo sharing to social media
- Album shareable links
- Collaborative albums
- User-to-user photo sharing

### Phase 5: Advanced Features (Future)
- Photo filters & editing
- AI-powered photo highlights
- Photo search by location/date/caption
- Photo enhancement (cloud processing)
- Video support
- Photo printing/merchandise

---

## API Endpoints

### Photo Management (Authentication Required)

**POST** `/api/photos` - Upload new photo
- Multipart form: `photo` (file), `caption`, `tripId`, `notes`
- Auto-captures: location, timestamp
- Returns: created photo document

**GET** `/api/photos` - List user's photos
- Query: `skip`, `limit`, `tripId`, `startDate`, `endDate`, `favorite`
- Returns: paginated photos array

**GET** `/api/photos/:id` - Get photo details
- Returns: complete photo object with metadata

**PATCH** `/api/photos/:id` - Update photo
- Body: `caption`, `notes`, `favorite`, etc
- Returns: updated photo

**DELETE** `/api/photos/:id` - Delete photo
- Returns: success message (soft delete)

**GET** `/api/photos/map/locations` - Get all photo locations
- Returns: array of { placeId, coordinates, photoCount }

### Album Management (Authentication Required)

**GET** `/api/albums` - List user's albums
- Query: `skip`, `limit`, `tripId`
- Returns: paginated albums array

**GET** `/api/albums/:id` - Get album details
- Returns: album with all photos

**PATCH** `/api/albums/:id` - Update album
- Body: `title`, `description`
- Returns: updated album

**POST** `/api/albums/:id/share` - Generate share link
- Body: `expiresAt` (optional)
- Returns: shareable URL

---

## UI Components

### CameraScreen
- Full-screen camera preview
- Capture button
- Settings menu
- Flash/mode toggles
- Optional overlay customization

### PhotoTimelineScreen
- Chronological photo feed
- Trip grouping
- Photo card with metadata
- Quick favorites toggle
- Open full-size view

### PhotoGridScreen
- Thumbnail grid layout
- Multi-select for batch operations
- Filter by trip/date
- Favorites view
- Swipe to view full-size

### MapViewScreen
- Full-screen map
- Photo markers
- Cluster view
- Click-to-preview
- Journey line connecting photos

### PhotoDetailScreen
- Full-size photo display
- All metadata display
- Caption/notes editor
- Favorite toggle
- Share options
- Navigation to next/previous

### AlbumManagementScreen
- Create new albums
- Rename/delete albums
- Move photos between albums
- Album cover selection
- Share album option

---

## Database Schema

```javascript
// Photos Collection
db.photos.createIndex({ userId: 1, capturedAt: -1 });
db.photos.createIndex({ tripId: 1, capturedAt: -1 });
db.photos.createIndex({ favorite: 1, userId: 1 });
db.photos.createIndex({ "location": "2dsphere" }); // Geospatial

// Albums Collection
db.albums.createIndex({ userId: 1, createdAt: -1 });
db.albums.createIndex({ tripId: 1 });
```

---

## Storage Architecture

**Cloud Storage**:
- Original photo: `photos/{userId}/{tripId}/{photoId}/original.jpg`
- Thumbnail: `photos/{userId}/{tripId}/{photoId}/thumb.jpg`
- Metadata: MongoDB (locations, captions, etc)

**Sizing**:
- Thumbnail: 300x300px (~50KB)
- Display: 1200x1200px (~200KB)
- Original: Full resolution (~2-5MB)

**CDN Delivery**:
- Thumbnails & display images via CDN
- Original stored in object storage
- Lazy load full-size on demand

---

## Security & Privacy

**Photo Access**:
- Only photo owner can view full-size
- Thumbnails visible to self only (initially)
- Shared albums visible only to recipients
- Public links require authentication

**Location Privacy**:
- Geolocation data optional
- Can disable geotagging
- Can remove location from shared photos
- Batch privacy controls

**File Upload**:
- Validate MIME type (image/* only)
- Scan for EXIF data (remove sensitive metadata)
- Compress before storage
- Virus scan

---

## Success Metrics

- Users capture average 5+ photos per trip
- 80%+ of photos geotagged
- Map view loaded in < 1 second
- Photo upload < 10 seconds on 4G
- 50%+ of albums shared
- Average 100+ photos per user after 3 months

---

## Future Enhancements

1. **Photo Editing**: Built-in filters and adjustments
2. **AI Features**: Auto-highlights, smart albums, search
3. **Video Support**: Record short travel videos
4. **Face Recognition**: Auto-tag people in photos
5. **Print Products**: Photo books, prints, merchandise
6. **Collaboration**: Joint albums with other travelers
7. **AR Features**: Augmented reality overlays
8. **Photo Search**: Search by content, location, date, caption
9. **Cloud Sync**: Sync across devices
10. **Podcast Integration**: Create audio guides from photos

---

## References

- Feature: This document
- Trip Planning: `docs/features/TRIP_PLAN.md`
- Places: `docs/features/PLACES.md`
- Database Schema: `docs/03_architecture/DATABASE_SCHEMA.md`
- API Reference: `docs/04_api/API_REFERENCE.md`
