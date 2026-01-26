const express = require('express');
const { checkJwt, extractUserId } = require('../middleware/auth');
const {
  getPreplannedTrips,
  getPreplannedTripById,
  cloneTemplate,
} = require('../controllers/preplannedTripsController');

const router = express.Router();

// GET /api/preplanned-trips - List all pre-planned trip templates
router.get('/', getPreplannedTrips);

// GET /api/preplanned/:id - Get single pre-planned template
router.get('/:id', getPreplannedTripById);

// POST /api/preplanned/:id/clone - Clone template into user's travel
router.post('/:id/clone', checkJwt, extractUserId, cloneTemplate);

module.exports = router;
