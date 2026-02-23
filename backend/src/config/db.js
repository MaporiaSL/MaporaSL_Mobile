const mongoose = require('mongoose');

async function connectDB() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('Missing MONGODB_URI in environment');
    process.exit(1);
  }
  
  // Retry configuration
  const maxRetries = 5;
  const retryDelayMs = 2000;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`🔗 MongoDB connection attempt ${attempt}/${maxRetries}...`);
      
      const conn = await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 10000,
        socketTimeoutMS: 45000,
        retryWrites: true,
        w: 'majority',
        maxPoolSize: 10,
        minPoolSize: 2,
      });
      
      console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
      return conn;
    } catch (err) {
      console.error(`❌ Connection attempt ${attempt} failed:`, err.message);
      
      if (attempt < maxRetries) {
        console.log(`⏳ Retrying in ${retryDelayMs}ms...`);
        await new Promise(resolve => setTimeout(resolve, retryDelayMs));
      } else {
        console.error('❌ Failed to connect to MongoDB after all retries');
        process.exit(1);
      }
    }
  }
}

module.exports = connectDB;
