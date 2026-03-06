const mongoose = require('mongoose');

const visitSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    placeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Place',
      required: true,
      index: true,
    },
    coordinates: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    rejectionReason: {
      type: String,
      enum: ['too_far', 'invalid_coords', null],
      default: null,
    },
    visitedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

// Prevent duplicate visits (user can only visit a place once)
visitSchema.index({ userId: 1, placeId: 1 }, { unique: true });

const Visit = mongoose.model('Visit', visitSchema);

module.exports = Visit;
