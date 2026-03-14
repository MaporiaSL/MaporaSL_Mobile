const express = require('express');
const router = express.Router();
const { getUserProgress, getDistrictProgress } = require('../controllers/userController');
const { getTimeline } = require('../controllers/timelineController');
const { checkJwt, extractUserId } = require('../middleware/auth');

// Apply JWT middleware to all routes
router.use(checkJwt);
router.use(extractUserId);

/**
 * @route   GET /api/users/:userId/progress
 * @desc    Get user's progress (unlocked districts, provinces, achievements)
 * @access  Private (JWT required, must match userId)
 */
router.get('/:userId/progress', getUserProgress);

/**
 * @route   GET /api/districts/:districtId/progress
 * @desc    Get progress for a specific district
 * @access  Private (JWT required)
 */
router.get('/districts/:districtId/progress', getDistrictProgress);

/**
 * @route   GET /api/users/:userId/timeline
 * @desc    Get unified timeline events for a user
 * @access  Private (JWT required, must match userId)
 */
router.get('/:userId/timeline', getTimeline);

module.exports = router;
