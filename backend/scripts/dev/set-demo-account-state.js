const path = require('path');
const mongoose = require('mongoose');

require('dotenv').config({ path: path.resolve(__dirname, '../../../.env') });

const connectDB = require('../../src/config/db');
const User = require('../../src/models/User');
const UserDistrictAssignment = require('../../src/models/UserDistrictAssignment');
const Place = require('../../src/models/Place');

function normalize(value) {
  return String(value || '').trim().toLowerCase();
}

function parseArgs(argv) {
  const args = {
    user: '',
    mode: 'status',
    district: '',
    dryRun: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === '--user' || token === '-u') {
      args.user = argv[i + 1] || '';
      i += 1;
      continue;
    }
    if (token === '--mode' || token === '-m') {
      args.mode = normalize(argv[i + 1] || 'status');
      i += 1;
      continue;
    }
    if (token === '--district' || token === '-d') {
      args.district = String(argv[i + 1] || '').trim();
      i += 1;
      continue;
    }
    if (token === '--dry-run') {
      args.dryRun = true;
      continue;
    }
  }

  return args;
}

function summarizeAssignment(assignment) {
  return `${assignment.district}: ${assignment.visitedCount}/${assignment.assignedCount} visited${assignment.unlockedAt ? ' (unlocked)' : ''}`;
}

function pickTargetAssignment(assignments, districtHint, minAssigned) {
  if (districtHint) {
    const hinted = assignments.find(
      (item) => normalize(item.district) === normalize(districtHint)
    );
    if (hinted) return hinted;
  }

  const candidates = assignments
    .filter((item) => item.assignedCount >= minAssigned)
    .sort((a, b) => a.assignedCount - b.assignedCount);

  return candidates[0] || null;
}

function buildVisitedProofs(locationIds) {
  const now = Date.now();
  return locationIds.map((locationId, index) => ({
    locationId,
    visitedAt: new Date(now - (locationIds.length - index) * 1000),
    accuracyMeters: 5,
    source: 'admin_override',
    adminReason: 'demo-state-script',
  }));
}

function computeUnlockedProvinces(assignments) {
  const provinceMap = new Map();

  assignments.forEach((assignment) => {
    const key = normalize(assignment.province);
    if (!provinceMap.has(key)) {
      provinceMap.set(key, {
        province: assignment.province,
        total: 0,
        unlocked: 0,
      });
    }
    const group = provinceMap.get(key);
    group.total += 1;
    if (assignment.unlockedAt) group.unlocked += 1;
  });

  const unlocked = [];
  provinceMap.forEach((group) => {
    if (group.total > 0 && group.total === group.unlocked) {
      unlocked.push(group.province);
    }
  });
  return unlocked;
}

async function recomputeUserProgress(auth0Id, dryRun) {
  const assignments = await UserDistrictAssignment.find({ userId: auth0Id });
  const totalAssigned = assignments.reduce((sum, a) => sum + (a.assignedCount || 0), 0);
  const totalVisited = assignments.reduce((sum, a) => sum + (a.visitedCount || 0), 0);
  const unlockedDistricts = assignments
    .filter((a) => Boolean(a.unlockedAt))
    .map((a) => a.district);
  const unlockedProvinces = computeUnlockedProvinces(assignments);

  if (!dryRun) {
    await User.updateOne(
      { auth0Id },
      {
        $set: {
          explorationUnlockedDistricts: unlockedDistricts,
          explorationUnlockedProvinces: unlockedProvinces,
          explorationStats: {
            totalAssigned,
            totalVisited,
          },
          // Clear cooldown so back-to-back demo checks are possible.
          explorationLastUnlockAt: null,
          updatedAt: new Date(),
        },
      }
    );
  }

  return {
    totalAssigned,
    totalVisited,
    unlockedDistricts,
    unlockedProvinces,
  };
}

async function printNextLocationHint(assignment) {
  const visitedSet = new Set(
    (assignment.visitedLocationIds || []).map((id) => id.toString())
  );
  const nextId = (assignment.assignedLocationIds || []).find(
    (id) => !visitedSet.has(id.toString())
  );

  if (!nextId) {
    console.log('No unvisited location left in selected district.');
    return;
  }

  const place = await Place.findById(nextId).select('name district latitude longitude');
  if (!place) {
    console.log(`Next location id: ${nextId.toString()} (place document not found)`);
    return;
  }

  console.log('Next location to test:');
  console.log(`- id: ${place._id}`);
  console.log(`- name: ${place.name}`);
  console.log(`- district: ${place.district}`);
  console.log(`- latitude: ${place.latitude}`);
  console.log(`- longitude: ${place.longitude}`);
}

async function run() {
  const args = parseArgs(process.argv.slice(2));
  const validModes = new Set(['status', 'visit', 'unlock', 'reset']);

  if (!validModes.has(args.mode)) {
    console.error('Invalid --mode. Use one of: status, visit, unlock, reset');
    process.exit(1);
  }

  if (!args.user) {
    console.error('Missing --user. Example: --user anuja.20231258@iit.ac.lk');
    process.exit(1);
  }

  try {
    await connectDB();

    const user = await User.findOne({
      $or: [
        { email: normalize(args.user) },
        { auth0Id: args.user },
      ],
    });

    if (!user) {
      console.error(`User not found for: ${args.user}`);
      process.exit(1);
    }

    const assignments = await UserDistrictAssignment.find({ userId: user.auth0Id });

    if (!assignments.length) {
      console.error('User has no exploration assignments yet. Open exploration once or initialize first.');
      process.exit(1);
    }

    if (args.mode === 'status') {
      const progress = await recomputeUserProgress(user.auth0Id, true);
      console.log(`User: ${user.email} (${user.auth0Id})`);
      console.log(`Progress: ${progress.totalVisited}/${progress.totalAssigned}`);
      console.log(`Unlocked districts: ${progress.unlockedDistricts.length}`);
      console.log(`Unlocked provinces: ${progress.unlockedProvinces.length}`);
      assignments.slice(0, 10).forEach((a) => console.log(`- ${summarizeAssignment(a)}`));
      if (assignments.length > 10) {
        console.log(`... and ${assignments.length - 10} more districts`);
      }
      return;
    }

    if (args.mode === 'reset') {
      assignments.forEach((assignment) => {
        assignment.visitedLocationIds = [];
        assignment.visitedLocationProofs = [];
        assignment.visitedCount = 0;
        assignment.unlockedAt = null;
      });

      if (!args.dryRun) {
        await Promise.all(assignments.map((assignment) => assignment.save()));
      }

      const progress = await recomputeUserProgress(user.auth0Id, args.dryRun);
      console.log(args.dryRun ? '[dry-run] Reset preview complete.' : 'Reset complete.');
      console.log(`Progress now: ${progress.totalVisited}/${progress.totalAssigned}`);
      return;
    }

    const target = pickTargetAssignment(
      assignments,
      args.district,
      args.mode === 'visit' ? 2 : 1
    );

    if (!target) {
      console.error('No suitable district assignment found for requested mode.');
      process.exit(1);
    }

    const allIds = (target.assignedLocationIds || []).map((id) => id);
    let keepVisitedCount = 0;

    if (args.mode === 'visit') {
      // Keep 0..(n-2) visited so next visit is a normal discovery, not district unlock.
      keepVisitedCount = Math.max(0, allIds.length - 2);
    } else if (args.mode === 'unlock') {
      // Keep n-1 visited so next visit unlocks the district.
      keepVisitedCount = Math.max(0, allIds.length - 1);
    }

    const visitedIds = allIds.slice(0, keepVisitedCount);

    target.visitedLocationIds = visitedIds;
    target.visitedLocationProofs = buildVisitedProofs(visitedIds);
    target.visitedCount = visitedIds.length;
    target.unlockedAt = null;

    if (!args.dryRun) {
      await target.save();
    }

    const progress = await recomputeUserProgress(user.auth0Id, args.dryRun);

    console.log(args.dryRun ? '[dry-run] Scenario preview complete.' : 'Scenario prepared.');
    console.log(`User: ${user.email}`);
    console.log(`Mode: ${args.mode}`);
    console.log(`District: ${target.district}`);
    console.log(`District state: ${target.visitedCount}/${target.assignedCount}`);
    console.log(`Overall progress: ${progress.totalVisited}/${progress.totalAssigned}`);
    await printNextLocationHint(target);
  } finally {
    await mongoose.connection.close();
  }
}

run().catch((error) => {
  console.error('Failed to set demo account state:', error.message);
  process.exit(1);
});
