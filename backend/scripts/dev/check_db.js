const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const connectDB = require('./src/config/db');
const RealStoreItem = require('./src/models/RealStoreItem');

async function checkDB() {
  try {
    await connectDB();
    const item = await RealStoreItem.findOne({ itemId: 'prd-colombo-keytag-01' });
    if (item) {
      console.log('Product Found:');
      console.log('Name:', item.name);
      console.log('Thumbnail:', item.thumbnail);
    } else {
      console.log('Product not found in DB.');
    }
    await mongoose.connection.close();
  } catch (error) {
    console.error('Error:', error);
  }
}

checkDB();
