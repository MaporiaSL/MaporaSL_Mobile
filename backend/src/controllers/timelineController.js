const User = require('../models/User');
const Destination = require('../models/Destination');
const Album = require('../models/Album');

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
