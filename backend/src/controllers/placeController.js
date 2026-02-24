const Destination = require('../models/Destination');
const Place = require('../models/Place');

// Get all system places with pagination and filtering
exports.getPlaces = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      category,
      province,
      district,
      source,
    } = req.query;

    let places = [];
    let total = 0;

    // Try to get from the new Place model first
    const query = { isActive: true };

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    if (category) query.category = category;
    if (province) query.province = province;
    if (district) query.district = { $regex: district, $options: 'i' };
    if (source) query.source = source;

    console.log(
      `[PlacesAPI] Search: "${search || ''}", Query: ${JSON.stringify(query)}`
    );

    places = await Place.find(query)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ rating: -1, createdAt: -1 });

    total = await Place.countDocuments(query);

    // If no places in new collection, try old Destination collection
    if (total === 0) {
      const oldQuery = { isSystemPlace: true };

      if (search) {
        oldQuery.$or = [
          { name: { $regex: `^${search}`, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
        ];
      }

      if (category) oldQuery.category = category;
      if (province) oldQuery.province = province;
      if (district) oldQuery.districtId = { $regex: district, $options: 'i' };

      places = await Destination.find(oldQuery)
        .limit(limit * 1)
        .skip((page - 1) * limit)
        .sort({ visitCount: -1, rating: -1 });

      total = await Destination.countDocuments(oldQuery);
    }

    res.status(200).json({
      places,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      totalPlaces: total,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get single place by ID
exports.getPlaceById = async (req, res) => {
  try {
    let place = await Place.findById(req.params.id);

    if (!place) {
      place = await Destination.findById(req.params.id);
    }

    if (!place) {
      return res.status(404).json({ message: 'Place not found' });
    }

    res.status(200).json(place);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get places by district (for exploration and discovery)
exports.getPlacesByDistrict = async (req, res) => {
  try {
    const { district } = req.params;
    const { limit = 10 } = req.query;

    let places = await Place.find({
      district,
      isActive: true,
    })
      .limit(Math.min(100, parseInt(limit)))
      .sort({ rating: -1 });

    // Fallback to old system
    if (places.length === 0) {
      places = await Destination.find({
        districtId: { $regex: district, $options: 'i' },
        isSystemPlace: true,
      })
        .limit(Math.min(100, parseInt(limit)))
        .sort({ visitCount: -1, rating: -1 });
    }

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
};

// Search places by name or category
exports.searchPlaces = async (req, res) => {
  try {
    const { q, category, skip = 0, limit = 20 } = req.query;

    if (!q || q.length < 2) {
      return res.status(400).json({ error: 'Search query too short' });
    }

    const filter = { isActive: true };

    filter.$or = [
      { name: { $regex: q, $options: 'i' } },
      { description: { $regex: q, $options: 'i' } },
    ];

    if (category) {
      filter.category = category;
    }

    const places = await Place.find(filter)
      .skip(Math.max(0, parseInt(skip)))
      .limit(Math.min(100, parseInt(limit)))
      .sort({ rating: -1 });

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
};

// Get nearby places using geospatial query
exports.getNearbyPlaces = async (req, res) => {
  try {
    const { latitude, longitude, maxDistance = 5000 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({
        error: 'latitude and longitude are required',
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
          $maxDistance: Math.min(50000, parseInt(maxDistance)),
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
};

// Get aggregate statistics about places
exports.getPlacesStats = async (req, res) => {
  try {
    const stats = await Place.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: null,
          totalPlaces: { $sum: 1 },
          averageRating: { $avg: '$rating' },
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
};

