const fs = require('fs');
const file = 'd:/Github_projects/gemified-travel-portfolio/backend/src/controllers/explorationController.js';
let content = fs.readFileSync(file, 'utf8');

// replace 1
let out = '';
let inFallback1 = false;
let lines = content.split('\n');
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('// If no places found, fall back to UnlockLocation')) {
    i += 5; // skip the next lines
    continue;
  }
  if (lines[i].includes('if (!reassignedLocations.length) {') && lines[i+1].includes('reassignedLocations = await UnlockLocation.find({')) {
    i += 6;
    continue;
  }
  if (lines[i].includes('// Fall back to UnlockLocation if not found in Place')) {
    i += 6;
    continue;
  }
  out += lines[i] + '\n';
}

fs.writeFileSync(file, out);
