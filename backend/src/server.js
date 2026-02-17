const nodePath = require('path');
require('dotenv').config({ path: nodePath.resolve(__dirname, '../.env') });
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
const placeRoutes = require('./routes/placeRoutes');
const preplannedTripsRoutes = require('./routes/preplannedTripsRoutes');

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
app.use('/api/places', placeRoutes);
app.use('/api/districts', userRoutes);

// Boot: connect to DB first, then start server
(async () => {
  try {
    await connectDB();
    console.log('MongoDB Connected');

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error.message);
    process.exit(1);
  }
})();

module.exports = app;
