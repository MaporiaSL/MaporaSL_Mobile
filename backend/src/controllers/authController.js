const User = require('../models/User');
const { assignExplorationForUser } = require('./explorationController');

const MAX_NAME_LENGTH = 40;
const MAX_DISTRICT_LENGTH = 60;
const MAX_LANGUAGE_LENGTH = 30;
const MAX_INTERESTS = 10;

function toTitleCase(value) {
  return String(value || '')
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
    if (!dedup.has(key)) dedup.set(key, normalized);
    if (dedup.size >= MAX_INTERESTS) break;
  }
  return Array.from(dedup.values());
}

function isUserMinimumProfileComplete(user) {
  const hasName = String(user?.name || '').trim().length >= 2;
  const hasDistrict = String(user?.hometownDistrict || '').trim().length > 0;
  const hasLanguage = String(user?.preferredLanguage || '').trim().length > 0;
  return hasName && hasDistrict && hasLanguage;
}

function validateRegisterPayload(payload) {
  const fieldErrors = {};

  const email = String(payload.email || '').trim();
  const name = String(payload.name || '').trim();
  const hometownDistrict = String(payload.hometownDistrict || '').trim();
  const preferredLanguage = payload.preferredLanguage;
  const travelInterests = payload.travelInterests;

  if (!email) {
    fieldErrors.email = 'Email is required';
  }

  if (!name) {
    fieldErrors.name = 'Name is required';
  } else if (name.length < 2) {
    fieldErrors.name = 'Name must be at least 2 characters';
  } else if (name.length > MAX_NAME_LENGTH) {
    fieldErrors.name = `Name must be under ${MAX_NAME_LENGTH} characters`;
  }

  if (!hometownDistrict) {
    fieldErrors.hometownDistrict = 'District is required';
  } else if (hometownDistrict.length > MAX_DISTRICT_LENGTH) {
    fieldErrors.hometownDistrict = `District must be under ${MAX_DISTRICT_LENGTH} characters`;
  }

  if (preferredLanguage != null && String(preferredLanguage).trim().length > MAX_LANGUAGE_LENGTH) {
    fieldErrors.preferredLanguage = `Preferred language must be under ${MAX_LANGUAGE_LENGTH} characters`;
  }

  if (travelInterests != null && !Array.isArray(travelInterests)) {
    fieldErrors.travelInterests = 'Travel interests must be a list';
  }

  if (Array.isArray(travelInterests) && travelInterests.length > MAX_INTERESTS * 3) {
    fieldErrors.travelInterests = 'Too many interests provided';
  }

  return {
    fieldErrors,
    normalized: {
      email,
      name,
      hometownDistrict: toTitleCase(hometownDistrict).slice(0, MAX_DISTRICT_LENGTH),
      preferredLanguage: sanitizePreferredLanguage(preferredLanguage || 'English'),
      travelInterests: sanitizeTravelInterests(travelInterests),
    },
  };
}

// Register or sync user (called after Firebase login)
async function registerUser(req, res) {
  try {
    const { profilePicture } = req.body || {};
    const authProviderId = req.userId;

    const { fieldErrors, normalized } = validateRegisterPayload(req.body || {});

    // Validate required fields
    if (!authProviderId) {
      return res.status(400).json({
        error: 'Missing authenticated user id',
        fieldErrors: {
          auth: 'Authenticated user id is required',
        },
      });
    }

    if (Object.keys(fieldErrors).length > 0) {
      return res.status(400).json({
        error: 'Invalid profile setup payload',
        fieldErrors,
      });
    }

    // Check if user exists
    let user = await User.findOne({ auth0Id: authProviderId });

    if (user) {
      const profileSetupCompleted = user.profileSetupCompleted || isUserMinimumProfileComplete(user);

      if (profileSetupCompleted && !user.profileSetupCompleted) {
        user.profileSetupCompleted = true;
        user.profileSetupCompletedAt = user.profileSetupCompletedAt || new Date();
        await user.save();
      }

      return res.status(200).json({
        message: 'User already registered',
        user,
        profileSetupRequired: !profileSetupCompleted,
      });
    }

    // Create new user
    user = new User({
      auth0Id: authProviderId,
      email: normalized.email,
      name: normalized.name,
      profilePicture,
      hometownDistrict: normalized.hometownDistrict,
      preferredLanguage: normalized.preferredLanguage,
      travelInterests: normalized.travelInterests,
      profileSetupCompleted: false,
      profileSetupCompletedAt: null,
    });

    await user.save();

    try {
      await assignExplorationForUser(authProviderId, normalized.hometownDistrict);
    } catch (assignmentError) {
      await User.deleteOne({ auth0Id: authProviderId });
      return res.status(500).json({
        error: 'Failed to create exploration assignments'
      });
    }

    res.status(201).json({
      message: 'User registered successfully',
      user,
      profileSetupRequired: true,
    });
  } catch (error) {
    console.error('Register error:', error);
    
    // Handle duplicate key errors
    if (error.code === 11000) {
      return res.status(409).json({ error: 'User with this email or auth0Id already exists' });
    }
    
    res.status(500).json({ error: 'Failed to register user' });
  }
}

// Get current user profile
async function getMe(req, res) {
  try {
    let user = await User.findOne({ auth0Id: req.userId });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const profileSetupCompleted = user.profileSetupCompleted || isUserMinimumProfileComplete(user);
    if (profileSetupCompleted && !user.profileSetupCompleted) {
      user.profileSetupCompleted = true;
      user.profileSetupCompletedAt = user.profileSetupCompletedAt || new Date();
      user = await user.save();
    }

    res.json({
      user,
      profileSetupRequired: !profileSetupCompleted,
      requiredFields: ['name', 'hometownDistrict', 'preferredLanguage'],
      optionalFields: ['travelInterests', 'avatarUrl', 'bio'],
    });
  } catch (error) {
    console.error('GetMe error:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
}

// Logout (client-side token removal, optional backend cleanup)
async function logoutUser(req, res) {
  // No server-side session; client discards token
  res.json({ message: 'Logout successful' });
}

module.exports = {
  registerUser,
  getMe,
  logoutUser
};
