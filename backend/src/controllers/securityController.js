const User = require('../models/User');
const Session = require('../models/Session');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');

// Get active sessions
async function getSessions(req, res) {
  try {
    const sessions = await Session.find({ userId: req.userId }).sort({ lastUsedAt: -1 });
    res.json({ sessions });
  } catch (error) {
    console.error('getSessions error:', error);
    res.status(500).json({ error: 'Failed to fetch sessions' });
  }
}

// Logout all sessions (revoke all)
async function logoutAll(req, res) {
  try {
    await Session.deleteMany({ userId: req.userId });
    res.json({ message: 'All sessions revoked. Please log in again.' });
  } catch (error) {
    console.error('logoutAll error:', error);
    res.status(500).json({ error: 'Failed to revoke sessions' });
  }
}

// Setup 2FA - Generate secret and QR code
async function setup2FA(req, res) {
  try {
    const user = await User.findOne({ auth0Id: req.userId });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const secret = speakeasy.generateSecret({
      name: `Maporia (${user.email})`
    });

    // Store temporary secret until verified
    user.security.twoFactorSecret = secret.base32;
    await user.save();

    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

    res.json({
      secret: secret.base32,
      qrCode: qrCodeUrl
    });
  } catch (error) {
    console.error('setup2FA error:', error);
    res.status(500).json({ error: 'Failed to setup 2FA' });
  }
}

// Verify 2FA - Enable it after first verification
async function verify2FA(req, res) {
  try {
    const { token } = req.body;
    const user = await User.findOne({ auth0Id: req.userId });
    if (!user || !user.security.twoFactorSecret) {
      return res.status(400).json({ error: '2FA setup not initiated' });
    }

    const verified = speakeasy.totp.verify({
      secret: user.security.twoFactorSecret,
      encoding: 'base32',
      token
    });

    if (verified) {
      user.security.twoFactorEnabled = true;
      await user.save();
      res.json({ message: '2FA enabled successfully' });
    } else {
      res.status(400).json({ error: 'Invalid verification code' });
    }
  } catch (error) {
    console.error('verify2FA error:', error);
    res.status(500).json({ error: 'Failed to verify 2FA' });
  }
}

// Disable 2FA
async function disable2FA(req, res) {
  try {
    const user = await User.findOne({ auth0Id: req.userId });
    if (!user) return res.status(404).json({ error: 'User not found' });

    user.security.twoFactorEnabled = false;
    user.security.twoFactorSecret = null;
    await user.save();

    res.json({ message: '2FA disabled successfully' });
  } catch (error) {
    console.error('disable2FA error:', error);
    res.status(500).json({ error: 'Failed to disable 2FA' });
  }
}

module.exports = {
  getSessions,
  logoutAll,
  setup2FA,
  verify2FA,
  disable2FA
};
