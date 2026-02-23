const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');

async function checkTestUser() {
  try {
    console.log('🔗 Connecting to MongoDB Atlas...');
    await mongoose.connect(process.env.MONGODB_URI, {
      serverSelectionTimeoutMS: 10000,
    });
    console.log('✅ Connected!\n');

    const db = mongoose.connection.db;
    const usersCollection = db.collection('users');

    // Check if test user exists
    console.log('🔍 Checking for test user (auth0Id: test-user-123)...');
    const testUser = await usersCollection.findOne({ auth0Id: 'test-user-123' });

    if (testUser) {
      console.log('✅ Test user FOUND!\n');
      console.log('MongoDB ID:', testUser._id);
      console.log('Email:', testUser.email);
      console.log('Name:', testUser.name);
      console.log('Created:', testUser.createdAt);
    } else {
      console.log('❌ Test user NOT FOUND in database');
    }

    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

checkTestUser();
