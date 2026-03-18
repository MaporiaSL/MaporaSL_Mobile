const User = require('../models/User');
const PlaceSubmission = require('../models/PlaceSubmission');
const UserBadge = require('../models/UserBadge');
const PlaceUsageTracking = require('../models/PlaceUsageTracking');
const { getStorage } = require('../config/firebase');
const path = require('path');
const crypto = require('crypto');

const MAX_NAME_LENGTH = 40;
const MAX_BIO_LENGTH = 200;
const MAX_DISTRICT_LENGTH = 60;
const MAX_LANGUAGE_LENGTH = 30;
const MAX_INTERESTS = 10;

function toTitleCase(value) {
  return value
    .toLowerCase()
    .split(' ')
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function sanitizePreferredLanguage(rawValue) {
  const normalized = String(rawValue || '').trim().toLowerCase();
  const supported = {
    english: 'English',
    sinhala: 'Sinhala',
    tamil: 'Tamil',
  };
  return supported[normalized] || 'English';
}

function sanitizeTravelInterests(rawInterests) {
  if (!Array.isArray(rawInterests)) return [];

  const dedup = new Map();
  for (const interest of rawInterests) {
    const trimmed = String(interest || '').trim();
    if (!trimmed) continue;
    const normalized = toTitleCase(trimmed).slice(0, 30);
    const key = normalized.toLowerCase();
    if (!dedup.has(key)) {
      dedup.set(key, normalized);
    }
    if (dedup.size >= MAX_INTERESTS) break;
  }
  return Array.from(dedup.values());
}

function sanitizeProfileUpdateInput(payload) {
  const {
    name,
    avatarUrl,
    bio,
    hometownDistrict,
    preferredLanguage,
    travelInterests,
  } = payload;

  if (name != null) {
    const trimmedName = String(name).trim();
    if (trimmedName.length < 2) {
      return { error: 'Name must be at least 2 characters' };
    }
    if (trimmedName.length > MAX_NAME_LENGTH) {
      return { error: `Name must be under ${MAX_NAME_LENGTH} characters` };
    }
  }

  if (bio != null && String(bio).trim().length > MAX_BIO_LENGTH) {
    return { error: `Bio must be under ${MAX_BIO_LENGTH} characters` };
  }

  if (hometownDistrict != null && String(hometownDistrict).trim().length > MAX_DISTRICT_LENGTH) {
    return { error: `District must be under ${MAX_DISTRICT_LENGTH} characters` };
  }

  if (preferredLanguage != null && String(preferredLanguage).trim().length > MAX_LANGUAGE_LENGTH) {
    return { error: `Preferred language must be under ${MAX_LANGUAGE_LENGTH} characters` };
  }

  if (travelInterests != null && !Array.isArray(travelInterests)) {
    return { error: 'travelInterests must be a list of strings' };
  }

  if (Array.isArray(travelInterests) && travelInterests.length > MAX_INTERESTS * 3) {
    return { error: `Too many interests provided. Limit request size before save.` };
  }

  const updateDoc = {
    ...(name != null && { name: String(name).trim() }),
    ...(avatarUrl != null && { profilePicture: String(avatarUrl).trim() }),
    ...(bio != null && { bio: String(bio).trim().slice(0, MAX_BIO_LENGTH) }),
    ...(hometownDistrict != null && {
      hometownDistrict: toTitleCase(String(hometownDistrict).trim()).slice(0, MAX_DISTRICT_LENGTH),
    }),
    ...(preferredLanguage != null && {
      preferredLanguage: sanitizePreferredLanguage(preferredLanguage),
    }),
    ...(travelInterests != null && {
      travelInterests: sanitizeTravelInterests(travelInterests),
    }),
  };

  return { updateDoc };
}

async function buildProfileResponse(userId, userDoc) {
  const user = userDoc || await User.findOne({ auth0Id: userId });
  if (!user) return null;

  const totalSubmitted = await PlaceSubmission.countDocuments({ userId });
  const approvedCount = await PlaceSubmission.countDocuments({
    userId,
    status: 'approved',
  });
  const approvalRate = totalSubmitted > 0 ? approvedCount / totalSubmitted : 0;

  const userBadges = await UserBadge.findOne({ userId });
  const badgesList = userBadges ? userBadges.badges : [];

  const rankedUsers = await PlaceSubmission.aggregate([
    { $match: { status: 'approved' } },
    { $group: { _id: '$userId', approvedCount: { $sum: 1 } } },
    { $sort: { approvedCount: -1 } },
  ]);

  let leaderboardRank = 0;
  rankedUsers.forEach((u, index) => {
    if (u._id === userId) {
      leaderboardRank = index + 1;
    }
  });

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

  return {
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
    },
    badges: badgesList,
    leaderboardRank,
    impactCount,
  };
}

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

    // Verify requesting user matches userId
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot access another user\'s profile' });
    }

    const responseBody = await buildProfileResponse(userId);
    if (!responseBody) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json(responseBody);
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

    // Verify requesting user matches userId
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot access another user\'s contributions' });
    }

    // Fetch all contribution statuses for full profile history
    const contributedPlaces = await PlaceSubmission.find(
      { userId },
      { placeName: 1, description: 1, approvedAt: 1, submittedAt: 1, reviewedAt: 1, status: 1, rejectionReason: 1, photos: 1 }
    ).sort({ submittedAt: -1 });

    const contributions = contributedPlaces.map((place) => ({
      id: place._id,
      name: place.placeName,
      description: place.description,
      approved: place.status === 'approved',
      status: place.status,
      submittedAt: place.submittedAt,
      reviewedAt: place.reviewedAt,
      approvedAt: place.approvedAt,
      rejectionReason: place.rejectionReason,
      photoUrl: Array.isArray(place.photos) && place.photos.length > 0 ? place.photos[0] : '',
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
    const payload = req.body || {};

    // Verify requesting user matches userId
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot update another user\'s profile' });
    }

    const { error: validationError, updateDoc } = sanitizeProfileUpdateInput(payload);
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    // Update user
    const updatedUser = await User.findOneAndUpdate(
      { auth0Id: userId },
      updateDoc,
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    const responseBody = await buildProfileResponse(userId, updatedUser);
    if (!responseBody) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json({
      message: 'Profile updated successfully',
      ...responseBody,
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

    if (req.userId !== userId) {
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
    await file.makePublic();
    const avatarUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;

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
