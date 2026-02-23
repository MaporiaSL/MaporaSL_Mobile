/**
 * Verify Test User Exists in MongoDB
 * 
 * Usage:
 *   node verify-test-user.js
 * 
 * This checks if the test user exists and shows all users in the database.
 */

const mongoose = require('mongoose');
require('dotenv').config();

const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/maporia';

async function verifyTestUser() {
  try {
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected!\n');

    const db = mongoose.connection.db;
    const usersCollection = db.collection('users');

    // Check if test user exists
    console.log('🔍 Checking for test user (auth0Id: test-user-123)...');
    const testUser = await usersCollection.findOne({ auth0Id: 'test-user-123' });

    if (testUser) {
      console.log('✅ Test user FOUND!\n');
      console.log('User details:');
      console.log(JSON.stringify(testUser, null, 2));
    } else {
      console.log('❌ Test user NOT FOUND\n');
      console.log('📝 Creating test user now...\n');

      const newUser = {
        auth0Id: 'test-user-123',
        email: 'test@example.com',
        name: 'Test User',
        profilePicture: null,
        hometownDistrict: null,
        explorationUnlockedDistricts: [],
        explorationUnlockedProvinces: [],
        explorationStats: {
          totalAssigned: 0,
          totalVisited: 0
        },
        createdAt: new Date(),
        updatedAt: new Date()
      };

      const result = await usersCollection.insertOne(newUser);
      console.log('✅ Test user created!');
      console.log(`   - ID: ${result.insertedId}`);
      console.log(`   - Auth0 ID: test-user-123`);
      console.log(`   - Email: test@example.com\n`);
    }

    // List all users
    console.log('📊 All users in database:');
    const allUsers = await usersCollection.find({}).toArray();
    
    if (allUsers.length === 0) {
      console.log('   (No users found)');
    } else {
      allUsers.forEach((user, index) => {
        console.log(`   ${index + 1}. ${user.name || 'Unknown'} (${user.email || 'no-email'}) - auth0Id: ${user.auth0Id || 'none'}`);
      });
    }

    await mongoose.disconnect();
    console.log('\n✅ Done!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

verifyTestUser();
