/**
 * Create Test User in MongoDB
 * 
 * Usage: 
 *   node create-test-user.js
 * 
 * This script creates a test user so you can test the Profile feature
 * without needing Firebase authentication during development.
 */

const mongoose = require('mongoose');
require('dotenv').config();

// MongoDB connection
const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/maporia';

const testUser = {
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

async function createTestUser() {
  try {
    console.log('🔗 Connecting to MongoDB...');
    console.log(`📍 URI: ${MONGO_URI}`);
    
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected to MongoDB');

    const db = mongoose.connection.db;
    const usersCollection = db.collection('users');

    // Check if test user already exists
    const existingUser = await usersCollection.findOne({ auth0Id: 'test-user-123' });
    
    if (existingUser) {
      console.log('⚠️  Test user already exists:');
      console.log(existingUser);
      console.log('\nTo reset, delete this user first and run the script again.');
      return;
    }

    // Create the user
    const result = await usersCollection.insertOne(testUser);
    
    console.log('✅ Test user created successfully!');
    console.log('\n📊 User Details:');
    console.log(`  - ID: ${result.insertedId}`);
    console.log(`  - Auth0 ID: ${testUser.auth0Id}`);
    console.log(`  - Email: ${testUser.email}`);
    console.log(`  - Name: ${testUser.name}`);
    
    console.log('\n📱 Next Steps:');
    console.log('1. In mobile/lib/features/profile/presentation/providers/profile_providers.dart');
    console.log('   - The fallback test user ID is already set to: "test-user-123"');
    console.log('2. Hot reload the Flutter app (r in terminal)');
    console.log('3. Navigate to Profile screen');
    console.log('4. Profile should now load with Test User data!');

    await mongoose.disconnect();
    console.log('\n✅ Done!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createTestUser();
