const fs = require('fs');
const path = require('path');
const file = path.join(__dirname, '../src/controllers/explorationController.js');
let content = fs.readFileSync(file, 'utf8');

// 1. Remove UnlockLocation require
content = content.replace(/const UnlockLocation = require\('\.\.\/models\/UnlockLocation'\);\n/g, '');

// 2. Remove fallback aggregate from pickFallbackHometownDistrict
content = content.replace(/  const unlockGroup = await UnlockLocation\.aggregate\(\[\s+\{ \$match: \{ isActive: true \} \},\s+\{ \$group: \{ _id: '\$district', count: \{ \$sum: 1 \} \} \},\s+\{ \$sort: \{ count: -1 \} \},\s+\{ \$limit: 1 \},\s+\]\);\s+if \(unlockGroup\.length && unlockGroup\[0\]\._id\) \{\s+return unlockGroup\[0\]\._id;\s+\}\n\n/g, '');

// 3. assignExplorationForUser
content = content.replace(/  \/\/ Try to get places from the new Place collection first[\s\S]*?const hometownKey = normalizeKey\(hometownDistrict\);\s+hometownEntry = districtMap\.get\(hometownKey\);\s+\} else \{\s+\/\/ Fallback to UnlockLocation[\s\S]*?hometownEntry = districtMap\.get\(hometownKey\);\s+\}/,
`  const places = await Place.find({ isActive: true });

  if (places.length === 0) {
    throw new Error('No places found in the primary database for this district.');
  }

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
  hometownEntry = districtMap.get(hometownKey);`);

// 4. seedUnlockLocations
content = content.replace(/async function seedUnlockLocations[\s\S]*?\}\n\nasync function getAssignments/g, 'async function getAssignments');
content = content.replace(/,\s+seedUnlockLocations/g, '');

// 5. reassignLocation limits
content = content.replace(/    \/\/ If no places found, fall back to UnlockLocation\s+if \(\!locations\.length\) \{\s+locations = await UnlockLocation\.find\(\{\s+district: targetDistrict,\s+_id: \{ \$nin: userHistory \},\s+isActive: true,\s+\}\);\s+\}/g, '');
content = content.replace(/        if \(\!reassignedLocations\.length\) \{\s+reassignedLocations = await UnlockLocation\.find\(\{\s+district: assignment\.district,\s+_id: \{ \$nin: userHistory \},\s+isActive: true,\s+\}\);\s+\}/g, '');

// 6. verifyLocationVisit and getExplorationDashboard
content = content.replace(/    \/\/ Find location from Place collection first, then UnlockLocation\s+let location = await Place\.findById\(locationId\);\s+if \(\!location\) \{\s+location = await UnlockLocation\.findById\(locationId\);\s+\}/g, '    const location = await Place.findById(locationId);');

// 7. unlockHometown
content = content.replace(/    \/\/ First try to find in Place collection/g, '    // Find in Place collection');
content = content.replace(/    \/\/ Fall back to UnlockLocation if not found in Place\s+if \(\!hometownProvince\) \{\s+const unlockLocation = await UnlockLocation\.findOne\(\{\s+district: hometownKey,\s+isActive: true,\s+\}\);\s+hometownProvince = unlockLocation\?\.province;\s+\}/g, '');

// Replace 'fallback locations' message where appropriate
content = content.replace(/Fallback district/g, 'System district');
content = content.replace(/fallback locations/g, 'system locations');
content = content.replace(/pickFallbackHometownDistrict/g, 'pickSystemHometownDistrict');

fs.writeFileSync(file, content);
console.log('Refactoring complete');
