const express = require('express');
const multer = require('multer');
const router = express.Router({ mergeParams: true }); // access :albumId from parent router
const { checkJwt, extractUserId } = require('../middleware/auth');
const photoController = require('../controllers/photoController');

// Multer config (memory storage for Firebase upload)
const upload = multer({
  storage: multer.memoryStorage(), // store files in buffer
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
    files: 20 // max 20 files
  },
  fileFilter: (req, file, cb) => {
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed.'), false);
    }
  }
});

// Auth required for all photo routes
router.use(checkJwt, extractUserId);

// Multer error handling
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large. Maximum size is 10MB.' });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: 'Too many files. Maximum is 20 files per request.' });
    }
    return res.status(400).json({ error: err.message });
  }

  if (err.message === 'Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed.') {
    return res.status(400).json({ error: err.message });
  }

  next(err);
});

module.exports = router;