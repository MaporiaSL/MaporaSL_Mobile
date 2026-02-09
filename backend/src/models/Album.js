const { photoSchema } = require('./Photo');

const mongoose = require('mongoose');

const albumSchema = new mongoose.Schema({
  // User who owns this album
  userId: {
    type: String,
    required: true,
    index: true
  },
  // Album name
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  coverPhotoUrl: {
    type: String,
    default: null
  },
  // Photos in this album
  photos: [photoSchema],
  // Album tags for organization
  tags: {
    type: [String],
    default: []
  },
  // District association (for gamification)
  districtId: {
    type: String,
    default: null
  },
  // Province association
  provinceId: {
    type: String,
    default: null
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
albumSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Index for efficient queries
albumSchema.index({ userId: 1, createdAt: -1 });
albumSchema.index({ userId: 1, districtId: 1 });

module.exports = mongoose.model('Album', albumSchema);