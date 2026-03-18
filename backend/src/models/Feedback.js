const mongoose = require('mongoose');

/**
 * Feedback model for storing in-app user feedback submissions.
 * Linked to a userId (Firebase auth0Id) for basic attribution.
 */
const feedbackSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true,
  },
  subject: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200,
  },
  message: {
    type: String,
    required: true,
    trim: true,
    maxlength: 2000,
  },
  rating: {
    type: Number,
    min: 1,
    max: 5,
    default: null,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Feedback', feedbackSchema);
