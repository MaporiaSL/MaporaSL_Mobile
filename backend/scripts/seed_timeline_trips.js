require('dotenv').config({ path: '../../.env' });
const mongoose = require('mongoose');
const User = require('../src/models/User');
const Travel = require('../src/models/Travel');
const Destination = require('../src/models/Destination');
const Place = require('../src/models/Place');
const PlaceVisit = require('../src/models/PlaceVisit');

async function seedTimelineTrips() {
  try {
    const mongoUri = process.env.MONGODB_URI || process.env.MONGODB_STRING;
    console.log(`🔌 Connecting to MongoDB...`);
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // HARDCODED USER ID FROM APP LOGS
    const activeUserId = 'xFGv7GJG4yVJsdUE6irCodE7kR02';
    console.log(`👤 Targeted User ID: ${activeUserId}`);

    const now = new Date();
    
    const tripsToSeed = [
      {
        userId: activeUserId,
        title: 'Southern Heritage Road Trip',
        description: 'Exploring history and beaches of the Southern Province. Visited ancient forts and maritime museums.',
        startDate: new Date(now.getTime() - 45 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() - 40 * 24 * 60 * 60 * 1000),
        status: 'completed',
        locations: [
          { name: 'Galle Fort', day: 1 },
          { name: 'Unawatuna Beach', day: 2 },
          { name: 'Matara Star Fort', day: 4 }
        ],
        destinationNodes: [
           { name: 'Galle Fort', lat: 6.0269, lng: 80.2144, visited: true },
           { name: 'Matara Star Fort', lat: 5.9520, lng: 80.5435, visited: true }
        ]
      },
      {
        userId: activeUserId,
        title: 'Colombo City Pulse',
        description: 'Sacred temples and historical landmarks in the heart of the city.',
        startDate: new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() - 55 * 24 * 60 * 60 * 1000),
        status: 'completed',
        locations: [
          { name: 'Lotus Tower', day: 1 },
          { name: 'Gangaramaya Temple', day: 2 }
        ],
        destinationNodes: [
           { name: 'Lotus Tower', lat: 6.9298, lng: 79.8592, visited: true },
           { name: 'Gangaramaya Temple', lat: 6.9168, lng: 79.8549, visited: true }
        ]
      },
      {
        userId: activeUserId,
        title: 'Highlands Mist Adventure',
        description: 'Scaling peaks and chasing waterfalls in Ella.',
        startDate: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() + 4 * 24 * 60 * 60 * 1000),
        status: 'active',
        locations: [
          { name: 'Nine Arch Bridge', day: 1 },
          { name: 'Little Adams Peak', day: 2 }
        ],
        destinationNodes: [
           { name: 'Nine Arch Bridge', lat: 6.8768, lng: 81.0608, visited: true },
           { name: 'Little Adams Peak', lat: 6.8653, lng: 81.0620, visited: true }
        ]
      },
      {
        userId: activeUserId,
        title: 'Cultural Triangle 2.0',
        description: 'Ongoing exploration of ancient ruins and temples.',
        startDate: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() + 10 * 24 * 60 * 60 * 1000),
        status: 'active',
        locations: [
          { name: 'Anuradhapura', day: 1 }
        ],
        destinationNodes: [
           { name: 'Anuradhapura Sacred City', lat: 8.3114, lng: 80.4037, visited: true }
        ]
      },
      {
        userId: activeUserId,
        title: 'North Peninsula Exploration',
        description: 'The colorful north.',
        startDate: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() + 20 * 24 * 60 * 60 * 1000),
        status: 'planned',
        locations: [
          { name: 'Nallur Kovil', day: 1 }
        ],
        destinationNodes: [
           { name: 'Nallur Kovil', lat: 9.6745, lng: 80.0298, visited: false }
        ]
      },
      {
        userId: activeUserId,
        title: 'Eastern Wave Chaser',
        description: 'Surfing expedition.',
        startDate: new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() + 35 * 24 * 60 * 60 * 1000),
        status: 'planned',
        locations: [
          { name: 'Arugam Bay', day: 1 }
        ],
        destinationNodes: []
      },
      {
        userId: activeUserId,
        title: 'Sigiriya Expedition (Failed)',
        description: 'Canceled due to monsoon.',
        startDate: new Date(now.getTime() - 25 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() - 20 * 24 * 60 * 60 * 1000),
        status: 'canceled',
        locations: [
          { name: 'Sigiriya Rock', day: 1 }
        ],
        destinationNodes: []
      },
      {
        userId: activeUserId,
        title: 'Sinharaja Mystery',
        description: 'Rainforest trek canceled.',
        startDate: new Date(now.getTime() - 10 * 24 * 60 * 60 * 1000),
        endDate: new Date(now.getTime() - 8 * 24 * 60 * 60 * 1000),
        status: 'canceled',
        locations: [
          { name: 'Sinharaja Entry', day: 1 }
        ],
        destinationNodes: []
      }
    ];

    console.log(`🗑️ Clearing ONLY travels for this specific user ID...`);
    await Travel.deleteMany({ userId: activeUserId });
    await Destination.deleteMany({ userId: activeUserId, travelId: { $exists: true } });
    await PlaceVisit.deleteMany({ userId: activeUserId });
    
    console.log(`🌱 Seeding 8 High-Fidelity Road Trips...`);
    for (const tripData of tripsToSeed) {
      const { destinationNodes, ...travelData } = tripData;
      const travel = new Travel(travelData);
      await travel.save();
      console.log(`   ✅ Created Journey: "${travel.title}" [${travel.status}]`);

      for (const node of destinationNodes) {
         const dest = new Destination({
            name: node.name,
            latitude: node.lat,
            longitude: node.lng,
            visited: node.visited,
            travelId: travel._id,
            userId: activeUserId,
            isSystemPlace: false,
            location: { type: 'Point', coordinates: [node.lng, node.lat] }
         });
         await dest.save();
      }
    }

    // Force unlock trophies in User document
    console.log(`🏆 Updating User Achievement State...`);
    await User.updateOne(
      { auth0Id: activeUserId },
      { 
        $set: { 
          achievements: [
            { districtId: 'Colombo', progress: 100, unlockedAt: new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000) },
            { districtId: 'Galle', progress: 100, unlockedAt: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000) }
          ]
        } 
      }
    );
    console.log(`   ✅ Double Regional Mastery (Colombo, Galle) persistent.`);

    console.log('🎉 Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding:', error);
    process.exit(1);
  }
}

seedTimelineTrips();
