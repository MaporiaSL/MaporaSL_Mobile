const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');

console.log('\n🔍 MongoDB Connection Diagnostics\n');
console.log('MongoDB URI:', process.env.MONGODB_URI ? '✓ Found' : '✗ Missing');

if (process.env.MONGODB_URI) {
  // Mask password for security
  const maskedUri = process.env.MONGODB_URI.replace(/:([^:@]+)@/, ':****@');
  console.log('URI Preview:', maskedUri);
  
  console.log('\n🔌 Attempting connection...\n');
  
  mongoose.connect(process.env.MONGODB_URI, {
    serverSelectionTimeoutMS: 10000, // 10 second timeout
  })
  .then((conn) => {
    console.log('✅ SUCCESS! MongoDB Connected:', conn.connection.host);
    console.log('Database:', conn.connection.name);
    process.exit(0);
  })
  .catch((err) => {
    console.error('❌ CONNECTION FAILED\n');
    console.error('Error Type:', err.name);
    console.error('Error Message:', err.message);
    console.error('\n📋 Common Solutions:');
    console.error('1. MongoDB Atlas cluster may be PAUSED (free tier auto-pauses after inactivity)');
    console.error('   → Log into MongoDB Atlas and click "Resume" on your cluster');
    console.error('2. Check your IP whitelist in MongoDB Atlas Network Access');
    console.error('   → Add your current IP or use 0.0.0.0/0 for development');
    console.error('3. Verify credentials in .env file are correct');
    console.error('4. Check if you have internet connectivity');
    process.exit(1);
  });
} else {
  console.error('❌ MONGODB_URI not found in .env file');
  process.exit(1);
}
