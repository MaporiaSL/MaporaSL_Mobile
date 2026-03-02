const PrePlannedTrip = require('../models/PrePlannedTrip');
const Travel = require('../models/Travel');
const Destination = require('../models/Destination');

/**
 * GET /api/preplanned-trips
 * Fetch pre-planned trip templates with optional filtering
 */
exports.getPreplannedTrips = async (req, res) => {
  try {
    const { difficulty, tags, startingPoint, durationDays, limit = 20, skip = 0 } = req.query;

    // Build query filter
    const filter = {};
    if (difficulty) filter.difficulty = difficulty;
    if (startingPoint) filter.startingPoint = startingPoint;
    if (durationDays) filter.durationDays = parseInt(durationDays);
    if (tags) {
      const tagList = tags.split(',').map(t => t.trim());
      filter.tags = { $in: tagList };
    }

    const trips = await PrePlannedTrip.find(filter)
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .sort({ createdAt: -1 });

    const total = await PrePlannedTrip.countDocuments(filter);

    res.json({
      success: true,
      trips,
      total,
      count: trips.length,
    });
  } catch (err) {
    console.error('Error fetching pre-planned trips:', err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};

/**
 * GET /api/preplanned/:id
 * Fetch single pre-planned trip template
 */
exports.getPreplannedTripById = async (req, res) => {
  try {
    const { id } = req.params;
    const trip = await PrePlannedTrip.findById(id);

    if (!trip) {
      return res.status(404).json({
        success: false,
        error: 'Pre-planned trip not found',
      });
    }

    res.json({
      success: true,
      ...trip.toObject(),
    });
  } catch (err) {
    console.error('Error fetching pre-planned trip:', err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};

/**
 * POST /api/preplanned/:id/clone
 * Clone a template into user's travels + create destinations
 */
exports.cloneTemplate = async (req, res) => {
  try {
    const { id } = req.params;
    const { startDate, endDate } = req.body;
    const userId = req.userId;

    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized - user ID required',
      });
    }

    // Fetch template
    const template = await PrePlannedTrip.findById(id);
    if (!template) {
      return res.status(404).json({
        success: false,
        error: 'Template not found',
      });
    }

    // Create travel from template
    const travel = new Travel({
      userId,
      title: template.title,
      description: template.description,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      locations: template.placeIds,
      itinerary: template.itinerary,
    });

    await travel.save();

    // Create destinations for this travel (using placeIds from template)
    const destinations = await Promise.all(
      template.placeIds.map((placeId, index) =>
        new Destination({
          travelId: travel._id,
          name: placeId,
          order: index,
          visited: false,
        }).save()
      )
    );

    res.status(201).json({
      success: true,
      travel: {
        id: travel._id,
        ...travel.toObject(),
      },
      destinationCount: destinations.length,
    });
  } catch (err) {
    console.error('Error cloning template:', err);
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};
