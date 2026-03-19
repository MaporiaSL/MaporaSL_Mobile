const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const connectDB = require('./src/config/db');
const User = require('./src/models/User');

async function seedDevUser() {
  try {
    await connectDB();
    console.log('Connected to MongoDB');

    // Check if dev user already exists
    let user = await User.findOne({ auth0Id: 'dev-user-123' });
    
    if (user) {
      console.log('Dev user already exists:', user.email);
    } else {
      // Create dev user
      user = await User.create({
        auth0Id: 'dev-user-123',
        email: 'dev@example.com',
        name: 'Dev User',
        hometownDistrict: 'Colombo',
        hometownProvince: 'Western Province',
        xpTotal: 0,
        xpLedger: [],
        explorationStats: {
          totalAssigned: 0,
          totalVisited: 0,
          totalUnlocked: 0,
        },
      });
      console.log('Created dev user:', user.email);
    }

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('Error seeding dev user:', error);
    process.exit(1);
  }
}

seedDevUser();
