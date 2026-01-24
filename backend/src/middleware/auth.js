const { expressjwt: jwt } = require('express-jwt');
const jwksRsa = require('jwks-rsa');

// Validates JWT from Auth0 and attaches payload to req.auth
const checkJwt = jwt({
  secret: jwksRsa.expressJwtSecret({
    cache: true,
    rateLimit: true,
    jwksRequestsPerMinute: 5,
    jwksUri: `https://${process.env.AUTH0_DOMAIN}/.well-known/jwks.json`
  }),
  audience: process.env.AUTH0_AUDIENCE,
  issuer: `https://${process.env.AUTH0_DOMAIN}/`,
  algorithms: ['RS256']
});

// Extracts the userId from the JWT `sub` claim
function extractUserId(req, res, next) {
  const sub = req?.auth?.sub;
  if (!sub) return res.status(401).json({ error: 'Unauthorized: Missing sub claim' });
  req.userId = sub;
  next();
}

module.exports = { checkJwt, extractUserId };
