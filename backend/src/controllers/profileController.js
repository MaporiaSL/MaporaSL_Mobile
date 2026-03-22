const User = require('../models/User');
const PlaceSubmission = require('../models/PlaceSubmission');
const UserBadge = require('../models/UserBadge');
const PlaceUsageTracking = require('../models/PlaceUsageTracking');
const { getStorage } = require('../config/firebase');
const path = require('path');
const crypto = require('crypto');

const authBypassEnabled = process.env.AUTH_BYPASS === 'true';

function generateAvatarStoragePath(userId, originalName) {
  const ext = path.extname(originalName || '').toLowerCase() || '.jpg';
  const uniqueId = crypto.randomUUID();
  return `users/${userId}/avatars/${uniqueId}${ext}`;
}

/**
 * GET /api/profile/:userId
 * Fetch complete user profile with stats, badges, leaderboard rank, and impact metrics
 * Requires JWT authentication
 */
async function getUserProfile(req, res) {
  try {
    const { userId } = req.params;

    // Verify requesting user matches userId (skipped in bypass mode)
    if (!authBypassEnabled && req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot access another user\'s profile' });
    }

    // Fetch user basic info
    const user = await User.findOne({ auth0Id: userId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Fetch submission stats
    const totalSubmitted = await PlaceSubmission.countDocuments({ userId });
    const approvedCount = await PlaceSubmission.countDocuments({
      userId,
      status: 'approved',
    });
    const approvalRate = totalSubmitted > 0 ? approvedCount / totalSubmitted : 0;

    // Fetch user badges
    const userBadges = await UserBadge.findOne({ userId });
    const badgesList = userBadges ? userBadges.badges : [];

    // Calculate leaderboard rank
    const rankedUsers = await PlaceSubmission.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: '$userId', approvedCount: { $sum: 1 } } },
      { $sort: { approvedCount: -1 } },
    ]);

    let leaderboardRank = null;
    rankedUsers.forEach((u, index) => {
      if (u._id === userId) {
        leaderboardRank = index + 1;
      }
    });

    // Calculate impact metrics (how many users visited their contributed places)
    let impactCount = 0;
    const submittedPlaces = await PlaceSubmission.find({
      userId,
      status: 'approved',
    });

    for (const submission of submittedPlaces) {
      const usage = await PlaceUsageTracking.findOne({ placeId: submission._id });
      if (usage) {
        impactCount += usage.totalTimesAdded;
      }
    }

    // Calculate exploration level and XP
    const xpTotal = user.xpTotal || 0;
    const currentLevel = Math.floor(xpTotal / 100) + 1;
    const xpToNextLevel = (currentLevel * 100) - xpTotal;

    res.status(200).json({
      user: {
        id: user.auth0Id,
        name: user.name,
        email: user.email,
        avatarUrl: user.profilePicture || '',
        bio: user.bio || '',
        hometownDistrict: user.hometownDistrict || '',
        preferredLanguage: user.preferredLanguage || 'English',
        travelInterests: user.travelInterests || [],
      },
      stats: {
        totalSubmitted,
        approvedCount,
        approvalRate: parseFloat((approvalRate * 100).toFixed(2)),
        // Exploration stats
        xpTotal,
        currentLevel,
        xpToNextLevel,
        unlockedDistrictsCount: user.explorationUnlockedDistricts?.length || 0,
        unlockedProvincesCount: user.explorationUnlockedProvinces?.length || 0,
        totalAssigned: user.explorationStats?.totalAssigned || 0,
        totalVisited: user.explorationStats?.totalVisited || 0,
      },
      exploration: {
        unlockedDistricts: user.explorationUnlockedDistricts || [],
        unlockedProvinces: user.explorationUnlockedProvinces || [],
      },
      badges: badgesList,
      leaderboardRank: leaderboardRank || 0,
      impactCount,
    });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ error: 'Failed to retrieve user profile' });
  }
}

/**
 * GET /api/profile/:userId/contributions
 * Fetch all approved contributed places for a user
 * Requires JWT authentication
 */
async function getUserContributions(req, res) {
  try {
    const { userId } = req.params;

    // Verify requesting user matches userId (skipped in bypass mode)
    if (!authBypassEnabled && req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot access another user\'s contributions' });
    }

    // Fetch only approved contributions
    const contributedPlaces = await PlaceSubmission.find(
      { userId, status: 'approved' },
      { placeName: 1, description: 1, approvedAt: 1, status: 1 }
    ).sort({ approvedAt: -1 });

    const contributions = contributedPlaces.map((place) => ({
      id: place._id,
      name: place.placeName,
      description: place.description,
      approved: place.status === 'approved',
      approvedAt: place.approvedAt,
    }));

    res.status(200).json({ contributions });
  } catch (error) {
    console.error('Get user contributions error:', error);
    res.status(500).json({ error: 'Failed to retrieve user contributions' });
  }
}

/**
 * POST /api/profile/:userId
 * Update user profile (name, avatar)
 * Requires JWT authentication
 */
async function updateUserProfile(req, res) {
  try {
    const { userId } = req.params;
    const { name, avatarUrl } = req.body;

    // Verify requesting user matches userId (skipped in bypass mode)
    if (!authBypassEnabled && req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot update another user\'s profile' });
    }

    // Validate input
    if (name && name.trim().length < 2) {
      return res.status(400).json({ error: 'Name must be at least 2 characters' });
    }

    // Update user
    const updatedUser = await User.findOneAndUpdate(
      { auth0Id: userId },
      {
        ...(name && { name: name.trim() }),
        ...(avatarUrl && { profilePicture: avatarUrl }),
      },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Fetch submission stats for the full profile response
    const totalSubmitted = await PlaceSubmission.countDocuments({ userId });
    const approvedCount = await PlaceSubmission.countDocuments({
      userId,
      status: 'approved',
    });
    const approvalRate = totalSubmitted > 0 ? approvedCount / totalSubmitted : 0;

    // Fetch user badges
    const userBadges = await UserBadge.findOne({ userId });
    const badgesList = userBadges ? userBadges.badges : [];

    // Calculate leaderboard rank (consistent with getUserProfile)
    const rankedUsers = await PlaceSubmission.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: '$userId', approvedCount: { $sum: 1 } } },
      { $sort: { approvedCount: -1 } },
    ]);

    let leaderboardRank = null;
    rankedUsers.forEach((u, index) => {
      if (u._id === userId) {
        leaderboardRank = index + 1;
      }
    });

    // Calculate exploration level and XP
    const xpTotal = updatedUser.xpTotal || 0;
    const currentLevel = Math.floor(xpTotal / 100) + 1;
    const xpToNextLevel = (currentLevel * 100) - xpTotal;

    res.status(200).json({
      message: 'Profile updated successfully',
      user: {
        id: updatedUser.auth0Id,
        name: updatedUser.name,
        email: updatedUser.email,
        avatarUrl: updatedUser.profilePicture || '',
        bio: updatedUser.bio || '',
        hometownDistrict: updatedUser.hometownDistrict || '',
        preferredLanguage: updatedUser.preferredLanguage || 'English',
        travelInterests: updatedUser.travelInterests || [],
      },
      stats: {
        totalSubmitted,
        approvedCount,
        approvalRate: parseFloat((approvalRate * 100).toFixed(2)),
        // Exploration stats
        xpTotal,
        currentLevel,
        xpToNextLevel,
        unlockedDistrictsCount: updatedUser.explorationUnlockedDistricts?.length || 0,
        unlockedProvincesCount: updatedUser.explorationUnlockedProvinces?.length || 0,
        totalAssigned: updatedUser.explorationStats?.totalAssigned || 0,
        totalVisited: updatedUser.explorationStats?.totalVisited || 0,
      },
      exploration: {
        unlockedDistricts: updatedUser.explorationUnlockedDistricts || [],
        unlockedProvinces: updatedUser.explorationUnlockedProvinces || [],
      },
      badges: badgesList,
      leaderboardRank: leaderboardRank || 0,
    });
  } catch (error) {
    console.error('Update user profile error:', error);
    res.status(500).json({ error: 'Failed to update user profile' });
  }
}

/**
 * POST /api/auth/logout
 * Logout user (token invalidation handled on client side)
 */
async function logoutUser(req, res) {
  try {
    // In Firebase Auth, the token is invalidated on client side
    // This endpoint can be used for logging/audit purposes if needed
    res.status(200).json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ error: 'Failed to logout' });
  }
}

/**
 * GET /api/profile/leaderboard/top
 * Get top contributors globally (optional, for showing leaderboard)
 * Public endpoint (no auth required)
 */
async function getTopContributors(req, res) {
  try {
    const limit = parseInt(req.query.limit) || 10;

    const topContributors = await PlaceSubmission.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: '$userId', approvedCount: { $sum: 1 } } },
      { $sort: { approvedCount: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: 'auth0Id',
          as: 'userInfo',
        },
      },
      {
        $unwind: '$userInfo',
      },
      {
        $project: {
          _id: 0,
          userId: '$_id',
          userName: '$userInfo.name',
          approvedCount: 1,
          profilePicture: '$userInfo.profilePicture',
        },
      },
    ]);

    res.status(200).json({ topContributors });
  } catch (error) {
    console.error('Get top contributors error:', error);
    res.status(500).json({ error: 'Failed to retrieve leaderboard' });
  }
}

/**
 * POST /api/profile/:userId/avatar
 * Upload a profile picture file for a user
 * Requires JWT authentication + multipart/form-data with field 'avatar'
 */
async function uploadUserAvatar(req, res) {
  try {
    const { userId } = req.params;

    if (!authBypassEnabled && req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot update another user\'s avatar' });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'No avatar file provided' });
    }

    if (!req.file?.buffer) {
      return res.status(400).json({ error: 'Invalid file upload' });
    }

    const storagePath = generateAvatarStoragePath(userId, req.file.originalname);
    const bucket = getStorage();
    const file = bucket.file(storagePath);

    await file.save(req.file.buffer, {
      metadata: {
        contentType: req.file.mimetype,
        metadata: {
          originalName: req.file.originalname,
          uploadedBy: userId,
          uploadType: 'profile-avatar',
        },
      },
    });

    // Make the avatar publicly accessible for mobile profile rendering.
    // Use try-catch because many modern Firebase projects have Uniform Bucket-Level Access (UBLA) 
    // enabled, which prevents ACL-based makePublic() calls from working.
    try {
      await file.makePublic();
    } catch (publicError) {
      console.warn('makePublic failed (possibly UBLA is enabled):', publicError.message);
      // We proceed anyway; if the bucket has public read access, the URL will still work.
    }

    // Use the official Firebase Storage public URL format which is more reliable across platforms
    const avatarUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(storagePath)}?alt=media`;

    const updatedUser = await User.findOneAndUpdate(
      { auth0Id: userId },
      { profilePicture: avatarUrl },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json({
      message: 'Avatar uploaded successfully',
      avatarUrl,
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({ error: 'Failed to upload avatar' });
  }
}

module.exports = {
  getUserProfile,
  getUserContributions,
  updateUserProfile,
  logoutUser,
  getTopContributors,
  uploadUserAvatar,
};
