const mongoose = require('mongoose');

const placeAchievementSchema = new mongoose.Schema(
  {
    userId: {
      type: String, // Firebase UID
      required: true,
      index: true,
    },

    // Achievement definition
    title: {
      type: String,
      required: true,
      enum: [
        'Temple Explorer',
        'Beach Bum',
        'Mountain Climber',
        'Historic Hunter',
        'Wildlife Watcher',
        'All Districts',
        'Prolific Visitor',
        'Photo Collector',
        'Social Butterfly',
        'Master Traveler',
      ],
    },
    description: String,
    badgeEmoji: String,
    category: {
      type: String,
      enum: [
        'temples',
        'beaches',
        'mountains',
        'historical',
        'wildlife',
        'all_districts',
        'visit_count',
        'photos',
        'social',
        'overall',
      ],
    },

    // Progress tracking
    threshold: { type: Number, required: true }, // e.g., 10 (visit 10 temples)
    currentProgress: { type: Number, default: 0 },
    isUnlocked: { type: Boolean, default: false },
    unlockedAt: Date,

    // Rewards
    rewards: {
      points: { type: Number, default: 100 },
      coins: { type: Number, default: 50 },
      badgeIconUrl: String,
    },

    // Notification tracking
    notificationSent: { type: Boolean, default: false },
  },
  {
    timestamps: true,
    indexes: [
      { userId: 1, title: 1 }, // Unique per user per achievement type
      { isUnlocked: 1, unlockedAt: -1 },
    ],
  }
);

// Compound unique index - user can only have one of each achievement type
placeAchievementSchema.index({ userId: 1, title: 1 }, { unique: true });

// Pre-save hook to auto-calculate if achievement should be unlocked
placeAchievementSchema.pre('save', function (next) {
  // If currentProgress >= threshold, mark as unlocked
  if (this.currentProgress >= this.threshold && !this.isUnlocked) {
    this.isUnlocked = true;
    this.unlockedAt = new Date();
  }
  next();
});

module.exports = mongoose.model('PlaceAchievement', placeAchievementSchema);
