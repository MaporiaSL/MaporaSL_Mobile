const Destination = require('../models/Destination');
const { buildFeatureCollection } = require('../utils/geojsonBuilder');
const { calculateDistance } = require('../utils/geoUtils');

/**
 * Find destinations near a specific point
 * GET /api/destinations/nearby?lat=X&lng=Y&radius=Z&travelId=optional
 */
exports.findNearbyDestinations = async (req, res) => {
  try {
    const userId = req.user.sub;
    const { lat, lng, radius, travelId } = req.query;

    // Validate required parameters
    if (!lat || !lng) {
      return res.status(400).json({ 
        error: 'Missing required parameters: lat and lng' 
      });
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const radiusKm = radius ? parseFloat(radius) : 10; // Default 10km

    // Validate coordinates
    if (isNaN(latitude) || isNaN(longitude) || latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return res.status(400).json({ 
        error: 'Invalid coordinates. Latitude must be between -90 and 90, longitude between -180 and 180' 
      });
    }

    if (isNaN(radiusKm) || radiusKm <= 0) {
      return res.status(400).json({ 
        error: 'Invalid radius. Must be a positive number' 
      });
    }

    // Build query
    const query = {
      userId,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [longitude, latitude] // [lng, lat] per GeoJSON standard
          },
          $maxDistance: radiusKm * 1000 // Convert km to meters
        }
      }
    };

    // Filter by travelId if provided
    if (travelId) {
      query.travelId = travelId;
    }

    // Execute geospatial query
    const destinations = await Destination.find(query)
      .populate('travelId', 'name startDate endDate')
      .limit(100); // Reasonable limit to prevent overload

    // Calculate actual distances and add to results
    const results = destinations.map(dest => {
      const distance = calculateDistance(latitude, longitude, dest.latitude, dest.longitude);
      
      return {
        destination: dest,
        distanceKm: distance,
        bearing: calculateBearing(latitude, longitude, dest.latitude, dest.longitude)
      };
    });

    // Build GeoJSON response
    const featureCollection = buildFeatureCollection(destinations, { 
      includeRoute: false, 
      includeBoundary: false 
    });

    // Add query metadata
    featureCollection.properties = {
      queryPoint: {
        latitude,
        longitude
      },
      radiusKm,
      resultsCount: destinations.length,
      maxResults: 100
    };

    // Add distance to each feature
    featureCollection.features.forEach((feature, index) => {
      feature.properties.distanceKm = results[index].distanceKm;
      feature.properties.bearing = results[index].bearing;
    });

    res.json({
      query: {
        latitude,
        longitude,
        radiusKm,
        travelId: travelId || null
      },
      count: destinations.length,
      results,
      geojson: featureCollection
    });

  } catch (error) {
    console.error('Error finding nearby destinations:', error);
    res.status(500).json({ error: 'Failed to find nearby destinations' });
  }
};

/**
 * Find destinations within a bounding box
 * GET /api/destinations/within-bounds?swLat=X&swLng=Y&neLat=X&neLng=Y&travelId=optional
 */
exports.findDestinationsWithinBounds = async (req, res) => {
  try {
    const userId = req.user.sub;
    const { swLat, swLng, neLat, neLng, travelId } = req.query;

    // Validate required parameters
    if (!swLat || !swLng || !neLat || !neLng) {
      return res.status(400).json({ 
        error: 'Missing required parameters: swLat, swLng, neLat, neLng',
        description: 'Provide southwest and northeast corners of the bounding box'
      });
    }

    // Parse coordinates
    const southWestLat = parseFloat(swLat);
    const southWestLng = parseFloat(swLng);
    const northEastLat = parseFloat(neLat);
    const northEastLng = parseFloat(neLng);

    // Validate coordinates
    if (
      isNaN(southWestLat) || isNaN(southWestLng) || 
      isNaN(northEastLat) || isNaN(northEastLng) ||
      southWestLat < -90 || southWestLat > 90 ||
      northEastLat < -90 || northEastLat > 90 ||
      southWestLng < -180 || southWestLng > 180 ||
      northEastLng < -180 || northEastLng > 180
    ) {
      return res.status(400).json({ 
        error: 'Invalid coordinates. Latitude must be between -90 and 90, longitude between -180 and 180' 
      });
    }

    // Validate bounding box logic
    if (southWestLat >= northEastLat) {
      return res.status(400).json({ 
        error: 'Invalid bounding box: swLat must be less than neLat' 
      });
    }

    // Build polygon for $geoWithin query
    // GeoJSON Polygon: [[lng, lat], ...]
    const polygon = {
      type: 'Polygon',
      coordinates: [[
        [southWestLng, southWestLat], // Bottom-left
        [northEastLng, southWestLat], // Bottom-right
        [northEastLng, northEastLat], // Top-right
        [southWestLng, northEastLat], // Top-left
        [southWestLng, southWestLat]  // Close polygon
      ]]
    };

    // Build query
    const query = {
      userId,
      location: {
        $geoWithin: {
          $geometry: polygon
        }
      }
    };

    // Filter by travelId if provided
    if (travelId) {
      query.travelId = travelId;
    }

    // Execute geospatial query
    const destinations = await Destination.find(query)
      .populate('travelId', 'name startDate endDate')
      .limit(500); // Higher limit for bounding box queries

    // Build GeoJSON response
    const featureCollection = buildFeatureCollection(destinations, { 
      includeRoute: false, 
      includeBoundary: false 
    });

    // Add query metadata
    featureCollection.properties = {
      bounds: {
        swLat: southWestLat,
        swLng: southWestLng,
        neLat: northEastLat,
        neLng: northEastLng
      },
      resultsCount: destinations.length,
      maxResults: 500
    };

    res.json({
      query: {
        bounds: {
          southwest: { latitude: southWestLat, longitude: southWestLng },
          northeast: { latitude: northEastLat, longitude: northEastLng }
        },
        travelId: travelId || null
      },
      count: destinations.length,
      destinations,
      geojson: featureCollection
    });

  } catch (error) {
    console.error('Error finding destinations within bounds:', error);
    res.status(500).json({ error: 'Failed to find destinations within bounds' });
  }
};

/**
 * Helper function to calculate bearing between two points
 * @param {number} lat1 - Starting latitude
 * @param {number} lon1 - Starting longitude
 * @param {number} lat2 - Ending latitude
 * @param {number} lon2 - Ending longitude
 * @returns {string} Cardinal direction (N, NE, E, SE, S, SW, W, NW)
 */
function calculateBearing(lat1, lon1, lat2, lon2) {
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const lat1Rad = lat1 * Math.PI / 180;
  const lat2Rad = lat2 * Math.PI / 180;

  const y = Math.sin(dLon) * Math.cos(lat2Rad);
  const x = Math.cos(lat1Rad) * Math.sin(lat2Rad) -
            Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLon);
  
  let bearing = Math.atan2(y, x) * 180 / Math.PI;
  bearing = (bearing + 360) % 360; // Normalize to 0-360

  // Convert to cardinal directions
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  const index = Math.round(bearing / 45) % 8;
  
  return directions[index];
}
