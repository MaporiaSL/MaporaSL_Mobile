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
    // Advanced anti-cheat metadata (Consolidated from PlaceVisit)
    metadata: {
      accuracyMeters: { type: Number },
      compassHeading: Number,
      pitch: Number,
      roll: Number,
      deviceModel: String,
      osVersion: String,
      isLocationSpoofed: { type: Boolean, default: false },
      verificationTier: { type: String, enum: ['primary', 'failsafe', null], default: null },
      geofenceCategory: String,
      primaryRadius: Number,
      failsafeRadius: Number
    },
    // Server-side validation results
    validation: {
      isValid: { type: Boolean, default: false },
      status: {
        type: String,
        enum: ['approved', 'suspicious', 'rejected'],
        default: 'approved',
      },
      confidence: { type: Number, min: 0, max: 1, default: 1.0 },
      invalidReason: String,
      flaggedReason: String,
      flagSeverity: { type: Number, min: 1, max: 5, default: 1 },
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    reasons: {
      rejectionReason: {
        type: String,
        enum: ['too_far', 'invalid_coords', 'low_accuracy', 'impossible_speed', null],
        default: null,
      },
    },
    notes: {
      type: String,
      maxlength: 500,
    },
    photoUrl: String,
    // Social features
    likesCount: { type: Number, default: 0 },
    likedBy: [String], // Firebase IDs
    visitedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

// Prevent duplicate visits (user can only visit a place once)
visitSchema.index({ userId: 1, placeId: 1 }, { unique: true });
// Geospatial index for analytics
visitSchema.index({ 'coordinates.longitude': 1, 'coordinates.latitude': 1 });

const Visit = mongoose.model('Visit', visitSchema);

module.exports = Visit;
