const mongoose = require('mongoose');

const preplannedTripSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: false,
    default: '',
  },
  district: {
    type: String,
    required: true,
  },
  itinerary: {
    type: mongoose.Schema.Types.Mixed,
    default: {},
  },
  difficulty: {
    type: String,
    enum: ['Easy', 'Moderate', 'Hard'],
    default: 'Moderate',
  },
  durationDays: {
    type: Number,
    required: true,
    min: 1,
  },
  xpReward: {
    type: Number,
    default: 100,
  },
  placeIds: {
    type: [String],
    default: [],
  },
  tags: {
    type: [String],
    default: [],
  },
  startingPoint: {
    type: String,
    default: null,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

preplannedTripSchema.pre('save', function (next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('PrePlannedTrip', preplannedTripSchema);
