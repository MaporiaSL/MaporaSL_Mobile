const express = require('express');
const router = express.Router();
const { getUserProgress, getDistrictProgress, updateProfile, updatePrivacy, updateNotifications, updateDisplay, deleteUser } = require('../controllers/userController');
const { checkJwt, extractUserId } = require('../middleware/auth');

// Apply JWT middleware to all routes
router.use(checkJwt);
router.use(extractUserId);

/**
 * @route   GET /api/users/:userId/progress
 * @desc    Get user's progress (unlocked districts, provinces, achievements)
 * @access  Private (JWT required, must match us   erId)
 */
router.get('/:userId/progress', getUserProgress);

/**
 * @route   GET /api/districts/:districtId/progress
 * @desc    Get progress for a specific district
 * @access  Private (JWT required)
 */
router.get('/districts/:districtId/progress', getDistrictProgress);

/**
 * @route   PUT /api/users/:userId/profile
 * @desc    Update user profile (name, avatar)
 * @access  Private (JWT required)
 */
router.put('/:userId/profile', updateProfile);

/**
 * @route   PUT /api/users/:userId/privacy
 * @desc    Update user privacy and location settings
 * @access  Private (JWT required)
 */
router.put('/:userId/privacy', updatePrivacy);

/**
 * @route   PUT /api/users/:userId/notifications
 * @desc    Update user notification settings
 * @access  Private (JWT required)
 */
router.put('/:userId/notifications', updateNotifications);

/**
 * @route   PUT /api/users/:userId/display
 * @desc    Update user map and display settings
 * @access  Private (JWT required)
 */
router.put('/:userId/display', updateDisplay);

/**
 * @route   DELETE /api/users/:userId
 * @desc    Delete user account and data
 * @access  Private (JWT required)
 */
router.delete('/:userId', deleteUser);

module.exports = router;
