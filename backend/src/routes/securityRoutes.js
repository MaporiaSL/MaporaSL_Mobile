const express = require('express');
const router = express.Router();
const { checkJwt, extractUserId } = require('../middleware/auth');
const {
  getSessions,
  logoutAll,
  setup2FA,
  verify2FA,
  disable2FA
} = require('../controllers/securityController');

// All security routes are protected
router.use(checkJwt);
router.use(extractUserId);

router.get('/sessions', getSessions);
router.post('/sessions/logout-all', logoutAll);

router.post('/2fa/setup', setup2FA);
router.post('/2fa/verify', verify2FA);
router.post('/2fa/disable', disable2FA);

module.exports = router;
