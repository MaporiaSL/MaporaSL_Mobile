const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const connectDB = require('./src/config/db');
const Place = require('./src/models/Place');

async function getLocationCoords() {
  try {
    await connectDB();
    const place = await Place.findById('699bc24f4f8a602b984161fa');
    if (place) {
      console.log(`${place.name}:`);
      console.log(`Latitude: ${place.latitude}`);
      console.log(`Longitude: ${place.longitude}`);
    }
    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

getLocationCoords();
