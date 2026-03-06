const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../../src/server'); // Assuming server.js exports app
const User = require('../../src/models/User');
const Place = require('../../src/models/Place');
const Visit = require('../../src/models/Visit');

let mongoServer;
let token;
let user;
let placeId;

// Fake coordinates for testing
const PLACE_LAT = 40.7128;
const PLACE_LNG = -74.0060;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());

  // Create test user and get token
  // (Assuming you have a way to generate a token for tests, mocking here)
  user = await User.create({
    username: 'testuser',
    email: 'test@example.com',
    password: 'password123',
  });
  
  // Create a place
  const place = await Place.create({
    name: 'Statue of Liberty',
    type: 'cultural',
    location: {
      type: 'Point',
      coordinates: [PLACE_LNG, PLACE_LAT], // GeoJSON order: Longitude, Latitude
    },
    description: 'A test place'
  });
  placeId = place._id;
  
  // Mock auth token (adjust according to your auth logic)
  token = 'mock-jwt-token-for-user-' + user._id; 
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

afterEach(async () => {
  await Visit.deleteMany({});
});

describe('Visit Validation Logic', () => {
  // Mock auth middleware for these tests
  jest.mock('../../src/middleware/auth', () => ({
    protect: (req, res, next) => {
      req.user = { id: user._id };
      next();
    }
  }));

  it('should verify visit when within 200m geofence', async () => {
    // 100 meters away approx
    const res = await request(app)
      .post('/api/visits/mark')
      .set('Authorization', `Bearer ${token}`)
      .send({
        placeId,
        latitude: 40.7135,
        longitude: -74.0060
      });

    expect(res.status).toBe(201);
    expect(res.body.visit.isVerified).toBe(true);
    expect(res.body.visit.rejectionReason).toBeNull();
  });

  it('should reject verification when outside 200m geofence', async () => {
    // 5km away approx
    const res = await request(app)
      .post('/api/visits/mark')
      .set('Authorization', `Bearer ${token}`)
      .send({
        placeId,
        latitude: 40.7580,
        longitude: -73.9855
      });

    expect(res.status).toBe(201);
    expect(res.body.visit.isVerified).toBe(false);
    expect(res.body.visit.rejectionReason).toBe('too_far');
  });

  it('should not allow duplicate visits', async () => {
    // First visit
    await request(app)
      .post('/api/visits/mark')
      .set('Authorization', `Bearer ${token}`)
      .send({
        placeId,
        latitude: PLACE_LAT,
        longitude: PLACE_LNG
      });

    // Second visit
    const res = await request(app)
      .post('/api/visits/mark')
      .set('Authorization', `Bearer ${token}`)
      .send({
        placeId,
        latitude: PLACE_LAT,
        longitude: PLACE_LNG
      });

    expect(res.status).toBe(400);
    expect(res.body.error).toMatch(/visited/);
  });
});
