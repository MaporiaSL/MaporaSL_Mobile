const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const mongoose = require('mongoose');
const connectDB = require('../src/config/db');
const User = require('../src/models/User');

const DRY_RUN = process.argv.includes('--dry-run');

function hasText(value) {
  return String(value || '').trim().length > 0;
}

function isProfileSetupComplete(user) {
  const name = String(user.name || '').trim();
  const district = String(user.hometownDistrict || '').trim();
  const language = String(user.preferredLanguage || '').trim();

  return name.length >= 2 && hasText(district) && hasText(language);
}

function summarize(users) {
  const total = users.length;
  const completed = users.filter((u) => u.profileSetupCompleted === true).length;
  const missingCompletedAt = users.filter(
    (u) => u.profileSetupCompleted === true && !u.profileSetupCompletedAt,
  ).length;

  return {
    total,
    completed,
    notCompleted: total - completed,
    missingCompletedAt,
  };
}

async function run() {
  await connectDB();

  const users = await User.find(
    {},
    {
      _id: 1,
      name: 1,
      hometownDistrict: 1,
      preferredLanguage: 1,
      profileSetupCompleted: 1,
      profileSetupCompletedAt: 1,
      updatedAt: 1,
      createdAt: 1,
    },
  ).lean();

  const before = summarize(users);
  const now = new Date();
  const bulkOps = [];

  let markCompleted = 0;
  let markIncomplete = 0;
  let setCompletedAtOnly = 0;

  for (const user of users) {
    const shouldBeCompleted = isProfileSetupComplete(user);
    const patch = {};

    if (shouldBeCompleted) {
      if (user.profileSetupCompleted !== true) {
        patch.profileSetupCompleted = true;
        markCompleted += 1;
      }
      if (!user.profileSetupCompletedAt) {
        patch.profileSetupCompletedAt = user.updatedAt || user.createdAt || now;
        setCompletedAtOnly += 1;
      }
    } else {
      if (user.profileSetupCompleted !== false) {
        patch.profileSetupCompleted = false;
        markIncomplete += 1;
      }
      if (user.profileSetupCompletedAt) {
        patch.profileSetupCompletedAt = null;
      }
    }

    if (Object.keys(patch).length > 0) {
      bulkOps.push({
        updateOne: {
          filter: { _id: user._id },
          update: { $set: patch },
        },
      });
    }
  }

  if (!DRY_RUN && bulkOps.length > 0) {
    await User.bulkWrite(bulkOps, { ordered: false });
  }

  const afterUsers = DRY_RUN
    ? users.map((u) => {
        const shouldBeCompleted = isProfileSetupComplete(u);
        return {
          ...u,
          profileSetupCompleted: shouldBeCompleted,
          profileSetupCompletedAt: shouldBeCompleted
            ? (u.profileSetupCompletedAt || u.updatedAt || u.createdAt || now)
            : null,
        };
      })
    : await User.find(
        {},
        {
          _id: 1,
          profileSetupCompleted: 1,
          profileSetupCompletedAt: 1,
        },
      ).lean();

  const after = summarize(afterUsers);

  console.log(`Mode: ${DRY_RUN ? 'DRY RUN (no writes)' : 'WRITE'}`);
  console.log('Before:', before);
  console.log('After:', after);
  console.log('Changes:');
  console.log(`  Marked completed: ${markCompleted}`);
  console.log(`  Marked incomplete: ${markIncomplete}`);
  console.log(`  Set completedAt timestamp: ${setCompletedAtOnly}`);
  console.log(`  Total documents updated: ${bulkOps.length}`);

  await mongoose.connection.close();
}

run()
  .then(() => {
    console.log('Profile setup completion backfill complete');
    process.exit(0);
  })
  .catch(async (error) => {
    console.error('Profile setup completion backfill failed:', error);
    await mongoose.connection.close();
    process.exit(1);
  });
