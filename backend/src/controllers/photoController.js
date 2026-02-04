const path = require('path');
const Album = require('../models/Album');

const { v4: uuidv4 } = require('uuid');
const { getStorage } = require('../config/firebase');

function generateStoragePath(userId, originalName, albumId = null) {
  const ext = path.extname(originalName);
  const uniqueId = uuidv4();
  const basePath = albumId 
    ? `users/${userId}/albums/${albumId}` 
    : `users/${userId}/photos`;
  return `${basePath}/${uniqueId}${ext}`;
}

async function getSignedUrl(storagePath) {
  const bucket = getStorage();
  const file = bucket.file(storagePath);
  
  // Generate signed URL valid for 7 days
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 7 * 24 * 60 * 60 * 1000 // 7 days
  });
  
  return url;
}

/**
 * Upload a photo to Firebase Storage and save metadata to MongoDB
 * POST /api/albums/:albumId/photos
 * Body: multipart/form-data with 'photo' file field
 */
async function uploadPhoto(req, res) {
  try {
    const { albumId } = req.params;
    const userId = req.userId;
    const { caption, latitude, longitude, placeName, destinationId, travelId } = req.body;

    if (!req.file) {
      return res.status(400).json({ error: 'No photo file provided' });
    }

    // Validate file type
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedMimeTypes.includes(req.file.mimetype)) {
      return res.status(400).json({ error: 'Invalid file type. Allowed: JPEG, PNG, GIF, WebP' });
    }

    // Find the album and verify ownership
    const album = await Album.findOne({ _id: albumId, userId });
    if (!album) {
      return res.status(404).json({ error: 'Album not found' });
    }

    // Generate storage path
    const storagePath = generateStoragePath(userId, req.file.originalname, albumId);

    // Upload to Firebase Storage
    const bucket = getStorage();
    const file = bucket.file(storagePath);

    await file.save(req.file.buffer, {
      metadata: {
        contentType: req.file.mimetype,
        metadata: {
          originalName: req.file.originalname,
          uploadedBy: userId,
          albumId: albumId
        }
      }
    });

    // Make the file publicly accessible (or use signed URLs)
    await file.makePublic();

    // Get the public URL
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;

    // Create photo object
    const photoData = {
      storagePath,
      url: publicUrl,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      caption: caption || '',
      location: {
        latitude: latitude ? parseFloat(latitude) : undefined,
        longitude: longitude ? parseFloat(longitude) : undefined,
        placeName: placeName || undefined
      },
      destinationId: destinationId || null,
      travelId: travelId || null,
      createdAt: new Date()
    };

    // Add photo to album
    album.photos.push(photoData);

    // Set cover photo if this is the first photo
    if (!album.coverPhotoUrl) {
      album.coverPhotoUrl = publicUrl;
    }

    await album.save();

    // Get the newly added photo
    const newPhoto = album.photos[album.photos.length - 1];

    res.status(201).json({
      message: 'Photo uploaded successfully',
      photo: {
        id: newPhoto._id,
        url: newPhoto.url,
        originalName: newPhoto.originalName,
        caption: newPhoto.caption,
        location: newPhoto.location,
        createdAt: newPhoto.createdAt
      }
    });
  } catch (error) {
    console.error('Upload photo error:', error);
    res.status(500).json({ error: 'Failed to upload photo' });
  }
}

/**
 * Upload multiple photos to an album
 * POST /api/albums/:albumId/photos/bulk
 */
async function uploadMultiplePhotos(req, res) {
  try {
    const { albumId } = req.params;
    const userId = req.userId;

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'No photo files provided' });
    }

    const album = await Album.findOne({ _id: albumId, userId });
    if (!album) {
      return res.status(404).json({ error: 'Album not found' });
    }

    const bucket = getStorage();
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    const uploadedPhotos = [];
    const errors = [];

    for (const file of req.files) {
      if (!allowedMimeTypes.includes(file.mimetype)) {
        errors.push({ filename: file.originalname, error: 'Invalid file type' });
        continue;
      }

      try {
        const storagePath = generateStoragePath(userId, file.originalname, albumId);
        const bucketFile = bucket.file(storagePath);

        await bucketFile.save(file.buffer, {
          metadata: {
            contentType: file.mimetype,
            metadata: {
              originalName: file.originalname,
              uploadedBy: userId,
              albumId: albumId
            }
          }
        });

        await bucketFile.makePublic();
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;

        const photoData = {
          storagePath,
          url: publicUrl,
          originalName: file.originalname,
          mimeType: file.mimetype,
          size: file.size,
          caption: '',
          createdAt: new Date()
        };

        album.photos.push(photoData);
        uploadedPhotos.push({
          originalName: file.originalname,
          url: publicUrl
        });
      } catch (uploadError) {
        errors.push({ filename: file.originalname, error: uploadError.message });
      }
    }

    // Set cover photo if album didn't have one
    if (!album.coverPhotoUrl && album.photos.length > 0) {
      album.coverPhotoUrl = album.photos[0].url;
    }

    await album.save();

    res.status(201).json({
      message: `${uploadedPhotos.length} photos uploaded successfully`,
      uploadedPhotos,
      errors: errors.length > 0 ? errors : undefined
    });
  } catch (error) {
    console.error('Bulk upload error:', error);
    res.status(500).json({ error: 'Failed to upload photos' });
  }
}