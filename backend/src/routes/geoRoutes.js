const express = require('express');
const router = express.Router();
const geoController = require('../controllers/geoController');
const { checkJwt } = require('../middleware/auth');

/**
 * All geo routes require JWT authentication
 */
router.use(checkJwt);

/**
 * @route   GET /api/destinations/nearby
 * @desc    Find destinations near a specific point using geospatial $near query
 * @access  Private (JWT required)
 * @query   lat (number, required) - Latitude of center point
 * @query   lng (number, required) - Longitude of center point
 * @query   radius (number, optional) - Search radius in kilometers (default: 10)
 * @query   travelId (string, optional) - Filter by specific travel
 * @returns Array of destinations with distance and bearing, plus GeoJSON
 * @example /api/destinations/nearby?lat=6.9271&lng=79.8612&radius=50
 */
router.get('/nearby', geoController.findNearbyDestinations);

/**
 * @route   GET /api/destinations/within-bounds
 * @desc    Find destinations within a bounding box using geospatial $geoWithin query
 * @access  Private (JWT required)
 * @query   swLat (number, required) - Southwest corner latitude
 * @query   swLng (number, required) - Southwest corner longitude
 * @query   neLat (number, required) - Northeast corner latitude
 * @query   neLng (number, required) - Northeast corner longitude
 * @query   travelId (string, optional) - Filter by specific travel
 * @returns Array of destinations within bounds, plus GeoJSON
 * @example /api/destinations/within-bounds?swLat=6.0&swLng=79.0&neLat=7.0&neLng=81.0
 */
router.get('/within-bounds', geoController.findDestinationsWithinBounds);

module.exports = router;
