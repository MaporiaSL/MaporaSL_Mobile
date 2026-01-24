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
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true,
      index: '2dsphere'
    }
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

// Geospatial index for location-based queries
destinationSchema.index({ location: '2dsphere' });

// Pre-save hook: Auto-populate location from latitude/longitude
destinationSchema.pre('save', function(next) {
  // Update timestamp
  this.updatedAt = Date.now();
  
  // Auto-populate location.coordinates from latitude/longitude
  if (this.isModified('latitude') || this.isModified('longitude')) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude] // [lng, lat] order!
    };
  }
  
  next();
});

module.exports = mongoose.model('Destination', destinationSchema);
