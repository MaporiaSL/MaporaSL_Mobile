const mongoose = require('mongoose');

const placeSchema = new mongoose.Schema(
  {
    // Basic info
    name: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    description: {
      type: String,
      default: null,
    },
    category: {
      type: String,
      enum: [
        'temple',
        'beach',
        'mountain',
        'historical',
        'wildlife',
        'city',
        'food',
        'waterfall',
        'garden',
        'cultural',
        'adventure',
        'other',
      ],
      default: 'other',
      index: true,
    },

    // Location
    district: {
      type: String,
      required: true,
      index: true,
    },
    province: {
      type: String,
      required: true,
      index: true,
    },
    address: {
      type: String,
      default: null,
    },
    latitude: {
      type: Number,
      required: true,
      min: -90,
      max: 90,
    },
    longitude: {
      type: Number,
      required: true,
      min: -180,
      max: 180,
    },
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], index: '2dsphere' }, // [longitude, latitude]
    },

    // Metadata
    googleMapsUrl: {
      type: String,
      default: null,
    },
    type: {
      type: String,
      default: 'attraction',
    },

    // Photos
    photos: {
      type: [String], // URLs
      default: [],
    },

    // Community feedback
    rating: {
      type: Number,
      min: 0,
      max: 5,
      default: 0,
    },
    reviewCount: {
      type: Number,
      default: 0,
    },

    // Source info
    source: {
      type: String,
      enum: ['system', 'user-contributed', 'migrated'],
      default: 'system',
    },
    contributor: {
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null,
      },
      username: {
        type: String,
        default: null,
      },
    },
    verified: {
      type: Boolean,
      default: false,
    },

    // Availability
    isActive: {
      type: Boolean,
      default: true,
      index: true,
    },
    seasonality: {
      type: String,
      enum: ['year-round', 'seasonal', 'wet-season', 'dry-season'],
      default: 'year-round',
    },
    accessibility: {
      difficulty: {
        type: String,
        enum: ['easy', 'moderate', 'difficult'],
        default: 'easy',
      },
      estimatedDuration: String, // e.g., "2-3 hours"
      entryFee: String, // e.g., "1000 LKR" or "Free"
    },

    // Tags for filtering
    tags: {
      type: [String],
      default: [],
    },

    // Tracking
    createdAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
    updatedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

// Compound index for district + active status
placeSchema.index({ district: 1, isActive: 1 });
placeSchema.index({ province: 1, isActive: 1 });
placeSchema.index({ category: 1, district: 1 });

module.exports = mongoose.model('Place', placeSchema);
