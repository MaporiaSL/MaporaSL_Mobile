const Travel = require('../models/Travel');
const Destination = require('../models/Destination');
const { buildFeatureCollection, buildBoundaryFeature, buildBoundingBoxFeature } = require('../utils/geojsonBuilder');
const { calculateRouteDistance, calculateConvexHull, calculateArea, getCenterPoint, calculateBoundingBox } = require('../utils/geoUtils');

/**
 * Get complete GeoJSON representation of a travel with all destinations
 * GET /api/travel/:travelId/geojson
 */
exports.getTravelGeoJSON = async (req, res) => {
  try {
    const { travelId } = req.params;
    const userId = req.user.sub;

    // Query options
    const includeRoute = req.query.includeRoute !== 'false'; // Default true
    const includeBoundary = req.query.includeBoundary !== 'false'; // Default true
    const lightweight = req.query.lightweight === 'true'; // Default false

    // Verify travel belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    // Get all destinations for this travel
    const destinations = await Destination.find({ travelId, userId }).sort({ createdAt: 1 });

    if (destinations.length === 0) {
      return res.json({
        type: 'FeatureCollection',
        features: [],
        properties: {
          travelId,
          travelName: travel.name,
          destinationCount: 0
        }
      });
    }

    // Build GeoJSON FeatureCollection
    const featureCollection = buildFeatureCollection(destinations, {
      includeRoute,
      includeBoundary
    });

    // Add travel metadata
    featureCollection.properties = {
      travelId: travel._id.toString(),
      travelName: travel.name,
      startDate: travel.startDate,
      endDate: travel.endDate,
      destinationCount: destinations.length,
      visitedCount: destinations.filter(d => d.visited).length,
      unvisitedCount: destinations.filter(d => !d.visited).length
    };

    res.json(featureCollection);
  } catch (error) {
    console.error('Error getting travel GeoJSON:', error);
    res.status(500).json({ error: 'Failed to retrieve travel GeoJSON' });
  }
};

/**
 * Get boundary polygon for a travel (convex hull of all destinations)
 * GET /api/travel/:travelId/boundary
 */
exports.getTravelBoundary = async (req, res) => {
  try {
    const { travelId } = req.params;
    const userId = req.user.sub;

    // Verify travel belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    // Get all destinations
    const destinations = await Destination.find({ travelId, userId });

    if (destinations.length < 3) {
      return res.status(400).json({ 
        error: 'At least 3 destinations required to calculate boundary',
        count: destinations.length
      });
    }

    // Calculate convex hull
    const boundaryFeature = buildBoundaryFeature(destinations);

    if (!boundaryFeature) {
      return res.status(500).json({ error: 'Failed to calculate boundary' });
    }

    // Add travel context
    boundaryFeature.properties.travelId = travel._id.toString();
    boundaryFeature.properties.travelName = travel.name;

    res.json(boundaryFeature);
  } catch (error) {
    console.error('Error getting travel boundary:', error);
    res.status(500).json({ error: 'Failed to retrieve travel boundary' });
  }
};

/**
 * Get terrain/elevation data for a travel
 * GET /api/travel/:travelId/terrain
 * NOTE: This is a placeholder for Phase 3. Full implementation requires external elevation API.
 */
exports.getTravelTerrain = async (req, res) => {
  try {
    const { travelId } = req.params;
    const userId = req.user.sub;

    // Verify travel belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    // Get all destinations
    const destinations = await Destination.find({ travelId, userId });

    if (destinations.length === 0) {
      return res.json({
        travelId: travel._id.toString(),
        travelName: travel.name,
        terrain: [],
        message: 'No destinations available'
      });
    }

    // Placeholder response - to be implemented with elevation API
    const terrainData = {
      travelId: travel._id.toString(),
      travelName: travel.name,
      elevationProfile: destinations.map(dest => ({
        destinationId: dest._id.toString(),
        name: dest.name,
        latitude: dest.latitude,
        longitude: dest.longitude,
        elevation: null, // To be populated by elevation API
        elevationUnit: 'meters'
      })),
      message: 'Elevation data not yet implemented. Requires integration with elevation API (e.g., Open Elevation, Mapbox Terrain)'
    };

    res.json(terrainData);
  } catch (error) {
    console.error('Error getting travel terrain:', error);
    res.status(500).json({ error: 'Failed to retrieve travel terrain' });
  }
};

/**
 * Get comprehensive statistics for a travel
 * GET /api/travel/:travelId/stats
 */
exports.getTravelStats = async (req, res) => {
  try {
    const { travelId } = req.params;
    const userId = req.user.sub;

    // Verify travel belongs to user
    const travel = await Travel.findOne({ _id: travelId, userId });
    if (!travel) {
      return res.status(404).json({ error: 'Travel not found' });
    }

    // Get all destinations
    const destinations = await Destination.find({ travelId, userId }).sort({ createdAt: 1 });

    // Basic counts
    const totalDestinations = destinations.length;
    const visitedDestinations = destinations.filter(d => d.visited).length;
    const unvisitedDestinations = totalDestinations - visitedDestinations;

    // Geospatial calculations
    let routeDistance = 0;
    let boundaryArea = 0;
    let center = null;
    let bounds = null;

    if (destinations.length >= 2) {
      routeDistance = calculateRouteDistance(destinations);
      center = getCenterPoint(destinations);
      bounds = calculateBoundingBox(destinations);
    }

    if (destinations.length >= 3) {
      const hull = calculateConvexHull(destinations);
      if (hull) {
        boundaryArea = calculateArea(hull);
      }
    }

    // Photo counts
    const totalPhotos = destinations.reduce((sum, dest) => 
      sum + (dest.photos ? dest.photos.length : 0), 0
    );

    // Date calculations
    let travelDuration = null;
    if (travel.startDate && travel.endDate) {
      const start = new Date(travel.startDate);
      const end = new Date(travel.endDate);
      travelDuration = Math.ceil((end - start) / (1000 * 60 * 60 * 24)); // Days
    }

    // Visited dates
    const visitedDates = destinations
      .filter(d => d.visited && d.visitDate)
      .map(d => d.visitDate)
      .sort();

    const firstVisit = visitedDates.length > 0 ? visitedDates[0] : null;
    const lastVisit = visitedDates.length > 0 ? visitedDates[visitedDates.length - 1] : null;

    // Compile stats
    const stats = {
      travelId: travel._id.toString(),
      travelName: travel.name,
      
      // Destination counts
      destinations: {
        total: totalDestinations,
        visited: visitedDestinations,
        unvisited: unvisitedDestinations,
        completionPercentage: totalDestinations > 0 
          ? Math.round((visitedDestinations / totalDestinations) * 100)
          : 0
      },

      // Geospatial metrics
      geography: {
        routeDistanceKm: routeDistance,
        boundaryAreaKm2: boundaryArea,
        centerPoint: center,
        bounds: bounds
      },

      // Media counts
      media: {
        totalPhotos,
        averagePhotosPerDestination: totalDestinations > 0
          ? Math.round((totalPhotos / totalDestinations) * 10) / 10
          : 0
      },

      // Timeline
      timeline: {
        startDate: travel.startDate,
        endDate: travel.endDate,
        durationDays: travelDuration,
        firstVisit,
        lastVisit
      },

      // Metadata
      createdAt: travel.createdAt,
      updatedAt: travel.updatedAt
    };

    res.json(stats);
  } catch (error) {
    console.error('Error getting travel stats:', error);
    res.status(500).json({ error: 'Failed to retrieve travel statistics' });
  }
};
