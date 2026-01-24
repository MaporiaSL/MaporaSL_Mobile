const express = require('express');
const router = express.Router();
const { checkJwt, extractUserId } = require('../middleware/auth');
const { registerUser, getMe, logoutUser } = require('../controllers/authController');

// Public route (called after Auth0 signup/login to sync user)
router.post('/register', registerUser);

// Protected routes
router.get('/me', checkJwt, extractUserId, getMe);
router.post('/logout', checkJwt, extractUserId, logoutUser);

module.exports = router;
