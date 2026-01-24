const turf = require('@turf/turf');

/**
 * Calculate distance between two points using Haversine formula
 * @param {number} lat1 - Latitude of point 1
 * @param {number} lon1 - Longitude of point 1
 * @param {number} lat2 - Latitude of point 2
 * @param {number} lon2 - Longitude of point 2
 * @returns {number} Distance in kilometers
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
  const from = turf.point([lon1, lat1]);
  const to = turf.point([lon2, lat2]);
  const distance = turf.distance(from, to, { units: 'kilometers' });
  return Math.round(distance * 100) / 100; // Round to 2 decimal places
}

/**
 * Calculate convex hull (boundary polygon) from array of destinations
 * @param {Array} destinations - Array of destination objects with latitude/longitude
 * @returns {Object|null} GeoJSON Polygon feature or null if insufficient points
 */
function calculateConvexHull(destinations) {
  if (!destinations || destinations.length < 3) {
    return null; // Need at least 3 points for a polygon
  }

  try {
    // Convert destinations to GeoJSON points
    const points = destinations.map(dest => 
      turf.point([dest.longitude, dest.latitude])
    );
    
    // Create feature collection
    const featureCollection = turf.featureCollection(points);
    
    // Calculate convex hull
    const hull = turf.convex(featureCollection);
    
    return hull;
  } catch (error) {
    console.error('Error calculating convex hull:', error);
    return null;
  }
}

/**
 * Calculate total route distance by summing distances between consecutive destinations
 * @param {Array} destinations - Array of destination objects with latitude/longitude
 * @returns {number} Total distance in kilometers
 */
function calculateRouteDistance(destinations) {
  if (!destinations || destinations.length < 2) {
    return 0;
  }

  let totalDistance = 0;
  
  for (let i = 0; i < destinations.length - 1; i++) {
    const current = destinations[i];
    const next = destinations[i + 1];
    
    totalDistance += calculateDistance(
      current.latitude,
      current.longitude,
      next.latitude,
      next.longitude
    );
  }
  
  return Math.round(totalDistance * 100) / 100;
}

/**
 * Order destinations by proximity (nearest neighbor algorithm)
 * Simple TSP approximation for route optimization
 * @param {Array} destinations - Array of destination objects
 * @param {Object} startPoint - Optional starting point {latitude, longitude}
 * @returns {Array} Ordered array of destinations
 */
function orderDestinationsByProximity(destinations, startPoint = null) {
  if (!destinations || destinations.length <= 1) {
    return destinations;
  }

  const ordered = [];
  const remaining = [...destinations];
  
  // Start from given point or first destination
  let current = startPoint || remaining[0];
  if (!startPoint) {
    ordered.push(remaining.shift());
  }
  
  // Greedy nearest neighbor
  while (remaining.length > 0) {
    let nearestIndex = 0;
    let minDistance = Infinity;
    
    for (let i = 0; i < remaining.length; i++) {
      const dist = calculateDistance(
        current.latitude,
        current.longitude,
        remaining[i].latitude,
        remaining[i].longitude
      );
      
      if (dist < minDistance) {
        minDistance = dist;
        nearestIndex = i;
      }
    }
    
    const nearest = remaining.splice(nearestIndex, 1)[0];
    ordered.push(nearest);
    current = nearest;
  }
  
  return ordered;
}

/**
 * Calculate bounding box from array of destinations
 * @param {Array} destinations - Array of destination objects with latitude/longitude
 * @returns {Object} Bounding box {swLat, swLng, neLat, neLng} or null
 */
function calculateBoundingBox(destinations) {
  if (!destinations || destinations.length === 0) {
    return null;
  }

  try {
    const points = destinations.map(dest => 
      turf.point([dest.longitude, dest.latitude])
    );
    
    const featureCollection = turf.featureCollection(points);
    const bbox = turf.bbox(featureCollection);
    
    // bbox format: [minLng, minLat, maxLng, maxLat]
    return {
      swLng: bbox[0], // Southwest longitude
      swLat: bbox[1], // Southwest latitude
      neLng: bbox[2], // Northeast longitude
      neLat: bbox[3]  // Northeast latitude
    };
  } catch (error) {
    console.error('Error calculating bounding box:', error);
    return null;
  }
}

/**
 * Calculate area of a polygon in square kilometers
 * @param {Object} polygon - GeoJSON Polygon feature
 * @returns {number} Area in square kilometers
 */
function calculateArea(polygon) {
  if (!polygon || !polygon.geometry) {
    return 0;
  }

  try {
    const area = turf.area(polygon); // Returns area in square meters
    return Math.round((area / 1000000) * 100) / 100; // Convert to sq km, round to 2 decimals
  } catch (error) {
    console.error('Error calculating area:', error);
    return 0;
  }
}

/**
 * Calculate perimeter/length of a polygon or line in kilometers
 * @param {Object} feature - GeoJSON Polygon or LineString feature
 * @returns {number} Length in kilometers
 */
function calculateLength(feature) {
  if (!feature || !feature.geometry) {
    return 0;
  }

  try {
    const length = turf.length(feature, { units: 'kilometers' });
    return Math.round(length * 100) / 100;
  } catch (error) {
    console.error('Error calculating length:', error);
    return 0;
  }
}

/**
 * Check if a point is within a given radius of another point
 * @param {number} lat1 - Latitude of center point
 * @param {number} lon1 - Longitude of center point
 * @param {number} lat2 - Latitude of test point
 * @param {number} lon2 - Longitude of test point
 * @param {number} radiusKm - Radius in kilometers
 * @returns {boolean} True if within radius
 */
function isWithinRadius(lat1, lon1, lat2, lon2, radiusKm) {
  const distance = calculateDistance(lat1, lon1, lat2, lon2);
  return distance <= radiusKm;
}

/**
 * Get center point (centroid) of multiple destinations
 * @param {Array} destinations - Array of destination objects with latitude/longitude
 * @returns {Object|null} Center point {latitude, longitude} or null
 */
function getCenterPoint(destinations) {
  if (!destinations || destinations.length === 0) {
    return null;
  }

  try {
    const points = destinations.map(dest => 
      turf.point([dest.longitude, dest.latitude])
    );
    
    const featureCollection = turf.featureCollection(points);
    const center = turf.center(featureCollection);
    
    return {
      longitude: center.geometry.coordinates[0],
      latitude: center.geometry.coordinates[1]
    };
  } catch (error) {
    console.error('Error calculating center point:', error);
    return null;
  }
}

module.exports = {
  calculateDistance,
  calculateConvexHull,
  calculateRouteDistance,
  orderDestinationsByProximity,
  calculateBoundingBox,
  calculateArea,
  calculateLength,
  isWithinRadius,
  getCenterPoint
};
