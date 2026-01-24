const express = require('express');
const { validateCreateDestination, validateUpdateDestination } = require('../validators/destinationValidator');
const {
  createDestination,
  listDestinations,
  getSingleDestination,
  updateDestination,
  deleteDestination
} = require('../controllers/destinationController');

const router = express.Router({ mergeParams: true });

// POST /api/travel/:travelId/destinations - Create destination
router.post('/', validateCreateDestination, createDestination);

// GET /api/travel/:travelId/destinations - List destinations
router.get('/', listDestinations);

// GET /api/travel/:travelId/destinations/:destId - Get single destination
router.get('/:destId', getSingleDestination);

// PATCH /api/travel/:travelId/destinations/:destId - Update destination
router.patch('/:destId', validateUpdateDestination, updateDestination);

// DELETE /api/travel/:travelId/destinations/:destId - Delete destination
router.delete('/:destId', deleteDestination);

module.exports = router;
