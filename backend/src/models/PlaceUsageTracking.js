const mongoose = require('mongoose');

const placeUsageTrackingSchema = new mongoose.Schema(
  {
    placeId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    totalTimesAdded: {
      type: Number,
      default: 0,
    },
    usersWhoAdded: [
      {
        userId: String,
        addedAt: Date,
      },
    ],
    lastUsedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('PlaceUsageTracking', placeUsageTrackingSchema);
