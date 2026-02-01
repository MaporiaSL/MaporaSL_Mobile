# Album Feature Implementation

**Feature**: Travel Photo Album & Memories  
**Last Updated**: February 1, 2026  
**Status**: Planned (Not Yet Implemented)

---

## Overview

The Album feature allows users to upload, organize, and share photos from their trips. Photos are linked to specific destinations and trips for contextual browsing.

---

## Planned Architecture

```
Trip ──> Destinations ──> Photos
                      └──> Albums (Collections)
```

---

## Backend Implementation (Planned)

### Files to Create

| File | Purpose | Location |
|------|---------|----------|
| **Photo.js** | Photo model | `backend/src/models/Photo.js` (to create) |
| **Album.js** | Album collection model | `backend/src/models/Album.js` (to create) |
| **photoController.js** | Photo CRUD logic | `backend/src/controllers/photoController.js` (to create) |
| **photoRoutes.js** | Photo endpoints | `backend/src/routes/photoRoutes.js` (to create) |

### 1. Photo Model (To Create)

**Planned Schema**:
```javascript
const photoSchema = new mongoose.Schema({
  userId: { type: String, required: true, index: true },
  travelId: { type: mongoose.Schema.Types.ObjectId, ref: 'Travel' },
  destinationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Destination' },
  albumId: { type: mongoose.Schema.Types.ObjectId, ref: 'Album' },
  url: { type: String, required: true },
  thumbnail: String,
  caption: String,
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: [Number] // [lng, lat]
  },
  takenAt: Date,
  uploadedAt: { type: Date, default: Date.now },
  metadata: {
    width: Number,
    height: Number,
    fileSize: Number,
    mimeType: String
  }
});
```

### 2. Album Model (To Create)

**Planned Schema**:
```javascript
const albumSchema = new mongoose.Schema({
  userId: { type: String, required: true, index: true },
  travelId: { type: mongoose.Schema.Types.ObjectId, ref: 'Travel' },
  title: { type: String, required: true },
  description: String,
  coverPhoto: String,
  photoCount: { type: Number, default: 0 },
  isPublic: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});
```

---

## Frontend Implementation (Planned)

### Files to Create

| File | Purpose | Location |
|------|---------|----------|
| **album_screen.dart** | Album browser | `mobile/lib/features/album/screens/album_screen.dart` (to create) |
| **photo_upload_screen.dart** | Upload photos | `mobile/lib/features/album/screens/photo_upload_screen.dart` (to create) |
| **photo_gallery_widget.dart** | Photo grid | `mobile/lib/features/album/widgets/photo_gallery_widget.dart` (to create) |
| **album_provider.dart** | Album state | `mobile/lib/features/album/providers/album_provider.dart` (to create) |

---

## Planned API Endpoints

### Photo Endpoints

- `POST /api/photos/upload` - Upload photo
- `GET /api/photos?travelId=&destinationId=` - Get photos
- `GET /api/photos/:photoId` - Get single photo
- `PATCH /api/photos/:photoId` - Update caption/metadata
- `DELETE /api/photos/:photoId` - Delete photo

### Album Endpoints

- `POST /api/albums` - Create album
- `GET /api/albums` - Get user albums
- `GET /api/albums/:albumId` - Get album with photos
- `POST /api/albums/:albumId/photos` - Add photos to album
- `DELETE /api/albums/:albumId` - Delete album

---

## Storage Integration

### Cloud Storage Options

1. **AWS S3** (Recommended)
   - Large storage capacity
   - CDN integration with CloudFront
   - Cost-effective

2. **Cloudinary**
   - Image optimization built-in
   - Automatic thumbnail generation
   - Easy transformation URLs

3. **Firebase Storage**
   - Good integration with Flutter
   - Simple setup
   - Free tier available

### Implementation Steps

1. **Setup Storage Service**:
   ```bash
   npm install aws-sdk
   # or
   npm install cloudinary
   ```

2. **Create Upload Endpoint**:
   ```javascript
   const multer = require('multer');
   const upload = multer({ dest: 'uploads/' });
   
   router.post('/photos/upload', upload.single('photo'), async (req, res) => {
     // Upload to S3/Cloudinary
     const url = await uploadToCloud(req.file);
     
     const photo = new Photo({
       userId: req.user.auth0Id,
       url: url,
       travelId: req.body.travelId,
       caption: req.body.caption
     });
     
     await photo.save();
     res.json(photo);
   });
   ```

3. **Flutter Upload**:
   ```dart
   Future<void> uploadPhoto(File imageFile, String travelId) async {
     final formData = FormData.fromMap({
       'photo': await MultipartFile.fromFile(imageFile.path),
       'travelId': travelId,
       'caption': caption,
     });
     
     await dio.post('/api/photos/upload', data: formData);
   }
   ```

---

## Common Features to Implement

### 1. Photo Tagging

**Backend**:
```javascript
tags: [{
  type: String, // 'person', 'place', 'activity'
  value: String
}]
```

**Frontend**: Add tags when uploading

### 2. Photo Filters & Editing

**Frontend** (using packages):
```yaml
dependencies:
  image_picker: ^0.8.6
  photo_view: ^0.14.0
  image: ^4.0.15  # For filters
```

### 3. Auto-organize by Location

**Backend**: Use photo GPS metadata to assign to destinations

```javascript
// If photo has GPS coordinates
const nearestDest = await Destination.findOne({
  location: {
    $near: {
      $geometry: { type: 'Point', coordinates: [photoLng, photoLat] },
      $maxDistance: 1000 // 1km
    }
  }
});
```

### 4. Photo Timeline

**Frontend**: Sort photos by `takenAt` date

```dart
final sortedPhotos = photos..sort((a, b) => 
  b.takenAt.compareTo(a.takenAt)
);
```

---

## See Also

- [Album Feature Spec](../features/album.md)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Flutter Image Picker](https://pub.dev/packages/image_picker)
