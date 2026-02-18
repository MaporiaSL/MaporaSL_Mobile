const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');

console.log('\n🔍 MongoDB Connection Diagnostics\n');
console.log('MongoDB URI:', process.env.MONGODB_URI ? '✓ Found' : '✗ Missing');

if (process.env.MONGODB_URI) {
  // Mask password for security
  const maskedUri = process.env.MONGODB_URI.replace(/:([^:@]+)@/, ':****@');
  console.log('URI Preview:', maskedUri);
  
  console.log('\n🔌 Attempting connection (SRV method)...\n');
  
  mongoose.connect(process.env.MONGODB_URI, {
    serverSelectionTimeoutMS: 10000,
  })
  .then((conn) => {
    console.log('✅ SUCCESS! MongoDB Connected:', conn.connection.host);
    console.log('Database:', conn.connection.name);
    process.exit(0);
  })
  .catch((err) => {
    console.error('❌ SRV CONNECTION FAILED');
    console.error('Error:', err.message.substring(0, 100) + '...\n');
    
    // Try alternative connection method
    console.log('🔄 Attempting alternative connection (direct seed method)...\n');
    
    // Extract credentials from SRV URI
    const srvMatch = process.env.MONGODB_URI.match(/mongodb\+srv:\/\/([^:]+):([^@]+)@([^/]+)\/(.*)\?/);
    if (!srvMatch) {
      console.error('❌ Could not parse connection string');
      process.exit(1);
    }
    
    const [, username, password, cluster, db] = srvMatch;
    // Use direct connection to first seed
    const directUri = `mongodb+srv://${username}:${password}@${cluster}/${db}?directConnection=false&retryWrites=true`;
    
    const maskedDirect = directUri.replace(/:([^:@]+)@/, ':****@');
    console.log('Trying direct URI:', maskedDirect);
    
    mongoose.connect(directUri, {
      serverSelectionTimeoutMS: 10000,
    })
    .then((conn) => {
      console.log('✅ SUCCESS! MongoDB Connected (Direct):', conn.connection.host);
      console.log('Database:', conn.connection.name);
      process.exit(0);
    })
    .catch((err2) => {
      console.error('❌ DIRECT CONNECTION ALSO FAILED\n');
      console.error('Error Type:', err2.name);
      console.error('Error Message:', err2.message);
      console.error('\n📋 Troubleshooting Steps:');
      console.error('1. Clear DNS cache: ipconfig /flushdns');
      console.error('2. Verify MongoDB Atlas cluster is RUNNING (not paused)');
      console.error('3. Verify your IP is whitelisted: ');
      console.error('   → Network Access → Add your IP or 0.0.0.0/0');
      console.error('4. Check .env credentials:');
      console.error('   → Username and password must be correct');
      console.error('5. Try connecting from MongoDB Atlas dashboard');
      console.error('   → "Connect" button → "Shell" to test');
      process.exit(1);
    });
  });
} else {
  console.error('❌ MONGODB_URI not found in .env file');
  process.exit(1);
}
