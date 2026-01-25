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
