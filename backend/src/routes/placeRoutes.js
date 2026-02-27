const express = require('express');
const {
  getPlaces,
  getPlaceById,
  getPlacesByDistrict,
  searchPlaces,
  getNearbyPlaces,
  getPlacesStats,
} = require('../controllers/placeController');

const router = express.Router();

// GET /api/places - Get all places with pagination
router.get('/', getPlaces);

// GET /api/places/stats - Get places statistics
router.get('/stats', getPlacesStats);

// GET /api/places/search - Search places
router.get('/search', searchPlaces);

// GET /api/places/nearby - Get nearby places
router.get('/nearby', getNearbyPlaces);

// GET /api/places/district/:district - Get places by district
router.get('/district/:district', getPlacesByDistrict);

// GET /api/places/:id - Get single place
router.get('/:id', getPlaceById);

module.exports = router;

