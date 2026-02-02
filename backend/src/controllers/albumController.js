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