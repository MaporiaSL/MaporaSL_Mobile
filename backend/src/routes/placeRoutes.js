const express = require('express');
const { getPlaces, getPlaceById } = require('../controllers/placeController');

const router = express.Router();

// GET /api/places
router.get('/', getPlaces);

// GET /api/places/:id
router.get('/:id', getPlaceById);

module.exports = router;
