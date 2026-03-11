const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const router = express.Router();
const {
  getUserProfile,
  getUserContributions,
  updateUserProfile,
  logoutUser,
  getTopContributors,
  uploadUserAvatar,
} = require('../controllers/profileController');
const { checkJwt, extractUserId } = require('../middleware/auth');

// Avatar upload storage
const avatarDir = path.join(__dirname, '../../uploads/avatars');
if (!fs.existsSync(avatarDir)) {
  fs.mkdirSync(avatarDir, { recursive: true });
}
const avatarStorage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, avatarDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `avatar-${req.params.userId}-${Date.now()}${ext}`);
  },
});
const avatarUpload = multer({
  storage: avatarStorage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) cb(null, true);
    else cb(new Error('Only image files are allowed'));
  },
});

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
 * @desc    Update user profile (name, avatar URL)
 * @access  Private (JWT required, must match userId)
 */
router.post('/:userId', updateUserProfile);

/**
 * @route   POST /api/profile/:userId/avatar
 * @desc    Upload a profile picture (multipart/form-data, field: avatar)
 * @access  Private (JWT required, must match userId)
 */
router.post('/:userId/avatar', avatarUpload.single('avatar'), uploadUserAvatar);

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
