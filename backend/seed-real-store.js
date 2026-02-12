const path = require('path');
// Load root-level .env (one directory above /backend)
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const connectDB = require('./src/config/db');
const RealStoreItem = require('./src/models/RealStoreItem');
const sampleProducts = require('./src/data/realStoreSampleProducts.json');

async function seedRealStore() {
  try {
    await connectDB();
    console.log('Connected to MongoDB');

    await RealStoreItem.deleteMany({});
    console.log('Cleared existing real store items');

    await RealStoreItem.insertMany(sampleProducts);
    console.log(`Inserted ${sampleProducts.length} real store items`);

    await mongoose.connection.close();
    console.log('Seeding complete');
  } catch (error) {
    console.error('Real store seeding failed:', error);
    process.exit(1);
  }
}

seedRealStore();

