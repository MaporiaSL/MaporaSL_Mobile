const Travel = require('../models/Travel');

/**
 * Get unified timeline events for a user
 * GET /api/users/:userId/timeline
 */
async function getTimeline(req, res) {
  try {
    const { userId } = req.params;

    // Verify requesting user matches the userId in URL
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot access another user\'s timeline' });
    }

    // Initialize an array to hold all timeline events
    let timelineEvents = [];

    // 1. Fetch User's Real Trips (Planned/Completed)
    const userTrips = await Travel.find({ userId }).lean();
    const now = new Date();

    const tripEvents = userTrips.map(trip => {
      const isUpcoming = new Date(trip.startDate) > now;
      
      // Construct a short location summary
      let locationSummary = '';
      if (trip.locations && trip.locations.length > 0) {
        locationSummary = trip.locations.slice(0, 2).join(', ');
        if (trip.locations.length > 2) locationSummary += '...';
      }

      return {
        id: `trip_${trip._id.toString()}`,
        // Map to standard frontend enum types
        type: isUpcoming ? 'UPCOMING' : 'COMPLETED_TRIP',
        timestamp: trip.startDate,
        title: trip.title,
        description: trip.description || `Exploring ${locationSummary || 'Sri Lanka'}`,
        tripId: trip._id.toString(),
        // Metadata for frontend cards
        destinationCount: trip.locations ? trip.locations.length : 0,
        visitedCount: isUpcoming ? 0 : (trip.locations ? trip.locations.length : 0),
        completionPercentage: isUpcoming ? 0 : 100,
        metadata: {
          locations: trip.locations,
          startDate: trip.startDate,
          endDate: trip.endDate
        }
      };
    });
    timelineEvents.push(...tripEvents);

    // Sort all events chronologically (newest first)
    timelineEvents.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    res.status(200).json({
      timeline: timelineEvents,
      totalCount: timelineEvents.length
    });

  } catch (error) {
    console.error('Get timeline error:', error);
    res.status(500).json({ error: 'Failed to retrieve memory lane timeline' });
  }
}

module.exports = {
  getTimeline
};
