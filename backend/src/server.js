require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const connectDB = require('./config/db');
const { checkJwt, extractUserId } = require('./middleware/auth');
const authRoutes = require('./routes/authRoutes');
const travelRoutes = require('./routes/travelRoutes');
const destinationRoutes = require('./routes/destinationRoutes');

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

// Protected routes
app.use('/api/travel', checkJwt, extractUserId, travelRoutes);
app.use('/api/travel/:travelId/destinations', checkJwt, extractUserId, destinationRoutes);

// Boot: connect to DB first, then start server
(async () => {
  await connectDB();
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
})();

module.exports = app;
