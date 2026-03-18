const { admin } = require('../config/firebase');

// Auth bypass must be explicitly enabled via AUTH_BYPASS=true.
const authBypassEnabled = process.env.AUTH_BYPASS === 'true';

// Validates Firebase ID token and attaches payload to req.auth
const checkJwt = authBypassEnabled
  ? (req, res, next) => {
      req.auth = { uid: 'test-user-123' };
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
    // Keep auth endpoints stable in bypass mode.
    // /api/auth/me, /api/auth/register, /api/auth/logout should all map to one dev UID.
    if (req.baseUrl === '/api/auth') {
      req.userId = 'test-user-123';
      return next();
    }

    // req.params is not yet populated in router.use(); parse req.path directly.
    // Path patterns under /api/profile: /:uid, /:uid/contributions, /:uid/avatar
    const match = req.path.match(/^\/([^/]+)/);
    const firstSegment = match ? match[1] : null;
    if (!firstSegment || firstSegment === 'leaderboard' || firstSegment === 'auth') {
      req.userId = 'test-user-123';
      return next();
    }

    req.userId = firstSegment;
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
