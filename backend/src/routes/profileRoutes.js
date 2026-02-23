const express = require('express');
const router = express.Router();
const {
  getUserProfile,
  getUserContributions,
  updateUserProfile,
  logoutUser,
  getTopContributors,
} = require('../controllers/profileController');
const { checkJwt, extractUserId } = require('../middleware/auth');

// Apply JWT middleware to authenticated routes
router.use(checkJwt);
router.use(extractUserId);

/**
 * @route   GET /api/profile/:userId
 * @desc    Get user profile with stats, badges, leaderboard rank, and impact metrics
 * @access  Private (JWT required, must match userId)
 */
router.get('/:userId', getUserProfile);

/**
 * @route   GET /api/profile/:userId/contributions
 * @desc    Get all approved contributed places for a user
 * @access  Private (JWT required, must match userId)
 */
router.get('/:userId/contributions', getUserContributions);

/**
 * @route   POST /api/profile/:userId
 * @desc    Update user profile (name, avatar)
 * @access  Private (JWT required, must match userId)
 */
router.post('/:userId', updateUserProfile);

/**
 * @route   POST /api/auth/logout
 * @desc    Logout user (token invalidation handled on client)
 * @access  Private (JWT required)
 */
router.post('/auth/logout', logoutUser);

// Public route (no auth required)
/**
 * @route   GET /api/profile/leaderboard/top
 * @desc    Get top contributors globally
 * @access  Public
 * @query   limit - number of top contributors to return (default: 10)
 */
router.get('/leaderboard/top', (req, res, next) => {
  // Skip auth middleware for this route
  getTopContributors(req, res);
});

module.exports = router;
