const express = require('express');
const router = express.Router();
const visitController = require('../controllers/visitController');
const { checkJwt, extractUserId } = require('../middleware/auth');

router.post('/mark', checkJwt, extractUserId, visitController.markVisit);
router.get('/my-visits', checkJwt, extractUserId, visitController.getUserVisits);

module.exports = router;
