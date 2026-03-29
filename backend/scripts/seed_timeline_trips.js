require('dotenv').config({ path: '../../.env' });
const mongoose = require('mongoose');
const User = require('../src/models/User');
const Travel = require('../src/models/Travel');
const Destination = require('../src/models/Destination');

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
        title: 'Southern Heritage Road Trip',
        description: 'A 5-day journey exploring the history and beaches of the Southern Province.',
        startDate: new Date(now.getTime() - 45 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() - 40 * 24 * 60 * 60 * 1000),
        status: 'completed',
        locations: [
          { name: 'Galle Fort', day: 1 },
          { name: 'Lighthouse', day: 1 },
          { name: 'Unawatuna Beach', day: 2 },
          { name: 'Weligama Bay', day: 3 },
          { name: 'Matara Star Fort', day: 4 },
          { name: 'Dondra Head', day: 5 }
        ],
        destinationNodes: [
           { name: 'Galle Fort', lat: 6.0269, lng: 80.2144, visited: true },
           { name: 'Galle Lighthouse', lat: 6.0257, lng: 80.2186, visited: true },
           { name: 'Stilt Fishermen Weligama', lat: 5.9723, lng: 80.4187, visited: true },
           { name: 'Matara Star Fort', lat: 5.9520, lng: 80.5435, visited: true }
        ]
      },
      {
        userId: user.auth0Id,
        title: 'Highlands Mist Adventure',
        description: 'Scaling peaks and chasing waterfalls in Ella and Nuwara Eliya.',
        startDate: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() + 4 * 24 * 60 * 60 * 1000),
        status: 'active',
        locations: [
          { name: 'Ella Town', day: 1 },
          { name: 'Little Adams Peak', day: 2 },
          { name: 'Nine Arch Bridge', day: 2 },
          { name: 'Diyaluma Falls', day: 3 },
          { name: 'Liptons Seat', day: 4 }
        ],
        destinationNodes: [
           { name: 'Nine Arch Bridge', lat: 6.8768, lng: 81.0608, visited: true },
           { name: 'Little Adams Peak', lat: 6.8653, lng: 81.0620, visited: true },
           { name: 'Diyaluma Falls', lat: 6.7161, lng: 81.0303, visited: false },
           { name: 'Liptons Seat', lat: 6.7865, lng: 81.0155, visited: false }
        ]
      },
      {
        userId: user.auth0Id,
        title: 'Cultural Triangle Expedition',
        description: 'Visiting Sigiriya, Dambulla, and Polonnaruwa.',
        startDate: new Date(now.getTime() - 20 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() - 15 * 24 * 60 * 60 * 1000),
        status: 'canceled',
        locations: [
          { name: 'Sigiriya Rock', day: 1 },
          { name: 'Pidurangala', day: 1 },
          { name: 'Dambulla Cave Temple', day: 2 }
        ],
        destinationNodes: []
      },
      {
        userId: user.auth0Id,
        title: 'Northern Peninsula Exploration',
        description: 'Exploring the colorful northern tip and Casuarina beach.',
        startDate: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() + 20 * 24 * 60 * 60 * 1000),
        status: 'planned',
        locations: [
          { name: 'Nallur Kovil', day: 1 },
          { name: 'Jaffna Fort', day: 2 },
          { name: 'Point Pedro', day: 3 },
          { name: 'Casuarina Beach', day: 4 },
          { name: 'Delft Island', day: 5 }
        ],
        destinationNodes: [
           { name: 'Nallur Kandaswamy Kovil', lat: 9.6745, lng: 80.0298, visited: false },
           { name: 'Jaffna Fort', lat: 9.6611, lng: 80.0094, visited: false }
        ]
      }
    ];

    console.log(`🗑️ Clearing ANY existing trips & destinations for this user...`);
    await Travel.deleteMany({ userId: user.auth0Id });
    await Destination.deleteMany({ travelId: { $exists: true }, isSystemPlace: false });

    console.log(`🌱 Seeding multi-state Road Trips and Destinations...`);
    for (const tripData of tripsToSeed) {
      const { destinationNodes, ...travelData } = tripData;
      const travel = new Travel(travelData);
      await travel.save();
      console.log(`   ✅ Created Journey: "${travel.title}"`);

      for (const node of destinationNodes) {
         const dest = new Destination({
            name: node.name,
            latitude: node.lat,
            longitude: node.lng,
            visited: node.visited,
            travelId: travel._id,
            userId: user.auth0Id,
            isSystemPlace: false,
            location: { type: 'Point', coordinates: [node.lng, node.lat] }
         });
         await dest.save();
      }
      if (destinationNodes.length > 0) {
        console.log(`      📍 Inserted ${destinationNodes.length} destination nodes.`);
      }
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
