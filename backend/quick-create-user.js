/**
 * Quick: Create Test User - Direct MongoDB Insert
 * 
 * Usage:
 *   node quick-create-user.js
 */

const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://maporia_admin:maporiaT34@maporiacluster.wp5hsih.mongodb.net/gemified-travel?retryWrites=true&w=majority&appName=MaporiaCluster';

async function createUser() {
  try {
    console.log('🔗 Connecting to MongoDB Atlas...');
    await mongoose.connect(MONGO_URI, {
      serverSelectionTimeoutMS: 5000,
    });
    console.log('✅ Connected to MongoDB!\n');

    const db = mongoose.connection.db;
    const users = db.collection('users');

    const testUser = {
      auth0Id: 'test-user-123',
      name: 'Test User',
      email: 'test@example.com',
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

    // Check if exists
    const existing = await users.findOne({ auth0Id: 'test-user-123' });
    
    if (existing) {
      console.log('✅ Test user already exists!');
      console.log(`   Name: ${existing.name}`);
      console.log(`   Email: ${existing.email}`);
    } else {
      const result = await users.insertOne(testUser);
      console.log('✅ Test user created successfully!');
      console.log(`   ID: ${result.insertedId}`);
      console.log(`   Name: ${testUser.name}`);
      console.log(`   Email: ${testUser.email}`);
    }

    console.log('\n📱 Next Steps:');
    console.log('1. In Flutter terminal, press R to reload');
    console.log('2. Navigate to Profile screen');
    console.log('3. You should see "Test User" profile loading!\n');

    await mongoose.disconnect();
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createUser();
