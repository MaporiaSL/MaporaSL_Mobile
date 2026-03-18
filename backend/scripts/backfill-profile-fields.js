const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const mongoose = require('mongoose');
const connectDB = require('../src/config/db');
const User = require('../src/models/User');

const MAX_BIO_LENGTH = 200;
const MAX_DISTRICT_LENGTH = 60;
const MAX_INTERESTS = 10;

function toTitleCase(value) {
  return String(value || '')
    .toLowerCase()
    .split(' ')
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function normalizeLanguage(value) {
  const v = String(value || '').trim().toLowerCase();
  if (v === 'sinhala') return 'Sinhala';
  if (v === 'tamil') return 'Tamil';
  return 'English';
}

function normalizeInterests(interests) {
  if (!Array.isArray(interests)) return [];
  const map = new Map();
  for (const item of interests) {
    const normalized = toTitleCase(item).slice(0, 30);
    if (!normalized) continue;
    const key = normalized.toLowerCase();
    if (!map.has(key)) map.set(key, normalized);
    if (map.size >= MAX_INTERESTS) break;
  }
  return Array.from(map.values());
}

function computePatch(user) {
  const patch = {};

  const bio = String(user.bio || '').trim().slice(0, MAX_BIO_LENGTH);
  if (bio !== (user.bio || '')) patch.bio = bio;
  if (user.bio == null) patch.bio = '';

  const hometownDistrict = toTitleCase(user.hometownDistrict || '').slice(0, MAX_DISTRICT_LENGTH);
  if ((user.hometownDistrict || '') !== hometownDistrict) {
    patch.hometownDistrict = hometownDistrict;
  }

  const preferredLanguage = normalizeLanguage(user.preferredLanguage);
  if ((user.preferredLanguage || 'English') !== preferredLanguage) {
    patch.preferredLanguage = preferredLanguage;
  }

  const travelInterests = normalizeInterests(user.travelInterests);
  const previous = Array.isArray(user.travelInterests) ? user.travelInterests : [];
  if (JSON.stringify(previous) !== JSON.stringify(travelInterests)) {
    patch.travelInterests = travelInterests;
  }

  if (user.preferredLanguage == null) patch.preferredLanguage = 'English';
  if (!Array.isArray(user.travelInterests)) patch.travelInterests = [];

  return patch;
}

async function run() {
  await connectDB();

  const users = await User.find({}, {
    _id: 1,
    auth0Id: 1,
    bio: 1,
    hometownDistrict: 1,
    preferredLanguage: 1,
    travelInterests: 1,
  });

  let updated = 0;
  let scanned = 0;

  for (const user of users) {
    scanned += 1;
    const patch = computePatch(user);
    if (Object.keys(patch).length === 0) continue;

    await User.updateOne({ _id: user._id }, { $set: patch });
    updated += 1;
  }

  console.log(`Scanned users: ${scanned}`);
  console.log(`Updated users: ${updated}`);

  await mongoose.connection.close();
}

run()
  .then(() => {
    console.log('Profile backfill complete');
    process.exit(0);
  })
  .catch(async (error) => {
    console.error('Profile backfill failed:', error);
    await mongoose.connection.close();
    process.exit(1);
  });
