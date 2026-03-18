const Feedback = require('../models/Feedback');
const { body, validationResult } = require('express-validator');

/**
 * Validation middleware for feedback submission
 */
const validateFeedback = [
  body('subject')
    .trim()
    .notEmpty().withMessage('Subject is required')
    .isLength({ max: 200 }).withMessage('Subject must be at most 200 characters'),
  body('message')
    .trim()
    .notEmpty().withMessage('Message is required')
    .isLength({ max: 2000 }).withMessage('Message must be at most 2000 characters'),
  body('rating')
    .optional({ nullable: true })
    .isInt({ min: 1, max: 5 }).withMessage('Rating must be an integer between 1 and 5'),
];

/**
 * Submit feedback
 * POST /api/feedback
 */
async function submitFeedback(req, res) {
  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const { subject, message, rating } = req.body;

    const feedback = new Feedback({
      userId: req.userId,
      subject,
      message,
      rating: rating || null,
    });

    await feedback.save();

    res.status(201).json({
      message: 'Feedback submitted successfully. Thank you!',
      feedbackId: feedback._id,
    });
  } catch (error) {
    console.error('submitFeedback error:', error);
    res.status(500).json({ error: 'Failed to submit feedback' });
  }
}

module.exports = {
  submitFeedback,
  validateFeedback,
};
