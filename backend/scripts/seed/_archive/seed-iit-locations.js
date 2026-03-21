const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const connectDB = require('../../src/config/db');
const Place = require('../../src/models/Place');

const IIT_LOCATIONS = [
  {
    name: 'Informatics Institute of Technology - Wellawattha Campus',
    description: 'Main campus of IIT located in Wellawattha, Colombo. A leading IT education provider in Sri Lanka.',
    category: 'cultural',
    district: 'Colombo',
    province: 'Western Province',
    latitude: 6.8869,
    longitude: 80.6277,
  },
  {
    name: 'Informatics Institute of Technology - Bambalapitiya Campus',
    description: 'IIT secondary campus in Bambalapitiya, offering specialized IT courses and training programs.',
    category: 'cultural',
    district: 'Colombo',
    province: 'Western Province',
    latitude: 6.9250,
    longitude: 80.6407,
  },
  {
    name: 'Informatics Institute of Technology - Kollupitiya',
    description: 'IIT facility in Kollupitiya, providing advanced computing and technology education.',
    category: 'cultural',
    district: 'Colombo',
    province: 'Western Province',
    latitude: 6.9342,
    longitude: 80.6482,
  },
];

async function seedIITLocations() {
  try {
    await connectDB();
    console.log('Connected to MongoDB\n');

    // Delete existing IIT places to avoid duplicates
    const deleteResult = await Place.deleteMany({
      name: { $regex: 'Informatics Institute of Technology' },
    });
    console.log(`Deleted ${deleteResult.deletedCount} existing IIT places`);

    // Insert the three IIT locations
    const insertResult = await Place.insertMany(
      IIT_LOCATIONS.map(place => ({
        ...place,
        photos: [],
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      }))
    );

    console.log(`\n✅ Successfully seeded ${insertResult.length} IIT locations:`);
    insertResult.forEach((place, idx) => {
      console.log(`${idx + 1}. ${place.name}`);
      console.log(`   Location: ${place.latitude.toFixed(4)}, ${place.longitude.toFixed(4)}`);
      console.log(`   ID: ${place._id}`);
    });

    // Verify they're in the database
    const colomboPlaces = await Place.find({ district: 'Colombo', isActive: true });
    console.log(`\n📍 Total places in Colombo district: ${colomboPlaces.length}`);

  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
  }
}

seedIITLocations();
