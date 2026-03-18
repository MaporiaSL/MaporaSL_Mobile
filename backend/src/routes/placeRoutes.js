const express = require('express');
const multer = require('multer');
const { checkJwt, extractUserId, requireAdmin } = require('../middleware/auth');
const {
  getPlaces,
  getPlaceById,
  getPlacesByDistrict,
  searchPlaces,
  getNearbyPlaces,
  getPlacesStats,
} = require('../controllers/placeController');
const {
  submitPlace,
  getMySubmissions,
  getPendingSubmissions,
  resubmitSubmission,
  reviewSubmission,
} = require('../controllers/placeSubmissionController');

const router = express.Router();

const submissionUpload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 8 * 1024 * 1024,
    files: 6,
  },
  fileFilter: (req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype);
    if (!ok) return cb(new Error('Only jpeg/png/webp images are allowed'));
    cb(null, true);
  },
});

// GET /api/places - Get all places with pagination
router.get('/', getPlaces);

// GET /api/places/stats - Get places statistics
router.get('/stats', getPlacesStats);

// GET /api/places/search - Search places
router.get('/search', searchPlaces);

// GET /api/places/nearby - Get nearby places
router.get('/nearby', getNearbyPlaces);

// GET /api/places/district/:district - Get places by district
router.get('/district/:district', getPlacesByDistrict);

// POST /api/places/submit - Submit new place contribution (auth required)
router.post('/submit', checkJwt, extractUserId, submissionUpload.array('photos', 6), submitPlace);

// GET /api/places/submissions/me - Get current user's submission history (auth required)
router.get('/submissions/me', checkJwt, extractUserId, getMySubmissions);

// GET /api/places/submissions/pending - Admin moderation queue
router.get('/submissions/pending', checkJwt, extractUserId, requireAdmin, getPendingSubmissions);

// PATCH /api/places/submissions/:id/resubmit - Rejected submission edit/resubmit
router.patch(
  '/submissions/:id/resubmit',
  checkJwt,
  extractUserId,
  submissionUpload.array('photos', 6),
  resubmitSubmission,
);

// PATCH /api/places/submissions/:id/review - Admin review submission
router.patch('/submissions/:id/review', checkJwt, extractUserId, requireAdmin, reviewSubmission);

// GET /api/places/:id - Get single place
router.get('/:id', getPlaceById);

// Multer and file validation errors
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large. Max 8MB per image.' });
    }
    return res.status(400).json({ error: err.message });
  }
  if (err?.message?.includes('Only jpeg/png/webp images are allowed')) {
    return res.status(400).json({ error: err.message });
  }
  return next(err);
});

module.exports = router;

