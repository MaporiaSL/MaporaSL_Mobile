const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  auth0Id: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    index: true
  },
  name: {
    type: String,
    required: true
  },
  profilePicture: {
    type: String,
    default: null
  },
  hometownDistrict: {
    type: String,
    default: null
  },
  explorationUnlockedDistricts: {
    type: [String],
    default: []
  },
  explorationUnlockedProvinces: {
    type: [String],
    default: []
  },
  explorationStats: {
    totalAssigned: { type: Number, default: 0 },
    totalVisited: { type: Number, default: 0 }
  },
  explorationLastUnlockAt: {
    type: Date,
    default: null
  },
  assignmentFixedAt: {
    type: Date,
    default: null
  },
  rerollUsedAt: {
    type: Date,
    default: null
  },
  lastRerollReason: {
    type: String,
    default: null
  },
  lastRerollAt: {
    type: Date,
    default: null
  },
  xpTotal: {
    type: Number,
    default: 0
  },
  xpLedger: [
    {
      timestamp: { type: Date, default: Date.now },
      source: {
        type: String,
        enum: ['mapExploration', 'generalVisit', 'rerollReset'],
        required: true
      },
      amount: { type: Number, required: true },
      location: {
        latitude: { type: Number, default: null },
        longitude: { type: Number, default: null },
        accuracyMeters: { type: Number, default: null }
      },
      locationId: { type: mongoose.Schema.Types.ObjectId, default: null },
      note: { type: String, default: null }
    }
  ],
  // Gamification progress tracking
  unlockedDistricts: {
    type: [String],
    default: []
  },
  unlockedProvinces: {
    type: [String],
    default: []
  },
  achievements: [{
    districtId: { type: String, required: true },
    progress: { type: Number, default: 0 },
    unlockedAt: { type: Date, default: null }
  }],
  totalPlacesVisited: {
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update timestamp on save
userSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('User', userSchema);
