const admin = require('../config/firebaseAdmin');

// Development mode: bypass auth for testing
const isDevelopment = process.env.NODE_ENV !== 'production';

// Validates Firebase ID token and attaches payload to req.auth
const checkJwt = isDevelopment
  ? (req, res, next) => {
      // In development, create a mock auth object
      req.auth = { uid: 'dev-user-123' };
      next();
    }
  : async (req, res, next) => {
      try {
        const authHeader = req.headers.authorization || '';
        const token = authHeader.startsWith('Bearer ')
          ? authHeader.slice(7)
          : null;

        if (!token) {
          return res.status(401).json({ error: 'Unauthorized: Missing Bearer token' });
        }

        const decoded = await admin.auth().verifyIdToken(token);
        req.auth = decoded;
        next();
      } catch (error) {
        return res.status(401).json({ error: 'Unauthorized: Invalid token' });
      }
    };

// Extracts the userId from the Firebase token
function extractUserId(req, res, next) {
  const uid = req?.auth?.uid || req?.auth?.sub;
  if (!uid) return res.status(401).json({ error: 'Unauthorized: Missing uid' });
  req.userId = uid;
  next();
}

function requireAdmin(req, res, next) {
  if (req?.auth?.admin === true) return next();
  return res.status(403).json({ error: 'Forbidden: Admin access required' });
}

module.exports = { checkJwt, extractUserId, requireAdmin };
