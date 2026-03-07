const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const PrePlannedTrip = require('../models/PrePlannedTrip');

const sampleTrips = [
  {
    title: 'Southern Coastal Escape',
    description: 'Explore the beautiful beaches and historic sites of the Southern Province.',
    district: 'Galle',
    durationDays: 3,
    xpReward: 350,
    difficulty: 'Easy',
    startingPoint: 'Galle Fort',
    tags: ['Beach', 'History', 'Coastal'],
    placeIds: ['galle_fort', 'unawatuna_beach', 'mirissa_whale_watching'],
    itinerary: {
      'day_1': 'Walk around the historic Galle Fort and enjoy the sunset.',
      'day_2': 'Relax at Unawatuna beach and visit the Japanese Peace Pagoda.',
      'day_3': 'Head to Mirissa for whale watching and the Coconut Tree Hill.'
    }
  },
  {
    title: 'Hill Country Heritage',
    description: 'Experience the misty mountains, tea estates, and colonial charm of the hills.',
    district: 'Kandy',
    durationDays: 4,
    xpReward: 500,
    difficulty: 'Moderate',
    startingPoint: 'Kandy City',
    tags: ['Mountains', 'Tea', 'Heritage'],
    placeIds: ['temple_of_tooth', 'peradeniya_gardens', 'ella_rock', 'nine_arch_bridge'],
    itinerary: {
      'day_1': 'Visit the Temple of the Sacred Tooth Relic and Kandy Lake.',
      'day_2': 'Explore the Royal Botanical Gardens in Peradeniya.',
      'day_3': 'Take the scenic train to Ella and hike Little Adams Peak.',
      'day_4': 'Visit the Nine Arch Bridge and Ella Rock.'
    }
  },
  {
    title: 'Cultural Triangle Journey',
    description: 'A deep dive into the ancient civilizations and spiritual heart of Sri Lanka.',
    district: 'Anuradhapura',
    durationDays: 5,
    xpReward: 750,
    difficulty: 'Hard',
    startingPoint: 'Anuradhapura',
    tags: ['Ancient', 'Culture', 'Temples'],
    placeIds: ['sigiriya_rock', 'dambulla_cave_temple', 'polonnaruwa_ruins'],
    itinerary: {
      'day_1': 'Explore the ancient ruins of Anuradhapura.',
      'day_2': 'Climb the Sigiriya Lion Rock fortress.',
      'day_3': 'Visit the Dambulla Cave Temple complex.',
      'day_4': 'Discover the medieval city of Polonnaruwa.',
      'day_5': 'Climb Mihintale for a panoramic view.'
    }
  }
];

async function seedPreplanned() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB.');

    console.log('Clearing existing pre-planned trips...');
    await PrePlannedTrip.deleteMany({});

    console.log('Seeding sample pre-planned trips...');
    await PrePlannedTrip.insertMany(sampleTrips);

    console.log('Seeding completed successfully!');
  } catch (error) {
    console.error('Seeding failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB.');
  }
}

seedPreplanned();
