const mongoose = require('mongoose');

const placeSubmissionSchema = new mongoose.Schema(
  {
    // Submitter
    userId: {
      type: String,
      required: true,
      index: true,
    },

    // Place info
    placeName: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      minlength: 50,
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
      required: true,
    },

    // Location
    province: {
      type: String,
      required: true,
    },
    district: {
      type: String,
      required: true,
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

    // Photos (min 2 required)
    photos: {
      type: [String], // Firebase Storage URLs
      required: true,
      validate: {
        validator: (v) => v.length >= 2,
        message: 'At least 2 photos are required',
      },
    },

    // Optional metadata
    season: {
      type: String,
      default: 'year-round',
    },
    difficulty: {
      type: String,
      enum: ['easy', 'moderate', 'hard'],
      default: 'moderate',
    },
    entryFee: {
      type: Number,
      default: 0,
    },
    wheelchairAccessible: {
      type: Boolean,
      default: false,
    },
    contact: {
      type: String,
      default: null,
    },

    // Status and review
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending',
      index: true,
    },
    rejectionReason: {
      type: String,
      default: null,
    },
    reviewedBy: {
      type: String, // Admin userId
      default: null,
    },
    reviewedAt: {
      type: Date,
      default: null,
    },

    // Timestamps
    submittedAt: {
      type: Date,
      default: Date.now,
    },
    approvedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);

// Index for querying by userId and status
placeSubmissionSchema.index({ userId: 1, status: 1 });

module.exports = mongoose.model('PlaceSubmission', placeSubmissionSchema);
