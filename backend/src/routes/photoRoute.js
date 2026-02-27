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

// POST /api/albums/:albumId/photos - upload single photo
router.post('/', upload.single('photo'), photoController.uploadPhoto);

// POST /api/albums/:albumId/photos/bulk - upload multiple photos
router.post('/bulk', upload.array('photos', 20), photoController.uploadMultiplePhotos);

// GET /api/albums/:albumId/photos - get all photos
router.get('/', photoController.getPhotos);

// GET /api/albums/:albumId/photos/:photoId - get single photo
router.get('/:photoId', photoController.getPhoto);

// PATCH /api/albums/:albumId/photos/:photoId - update photo
router.patch('/:photoId', photoController.updatePhoto);

// DELETE /api/albums/:albumId/photos/:photoId - delete photo
router.delete('/:photoId', photoController.deletePhoto);

// POST /api/albums/:albumId/photos/:photoId/move - move photo to another album
router.post('/:photoId/move', photoController.movePhoto);

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
