const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const Destination = require('./src/models/Destination');
const Place = require('./src/models/Place');
const fs = require('fs');

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB Connected');
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err.message);
    process.exit(1);
  }
};

const importData = async () => {
  await connectDB();

  try {
    // Try to read from places_seed_data_2026.json first
    let dataPath = path.join(__dirname, '..', 'project_resorces', 'places_seed_data_2026.json');
    let seedData = null;

    if (fs.existsSync(dataPath)) {
      console.log(`Reading seed data from ${dataPath}...`);
      const fileContent = fs.readFileSync(dataPath, 'utf-8');
      seedData = JSON.parse(fileContent);
    } else {
      // Fall back to sri_lanka_real_places_100.json
      dataPath = path.join(__dirname, '..', 'project_resorces', 'sri_lanka_real_places_100.json');
      if (!fs.existsSync(dataPath)) {
        console.error(`Error: No seed data files found`);
        process.exit(1);
      }
      console.log(`Reading seed data from ${dataPath}...`);
      const fileContent = fs.readFileSync(dataPath, 'utf-8');
      seedData = JSON.parse(fileContent);
    }

    // Handle both formats
    let places = [];
    if (seedData.districts) {
      // Format: { districts: [...] }
      seedData.districts.forEach((district) => {
        district.attractions.forEach((attraction) => {
          places.push({
            name: attraction.name,
            description: attraction.description || null,
            category: attraction.category || 'other',
            province: district.province,
            district: district.district,
            address: attraction.address || null,
            latitude: attraction.lat,
            longitude: attraction.lon,
            googleMapsUrl: attraction.googleMapsUrl || null,
            type: attraction.type || 'attraction',
            photos: attraction.photos || [],
            rating: attraction.rating || 0,
            reviewCount: attraction.reviewCount || 0,
            accessibility: attraction.accessibility || {},
            tags: attraction.tags || [],
          });
        });
      });
    } else if (Array.isArray(seedData)) {
      // Format: array of places
      places = seedData;
    } else if (seedData.places && Array.isArray(seedData.places)) {
      // Format: { places: [...] }
      places = seedData.places;
    }

    if (!Array.isArray(places) || places.length === 0) {
      console.error('Error: Places data is not an array or is empty');
      process.exit(1);
    }

    console.log(`Found ${places.length} places to import...`);

    // Seed Place collection (new model)
    console.log('\n--- Seeding Place Collection ---');
    const placeForms = places.map((place) => ({
      name: place.name,
      description: place.description || null,
      category: place.category || 'other',
      district: place.district,
      province: place.province,
      address: place.address || null,
      latitude: place.latitude,
      longitude: place.longitude,
      location: {
        type: 'Point',
        coordinates: [place.longitude, place.latitude],
      },
      googleMapsUrl: place.googleMapsUrl || null,
      type: place.type || 'attraction',
      photos: place.photos || [],
      rating: place.rating || 0,
      reviewCount: place.reviewCount || 0,
      source: 'system',
      contributor: {
        userId: null,
        username: null,
      },
      verified: true,
      isActive: true,
      seasonality: place.seasonality || 'year-round',
      accessibility: place.accessibility || {},
      tags: place.tags || [],
    }));

    try {
      const placeResult = await Place.insertMany(placeForms, { ordered: false });
      console.log(`Successfully inserted ${placeResult.length} places to Place collection`);
    } catch (error) {
      if (error.code === 11000) {
        console.log('Some places already exist in Place collection, skipping duplicates');
      } else {
        throw error;
      }
    }

    // Also seed Destination collection for backward compatibility
    console.log('\n--- Seeding Destination Collection ---');
    let count = 0;
    for (const place of places) {
      // Check if place already exists by name to avoid duplicates
      const exists = await Destination.findOne({
        name: place.name,
        isSystemPlace: true,
      });
      if (exists) {
        continue;
      }

      await Destination.create({
        name: place.name,
        description: place.description,
        notes: place.description,
        category: place.category,
        province: place.province,
        districtId: place.district,
        address: place.address,
        latitude: place.latitude,
        longitude: place.longitude,
        location: {
          type: 'Point',
          coordinates: [place.longitude, place.latitude],
        },
        googleMapsUrl: place.googleMapsUrl,
        accessibility: place.accessibility || {},
        rating: {
          average: place.rating || 0,
          reviewCount: place.reviewCount || 0,
        },
        photos: place.photos || [],
        tags: place.tags || [],
        isSystemPlace: true,
        visited: false,
        visitCount: place.visitCount || 0,
      });
      count++;
    }
    console.log(`Successfully imported ${count} places to Destination collection`);

    // Print summary
    console.log('\n--- Summary ---');
    const districtStats = await Place.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$district',
          count: { $sum: 1 },
        },
      },
      { $sort: { count: -1 } },
    ]);

    console.log(`Total districts: ${districtStats.length}`);
    console.log('Places per district:');
    districtStats.forEach((entry) => {
      console.log(`  ${entry._id}: ${entry.count} places`);
    });

    console.log('\nSeed completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error with data import:', error);
    process.exit(1);
  }
};

importData();
