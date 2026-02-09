const express = require('express');
const router = express.Router();
const albumController = require('../controllers/albumController');
const photoRoutes = require('./photoRoutes');

const { checkJwt, extractUserId } = require('../middleware/auth');

// Auth required for all routes
router.use(checkJwt, extractUserId);

// GET /api/albums/stats - album & photo stats
router.get('/stats', albumController.getAlbumStats);

// GET /api/albums - get all albums
router.get('/', albumController.getAlbums);

// GET /api/albums/:albumId - get single album
router.get('/:albumId', albumController.getAlbum);

// POST /api/albums - create album
router.post('/', albumController.createAlbum);

// PATCH /api/albums/:albumId - update album
router.patch('/:albumId', albumController.updateAlbum);

// DELETE /api/albums/:albumId - delete album
router.delete('/:albumId', albumController.deleteAlbum);

// Binding the photo related routes to Album routes
// /api/albums/:albumId/photos/* - album photos
router.use('/:albumId/photos', photoRoutes);

module.exports = router;