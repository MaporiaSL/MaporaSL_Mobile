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
        title: 'Galle Heritage Walk',
        description: 'Completed exploration of the historic Galle Fort and Lighthouse.',
        startDate: new Date(now.getTime() - 40 * 24 * 60 * 60 * 1000), // 40 days ago
        endDate: new Date(now.getTime() - 35 * 24 * 60 * 60 * 1000),
        locations: [
          { name: 'Galle Fort', day: 1 },
          { name: 'Galle Lighthouse', day: 1 },
          { name: 'Dutch Reformed Church', day: 1 }
        ]
      },
      {
        userId: user.auth0Id,
        title: 'Ella Mist & Peaks',
        description: 'Currently scaling Little Adams Peak and visiting Nine Arch Bridge.',
        startDate: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000), // Started 2 days ago
        endDate: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000),   // Ending in 3 days
        locations: [
          { name: 'Nine Arch Bridge', day: 1 },
          { name: 'Little Adams Peak', day: 2 },
          { name: 'Ravana Falls', day: 3 }
        ]
      },
      {
        userId: user.auth0Id,
        title: 'Wonders of Jaffna Peninsula',
        description: 'Exploring the colorful northern tip, Nallur Kovil, and Casuarina beach.',
        startDate: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000), // 14 days from now
        endDate: new Date(now.getTime() + 20 * 24 * 60 * 60 * 1000),
        locations: [
          { name: 'Nallur Kandaswamy Kovil', day: 1 },
          { name: 'Jaffna Fort', day: 2 },
          { name: 'Casuarina Beach', day: 3 }
        ]
      },
      {
        userId: user.auth0Id,
        title: 'Trincomalee Coastal Retreat',
        description: 'Diving around Pigeon Island, relaxing at Nilaveli, discovering Koneswaram Temple.',
        startDate: new Date(now.getTime() + 28 * 24 * 60 * 60 * 1000), // 28 days from now
        endDate: new Date(now.getTime() + 32 * 24 * 60 * 60 * 1000),
        locations: [
          { name: 'Nilaveli Beach', day: 1 },
          { name: 'Pigeon Island', day: 2 },
          { name: 'Koneswaram Temple', day: 3 }
        ]
      }
    ];

    console.log(`🗑️ Clearing ANY existing trips for this user to ensure fresh demo state...`);
    await Travel.deleteMany({ userId: user.auth0Id });

    console.log(`🌱 Seeding multi-state demo trips...`);
    for (const tripData of tripsToSeed) {
      const trip = new Travel(tripData);
      await trip.save();
      console.log(`   ✅ Inserted: "${trip.title}"`);
    }

    console.log(`🏆 Updating User Achievements...`);
    user.achievements = [
      { districtId: 'Colombo', progress: 100, unlockedAt: new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000) },
      { districtId: 'Galle', progress: 75, unlockedAt: null },
      { districtId: 'Matale', progress: 40, unlockedAt: null }
    ];
    await user.save();
    console.log(`   ✅ Colombo, Galle, and Matale progress updated.`);

    console.log('🎉 Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding timeline trips:', error);
    process.exit(1);
  }
}

seedTimelineTrips();
