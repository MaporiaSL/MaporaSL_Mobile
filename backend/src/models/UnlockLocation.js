const mongoose = require('mongoose');

const unlockLocationSchema = new mongoose.Schema(
  {
    district: { type: String, required: true, index: true },
    province: { type: String, required: true, index: true },
    name: { type: String, required: true },
    type: { type: String, required: true },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

unlockLocationSchema.index({ district: 1, name: 1 }, { unique: true });

module.exports = mongoose.model('UnlockLocation', unlockLocationSchema);
