const express = require('express');
const router = express.Router();
const { checkJwt, extractUserId } = require('../middleware/auth');
const { submitFeedback, validateFeedback } = require('../controllers/feedbackController');

// All feedback routes require authentication
router.use(checkJwt);
router.use(extractUserId);

/**
 * @route   POST /api/feedback
 * @desc    Submit user feedback (stored in MongoDB)
 * @access  Private (JWT required)
 */
router.post('/', validateFeedback, submitFeedback);

module.exports = router;
