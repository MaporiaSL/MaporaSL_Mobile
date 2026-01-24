const mongoose = require('mongoose');

const destinationSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  travelId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Travel',
    index: true
  },
  name: {
    type: String,
    required: true,
    minlength: 2
  },
  latitude: {
    type: Number,
    required: true,
    min: -90,
    max: 90
  },
  longitude: {
    type: Number,
    required: true,
    min: -180,
    max: 180
  },
  notes: {
    type: String,
    default: null
  },
  visited: {
    type: Boolean,
    default: false
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

// Compound indexes for common queries
destinationSchema.index({ userId: 1, travelId: 1 });

// Update timestamp on save
destinationSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Destination', destinationSchema);
