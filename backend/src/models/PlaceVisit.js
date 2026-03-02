const mongoose = require('mongoose');

const placeVisitSchema = new mongoose.Schema(
  {
    // References
    placeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Place',
      required: true,
      index: true,
    },
    userId: {
      type: String, // Firebase UID
      required: true,
      index: true,
    },

    // Visit content
    notes: {
      type: String,
      maxlength: 500,
    },
    photoUrl: String,

    // Anti-cheat metadata collected at visit time
    metadata: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
      accuracyMeters: { type: Number, required: true },
      compassHeading: Number,
      pitch: Number,
      roll: Number,
      deviceModel: String,
      osVersion: String,
      lightLevel: Number,
      cellSignalStrength: Number,
      photoExifLat: String,
      photoExifLon: String,
      photoExifTimestamp: String,
      photoExifDatestamp: String,
      collectionTimeMs: { type: Number, required: true },
      isLocationSpoofed: { type: Boolean, default: false },
      sensorProvider: String,
    },

    // Server-side anti-cheat validation results
    validation: {
      isValid: { type: Boolean, default: false },
      status: {
        type: String,
        enum: ['approved', 'suspicious', 'rejected'],
        default: 'suspicious',
      },
      confidence: { type: Number, min: 0, max: 1, default: 0.5 },
      gpsAccuracyValid: Boolean,
      geoFencingValid: Boolean,
      headingValid: Boolean,
      photoExifValid: Boolean,
      deviceSignatureSuspicious: Boolean,
      beingThrottled: Boolean,
      speedValid: Boolean,
      invalidReason: String,
      flaggedReason: String,
      flagSeverity: { type: Number, min: 1, max: 5, default: 1 },
    },

    // Achievement data (populated if achievement unlocked)
    achievementId: mongoose.Schema.Types.ObjectId,
    achievementTitle: String,

    // Trip link (optional, visits are separate from trips)
    tripId: mongoose.Schema.Types.ObjectId,

    // Social features
    likesCount: { type: Number, default: 0 },
    likedBy: [String], // Array of user IDs who liked this visit

    // Server metadata
    ipAddress: String,
    userAgent: String,

    // Server timestamp (authoritative, can't be spoofed)
    visitedAt: { type: Date, default: Date.now, required: true },
  },
  {
    timestamps: true, // Adds createdAt, updatedAt
    indexes: [
      { placeId: 1, visitedAt: -1 },
      { userId: 1, visitedAt: -1 },
      { 'validation.isValid': 1, visitedAt: -1 },
      { userId: 1, placeId: 1 }, // Prevent duplicate visits
    ],
  }
);

// Compound index to prevent duplicate visits within cooldown period
placeVisitSchema.index(
  { userId: 1, placeId: 1, visitedAt: 1 },
  { name: 'rate_limit_index' }
);

// Prevent duplicate visits from same user on same place within 1 hour
placeVisitSchema.pre('save', async function (next) {
  if (this.isNew) {
    const oneHourAgo = new Date(Date.now() - 3600 * 1000);
    const recentVisit = await mongoose.model('PlaceVisit').findOne({
      userId: this.userId,
      placeId: this.placeId,
      visitedAt: { $gte: oneHourAgo },
    });

    if (recentVisit) {
      this.validation.beingThrottled = true;
      this.validation.invalidReason = 'Cannot visit same place more than once per hour';
      this.validation.isValid = false;
    }
  }
  next();
});

module.exports = mongoose.model('PlaceVisit', placeVisitSchema);
