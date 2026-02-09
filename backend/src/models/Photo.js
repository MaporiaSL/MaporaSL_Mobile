const mongoose = require('mongoose');

const photoSchema = new mongoose.Schema({
  // Firebase Storage reference path
  storagePath: {
    type: String,
    required: true
  },
  // Public download URL from Firebase
  url: {
    type: String,
    required: true
  },
  originalName: {
    type: String,
    required: true
  },
  // MIME type
  mimeType: {
    type: String,
    required: true
  },
  size: {
    type: Number,
    required: true
  },
  // Optional caption/description
  caption: {
    type: String,
    default: ''
  },
  // Location data 
  location: {
    latitude: { type: Number },
    longitude: { type: Number },
    placeName: { type: String }
  },
  // Reference to destination if linked
  destinationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Destination',
    default: null
  },
  // Reference to travel if linked
  travelId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Travel',
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = { photoSchema };
