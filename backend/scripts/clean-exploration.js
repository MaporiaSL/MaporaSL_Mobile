const fs = require('fs');
const path = require('path');
const file = path.join(__dirname, '../src/controllers/explorationController.js');
let content = fs.readFileSync(file, 'utf8');

const startStr = 'async function seedUnlockLocations(req, res) {';
const startIdx = content.indexOf(startStr);
if (startIdx !== -1) {
  const endStr = 'async function getAssignments';
  const endIdx = content.indexOf(endStr, startIdx);
  if(endIdx !== -1) {
    content = content.slice(0, startIdx) + content.slice(endIdx);
  }
}

// Remove fallback blocks using exact string replacement
let reassign1 = `    // If no places found, fall back to UnlockLocation
    if (!locations.length) {
      locations = await UnlockLocation.find({
        district: targetDistrict,
        _id: { $nin: userHistory },
        isActive: true,
      });
    }`;
content = content.replace(reassign1, '');

let reassign2 = `        if (!reassignedLocations.length) {
          reassignedLocations = await UnlockLocation.find({
            district: assignment.district,
            _id: { $nin: userHistory },
            isActive: true,
          });
        }`;
content = content.replace(reassign2, '');

let hometown1 = `      const unlockLocation = await UnlockLocation.findOne({
        district: hometownKey,
        isActive: true,
      });
      hometownProvince = unlockLocation?.province;`;
content = content.replace(hometown1, '');

content = content.replace(/,\s+seedUnlockLocations/g, '');

fs.writeFileSync(file, content);
console.log('Cleaned');
