const express = require('express');
const router = express.Router();
const {
  getAssignments,
  getDistricts,
  initializeExploration,
  visitLocation,
  rerollAssignments,
} = require('../controllers/explorationController');
const { checkJwt, extractUserId } = require('../middleware/auth');

router.use(checkJwt);
router.use(extractUserId);

// POST /api/exploration/initialize
router.post('/initialize', initializeExploration);

// GET /api/exploration/assignments
router.get('/assignments', getAssignments);

// GET /api/exploration/districts
router.get('/districts', getDistricts);

// POST /api/exploration/visit
router.post('/visit', visitLocation);

// POST /api/exploration/reroll
router.post('/reroll', rerollAssignments);

module.exports = router;
