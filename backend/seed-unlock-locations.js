const path = require('path');
// Load root-level .env (one directory above /backend)
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const connectDB = require('./src/config/db');
const UnlockLocation = require('./src/models/UnlockLocation');
const fs = require('fs');

async function seedUnlockLocations() {
  try {
    await connectDB();
    console.log('Connected to MongoDB');

    // Read seed data
    const jsonPath = path.resolve(__dirname, '../project_resorces/places_seed_data_2026.json');
    const raw = fs.readFileSync(jsonPath, 'utf-8');
    const data = JSON.parse(raw);

    if (!data?.districts?.length) {
      throw new Error('Seed data missing districts');
    }

    console.log(`Processing ${data.districts.length} districts...`);

    // Clear existing locations
    await UnlockLocation.deleteMany({});
    console.log('Cleared existing unlock locations');

    // Create locations from seed data
    const locations = [];
    data.districts.forEach((districtEntry) => {
      districtEntry.attractions.forEach((attraction) => {
        locations.push({
          district: districtEntry.district,
          province: districtEntry.province,
          name: attraction.name,
          type: attraction.type,
          latitude: attraction.lat,
          longitude: attraction.lon,
          isActive: true,
        });
      });
    });

    console.log(`Inserting ${locations.length} locations...`);
    await UnlockLocation.insertMany(locations);
    console.log(`Successfully inserted ${locations.length} unlock locations`);

    // Verify district coverage
    const districts = await UnlockLocation.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$district',
          count: { $sum: 1 },
          province: { $first: '$province' },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    console.log('\n=== District Coverage ===');
    districts.forEach((district) => {
      console.log(`${district._id} (${district.province}): ${district.count} locations`);
    });

    const underMin = districts.filter((entry) => entry.count < 3);
    if (underMin.length) {
      console.warn(
        `\nWARNING: ${underMin.length} districts have fewer than 3 locations:`,
        underMin
      );
    } else {
      console.log('\n✓ All districts have 3+ locations');
    }

    await mongoose.connection.close();
    console.log('\nSeeding complete');
  } catch (error) {
    console.error('Unlock locations seeding failed:', error);
    process.exit(1);
  }
}

seedUnlockLocations();
