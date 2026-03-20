const express = require('express');
const router = express.Router();
const { checkJwt, extractUserId } = require('../middleware/auth');
const { registerUser, getMe, logoutUser, deleteAccount } = require('../controllers/authController');

// Protected route (called after Firebase login to sync user)
router.post('/register', checkJwt, extractUserId, registerUser);

// Protected routes
router.get('/me', checkJwt, extractUserId, getMe);
router.post('/logout', checkJwt, extractUserId, logoutUser);
router.delete('/account', checkJwt, extractUserId, deleteAccount);

module.exports = router;
