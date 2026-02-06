const mongoose = require('mongoose');

const visitedLocationProofSchema = new mongoose.Schema(
  {
    locationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'UnlockLocation',
      required: true,
    },
    visitedAt: { type: Date, required: true },
    accuracyMeters: { type: Number, required: true },
    source: {
      type: String,
      enum: ['gps', 'gps_verified', 'admin_override'],
      required: true,
    },
    adminReason: { type: String, default: null },
  },
  { _id: false }
);

const userDistrictAssignmentSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, index: true },
    district: { type: String, required: true, index: true },
    province: { type: String, required: true, index: true },
    assignedLocationIds: [
      { type: mongoose.Schema.Types.ObjectId, ref: 'UnlockLocation' },
    ],
    visitedLocationIds: [
      { type: mongoose.Schema.Types.ObjectId, ref: 'UnlockLocation' },
    ],
    visitedLocationProofs: [visitedLocationProofSchema],
    assignedCount: { type: Number, default: 0 },
    visitedCount: { type: Number, default: 0 },
    unlockedAt: { type: Date, default: null },
  },
  { timestamps: true }
);

userDistrictAssignmentSchema.index({ userId: 1, district: 1 }, { unique: true });

module.exports = mongoose.model(
  'UserDistrictAssignment',
  userDistrictAssignmentSchema
);
