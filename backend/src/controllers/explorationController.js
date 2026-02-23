const fs = require('fs');
const path = require('path');
const UnlockLocation = require('../models/UnlockLocation');
const Place = require('../models/Place');
const UserDistrictAssignment = require('../models/UserDistrictAssignment');
const User = require('../models/User');

const COOLDOWN_MS = 5 * 60 * 1000;
const MAX_DISTANCE_METERS = 100;
const MAX_ACCURACY_METERS = 50;
const MIN_SAMPLE_COUNT = 3;
const SAMPLE_INTERVAL_SECONDS = 2;

const XP_CONFIG = {
  sameDistrict: { base: 10, bonusMax: 4 },
  sameProvince: { base: 12, bonusMax: 4 },
  otherProvince: { base: 15, bonusMax: 4 },
};

const COUNT_TIERS = {
  sameDistrict: { min: 4, max: 7 },
  sameProvince: { min: 4, max: 6 },
  otherProvince: { min: 3, max: 5 },
};

function normalizeKey(value) {
  return value?.toString().trim().toLowerCase();
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function shuffle(array) {
  const cloned = array.slice();
  for (let i = cloned.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [cloned[i], cloned[j]] = [cloned[j], cloned[i]];
  }
  return cloned;
}

function toRadians(value) {
  return (value * Math.PI) / 180;
}

function distanceMeters(lat1, lon1, lat2, lon2) {
  const earthRadius = 6371000;
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadius * c;
}

function buildDistrictMap(locations) {
  const map = new Map();
  locations.forEach((location) => {
    const key = normalizeKey(location.district);
    if (!map.has(key)) {
      map.set(key, {
        district: location.district,
        province: location.province,
        locationIds: [],
      });
    }
    map.get(key).locationIds.push(location._id);
  });
  return map;
}

function resolveTier(districtKey, provinceKey, hometownKey, hometownProvinceKey) {
  if (districtKey === hometownKey) return 'sameDistrict';
  if (provinceKey === hometownProvinceKey) return 'sameProvince';
  return 'otherProvince';
}

function computeXp(tier) {
  const config = XP_CONFIG[tier] || XP_CONFIG.otherProvince;
  return config.base + getRandomInt(0, config.bonusMax);
}

async function updateExplorationProgress(userId) {
  const assignments = await UserDistrictAssignment.find({ userId });
  const totalAssigned = assignments.reduce(
    (sum, assignment) => sum + assignment.assignedCount,
    0
  );
  const totalVisited = assignments.reduce(
    (sum, assignment) => sum + assignment.visitedCount,
    0
  );

  const unlockedDistricts = assignments
    .filter((assignment) => assignment.unlockedAt)
    .map((assignment) => assignment.district);

  const provinceGroups = new Map();
  assignments.forEach((assignment) => {
    const provinceKey = normalizeKey(assignment.province);
    if (!provinceGroups.has(provinceKey)) {
      provinceGroups.set(provinceKey, {
        province: assignment.province,
        total: 0,
        unlocked: 0,
      });
    }
    const group = provinceGroups.get(provinceKey);
    group.total += 1;
    if (assignment.unlockedAt) group.unlocked += 1;
  });

  const unlockedProvinces = [];
  provinceGroups.forEach((group) => {
    if (group.unlocked === group.total && group.total > 0) {
      unlockedProvinces.push(group.province);
    }
  });

  await User.findOneAndUpdate(
    { auth0Id: userId },
    {
      $set: {
        explorationUnlockedDistricts: unlockedDistricts,
        explorationUnlockedProvinces: unlockedProvinces,
        explorationStats: { totalAssigned, totalVisited },
        updatedAt: new Date(),
      },
    }
  );

  return { totalAssigned, totalVisited, unlockedDistricts, unlockedProvinces };
}

async function assignExplorationForUser(userId, hometownDistrict, options = {}) {
  // Try to get places from the new Place collection first
  // Falls back to UnlockLocation for backward compatibility
  
  let placesByDistrict = new Map();
  let hometownEntry = null;
  
  // Try to use the new Place model (ever-growing list)
  const places = await Place.find({ isActive: true });
  
  if (places.length > 0) {
    // Use dynamic Place collection
    const districtMap = new Map();
    places.forEach((place) => {
      const key = normalizeKey(place.district);
      if (!districtMap.has(key)) {
        districtMap.set(key, {
          district: place.district,
          province: place.province,
          placeIds: [],
        });
      }
      districtMap.get(key).placeIds.push(place._id);
    });
    
    placesByDistrict = districtMap;
    const hometownKey = normalizeKey(hometownDistrict);
    hometownEntry = districtMap.get(hometownKey);
  } else {
    // Fallback to UnlockLocation for backward compatibility
    const locations = await UnlockLocation.find({ isActive: true });
    if (!locations.length) {
      throw new Error('No places found in either Place or UnlockLocation collections');
    }
    
    const districtMap = buildDistrictMap(locations);
    placesByDistrict = districtMap;
    const hometownKey = normalizeKey(hometownDistrict);
    hometownEntry = districtMap.get(hometownKey);
  }
  
  if (!hometownEntry) {
    throw new Error('Hometown district not found in places catalog');
  }

  const hometownProvinceKey = normalizeKey(hometownEntry.province);
  const assignments = [];
  let totalAssigned = 0;

  placesByDistrict.forEach((entry, districtKey) => {
    const tier = resolveTier(
      districtKey,
      normalizeKey(entry.province),
      normalizeKey(hometownDistrict),
      hometownProvinceKey
    );
    const range = COUNT_TIERS[tier];
    const locationIds = entry.locationIds || entry.placeIds;
    const maxPossible = locationIds.length;
    const count = Math.min(getRandomInt(range.min, range.max), maxPossible);
    const selected = shuffle(locationIds).slice(0, count);

    totalAssigned += selected.length;

    assignments.push({
      userId,
      district: entry.district,
      province: entry.province,
      assignedLocationIds: selected,
      visitedLocationIds: [],
      visitedLocationProofs: [],
      assignedCount: selected.length,
      visitedCount: 0,
      unlockedAt: null,
    });
  });

  await UserDistrictAssignment.deleteMany({ userId });
  await UserDistrictAssignment.insertMany(assignments, { ordered: false });

  const now = new Date();
  await User.findOneAndUpdate(
    { auth0Id: userId },
    {
      $set: {
        hometownDistrict: hometownEntry.district,
        explorationUnlockedDistricts: [],
        explorationUnlockedProvinces: [],
        explorationStats: { totalAssigned, totalVisited: 0 },
        explorationLastUnlockAt: null,
        assignmentFixedAt: options.assignmentFixedAt || now,
        updatedAt: now,
      },
    }
  );

  return { assignments, totalAssigned };
}

async function seedUnlockLocations(req, res) {
  try {
    const jsonPath = path.resolve(
      __dirname,
      '../../..',
      'project_resorces',
      'places_seed_data_2026.json'
    );
    const raw = fs.readFileSync(jsonPath, 'utf-8');
    const data = JSON.parse(raw);

    if (!data?.districts?.length) {
      return res.status(400).json({ error: 'Seed data missing districts' });
    }

    const operations = [];
    data.districts.forEach((districtEntry) => {
      districtEntry.attractions.forEach((attraction) => {
        operations.push({
          updateOne: {
            filter: {
              district: districtEntry.district,
              name: attraction.name,
            },
            update: {
              $set: {
                district: districtEntry.district,
                province: districtEntry.province,
                name: attraction.name,
                type: attraction.type,
                latitude: attraction.lat,
                longitude: attraction.lon,
                isActive: true,
              },
            },
            upsert: true,
          },
        });
      });
    });

    if (!operations.length) {
      return res.status(400).json({ error: 'No seed operations created' });
    }

    const result = await UnlockLocation.bulkWrite(operations, { ordered: false });

    const counts = await UnlockLocation.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$district',
          count: { $sum: 1 },
        },
      },
    ]);

    const underMin = counts.filter((entry) => entry.count < 3);
    if (underMin.length) {
      return res.status(400).json({
        error: 'Some districts have fewer than 3 locations',
        districts: underMin,
      });
    }

    return res.status(200).json({
      message: 'Unlock locations seeded',
      result,
    });
  } catch (error) {
    console.error('Seed unlock locations error:', error);
    return res.status(500).json({ error: 'Failed to seed unlock locations' });
  }
}

async function getAssignments(req, res) {
  try {
    let assignments = await UserDistrictAssignment.find({
      userId: req.userId,
    });

    // If user has no assignments yet, initialize them
    if (assignments.length === 0) {
      const user = await User.findOne({ auth0Id: req.userId });
      if (!user || !user.hometownDistrict) {
        return res.status(400).json({
          error: 'User must set hometown district before starting exploration',
        });
      }

      // Create assignments for this user
      await assignExplorationForUser(req.userId, user.hometownDistrict);
      
      // Fetch the newly created assignments
      assignments = await UserDistrictAssignment.find({
        userId: req.userId,
      });
    }

    const locationIds = assignments.flatMap(
      (assignment) => assignment.assignedLocationIds
    );

    // Try to get locations from the new Place collection first
    let locations = await Place.find({
      _id: { $in: locationIds },
    });

    // If no places found, fall back to UnlockLocation
    if (locations.length === 0) {
      locations = await UnlockLocation.find({
        _id: { $in: locationIds },
      });
    }

    const locationMap = new Map(
      locations.map((location) => [location._id.toString(), location])
    );

    const payload = assignments.map((assignment) => {
      const locationsForDistrict = assignment.assignedLocationIds
        .map((id) => {
          const location = locationMap.get(id.toString());
          if (!location) return null;
          const visited = assignment.visitedLocationIds.some(
            (visitedId) => visitedId.toString() === id.toString()
          );
          return {
            id: location._id,
            name: location.name,
            type: location.type || location.category || 'attraction',
            latitude: location.latitude,
            longitude: location.longitude,
            description: location.description || null,
            category: location.category || null,
            photos: location.photos || [],
            visited,
          };
        })
        .filter(Boolean);

      return {
        district: assignment.district,
        province: assignment.province,
        assignedCount: assignment.assignedCount,
        visitedCount: assignment.visitedCount,
        unlockedAt: assignment.unlockedAt,
        locations: locationsForDistrict,
      };
    });

    res.status(200).json({ assignments: payload });
  } catch (error) {
    console.error('Get assignments error:', error);
    res.status(500).json({ error: 'Failed to fetch assignments' });
  }
}

async function getDistricts(req, res) {
  try {
    const assignments = await UserDistrictAssignment.find({
      userId: req.userId,
    });

    const payload = assignments.map((assignment) => ({
      district: assignment.district,
      province: assignment.province,
      assignedCount: assignment.assignedCount,
      visitedCount: assignment.visitedCount,
      unlockedAt: assignment.unlockedAt,
    }));

    res.status(200).json({ districts: payload });
  } catch (error) {
    console.error('Get districts error:', error);
    res.status(500).json({ error: 'Failed to fetch district progress' });
  }
}

async function initializeExploration(req, res) {
  try {
    const { hometownDistrict } = req.body;

    if (!hometownDistrict) {
      return res.status(400).json({ error: 'hometownDistrict is required' });
    }

    // Check if user already has assignments
    const existingAssignments = await UserDistrictAssignment.findOne({
      userId: req.userId,
    });

    if (existingAssignments) {
      return res.status(400).json({
        error: 'Exploration already initialized for this user',
      });
    }

    // Update user hometown
    await User.findOneAndUpdate(
      { auth0Id: req.userId },
      { hometownDistrict },
      { new: true },
    );

    // Create assignments
    await assignExplorationForUser(req.userId, hometownDistrict);

    res.status(200).json({
      message: 'Exploration initialized',
      hometownDistrict,
    });
  } catch (error) {
    console.error('Initialize exploration error:', error);
    res.status(500).json({ error: error.message || 'Failed to initialize exploration' });
  }
}

async function visitLocation(req, res) {
  try {
    const { locationId, samples } = req.body;

    if (!locationId || !Array.isArray(samples)) {
      return res
        .status(400)
        .json({ error: 'locationId and samples are required' });
    }

    if (samples.length < MIN_SAMPLE_COUNT) {
      return res.status(400).json({
        error: `At least ${MIN_SAMPLE_COUNT} samples are required`,
      });
    }

    const user = await User.findOne({ auth0Id: req.userId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.explorationLastUnlockAt) {
      const diff = Date.now() - new Date(user.explorationLastUnlockAt).getTime();
      if (diff < COOLDOWN_MS) {
        return res
          .status(429)
          .json({ error: 'Cooldown active. Try again later.' });
      }
    }

    // Find location from Place collection first, then UnlockLocation
    let location = await Place.findById(locationId);
    if (!location) {
      location = await UnlockLocation.findById(locationId);
    }

    if (!location) {
      return res.status(404).json({ error: 'Location not found' });
    }

    const assignment = await UserDistrictAssignment.findOne({
      userId: req.userId,
      district: location.district,
    });

    if (!assignment) {
      return res.status(404).json({ error: 'Assignment not found' });
    }

    const assignedIds = assignment.assignedLocationIds.map((id) => id.toString());
    if (!assignedIds.includes(locationId)) {
      return res.status(403).json({ error: 'Location not assigned to user' });
    }

    const alreadyVisited = assignment.visitedLocationIds.some(
      (id) => id.toString() === locationId
    );

    if (alreadyVisited) {
      return res.status(200).json({
        message: 'Location already visited',
        district: assignment.district,
      });
    }

    const validSamples = samples.filter((sample) => {
      if (
        sample == null ||
        typeof sample.latitude !== 'number' ||
        typeof sample.longitude !== 'number' ||
        typeof sample.accuracyMeters !== 'number'
      ) {
        return false;
      }

      if (sample.accuracyMeters > MAX_ACCURACY_METERS) return false;

      const distance = distanceMeters(
        sample.latitude,
        sample.longitude,
        location.latitude,
        location.longitude
      );
      return distance <= MAX_DISTANCE_METERS;
    });

    if (validSamples.length < MIN_SAMPLE_COUNT) {
      return res.status(400).json({
        error: 'Not enough valid GPS samples to verify visit',
        requiredSamples: MIN_SAMPLE_COUNT,
        sampleIntervalSeconds: SAMPLE_INTERVAL_SECONDS,
        radiusMeters: MAX_DISTANCE_METERS,
      });
    }

    const accuracyMeters = Math.max(
      ...validSamples.map((sample) => sample.accuracyMeters)
    );

    assignment.visitedLocationIds.push(location._id);
    assignment.visitedLocationProofs.push({
      locationId: location._id,
      visitedAt: new Date(),
      accuracyMeters,
      source: 'gps_verified',
      adminReason: null,
    });
    assignment.visitedCount = assignment.visitedLocationIds.length;
    if (assignment.visitedCount >= assignment.assignedCount) {
      assignment.unlockedAt = new Date();
    }

    await assignment.save();

    const hometownLocation = await Place.findOne({
      district: user.hometownDistrict,
      isActive: true,
    });
    
    let hometownProvince = null;
    if (!hometownLocation) {
      const unlockLocation = await UnlockLocation.findOne({
        district: user.hometownDistrict,
        isActive: true,
      });
      hometownProvince = unlockLocation?.province;
    } else {
      hometownProvince = hometownLocation.province;
    }

    const hometownProvinceKey = normalizeKey(hometownProvince);

    const tier = resolveTier(
      normalizeKey(location.district),
      normalizeKey(location.province),
      normalizeKey(user.hometownDistrict),
      hometownProvinceKey
    );
    const xpAmount = computeXp(tier);

    user.xpTotal = (user.xpTotal || 0) + xpAmount;
    user.xpLedger.push({
      timestamp: new Date(),
      source: 'mapExploration',
      amount: xpAmount,
      location: {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracyMeters,
      },
      locationId: location._id,
      note: 'Map exploration visit',
    });
    user.explorationLastUnlockAt = new Date();

    await user.save();

    const progress = await updateExplorationProgress(req.userId);

    res.status(200).json({
      message: 'Location verified',
      xpAwarded: xpAmount,
      progress,
    });
  } catch (error) {
    console.error('Visit location error:', error);
    res.status(500).json({ error: 'Failed to verify location visit' });
  }
}

async function rerollAssignments(req, res) {
  try {
    const { reason, reasonDetail } = req.body;
    const user = await User.findOne({ auth0Id: req.userId });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.rerollUsedAt) {
      return res.status(400).json({ error: 'Reroll already used' });
    }

    const totalAssigned = user.explorationStats?.totalAssigned || 0;
    const totalVisited = user.explorationStats?.totalVisited || 0;
    const progressPercent = totalAssigned
      ? (totalVisited / totalAssigned) * 100
      : 0;

    if (progressPercent >= 35) {
      return res
        .status(400)
        .json({ error: 'Reroll not allowed after 35% exploration' });
    }

    if (!reason) {
      return res.status(400).json({ error: 'Reroll reason is required' });
    }

    if (reason.toLowerCase() === 'other' && !reasonDetail) {
      return res.status(400).json({
        error: 'reasonDetail is required when reason is Other',
      });
    }

    const mapXpTotal = user.xpLedger
      .filter((entry) => entry.source === 'mapExploration')
      .reduce((sum, entry) => sum + entry.amount, 0);

    if (mapXpTotal > 0) {
      user.xpTotal = Math.max(0, (user.xpTotal || 0) - mapXpTotal);
      user.xpLedger.push({
        timestamp: new Date(),
        source: 'rerollReset',
        amount: -mapXpTotal,
        location: {
          latitude: null,
          longitude: null,
          accuracyMeters: null,
        },
        locationId: null,
        note: 'Reroll reset (map exploration XP removed)',
      });
    }

    user.rerollUsedAt = new Date();
    user.lastRerollAt = new Date();
    user.lastRerollReason = reasonDetail ? `${reason} - ${reasonDetail}` : reason;
    user.explorationUnlockedDistricts = [];
    user.explorationUnlockedProvinces = [];
    user.explorationStats = { totalAssigned: 0, totalVisited: 0 };
    user.explorationLastUnlockAt = null;

    await user.save();

    await assignExplorationForUser(req.userId, user.hometownDistrict, {
      assignmentFixedAt: user.assignmentFixedAt || new Date(),
    });

    res.status(200).json({ message: 'Reroll completed' });
  } catch (error) {
    console.error('Reroll error:', error);
    res.status(500).json({ error: 'Failed to reroll assignments' });
  }
}

async function adminOverrideVisit(req, res) {
  try {
    const { userId, locationId, reason } = req.body;
    if (!userId || !locationId || !reason) {
      return res
        .status(400)
        .json({ error: 'userId, locationId, and reason are required' });
    }

    // Find location from Place collection first, then UnlockLocation
    let location = await Place.findById(locationId);
    if (!location) {
      location = await UnlockLocation.findById(locationId);
    }

    if (!location) {
      return res.status(404).json({ error: 'Location not found' });
    }

    const assignment = await UserDistrictAssignment.findOne({
      userId,
      district: location.district,
    });

    if (!assignment) {
      return res.status(404).json({ error: 'Assignment not found' });
    }

    const assignedIds = assignment.assignedLocationIds.map((id) => id.toString());
    if (!assignedIds.includes(locationId)) {
      return res.status(403).json({ error: 'Location not assigned to user' });
    }

    const alreadyVisited = assignment.visitedLocationIds.some(
      (id) => id.toString() === locationId
    );

    if (!alreadyVisited) {
      assignment.visitedLocationIds.push(location._id);
      assignment.visitedLocationProofs.push({
        locationId: location._id,
        visitedAt: new Date(),
        accuracyMeters: 0,
        source: 'admin_override',
        adminReason: reason,
      });
      assignment.visitedCount = assignment.visitedLocationIds.length;
      if (assignment.visitedCount >= assignment.assignedCount) {
        assignment.unlockedAt = new Date();
      }
      await assignment.save();
    }

    await updateExplorationProgress(userId);

    res.status(200).json({ message: 'Override applied' });
  } catch (error) {
    console.error('Admin override error:', error);
    res.status(500).json({ error: 'Failed to apply override' });
  }
}

module.exports = {
  seedUnlockLocations,
  assignExplorationForUser,
  getAssignments,
  getDistricts,
  initializeExploration,
  visitLocation,
  rerollAssignments,
  adminOverrideVisit,
};
