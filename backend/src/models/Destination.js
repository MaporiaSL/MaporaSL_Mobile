const mongoose = require('mongoose');

const destinationSchema = new mongoose.Schema({

  name: {
    type: String,
    required: true,
    minlength: 2
  },
  description: {
    type: String,
    default: null
  },
  category: {
    type: String,
    default: 'other'
  },
  address: {
    type: String,
    default: null
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
  googleMapsUrl: {
    type: String,
    default: null
  },
  photos: {
    type: [String],
    default: []
  },
  rating: {
    average: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 }
  },
  notes: {
    type: String,
    default: null
  },
  tags: {
    type: [String],
    default: []
  },
  isSystemPlace: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  visited: {
    type: Boolean,
    default: false
  },
  visitedAt: {
    type: Date,
    default: null
  },
  visitCount: {
    type: Number,
    default: 0
  },
  districtId: {
    type: String,
    default: null,
    index: true
  },
  province: {
    type: String,
    default: null
  },
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], required: true, index: '2dsphere' }
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  travelId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Travel',
    required: function () { return !this.isSystemPlace; },
    index: true
  }
});

// Compound indexes for common queries
destinationSchema.index({ userId: 1, travelId: 1 });

// 2dsphere index for geospatial queries
destinationSchema.index({ location: '2dsphere' });

// Update timestamp on save and sync location from lat/lng
destinationSchema.pre('save', function (next) {
  this.updatedAt = Date.now();
  if (this.isModified('latitude') || this.isModified('longitude')) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude]
    };
  }
  next();
});

module.exports = mongoose.model('Destination', destinationSchema);
