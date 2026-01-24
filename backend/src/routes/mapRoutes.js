const express = require('express');
const router = express.Router();
const mapController = require('../controllers/mapController');
const { checkJwt } = require('../middleware/auth');

/**
 * All map routes require JWT authentication
 */
router.use(checkJwt);

/**
 * @route   GET /api/travel/:travelId/geojson
 * @desc    Get complete GeoJSON representation of a travel with all destinations
 * @access  Private (JWT required)
 * @query   includeRoute (boolean, default: true) - Include route LineString
 * @query   includeBoundary (boolean, default: true) - Include boundary Polygon
 * @query   lightweight (boolean, default: false) - Minimal properties only
 */
router.get('/:travelId/geojson', mapController.getTravelGeoJSON);

/**
 * @route   GET /api/travel/:travelId/boundary
 * @desc    Get convex hull boundary polygon for all destinations in a travel
 * @access  Private (JWT required)
 * @returns GeoJSON Polygon Feature with area metadata
 */
router.get('/:travelId/boundary', mapController.getTravelBoundary);

/**
 * @route   GET /api/travel/:travelId/terrain
 * @desc    Get terrain/elevation data for destinations in a travel
 * @access  Private (JWT required)
 * @note    Placeholder endpoint - requires elevation API integration
 */
router.get('/:travelId/terrain', mapController.getTravelTerrain);

/**
 * @route   GET /api/travel/:travelId/stats
 * @desc    Get comprehensive statistics for a travel
 * @access  Private (JWT required)
 * @returns Distance, area, completion percentage, photo counts, timeline
 */
router.get('/:travelId/stats', mapController.getTravelStats);

module.exports = router;
