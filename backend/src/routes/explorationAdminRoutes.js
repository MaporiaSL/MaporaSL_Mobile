const express = require('express');
const router = express.Router();
const {
  seedUnlockLocations,
  adminOverrideVisit,
} = require('../controllers/explorationController');
const { checkJwt, extractUserId, requireAdmin } = require('../middleware/auth');

router.use(checkJwt);
router.use(extractUserId);
router.use(requireAdmin);

// POST /api/admin/unlock-locations/seed
router.post('/unlock-locations/seed', seedUnlockLocations);

// POST /api/admin/exploration/override
router.post('/exploration/override', adminOverrideVisit);

module.exports = router;
