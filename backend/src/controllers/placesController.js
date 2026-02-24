const Place = require('../models/Place');

/**
 * Get all places with optional filtering
 * GET /api/places?district=X&category=Y&skip=0&limit=50
 */
async function getPlaces(req, res) {
  try {
    const { district, category, skip = 0, limit = 50 } = req.query;
    const filter = { isActive: true };

    if (district) {
      filter.district = district;
    }

    if (category) {
      filter.category = category;
    }

    const places = await Place.find(filter)
      .skip(Math.max(0, parseInt(skip) || 0))
      .limit(Math.min(100, parseInt(limit) || 50))
      .sort({ createdAt: -1 });

    const total = await Place.countDocuments(filter);

    res.status(200).json({
      places,
      total,
      skip: parseInt(skip) || 0,
      limit: parseInt(limit) || 50,
    });
  } catch (error) {
    console.error('Get places error:', error);
    res.status(500).json({ error: 'Failed to fetch places' });
  }
}

/**
 * Get a single place by ID
 * GET /api/places/:id
 */
async function getPlaceById(req, res) {
  try {
    const { id } = req.params;
    const place = await Place.findById(id);

    if (!place) {
      return res.status(404).json({ error: 'Place not found' });
    }

    res.status(200).json({ place });
  } catch (error) {
    console.error('Get place error:', error);
    res.status(500).json({ error: 'Failed to fetch place' });
  }
}

/**
 * Get places by district (for exploration)
 * GET /api/places/discover/by-district/:district
 */
async function getPlacesByDistrict(req, res) {
  try {
    const { district } = req.params;
    const { limit = 10 } = req.query;

    const places = await Place.find({
      district,
      isActive: true,
    })
      .limit(Math.min(100, parseInt(limit)))
      .sort({ rating: -1 });

    if (places.length === 0) {
      return res.status(404).json({ 
        error: 'No places found for this district',
        district,
      });
    }

    res.status(200).json({
      district,
      places,
      count: places.length,
    });
  } catch (error) {
    console.error('Get places by district error:', error);
    res.status(500).json({ error: 'Failed to fetch places' });
  }
}

/**
 * Search places by name or category
 * GET /api/places/search?q=temple&category=cultural
 */
async function searchPlaces(req, res) {
  try {
    const { q, category, skip = 0, limit = 20 } = req.query;

    if (!q || q.length < 2) {
      return res.status(400).json({ error: 'Search query too short' });
    }

    const filter = { isActive: true };

    // Text search on name and description
    filter.$text = { $search: q };

    if (category) {
      filter.category = category;
    }

    const places = await Place.find(filter)
      .skip(Math.max(0, parseInt(skip)))
      .limit(Math.min(100, parseInt(limit)))
      .sort({ score: { $meta: 'textScore' } });

    const total = await Place.countDocuments(filter);

    res.status(200).json({
      places,
      total,
      query: q,
      skip: parseInt(skip),
      limit: parseInt(limit),
    });
  } catch (error) {
    console.error('Search places error:', error);
    res.status(500).json({ error: 'Failed to search places' });
  }
}

/**
 * Get places near a location (geospatial query)
 * GET /api/places/nearby?latitude=X&longitude=Y&maxDistance=5000
 */
async function getNearbyPlaces(req, res) {
  try {
    const { latitude, longitude, maxDistance = 5000 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ 
        error: 'latitude and longitude are required' 
      });
    }

    const places = await Place.find({
      isActive: true,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(longitude), parseFloat(latitude)],
          },
          $maxDistance: Math.min(50000, parseInt(maxDistance)), // Max 50km
        },
      },
    });

    res.status(200).json({
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      maxDistanceMeters: parseInt(maxDistance),
      places,
      count: places.length,
    });
  } catch (error) {
    console.error('Get nearby places error:', error);
    res.status(500).json({ error: 'Failed to fetch nearby places' });
  }
}

/**
 * Get aggregate statistics about places
 * GET /api/places/stats
 */
async function getPlacesStats(req, res) {
  try {
    const stats = await Place.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: null,
          totalPlaces: { $sum: 1 },
          averageRating: { $avg: '$rating' },
          topCategory: { $push: '$category' },
        },
      },
    ]);

    const districtStats = await Place.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$district',
          count: { $sum: 1 },
          avgRating: { $avg: '$rating' },
        },
      },
      { $sort: { count: -1 } },
    ]);

    const categoryStats = await Place.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 },
          avgRating: { $avg: '$rating' },
        },
      },
      { $sort: { count: -1 } },
    ]);

    res.status(200).json({
      overall: stats[0] || {},
      byDistrict: districtStats,
      byCategory: categoryStats,
    });
  } catch (error) {
    console.error('Get places stats error:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
}

module.exports = {
  getPlaces,
  getPlaceById,
  getPlacesByDistrict,
  searchPlaces,
  getNearbyPlaces,
  getPlacesStats,
};
