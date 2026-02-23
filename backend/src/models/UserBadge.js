const mongoose = require('mongoose');

const userBadgeSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    badges: [
      {
        name: {
          type: String,
          enum: ['Explorer', 'Local Guide', 'Place Curator', 'Community Legend'],
        },
        icon: String, // Emoji or icon reference
        earnedAt: Date,
        contributionCount: Number, // 1, 5, 10, 20+
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserBadge', userBadgeSchema);
