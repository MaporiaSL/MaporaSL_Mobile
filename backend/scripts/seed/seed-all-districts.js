const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const connectDB = require('../../src/config/db');
const Place = require('../../src/models/Place');

// All 25 districts with geographic centers for reference
const ALL_SRI_LANKA_DISTRICTS = [
  { district: 'Colombo', province: 'Western Province', lat: 6.9271, lng: 80.6304 },
  { district: 'Gampaha', province: 'Western Province', lat: 7.0744, lng: 80.1793 },
  { district: 'Kalutara', province: 'Western Province', lat: 6.4348, lng: 80.3520 },
  { district: 'Matara', province: 'Southern Province', lat: 5.7491, lng: 80.5353 },
  { district: 'Galle', province: 'Southern Province', lat: 6.0535, lng: 80.2170 },
  { district: 'Hambantota', province: 'Southern Province', lat: 6.1250, lng: 81.1266 },
  { district: 'Jaffna', province: 'Northern Province', lat: 9.6615, lng: 80.7974 },
  { district: 'Mullaitivu', province: 'Northern Province', lat: 8.3047, lng: 81.8697 },
  { district: 'Vavuniya', province: 'Northern Province', lat: 8.7542, lng: 80.8089 },
  { district: 'Mannar', province: 'Northern Province', lat: 8.9833, lng: 79.9167 },
  { district: 'Batticaloa', province: 'Eastern Province', lat: 7.7137, lng: 81.6947 },
  { district: 'Trincomalee', province: 'Eastern Province', lat: 8.5874, lng: 81.2344 },
  { district: 'Ampara', province: 'Eastern Province', lat: 7.2906, lng: 81.6771 },
  { district: 'Kandy', province: 'Central Province', lat: 7.2906, lng: 80.6337 },
  { district: 'Matale', province: 'Central Province', lat: 7.5658, lng: 80.6278 },
  { district: 'Nuwara Eliya', province: 'Central Province', lat: 6.9271, lng: 80.7816 },
  { district: 'Badulla', province: 'Uva Province', lat: 6.9900, lng: 81.0550 },
  { district: 'Monaragala', province: 'Uva Province', lat: 6.8263, lng: 81.3584 },
  { district: 'Ratnapura', province: 'Sabaragamuwa Province', lat: 6.6828, lng: 80.4006 },
  { district: 'Kegalle', province: 'Sabaragamuwa Province', lat: 7.2548, lng: 80.3374 },
  { district: 'Kurunegala', province: 'North Western Province', lat: 7.4884, lng: 80.6353 },
  { district: 'Puttalam', province: 'North Western Province', lat: 8.0328, lng: 79.8276 },
  { district: 'Anuradhapura', province: 'North Central Province', lat: 8.3263, lng: 80.4303 },
  { district: 'Polonnaruwa', province: 'North Central Province', lat: 7.9408, lng: 81.0033 },
];

async function seedAllDistricts() {
  try {
    await connectDB();
    console.log('Connected to MongoDB');

    // Get all existing places
    const existingPlaces = await Place.find({ isActive: true });
    console.log(`Found ${existingPlaces.length} existing places`);

    if (existingPlaces.length === 0) {
      console.error('No existing places to seed from!');
      process.exit(1);
    }

    // Get districts that already have places
    const placedDistricts = new Set(existingPlaces.map(p => p.district?.toLowerCase().trim()));
    console.log(`Districts with places: ${placedDistricts.size}`);

    // Find districts without places
    const missingDistricts = ALL_SRI_LANKA_DISTRICTS.filter(
      d => !placedDistricts.has(d.district.toLowerCase().trim())
    );

    console.log(`\nDistricts needing places: ${missingDistricts.length}`);
    missingDistricts.forEach(d => console.log(`  - ${d.district} (${d.province})`));

    // Distribute existing places to missing districts
    let placesAdded = 0;
    let placeIndex = 0;

    for (const districtInfo of missingDistricts) {
      // Assign 5-8 places to each missing district by cloning existing places
      const placeCount = Math.floor(Math.random() * 4) + 5; // 5-8 places
      
      for (let i = 0; i < placeCount; i++) {
        const templatePlace = existingPlaces[placeIndex % existingPlaces.length];
        
        // Create a new place by cloning the template
        const newPlace = new Place({
          name: `${templatePlace.name} (${districtInfo.district})`,
          description: templatePlace.description || `Popular attraction in ${districtInfo.district}`,
          category: templatePlace.category || 'attraction',
          district: districtInfo.district,
          province: districtInfo.province,
          latitude: districtInfo.lat + (Math.random() * 0.2 - 0.1), // Add slight random offset
          longitude: districtInfo.lng + (Math.random() * 0.2 - 0.1),
          photos: templatePlace.photos || [],
          isActive: true,
          createdAt: new Date(),
          updatedAt: new Date(),
        });

        await newPlace.save();
        placesAdded++;
        placeIndex++;
      }

      console.log(`✅ Added ${placeCount} places to ${districtInfo.district}`);
    }

    // Verify all districts now have places
    console.log('\n--- Final District Count ---');
    const finalCounts = await Place.aggregate([
      { $match: { isActive: true } },
      { $group: { _id: '$district', count: { $sum: 1 } } },
      { $sort: { _id: 1 } },
    ]);

    finalCounts.forEach(dc => {
      console.log(`${dc._id}: ${dc.count} places`);
    });

    console.log(`\n✅ Seeding complete! Added ${placesAdded} new places`);
    console.log(`Total districts with places: ${finalCounts.length}/25`);
    console.log(`Total places in database: ${existingPlaces.length + placesAdded}`);

  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('✅ Database connection closed');
  }
}

seedAllDistricts();
