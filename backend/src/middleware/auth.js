const { admin } = require('../config/firebase');

// Auth bypass must be explicitly enabled via AUTH_BYPASS=true.
const authBypassEnabled = process.env.AUTH_BYPASS === 'true';
const fallbackBypassUid = process.env.PROFILE_FALLBACK_USER_ID || 'test-user-123';

// Validates Firebase ID token and attaches payload to req.auth
const checkJwt = authBypassEnabled
  ? (req, res, next) => {
      req.auth = { uid: fallbackBypassUid };
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
        console.error('Auth error:', error.message);
        return res.status(401).json({ error: 'Unauthorized: Invalid token' });
      }
    };

// Extracts the userId from the Firebase token (or URL in bypass mode)
function extractUserId(req, res, next) {
  if (authBypassEnabled) {
    // In bypass mode, keep a stable user id across all routes.
    // Some routers (for example /api/exploration/assignments) do not include
    // a user id in the path, so parsing req.path can produce invalid ids.
    req.userId = req?.auth?.uid || fallbackBypassUid;
    return next();
  }
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
