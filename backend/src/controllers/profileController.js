const User = require('../models/User');
const PlaceSubmission = require('../models/PlaceSubmission');
const UserBadge = require('../models/UserBadge');
const PlaceUsageTracking = require('../models/PlaceUsageTracking');
const { getStorage } = require('../config/firebase');
const { PROFILE_VALIDATION, ACCOUNT_DELETION_POLICY } = require('../config/profileValidation');
const path = require('path');
const crypto = require('crypto');

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
  const supported = new Map(
    PROFILE_VALIDATION.SUPPORTED_LANGUAGES.map((lang) => [
      lang.toLowerCase(),
      lang,
    ])
  );
  return supported.get(normalized) || PROFILE_VALIDATION.SUPPORTED_LANGUAGES[0];
}

function sanitizeTravelInterests(rawInterests) {
  if (!Array.isArray(rawInterests)) return [];

  const dedup = new Map();
  for (const interest of rawInterests) {
    const trimmed = String(interest || '').trim();
    if (!trimmed) continue;
    const normalized = toTitleCase(trimmed).slice(0, PROFILE_VALIDATION.MAX_INTEREST_LABEL_LENGTH);
    const key = normalized.toLowerCase();
    if (!dedup.has(key)) {
      dedup.set(key, normalized);
    }
    if (dedup.size >= PROFILE_VALIDATION.MAX_INTERESTS) break;
  }
  return Array.from(dedup.values());
}

function isUserMinimumProfileComplete(user) {
  const hasName = String(user?.name || '').trim().length >= 2;
  const hasDistrict = String(user?.hometownDistrict || '').trim().length > 0;
  const hasLanguage = String(user?.preferredLanguage || '').trim().length > 0;
  return hasName && hasDistrict && hasLanguage;
}

function sanitizeProfileUpdateInput(payload) {
  const {
    name,
    avatarUrl,
    bio,
    hometownDistrict,
    preferredLanguage,
    travelInterests,
    completeSetup,
  } = payload;

  const fieldErrors = {};

  if (name != null) {
    const trimmedName = String(name).trim();
    if (trimmedName.length < PROFILE_VALIDATION.MIN_NAME_LENGTH) {
      fieldErrors.name = 'Name must be at least 2 characters';
    }
    if (trimmedName.length > PROFILE_VALIDATION.MAX_NAME_LENGTH) {
      fieldErrors.name = `Name must be under ${PROFILE_VALIDATION.MAX_NAME_LENGTH} characters`;
    }
  }

  if (bio != null && String(bio).trim().length > PROFILE_VALIDATION.MAX_BIO_LENGTH) {
    fieldErrors.bio = `Bio must be under ${PROFILE_VALIDATION.MAX_BIO_LENGTH} characters`;
  }

  if (
    hometownDistrict != null &&
    String(hometownDistrict).trim().length > PROFILE_VALIDATION.MAX_DISTRICT_LENGTH
  ) {
    fieldErrors.hometownDistrict = `District must be under ${PROFILE_VALIDATION.MAX_DISTRICT_LENGTH} characters`;
  }

  if (
    preferredLanguage != null &&
    String(preferredLanguage).trim().length > PROFILE_VALIDATION.MAX_LANGUAGE_LENGTH
  ) {
    fieldErrors.preferredLanguage = `Preferred language must be under ${PROFILE_VALIDATION.MAX_LANGUAGE_LENGTH} characters`;
  }

  if (travelInterests != null && !Array.isArray(travelInterests)) {
    fieldErrors.travelInterests = 'travelInterests must be a list of strings';
  }

  if (
    Array.isArray(travelInterests) &&
    travelInterests.length > PROFILE_VALIDATION.MAX_INTERESTS * 3
  ) {
    fieldErrors.travelInterests = 'Too many interests provided. Limit request size before save.';
  }

  if (Object.keys(fieldErrors).length > 0) {
    return {
      error: 'Invalid profile payload',
      fieldErrors,
    };
  }

  const updateDoc = {
    ...(name != null && { name: String(name).trim() }),
    ...(avatarUrl != null && { profilePicture: String(avatarUrl).trim() }),
    ...(bio != null && {
      bio: String(bio).trim().slice(0, PROFILE_VALIDATION.MAX_BIO_LENGTH),
    }),
    ...(hometownDistrict != null && {
      hometownDistrict: toTitleCase(String(hometownDistrict).trim()).slice(
        0,
        PROFILE_VALIDATION.MAX_DISTRICT_LENGTH
      ),
    }),
    ...(preferredLanguage != null && {
      preferredLanguage: sanitizePreferredLanguage(preferredLanguage),
    }),
    ...(travelInterests != null && {
      travelInterests: sanitizeTravelInterests(travelInterests),
    }),
  };

  if (completeSetup != null) {
    updateDoc.profileSetupCompleted = Boolean(completeSetup);
    updateDoc.profileSetupCompletedAt = Boolean(completeSetup) ? new Date() : null;
  }

  return { updateDoc };
}

async function buildProfileResponse(userId, userDoc) {
  const user = userDoc || await User.findOne({ auth0Id: userId });
  if (!user) return null;

  const unlockedDistrictsCount = Math.max(
    Array.isArray(user.unlockedDistricts) ? user.unlockedDistricts.length : 0,
    Array.isArray(user.explorationUnlockedDistricts)
      ? user.explorationUnlockedDistricts.length
      : 0
  );
  const unlockedProvincesCount = Math.max(
    Array.isArray(user.unlockedProvinces) ? user.unlockedProvinces.length : 0,
    Array.isArray(user.explorationUnlockedProvinces)
      ? user.explorationUnlockedProvinces.length
      : 0
  );
  const totalPlacesVisited = Number.isFinite(user.totalPlacesVisited)
    ? user.totalPlacesVisited
    : Number(user?.explorationStats?.totalVisited || 0);

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
      unlockedDistrictsCount,
      unlockedProvincesCount,
      totalPlacesVisited,
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

function extractStoragePathFromPublicUrl(url, bucketName) {
  const raw = String(url || '').trim();
  if (!raw || !bucketName) return null;

  const prefix = `https://storage.googleapis.com/${bucketName}/`;
  if (!raw.startsWith(prefix)) return null;

  const remainder = raw.slice(prefix.length);
  if (!remainder) return null;
  return decodeURIComponent(remainder.split('?')[0]);
}

async function safeDeleteAvatarFromStorage(avatarUrl) {
  try {
    if (!avatarUrl) return;
    const bucket = getStorage();
    const storagePath = extractStoragePathFromPublicUrl(avatarUrl, bucket.name);
    if (!storagePath) return;

    await bucket.file(storagePath).delete({ ignoreNotFound: true });
  } catch (error) {
    // Best-effort cleanup: profile updates should not fail because of stale file deletion issues.
    console.warn('Avatar cleanup warning:', error.message);
  }
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
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const requestedLimit = parseInt(req.query.limit, 10) || 20;
    const limit = Math.min(Math.max(requestedLimit, 1), 50);
    const skip = (page - 1) * limit;

    // Verify requesting user matches userId
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot access another user\'s contributions' });
    }

    const total = await PlaceSubmission.countDocuments({ userId });

    // Fetch paginated contribution history ordered by most recent submission.
    const contributedPlaces = await PlaceSubmission.find(
      { userId },
      {
        placeName: 1,
        description: 1,
        approvedAt: 1,
        submittedAt: 1,
        reviewedAt: 1,
        status: 1,
        rejectionReason: 1,
        photos: 1,
        promotedPlaceId: 1,
      }
    )
      .sort({ submittedAt: -1 })
      .skip(skip)
      .limit(limit);

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
      photoUrls: Array.isArray(place.photos) ? place.photos : [],
      promotedPlaceId: place.promotedPlaceId || null,
    }));

    res.status(200).json({
      contributions,
      page,
      limit,
      total,
      hasMore: skip + contributions.length < total,
    });
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

    const { error: validationError, fieldErrors, updateDoc } = sanitizeProfileUpdateInput(payload);
    if (validationError) {
      return res.status(400).json({
        error: validationError,
        ...(fieldErrors ? { fieldErrors } : {}),
      });
    }

    const existingUser = await User.findOne({ auth0Id: userId });
    if (!existingUser) {
      return res.status(404).json({ error: 'User not found' });
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

    // If avatar is explicitly cleared, delete prior stored avatar as best-effort cleanup.
    if (
      Object.prototype.hasOwnProperty.call(updateDoc, 'profilePicture') &&
      updateDoc.profilePicture === '' &&
      existingUser.profilePicture
    ) {
      await safeDeleteAvatarFromStorage(existingUser.profilePicture);
    }

    if (payload.completeSetup === true) {
      const merged = {
        ...updatedUser.toObject(),
        ...updateDoc,
      };
      const missing = {};
      if (String(merged.name || '').trim().length < 2) {
        missing.name = 'Name is required';
      }
      if (String(merged.hometownDistrict || '').trim() === '') {
        missing.hometownDistrict = 'District is required';
      }
      if (String(merged.preferredLanguage || '').trim() === '') {
        missing.preferredLanguage = 'Preferred language is required';
      }

      if (Object.keys(missing).length > 0) {
        return res.status(400).json({
          error: 'Profile setup is incomplete',
          fieldErrors: missing,
          requiredFields: ['name', 'hometownDistrict', 'preferredLanguage'],
          optionalFields: ['travelInterests', 'avatarUrl', 'bio'],
        });
      }

      if (!updatedUser.profileSetupCompleted || !isUserMinimumProfileComplete(updatedUser)) {
        updatedUser.profileSetupCompleted = true;
        updatedUser.profileSetupCompletedAt = new Date();
        await updatedUser.save();
      }
    }

    const responseBody = await buildProfileResponse(userId, updatedUser);
    if (!responseBody) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json({
      message: 'Profile updated successfully',
      ...responseBody,
      requiredFields: ['name', 'hometownDistrict', 'preferredLanguage'],
      optionalFields: ['travelInterests', 'avatarUrl', 'bio'],
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
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const requestedLimit = parseInt(req.query.limit, 10) || 10;
    const limit = Math.min(Math.max(requestedLimit, 1), 50);
    const skip = (page - 1) * limit;

    const totalResults = await PlaceSubmission.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: '$userId' } },
      { $count: 'total' },
    ]);
    const total = totalResults[0]?.total || 0;

    const topContributors = await PlaceSubmission.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: '$userId', approvedCount: { $sum: 1 } } },
      { $sort: { approvedCount: -1 } },
      { $skip: skip },
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

    res.status(200).json({
      topContributors,
      page,
      limit,
      total,
      hasMore: skip + topContributors.length < total,
    });
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

    const existingUser = await User.findOne({ auth0Id: userId });
    const previousAvatarUrl = existingUser?.profilePicture || '';

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

    if (previousAvatarUrl && previousAvatarUrl !== avatarUrl) {
      await safeDeleteAvatarFromStorage(previousAvatarUrl);
    }
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({ error: 'Failed to upload avatar' });
  }
}

/**
 * DELETE /api/profile/:userId/account
 * Delete/anonymize user-owned profile domain data and profile account record.
 * Requires JWT authentication and matching userId.
 * Wraps database operations in a transaction for atomic all-or-nothing semantics.
 * 
 * Data Retention Policy: See ACCOUNT_DELETION_POLICY in profileValidation.js
 * Current behavior: HARD_DELETE_SUBMISSIONS = true (all contributions removed)
 * Next phase: Consider ANONYMIZE mode for compliance/data-preservation balance.
 */
async function deleteUserAccount(req, res) {
  const session = await User.startSession();
  session.startTransaction();

  try {
    const { userId } = req.params;

    if (req.userId !== userId) {
      await session.abortTransaction();
      session.endSession();
      return res.status(403).json({ error: 'Forbidden: Cannot delete another user\'s account' });
    }

    const user = await User.findOne({ auth0Id: userId }).session(session);
    if (!user) {
      await session.abortTransaction();
      session.endSession();
      return res.status(404).json({ error: 'User not found' });
    }

    const avatarUrl = user.profilePicture || '';
    const submissions = await PlaceSubmission.find({ userId }, { _id: 1 }).session(session);
    const submissionIds = submissions.map((item) => item._id.toString());

    const deletedSubmissionsResult = await PlaceSubmission.deleteMany(
      { userId },
      { session }
    );
    const deletedBadgesResult = await UserBadge.deleteMany(
      { userId },
      { session }
    );

    let removedUsageDocsCount = 0;
    let detachedUsageLinksCount = 0;

    if (submissionIds.length > 0) {
      const removedUsage = await PlaceUsageTracking.deleteMany(
        { placeId: { $in: submissionIds } },
        { session }
      );
      removedUsageDocsCount = removedUsage.deletedCount || 0;
    }

    const detachUsage = await PlaceUsageTracking.updateMany(
      { 'usersWhoAdded.userId': userId },
      {
        $pull: { usersWhoAdded: { userId } },
      },
      { session }
    );
    detachedUsageLinksCount = detachUsage.modifiedCount || 0;

    const deletedUserResult = await User.deleteOne(
      { auth0Id: userId },
      { session }
    );

    // Commit transaction before best-effort storage cleanup
    await session.commitTransaction();
    session.endSession();

    // Avatar cleanup is best-effort and does not affect response
    await safeDeleteAvatarFromStorage(avatarUrl);

    const auditId = crypto.randomUUID();
    return res.status(200).json({
      message: 'Account and profile data deleted successfully',
      audit: {
        requestId: auditId,
        timestamp: new Date().toISOString(),
      },
      cleanup: {
        userDeleted: deletedUserResult.deletedCount || 0,
        submissionsDeleted: deletedSubmissionsResult.deletedCount || 0,
        badgesDeleted: deletedBadgesResult.deletedCount || 0,
        usageDocsDeleted: removedUsageDocsCount,
        usageLinksDetached: detachedUsageLinksCount,
      },
    });
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    console.error('Delete user account error:', error);
    return res.status(500).json({ error: 'Failed to delete user account' });
  }
}

module.exports = {
  getUserProfile,
  getUserContributions,
  updateUserProfile,
  logoutUser,
  getTopContributors,
  uploadUserAvatar,
  deleteUserAccount,
};
