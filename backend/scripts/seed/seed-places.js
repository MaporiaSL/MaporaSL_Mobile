const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

require('dotenv').config({ path: path.resolve(__dirname, '../../../.env') });

const Place = require('../../src/models/Place');
const Destination = require('../../src/models/Destination');

const PLACE_CATEGORIES = new Set([
  'temple',
  'beach',
  'mountain',
  'historical',
  'wildlife',
  'city',
  'food',
  'waterfall',
  'garden',
  'cultural',
  'adventure',
  'other',
]);

const DESTINATION_CATEGORIES = new Set([
  'temple',
  'beach',
  'mountain',
  'historical',
  'wildlife',
  'city',
  'forest',
  'park',
  'waterfall',
  'garden',
  'food',
]);

function normalizeCategory(rawCategory, target) {
  const value = String(rawCategory || 'other').toLowerCase().trim();

  const aliases = {
    cultural: 'historical',
    adventure: 'mountain',
    forest: 'wildlife',
    park: 'city',
    other: 'city',
  };

  if (target === 'place') {
    if (PLACE_CATEGORIES.has(value)) {
      return value;
    }
    return value in aliases ? aliases[value] : 'other';
  }

  if (DESTINATION_CATEGORIES.has(value)) {
    return value;
  }
  return value in aliases ? aliases[value] : 'city';
}

const SAMPLE_PLACES = [
  {
    name: 'Galle Face Green',
    description: 'Popular oceanfront urban park ideal for sunset walks and local street food.',
    category: 'city',
    province: 'Western Province',
    district: 'Colombo',
    address: 'Galle Face, Colombo 03',
    latitude: 6.9271,
    longitude: 79.8448,
    rating: 4.3,
    reviewCount: 240,
    tags: ['sunset', 'street-food', 'family'],
    accessibility: { difficulty: 'easy', estimatedDuration: '1-2 hours', entryFee: 'Free' },
    photos: [],
  },
  {
    name: 'Gangaramaya Temple',
    description: 'Historic Buddhist temple with museum collections and iconic architecture.',
    category: 'temple',
    province: 'Western Province',
    district: 'Colombo',
    address: '61 Sri Jinarathana Rd, Colombo 02',
    latitude: 6.9167,
    longitude: 79.8562,
    rating: 4.5,
    reviewCount: 360,
    tags: ['heritage', 'buddhist', 'culture'],
    accessibility: { difficulty: 'easy', estimatedDuration: '1 hour', entryFee: '500 LKR' },
    photos: [],
  },
  {
    name: 'Sigiriya Rock Fortress',
    description: 'Ancient rock citadel with frescoes and panoramic views from the summit.',
    category: 'historical',
    province: 'Central Province',
    district: 'Matale',
    address: 'Sigiriya',
    latitude: 7.957,
    longitude: 80.7603,
    rating: 4.8,
    reviewCount: 520,
    tags: ['unesco', 'hiking', 'views'],
    accessibility: { difficulty: 'moderate', estimatedDuration: '2-3 hours', entryFee: '30 USD' },
    photos: [],
  },
  {
    name: 'Temple of the Tooth',
    description: 'Sacred Buddhist temple in Kandy housing a revered relic and cultural rituals.',
    category: 'temple',
    province: 'Central Province',
    district: 'Kandy',
    address: 'Sri Dalada Veediya, Kandy',
    latitude: 7.2936,
    longitude: 80.6413,
    rating: 4.7,
    reviewCount: 480,
    tags: ['religious', 'heritage', 'festival'],
    accessibility: { difficulty: 'easy', estimatedDuration: '1-2 hours', entryFee: '1500 LKR' },
    photos: [],
  },
  {
    name: 'Nine Arches Bridge',
    description: 'Scenic colonial-era railway bridge surrounded by tea country landscapes.',
    category: 'historical',
    province: 'Uva Province',
    district: 'Badulla',
    address: 'Ella',
    latitude: 6.8768,
    longitude: 81.0617,
    rating: 4.6,
    reviewCount: 310,
    tags: ['train', 'photography', 'nature'],
    accessibility: { difficulty: 'easy', estimatedDuration: '1 hour', entryFee: 'Free' },
    photos: [],
  },
  {
    name: 'Yala National Park',
    description: 'Sri Lanka wildlife hotspot known for leopard sightings and safari experiences.',
    category: 'wildlife',
    province: 'Southern Province',
    district: 'Hambantota',
    address: 'Yala',
    latitude: 6.3725,
    longitude: 81.5167,
    rating: 4.6,
    reviewCount: 270,
    tags: ['safari', 'leopard', 'wildlife'],
    accessibility: { difficulty: 'easy', estimatedDuration: '4-6 hours', entryFee: '43 USD' },
    photos: [],
  },
  {
    name: 'Unawatuna Beach',
    description: 'Calm and swimmable beach with cafes, snorkeling spots, and sunset views.',
    category: 'beach',
    province: 'Southern Province',
    district: 'Galle',
    address: 'Unawatuna',
    latitude: 6.0102,
    longitude: 80.248,
    rating: 4.4,
    reviewCount: 295,
    tags: ['beach', 'swimming', 'sunset'],
    accessibility: { difficulty: 'easy', estimatedDuration: '2-4 hours', entryFee: 'Free' },
    photos: [],
  },
  {
    name: 'Ravana Falls',
    description: 'Roadside waterfall near Ella, popular for quick scenic stops and photos.',
    category: 'waterfall',
    province: 'Uva Province',
    district: 'Badulla',
    address: 'A23, Ella-Wellawaya Rd',
    latitude: 6.8433,
    longitude: 81.0536,
    rating: 4.2,
    reviewCount: 190,
    tags: ['waterfall', 'nature', 'road-trip'],
    accessibility: { difficulty: 'easy', estimatedDuration: '30-60 minutes', entryFee: 'Free' },
    photos: [],
  },
];

function normalizeSeed(seedData) {
  if (Array.isArray(seedData)) {
    return seedData;
  }

  if (seedData && Array.isArray(seedData.places)) {
    return seedData.places;
  }

  if (seedData && Array.isArray(seedData.districts)) {
    const places = [];
    for (const districtEntry of seedData.districts) {
      for (const attraction of districtEntry.attractions || []) {
        places.push({
          name: attraction.name,
          description: attraction.description || null,
          category: attraction.category || 'other',
          province: districtEntry.province,
          district: districtEntry.district,
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
      }
    }
    return places;
  }

  return [];
}

function getSeedCandidates() {
  return [
    path.resolve(__dirname, '../../../project_resources/places_seed_data_2026.json'),
    path.resolve(__dirname, '../../../project_resources/sri_lanka_real_places_100.json'),
    path.resolve(__dirname, '../../../project_resources/Placesresorces/final_places_seed.json'),
    path.resolve(__dirname, '../../../project_resources/places_seed_data.json'),
  ];
}

async function connectDb() {
  if (!process.env.MONGODB_URI) {
    throw new Error('MONGODB_URI is missing. Add it to the project root .env');
  }
  await mongoose.connect(process.env.MONGODB_URI);
}

function toPlaceDoc(place) {
  return {
    name: place.name,
    description: place.description || null,
    category: normalizeCategory(place.category, 'place'),
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
    contributor: { userId: null, username: null },
    verified: true,
    isActive: true,
    seasonality: place.seasonality || 'year-round',
    accessibility: place.accessibility || {},
    tags: place.tags || [],
  };
}

function toDestinationDoc(place) {
  return {
    name: place.name,
    description: place.description || null,
    notes: place.description || null,
    category: normalizeCategory(place.category, 'destination'),
    province: place.province,
    districtId: place.district,
    address: place.address || null,
    latitude: place.latitude,
    longitude: place.longitude,
    location: {
      type: 'Point',
      coordinates: [place.longitude, place.latitude],
    },
    googleMapsUrl: place.googleMapsUrl || null,
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
  };
}

async function seedPlaces() {
  try {
    await connectDb();
    console.log('MongoDB connected');

    let places = [];
    for (const candidate of getSeedCandidates()) {
      if (!fs.existsSync(candidate)) {
        continue;
      }

      const raw = fs.readFileSync(candidate, 'utf-8');
      const parsed = JSON.parse(raw);
      const normalized = normalizeSeed(parsed);
      if (normalized.length > 0) {
        places = normalized;
        console.log(`Using seed file: ${candidate}`);
        break;
      }
    }

    if (places.length === 0) {
      places = SAMPLE_PLACES;
      console.log('No external seed files found. Using built-in sample places.');
    }

    console.log(`Preparing to seed ${places.length} places...`);

    // Replace system places for predictable testing.
    await Place.deleteMany({ source: 'system' });
    await Destination.deleteMany({ isSystemPlace: true });

    await Place.insertMany(places.map(toPlaceDoc), { ordered: true });
    await Destination.insertMany(places.map(toDestinationDoc), { ordered: true });

    const districtCounts = await Place.aggregate([
      { $match: { isActive: true } },
      { $group: { _id: '$district', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);

    console.log('Seed complete. District counts:');
    districtCounts.forEach((row) => {
      console.log(`- ${row._id}: ${row.count}`);
    });

    console.log('Sample places are ready for UI and logic testing.');
    process.exit(0);
  } catch (error) {
    console.error('Place seeding failed:', error.message);
    process.exit(1);
  }
}

seedPlaces();
