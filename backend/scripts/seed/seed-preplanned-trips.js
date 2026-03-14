const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const PrePlannedTrip = require('./src/models/PrePlannedTrip');

const sampleTrips = [
  {
    title: 'Cultural Triangle Quest',
    description: 'Explore Sri Lanka\'s ancient temples and cultural sites in the heart of the island.',
    difficulty: 'Moderate',
    durationDays: 4,
    xpReward: 250,
    startingPoint: 'Kandy',
    placeIds: ['Kandy Temple', 'Sigiriya Rock', 'Polonnaruwa Ancient City', 'Dambulla Cave Temple'],
    tags: ['Culture', 'History', 'Adventure'],
  },
  {
    title: 'Southern Beaches Paradise',
    description: 'Relax on pristine beaches and explore coastal villages along the south coast.',
    difficulty: 'Easy',
    durationDays: 3,
    xpReward: 150,
    startingPoint: 'Colombo',
    placeIds: ['Mirissa Beach', 'Unawatuna', 'Galle Fort', 'Matara Beach'],
    tags: ['Beach', 'Relaxation', 'Nature'],
  },
  {
    title: 'Mountain High Adventure',
    description: 'Trek through misty mountains, tea plantations, and cool hill stations.',
    difficulty: 'Hard',
    durationDays: 5,
    xpReward: 400,
    startingPoint: 'Kandy',
    placeIds: ['Nuwara Eliya', 'Adam\'s Peak', 'Tea Plantations', 'Horton Plains National Park'],
    tags: ['Mountain', 'Adventure', 'Nature'],
  },
  {
    title: 'Northern Expedition',
    description: 'Discover the unique culture and history of Sri Lanka\'s northern peninsula.',
    difficulty: 'Moderate',
    durationDays: 4,
    xpReward: 280,
    startingPoint: 'Jaffna',
    placeIds: ['Jaffna Fort', 'Nallur Kandasamy Temple', 'Kankesanthurai Beach', 'Mullaitivu'],
    tags: ['Culture', 'History', 'Beach'],
  },
  {
    title: 'Whale Watching & Wildlife',
    description: 'Spot blue whales, dolphins, and explore diverse ecosystems along the coast.',
    difficulty: 'Moderate',
    durationDays: 3,
    xpReward: 200,
    startingPoint: 'Mirissa',
    placeIds: ['Mirissa Whale Watch', 'Dondra Lighthouse', 'Matara Beach', 'Trincomalee'],
    tags: ['Nature', 'Adventure', 'Wildlife'],
  },
  {
    title: 'City Explorer Pass',
    description: 'Discover vibrant city life, museums, markets, and modern attractions.',
    difficulty: 'Easy',
    durationDays: 2,
    xpReward: 100,
    startingPoint: 'Colombo',
    placeIds: ['National Museum', 'Colombo Fort', 'Galle Face Hotel', 'Colombo Market'],
    tags: ['City', 'Culture', 'History'],
  },
  {
    title: 'East Coast Island Hopping',
    description: 'Visit tropical islands and pristine beaches on the east coast.',
    difficulty: 'Easy',
    durationDays: 3,
    xpReward: 180,
    startingPoint: 'Trinco',
    placeIds: ['Pigeon Island', 'Nilaveli Beach', 'Trincomalee Fort', 'Hot Wells Beach'],
    tags: ['Beach', 'Island', 'Relaxation'],
  },
];

async function seedPreplannedTrips() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB Connected');

    // Clear existing
    await PrePlannedTrip.deleteMany({});
    console.log('Cleared existing pre-planned trips');

    // Insert samples
    const inserted = await PrePlannedTrip.insertMany(sampleTrips);
    console.log(`Inserted ${inserted.length} pre-planned trips`);

    console.log('\nSample trips:');
    inserted.forEach((trip, i) => {
      console.log(`${i + 1}. ${trip.title} (${trip.durationDays} days, ${trip.difficulty})`);
    });

    await mongoose.disconnect();
    console.log('\nDone!');
  } catch (err) {
    console.error('Seed error:', err);
    process.exit(1);
  }
}

seedPreplannedTrips();
