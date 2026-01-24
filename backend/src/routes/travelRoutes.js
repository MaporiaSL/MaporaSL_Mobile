const express = require('express');
const { validateCreateTravel, validateUpdateTravel } = require('../validators/travelValidator');
const {
  createTravel,
  listTravels,
  getSingleTravel,
  updateTravel,
  deleteTravel
} = require('../controllers/travelController');

const router = express.Router();

// POST /api/travel - Create travel
router.post('/', validateCreateTravel, createTravel);

// GET /api/travel - List travels
router.get('/', listTravels);

// GET /api/travel/:id - Get single travel
router.get('/:id', getSingleTravel);

// PATCH /api/travel/:id - Update travel
router.patch('/:id', validateUpdateTravel, updateTravel);

// DELETE /api/travel/:id - Delete travel
router.delete('/:id', deleteTravel);

module.exports = router;
