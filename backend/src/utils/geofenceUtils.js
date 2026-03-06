/**
 * Geofence radius categories and failsafes based on attraction type.
 */
const RADIUS_CONFIG = {
  SMALL: { primary: 300, failsafe: 500 },
  MEDIUM: { primary: 1000, failsafe: 1500 },
  LARGE: { primary: 3000, failsafe: 5000 },
  XLARGE: { primary: 10000, failsafe: 15000 }
};

const TYPE_MAPPING = {
  // SMALL
  'buddhist temple': 'SMALL',
  'temple': 'SMALL',
  'stupa': 'SMALL',
  'statue': 'SMALL',
  'monument': 'SMALL',
  'museum': 'SMALL',
  'ruin': 'SMALL',
  'lighthouse': 'SMALL',
  'market': 'SMALL',
  'observation tower': 'SMALL',
  'urban park': 'SMALL',
  'observation deck': 'SMALL',
  'landmark': 'SMALL',

  // MEDIUM
  'botanical garden': 'MEDIUM',
  'zoo': 'MEDIUM',
  'theme park': 'MEDIUM',
  'ancient fortress': 'MEDIUM',
  'temple complex': 'MEDIUM',
  'sacred city': 'MEDIUM',
  'dutch fort': 'MEDIUM',
  'tea plantation': 'MEDIUM',
  'ancient temple': 'MEDIUM',
  'fortress': 'MEDIUM',

  // LARGE
  'beach': 'LARGE',
  'lake': 'LARGE',
  'reservoir': 'LARGE',
  'waterfall': 'LARGE',
  'mountain': 'LARGE',
  'viewpoint': 'LARGE',
  'trekking': 'LARGE',
  'wetland': 'LARGE',
  'lagoon': 'LARGE',
  'marine park': 'LARGE',
  'cliff': 'LARGE',
  'forest': 'LARGE',

  // XLARGE
  'national park': 'XLARGE',
  'wildlife sanctuary': 'XLARGE',
  'rainforest': 'XLARGE',
  'nature reserve': 'XLARGE'
};

/**
 * Gets the geofence radius config for a given attraction type.
 * @param {string} type - The attraction type (e.g., 'National Park')
 * @returns {object} { primary, failsafe, category }
 */
function getRadiusConfig(type) {
  const normalizedType = type?.toLowerCase().trim() || '';
  
  // Find exact match or partial match
  let category = 'SMALL'; // Default
  
  for (const [key, cat] of Object.entries(TYPE_MAPPING)) {
    if (normalizedType.includes(key)) {
      category = cat;
      break;
    }
  }
  
  return {
    ...RADIUS_CONFIG[category],
    category
  };
}

module.exports = {
  getRadiusConfig,
  RADIUS_CONFIG
};
