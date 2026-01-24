const turf = require('@turf/turf');

/**
 * Build a GeoJSON FeatureCollection from destinations
 * Includes point features for each destination and optional route/boundary features
 * @param {Array} destinations - Array of destination documents
 * @param {Object} options - Optional features {includeRoute: boolean, includeBoundary: boolean}
 * @returns {Object} GeoJSON FeatureCollection
 */
function buildFeatureCollection(destinations, options = {}) {
  const { includeRoute = false, includeBoundary = false } = options;
  
  if (!destinations || destinations.length === 0) {
    return {
      type: 'FeatureCollection',
      features: []
    };
  }

  const features = [];

  // Add point feature for each destination
  destinations.forEach((dest, index) => {
    features.push(buildDestinationFeature(dest, index));
  });

  // Add route feature if requested and we have multiple destinations
  if (includeRoute && destinations.length >= 2) {
    const routeFeature = buildRouteFeature(destinations);
    if (routeFeature) {
      features.push(routeFeature);
    }
  }

  // Add boundary feature if requested and we have enough points
  if (includeBoundary && destinations.length >= 3) {
    const boundaryFeature = buildBoundaryFeature(destinations);
    if (boundaryFeature) {
      features.push(boundaryFeature);
    }
  }

  return {
    type: 'FeatureCollection',
    features
  };
}

/**
 * Build a GeoJSON Point feature for a single destination
 * @param {Object} destination - Destination document
 * @param {number} index - Optional index for ordering
 * @returns {Object} GeoJSON Feature with Point geometry
 */
function buildDestinationFeature(destination, index = null) {
  const feature = {
    type: 'Feature',
    geometry: {
      type: 'Point',
      coordinates: [destination.longitude, destination.latitude]
    },
    properties: {
      id: destination._id.toString(),
      name: destination.name,
      description: destination.description || null,
      notes: destination.notes || null,
      visited: destination.visited || false,
      visitDate: destination.visitDate || null,
      photos: destination.photos ? destination.photos.length : 0,
      category: destination.category || null,
      rating: destination.rating || null,
      createdAt: destination.createdAt,
      updatedAt: destination.updatedAt
    }
  };

  // Add order index if provided
  if (index !== null) {
    feature.properties.order = index + 1;
  }

  // Add marker color based on visited status
  feature.properties['marker-color'] = destination.visited ? '#10b981' : '#3b82f6';
  feature.properties['marker-symbol'] = destination.visited ? 'circle' : 'circle-stroked';
  feature.properties['marker-size'] = 'medium';

  return feature;
}

/**
 * Build a GeoJSON LineString feature representing the route between destinations
 * @param {Array} destinations - Array of destination documents (ordered)
 * @returns {Object|null} GeoJSON Feature with LineString geometry
 */
function buildRouteFeature(destinations) {
  if (!destinations || destinations.length < 2) {
    return null;
  }

  try {
    // Extract coordinates in order
    const coordinates = destinations.map(dest => [
      dest.longitude,
      dest.latitude
    ]);

    // Calculate total distance using turf
    const line = turf.lineString(coordinates);
    const distance = turf.length(line, { units: 'kilometers' });

    return {
      type: 'Feature',
      geometry: {
        type: 'LineString',
        coordinates
      },
      properties: {
        type: 'route',
        distance: Math.round(distance * 100) / 100,
        segments: destinations.length - 1,
        'stroke': '#8b5cf6',
        'stroke-width': 3,
        'stroke-opacity': 0.7
      }
    };
  } catch (error) {
    console.error('Error building route feature:', error);
    return null;
  }
}

/**
 * Build a GeoJSON Polygon feature representing the boundary of all destinations
 * Uses convex hull algorithm
 * @param {Array} destinations - Array of destination documents
 * @returns {Object|null} GeoJSON Feature with Polygon geometry
 */
function buildBoundaryFeature(destinations) {
  if (!destinations || destinations.length < 3) {
    return null;
  }

  try {
    // Create points for turf
    const points = destinations.map(dest => 
      turf.point([dest.longitude, dest.latitude])
    );
    
    const featureCollection = turf.featureCollection(points);
    const hull = turf.convex(featureCollection);

    if (!hull) {
      return null;
    }

    // Calculate area
    const area = turf.area(hull);
    const areaKm2 = Math.round((area / 1000000) * 100) / 100;

    return {
      type: 'Feature',
      geometry: hull.geometry,
      properties: {
        type: 'boundary',
        area: areaKm2,
        destinations: destinations.length,
        'fill': '#8b5cf6',
        'fill-opacity': 0.2,
        'stroke': '#8b5cf6',
        'stroke-width': 2,
        'stroke-opacity': 0.8
      }
    };
  } catch (error) {
    console.error('Error building boundary feature:', error);
    return null;
  }
}

/**
 * Build a simplified GeoJSON FeatureCollection with only essential properties
 * Useful for mobile apps with bandwidth constraints
 * @param {Array} destinations - Array of destination documents
 * @returns {Object} Lightweight GeoJSON FeatureCollection
 */
function buildLightweightFeatureCollection(destinations) {
  if (!destinations || destinations.length === 0) {
    return {
      type: 'FeatureCollection',
      features: []
    };
  }

  const features = destinations.map(dest => ({
    type: 'Feature',
    geometry: {
      type: 'Point',
      coordinates: [dest.longitude, dest.latitude]
    },
    properties: {
      id: dest._id.toString(),
      name: dest.name,
      visited: dest.visited || false
    }
  }));

  return {
    type: 'FeatureCollection',
    features
  };
}

/**
 * Build a GeoJSON MultiPoint feature from multiple destinations
 * Useful for cluster visualization
 * @param {Array} destinations - Array of destination documents
 * @returns {Object} GeoJSON Feature with MultiPoint geometry
 */
function buildMultiPointFeature(destinations) {
  if (!destinations || destinations.length === 0) {
    return null;
  }

  const coordinates = destinations.map(dest => [
    dest.longitude,
    dest.latitude
  ]);

  return {
    type: 'Feature',
    geometry: {
      type: 'MultiPoint',
      coordinates
    },
    properties: {
      count: destinations.length,
      visited: destinations.filter(d => d.visited).length,
      unvisited: destinations.filter(d => !d.visited).length
    }
  };
}

/**
 * Build a bounding box GeoJSON Polygon from destinations
 * @param {Array} destinations - Array of destination documents
 * @returns {Object|null} GeoJSON Feature with Polygon geometry
 */
function buildBoundingBoxFeature(destinations) {
  if (!destinations || destinations.length === 0) {
    return null;
  }

  try {
    const points = destinations.map(dest => 
      turf.point([dest.longitude, dest.latitude])
    );
    
    const featureCollection = turf.featureCollection(points);
    const bbox = turf.bbox(featureCollection);
    
    // Create polygon from bbox [minLng, minLat, maxLng, maxLat]
    const bboxPolygon = turf.bboxPolygon(bbox);

    return {
      type: 'Feature',
      geometry: bboxPolygon.geometry,
      properties: {
        type: 'bbox',
        bounds: {
          swLng: bbox[0],
          swLat: bbox[1],
          neLng: bbox[2],
          neLat: bbox[3]
        }
      }
    };
  } catch (error) {
    console.error('Error building bounding box feature:', error);
    return null;
  }
}

/**
 * Validate if an object is valid GeoJSON
 * @param {Object} geojson - Object to validate
 * @returns {boolean} True if valid GeoJSON
 */
function isValidGeoJSON(geojson) {
  if (!geojson || typeof geojson !== 'object') {
    return false;
  }

  // Check for required properties
  if (geojson.type === 'FeatureCollection') {
    return Array.isArray(geojson.features);
  }

  if (geojson.type === 'Feature') {
    return geojson.geometry && geojson.geometry.type && geojson.geometry.coordinates;
  }

  // Direct geometry object
  const validTypes = ['Point', 'LineString', 'Polygon', 'MultiPoint', 'MultiLineString', 'MultiPolygon'];
  return validTypes.includes(geojson.type) && Array.isArray(geojson.coordinates);
}

module.exports = {
  buildFeatureCollection,
  buildDestinationFeature,
  buildRouteFeature,
  buildBoundaryFeature,
  buildLightweightFeatureCollection,
  buildMultiPointFeature,
  buildBoundingBoxFeature,
  isValidGeoJSON
};
