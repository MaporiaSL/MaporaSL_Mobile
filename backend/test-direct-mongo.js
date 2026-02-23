const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');

async function testDirectConnection() {
  try {
    console.log('🔗 Testing MongoDB connection...\n');
    
    // Extract connection string
    const mongoUri = process.env.MONGODB_URI;
    console.log('Connection method: Direct (no SRV)\n');
    
    // Try connection with directConnection flag
    await mongoose.connect(mongoUri, {
      directConnection: false,
      serverSelectionTimeoutMS: 15000,
      socketTimeoutMS: 15000,
      retryWrites: true,
      w: 'majority',
    });
    
    console.log('✅ MongoDB Connected successfully!');
    console.log('Database:', mongoose.connection.name);
    console.log('Host:', mongoose.connection.host);
    
    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error('❌ Connection failed:', err.message);
    console.error('\nTroubleshooting:');
    console.error('1. Check internet connection');
    console.error('2. Verify MongoDB Atlas IP whitelist includes your IP');
    console.error('3. Check if MongoDB Atlas cluster is still active');
    console.error('4. Try pinging 8.8.8.8 to verify DNS works');
    process.exit(1);
  }
}

testDirectConnection();
