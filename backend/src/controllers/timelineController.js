const User = require('../models/User');
const Destination = require('../models/Destination');
const Album = require('../models/Album');
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

    // 1. Fetch Visited Destinations
    const visitedDestinations = await Destination.find({
      userId,
      visited: true,
      visitedAt: { $ne: null }
    }).lean();

    const visitEvents = visitedDestinations.map(dest => ({
      id: `visit_${dest._id.toString()}`,
      type: 'VISIT',
      timestamp: dest.visitedAt,
      title: 'Discovered a new place',
      description: dest.name,
      metadata: {
        placeId: dest._id.toString(),
        latitude: dest.latitude,
        longitude: dest.longitude,
        districtId: dest.districtId
      }
    }));
    timelineEvents.push(...visitEvents);

    // 2. Fetch Photos and Albums
    const albums = await Album.find({ userId }).lean();
    
    // Flatten photos from all albums
    albums.forEach(album => {
      if (album.photos && album.photos.length > 0) {
        const photoEvents = album.photos.map(photo => {
          let title = 'Captured a memory';
          if (album.name && album.name.toLowerCase() !== 'default album') {
            title += ` in ${album.name}`;
          }

          return {
            id: `photo_${photo._id.toString()}`,
            type: 'PHOTO',
            timestamp: photo.createdAt,
            title,
            description: photo.caption || 'A beautiful moment from your journey.',
            metadata: {
              imageUrl: photo.url,
              albumId: album._id.toString(),
              placeName: photo.location?.placeName
            }
          };
        });
        timelineEvents.push(...photoEvents);
      }
    });

    // 3. Fetch Achievements (Gamified progression)
    const user = await User.findOne({ auth0Id: userId }).lean();
    
    if (user && user.achievements && user.achievements.length > 0) {
      const unlockedAchievements = user.achievements.filter(ach => ach.unlockedAt != null);
      
      const achievementEvents = unlockedAchievements.map((ach, index) => ({
        id: `achievement_${userId}_${ach.districtId}_${index}`,
        type: 'ACHIEVEMENT',
        timestamp: ach.unlockedAt,
        title: 'Achievement Unlocked',
        description: `Unlocked the ${ach.districtId.charAt(0).toUpperCase() + ach.districtId.slice(1)} Explorer badge!`,
        metadata: {
          districtId: ach.districtId,
          badgeIcon: 'star' 
        }
      }));
      timelineEvents.push(...achievementEvents);
    }

    // 4. Fetch User's Real Trips (Only non-completed/upcoming for now)
    const userTrips = await Travel.find({ userId }).lean();
    const now = new Date();

    const tripEvents = userTrips
      .filter(trip => new Date(trip.startDate) > now) // Only upcoming trips
      .map(trip => {
        // Construct a short location summary
        let locationSummary = '';
        if (trip.locations && trip.locations.length > 0) {
          locationSummary = trip.locations.slice(0, 2).map(l => l.name || l).join(', ');
          if (trip.locations.length > 2) locationSummary += '...';
        }

        return {
          id: `trip_${trip._id.toString()}`,
          type: 'UPCOMING',
          timestamp: trip.startDate,
          title: trip.title,
          description: trip.description || `Exploring ${locationSummary || 'Sri Lanka'}`,
          tripId: trip._id.toString(),
          metadata: {
            locations: trip.locations,
            startDate: trip.startDate,
            endDate: trip.endDate
          }
        };
      });
    timelineEvents.push(...tripEvents);

    // 5. Add Hardcoded Upcoming Trip Mocks (for demo until real trips are created)
    const mockUpcoming = [
      {
        id: 'mock_trip_1',
        type: 'UPCOMING',
        timestamp: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
        title: 'Wonders of Galle Fort',
        description: 'Exploring the colonial charm and narrow streets of the historic Galle Fort.',
        metadata: {
          locations: ['Galle Fort', 'Lighthouse', 'Maritime Museum'],
          startDate: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000)
        }
      },
      {
        id: 'mock_trip_2',
        type: 'UPCOMING',
        timestamp: new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
        title: 'Hill Country Tea Escape',
        description: 'Breathtaking views of mist-covered mountains and rolling tea estates in Nuwara Eliya.',
        metadata: {
          locations: ['Gregory Lake', 'Tea Factory', 'Victoria Park'],
          startDate: new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)
        }
      }
    ];
    timelineEvents.push(...mockUpcoming);

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
