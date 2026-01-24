const User = require('../models/User');

// Register or sync user (called after Auth0 signup/login)
async function registerUser(req, res) {
  try {
    const { auth0Id, email, name, profilePicture } = req.body;

    // Validate required fields
    if (!auth0Id || !email || !name) {
      return res.status(400).json({ error: 'Missing required fields: auth0Id, email, name' });
    }

    // Check if user exists
    let user = await User.findOne({ auth0Id });

    if (user) {
      return res.status(200).json({
        message: 'User already registered',
        user
      });
    }

    // Create new user
    user = new User({
      auth0Id,
      email,
      name,
      profilePicture
    });

    await user.save();

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
    
    res.status(500).json({ error: 'Failed to register user' });
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

module.exports = {
  registerUser,
  getMe,
  logoutUser
};
