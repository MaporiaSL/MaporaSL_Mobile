const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const connectDB = require('./src/config/db');
const User = require('./src/models/User');
const Place = require('./src/models/Place');
const UserDistrictAssignment = require('./src/models/UserDistrictAssignment');

async function seedDevExploration() {
  try {
    await connectDB();
    console.log('Connected to MongoDB');

    const user = await User.findOne({ auth0Id: 'dev-user-123' });
    if (!user) {
      console.error('Dev user not found. Run seed-dev-user.js first.');
      process.exit(1);
    }

    // Get some places from Colombo district
    const places = await Place.find({ district: 'Colombo', isActive: true }).limit(5);
    
    if (places.length === 0) {
      console.error('No places found in Colombo district.');
      process.exit(1);
    }

    console.log(`Found ${places.length} places in Colombo`);

    // Check if assignment already exists
    let assignment = await UserDistrictAssignment.findOne({
      userId: user.auth0Id,
      district: 'Colombo',
    });

    if (assignment) {
      console.log('Assignment already exists for dev user');
    } else {
      // Create assignment
      assignment = await UserDistrictAssignment.create({
        userId: user.auth0Id,
        district: 'Colombo',
        assignedLocationIds: places.map(p => p._id),
        visitedLocationIds: [],
        visitedLocationProofs: [],
        assignedCount: places.length,
        visitedCount: 0,
        assignedAt: new Date(),
      });
      console.log(`Created assignment with ${places.length} locations`);
    }

    console.log('\nAssigned locations:');
    places.forEach(p => {
      console.log(`- ${p.name} (ID: ${p._id})`);
    });

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('Error seeding dev exploration:', error);
    process.exit(1);
  }
}

seedDevExploration();
