const Album = require('../models/Album');

const { getStorage } = require('../config/firebase');

/**
 * Create a new album
 * POST /api/albums
 */
async function createAlbum(req, res) {
  try {
    const userId = req.userId;
    const { name, description, tags, districtId, provinceId } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Album name is required' });
    }

    const album = new Album({
      userId,
      name,
      description: description || '',
      tags: tags || [],
      districtId: districtId || null,
      provinceId: provinceId || null
    });

    await album.save();

    res.status(201).json({
      message: 'Album created successfully',
      album: {
        id: album._id,
        name: album.name,
        description: album.description,
        tags: album.tags,
        districtId: album.districtId,
        provinceId: album.provinceId,
        photoCount: 0,
        coverPhotoUrl: null,
        createdAt: album.createdAt
      }
    });
  } catch (error) {
    console.error('Create album error:', error);
    res.status(500).json({ error: 'Failed to create album' });
  }
}

/**
 * Get all albums for a user
 * GET /api/albums
 */
async function getAlbums(req, res) {
  try {
    const userId = req.userId;
    const { page = 1, limit = 10, districtId, provinceId } = req.query;

    const query = { userId };
    if (districtId) query.districtId = districtId;
    if (provinceId) query.provinceId = provinceId;

    const totalAlbums = await Album.countDocuments(query);
    const albums = await Album.find(query)
      .select('name description coverPhotoUrl tags districtId provinceId photos createdAt updatedAt')
      .sort({ createdAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit));

    res.status(200).json({
      totalAlbums,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(totalAlbums / parseInt(limit)),
      albums: albums.map(album => ({
        id: album._id,
        name: album.name,
        description: album.description,
        coverPhotoUrl: album.coverPhotoUrl,
        tags: album.tags,
        districtId: album.districtId,
        provinceId: album.provinceId,
        photoCount: album.photos.length,
        createdAt: album.createdAt,
        updatedAt: album.updatedAt
      }))
    });
  } catch (error) {
    console.error('Get albums error:', error);
    res.status(500).json({ error: 'Failed to retrieve albums' });
  }
}

/**
 * Get a single album by ID
 * GET /api/albums/:albumId
 */
async function getAlbum(req, res) {
  try {
    const { albumId } = req.params;
    const userId = req.userId;

    const album = await Album.findOne({ _id: albumId, userId });
    if (!album) {
      return res.status(404).json({ error: 'Album not found' });
    }

    res.status(200).json({
      id: album._id,
      name: album.name,
      description: album.description,
      coverPhotoUrl: album.coverPhotoUrl,
      tags: album.tags,
      districtId: album.districtId,
      provinceId: album.provinceId,
      photoCount: album.photos.length,
      photos: album.photos.map(photo => ({
        id: photo._id,
        url: photo.url,
        originalName: photo.originalName,
        caption: photo.caption,
        location: photo.location,
        createdAt: photo.createdAt
      })),
      createdAt: album.createdAt,
      updatedAt: album.updatedAt
    });
  } catch (error) {
    console.error('Get album error:', error);
    res.status(500).json({ error: 'Failed to retrieve album' });
  }
}

/**
 * Get user's album and photo statistics
 * GET /api/albums/stats
 */
async function getAlbumStats(req, res) {
  try {
    const userId = req.userId;

    const albums = await Album.find({ userId });
    
    const totalAlbums = albums.length;
    const totalPhotos = albums.reduce((sum, album) => sum + album.photos.length, 0);
    const totalStorageBytes = albums.reduce((sum, album) => 
      sum + album.photos.reduce((photoSum, photo) => photoSum + (photo.size || 0), 0), 0
    );

    // Group photos by district
    const photosByDistrict = {};
    albums.forEach(album => {
      if (album.districtId) {
        photosByDistrict[album.districtId] = (photosByDistrict[album.districtId] || 0) + album.photos.length;
      }
    });

    res.status(200).json({
      totalAlbums,
      totalPhotos,
      totalStorageMB: Math.round(totalStorageBytes / (1024 * 1024) * 100) / 100,
      photosByDistrict,
      recentAlbums: albums
        .sort((a, b) => b.createdAt - a.createdAt)
        .slice(0, 5)
        .map(a => ({
          id: a._id,
          name: a.name,
          photoCount: a.photos.length,
          coverPhotoUrl: a.coverPhotoUrl
        }))
    });
  } catch (error) {
    console.error('Get album stats error:', error);
    res.status(500).json({ error: 'Failed to retrieve album statistics' });
  }
}

/**
 * Update album metadata
 * PATCH /api/albums/:albumId
 */
async function updateAlbum(req, res) {
  try {
    const { albumId } = req.params;
    const userId = req.userId;
    const { name, description, tags, districtId, provinceId, coverPhotoId } = req.body;

    const album = await Album.findOne({ _id: albumId, userId });
    if (!album) {
      return res.status(404).json({ error: 'Album not found' });
    }

    // Update fields if provided
    if (name !== undefined) album.name = name;
    if (description !== undefined) album.description = description;
    if (tags !== undefined) album.tags = tags;
    if (districtId !== undefined) album.districtId = districtId;
    if (provinceId !== undefined) album.provinceId = provinceId;

    // Update cover photo if specified
    if (coverPhotoId) {
      const photo = album.photos.id(coverPhotoId);
      if (photo) {
        album.coverPhotoUrl = photo.url;
      }
    }

    await album.save();

    res.status(200).json({
      message: 'Album updated successfully',
      album: {
        id: album._id,
        name: album.name,
        description: album.description,
        coverPhotoUrl: album.coverPhotoUrl,
        tags: album.tags,
        districtId: album.districtId,
        provinceId: album.provinceId,
        photoCount: album.photos.length
      }
    });
  } catch (error) {
    console.error('Update album error:', error);
    res.status(500).json({ error: 'Failed to update album' });
  }
}

/**
 * Delete an album and all its photos from Firebase Storage
 * DELETE /api/albums/:albumId
 */
async function deleteAlbum(req, res) {
  try {
    const { albumId } = req.params;
    const userId = req.userId;

    const album = await Album.findOne({ _id: albumId, userId });
    if (!album) {
      return res.status(404).json({ error: 'Album not found' });
    }

    // Delete all photos from Firebase Storage
    const bucket = getStorage();
    const deletePromises = album.photos.map(async (photo) => {
      try {
        const file = bucket.file(photo.storagePath);
        await file.delete();
      } catch (err) {
        console.error(`Failed to delete file ${photo.storagePath}:`, err);
      }
    });

    await Promise.all(deletePromises);

    // Delete album from MongoDB
    await Album.deleteOne({ _id: albumId, userId });

    res.status(200).json({ message: 'Album and all photos deleted successfully' });
  } catch (error) {
    console.error('Delete album error:', error);
    res.status(500).json({ error: 'Failed to delete album' });
  }
}

module.exports = {
  createAlbum,
  getAlbums,
  getAlbum,
  updateAlbum,
  deleteAlbum,
  getAlbumStats
};

