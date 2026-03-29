require('dotenv').config({ path: '../../.env' });
const mongoose = require('mongoose');
const User = require('../src/models/User');
const Travel = require('../src/models/Travel');

async function seedTimelineTrips() {
  try {
    const mongoUri = process.env.MONGODB_URI || process.env.MONGODB_STRING;
    if (!mongoUri) {
      console.error('❌ MONGODB_URI not found in .env');
      process.exit(1);
    }
    
    console.log(`🔌 Connecting to MongoDB...`);
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    const targetEmail = 'anuja.20231258@iit.ac.lk';
    const user = await User.findOne({ email: targetEmail });
    
    if (!user) {
      console.error(`❌ User with email ${targetEmail} not found!`);
      process.exit(1);
    }

    console.log(`👤 Found user: ${user.name} (auth0Id: ${user.auth0Id})`);

    const now = new Date();
    
    const tripsToSeed = [
      {
        userId: user.auth0Id,
        title: 'Wonders of Jaffna Peninsula',
        description: 'Exploring the colorful northern tip, Nallur Kovil, and Casuarina beach.',
        startDate: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000), // 14 days from now
        endDate: new Date(now.getTime() + 20 * 24 * 60 * 60 * 1000),
        locations: ['Nallur Kandaswamy Kovil', 'Jaffna Fort', 'Casuarina Beach']
      },
      {
        userId: user.auth0Id,
        title: 'Trincomalee Coastal Retreat',
        description: 'Diving around Pigeon Island, relaxing at Nilaveli, discovering Koneswaram Temple.',
        startDate: new Date(now.getTime() + 28 * 24 * 60 * 60 * 1000), // 28 days from now
        endDate: new Date(now.getTime() + 32 * 24 * 60 * 60 * 1000),
        locations: ['Nilaveli Beach', 'Pigeon Island', 'Koneswaram Temple']
      }
    ];

    console.log(`🗑️ Clearing any existing mock/upcoming trips for this user...`);
    // Remove existing trips for this user that start in the future to prevent duplicates
    await Travel.deleteMany({ userId: user.auth0Id, startDate: { $gt: now } });

    console.log(`🌱 Seeding upcoming timeline trips...`);
    for (const tripData of tripsToSeed) {
      const trip = new Travel(tripData);
      await trip.save();
      console.log(`✅ Inserted trip: "${trip.title}"`);
    }

    console.log('🎉 Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding timeline trips:', error);
    process.exit(1);
  }
}

seedTimelineTrips();
