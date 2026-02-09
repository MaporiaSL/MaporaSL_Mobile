const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const connectDB = require('./config/db');
const { checkJwt, extractUserId } = require('./middleware/auth');
const authRoutes = require('./routes/authRoutes');
const travelRoutes = require('./routes/travelRoutes');
const destinationRoutes = require('./routes/destinationRoutes');
const mapRoutes = require('./routes/mapRoutes');
const geoRoutes = require('./routes/geoRoutes');
const userRoutes = require('./routes/userRoutes');
const realStoreRoutes = require('./routes/realStoreRoutes');
const preplannedTripsRoutes = require('./routes/preplannedTripsRoutes');
const explorationRoutes = require('./routes/explorationRoutes');
const explorationAdminRoutes = require('./routes/explorationAdminRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Core middleware
app.use(helmet());
app.use(cors({ origin: process.env.CLIENT_ORIGIN || '*' }));
app.use(express.json());
app.use(morgan('dev'));

// Health endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Auth routes (public + JWT protected)
app.use('/api/auth', authRoutes);

// Pre-planned trips (public read, protected clone)
app.use('/api/preplanned-trips', preplannedTripsRoutes);

// Protected routes
app.use('/api/travel', checkJwt, extractUserId, travelRoutes);
app.use('/api/travel/:travelId/destinations', checkJwt, extractUserId, destinationRoutes);

// Map and geospatial routes (JWT protected within route files)
app.use('/api/travel', mapRoutes);
app.use('/api/destinations', geoRoutes);

// User progress routes (JWT protected)
app.use('/api/users', userRoutes);
app.use('/api/districts', userRoutes);

// Exploration routes (JWT protected)
app.use('/api/exploration', explorationRoutes);

// Admin exploration routes (JWT + admin)
app.use('/api/admin', explorationAdminRoutes);

// Real store (shop) routes
app.use('/api/store', realStoreRoutes);

// Boot: connect to DB first, then start server
(async () => {
  await connectDB();
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
})();

module.exports = app;
