const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
  userId: {
    type: String, // Firebase UID
    required: true,
    index: true
  },
  deviceId: {
    type: String,
    required: true
  },
  deviceType: {
    type: String,
    default: 'Mobile'
  },
  ip: {
    type: String,
    default: 'Unknown'
  },
  userAgent: {
    type: String,
    default: 'Unknown'
  },
  lastUsedAt: {
    type: Date,
    default: Date.now
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Update timestamp on use
sessionSchema.methods.touch = function() {
  this.lastUsedAt = Date.now();
  return this.save();
};

module.exports = mongoose.model('Session', sessionSchema);
