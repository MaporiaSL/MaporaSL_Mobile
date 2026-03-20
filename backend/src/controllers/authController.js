const User = require('../models/User');
const Session = require('../models/Session');
const UserDistrictAssignment = require('../models/UserDistrictAssignment');
const { assignExplorationForUser } = require('./explorationController');

// Register or sync user (called after Firebase login)
async function registerUser(req, res) {
  try {
    const { email, name, profilePicture, hometownDistrict } = req.body;
    const authProviderId = req.userId;

    // Validate required fields
    if (!authProviderId || !email || !name || !hometownDistrict) {
      return res.status(400).json({
        error: 'Missing required fields: email, name, hometownDistrict'
      });
    }

    // Check if user exists
    let user = await User.findOne({ auth0Id: authProviderId });

    if (user) {
      // Track session for existing user on sync
      try {
        const session = new Session({
          userId: authProviderId,
          deviceId: req.headers['x-device-id'] || 'Unknown',
          deviceType: req.headers['x-device-type'] || 'Mobile',
          ip: req.ip || req.headers['x-forwarded-for'],
          userAgent: req.headers['user-agent']
        });
        await session.save();
      } catch (sessionError) {
        console.warn('Failed to track session:', sessionError.message);
      }

      return res.status(200).json({
        message: 'User already registered',
        user
      });
    }

    // Create new user
    user = new User({
      auth0Id: authProviderId,
      email,
      name,
      profilePicture,
      hometownDistrict
    });

    await user.save();

    try {
      await assignExplorationForUser(authProviderId, hometownDistrict);
    } catch (assignmentError) {
      console.error('Assignment error for new user:', assignmentError.message);
      await User.deleteOne({ auth0Id: authProviderId });
      return res.status(500).json({
        error: 'Failed to create exploration assignments',
        details: assignmentError.message
      });
    }

    // Track session
    try {
      const session = new Session({
        userId: authProviderId,
        deviceId: req.headers['x-device-id'] || 'Unknown',
        deviceType: req.headers['x-device-type'] || 'Mobile',
        ip: req.ip || req.headers['x-forwarded-for'],
        userAgent: req.headers['user-agent']
      });
      await session.save();
    } catch (sessionError) {
      console.warn('Failed to track session:', sessionError.message);
    }

    res.status(201).json({
      message: 'User registered successfully',
      user
    });
  } catch (error) {
    console.error('Register error:', error);
    
    // Handle duplicate key errors
    if (error.code === 11000) {
      return res.status(409).json({ error: 'User with this email or auth0Id already exists' });
    }
    
    res.status(500).json({ error: 'Failed to register user', details: error.message });
  }
}

// Get current user profile
async function getMe(req, res) {
  try {
    const user = await User.findOne({ auth0Id: req.userId });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user });
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

// Delete user account and all associated data
async function deleteAccount(req, res) {
  try {
    const userId = req.userId;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Find the user
    const user = await User.findOne({ auth0Id: userId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Delete all user-related data
    // 1. Delete user's exploration assignments
    await UserDistrictAssignment.deleteMany({ userId });

    // 2. Delete user's sessions
    await Session.deleteMany({ userId });

    // 3. Delete the user account
    await User.findOneAndDelete({ auth0Id: userId });

    res.status(200).json({ message: 'Account deleted successfully' });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ error: 'Failed to delete account' });
  }
}

module.exports = {
  registerUser,
  getMe,
  logoutUser,
  deleteAccount
};
