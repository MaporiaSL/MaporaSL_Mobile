const User = require('../models/User');
const Destination = require('../models/Destination');

/**
 * Get user progress - unlocked districts, provinces, achievements
 * GET /api/users/:userId/progress
 */
async function getUserProgress(req, res) {
  try {
    const { userId } = req.params;

    // Verify requesting user matches the userId in URL
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot access another user\'s progress' });
    }

    // Fetch user
    const user = await User.findOne({ auth0Id: userId });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Calculate completion percentage
    // Sri Lanka has 25 districts total
    const totalDistricts = 25;
    const completionPercentage = Math.round((user.unlockedDistricts.length / totalDistricts) * 100);

    res.status(200).json({
      userId: user.auth0Id,
      unlockedDistricts: user.unlockedDistricts,
      unlockedProvinces: user.unlockedProvinces,
      totalPlacesVisited: user.totalPlacesVisited,
      completionPercentage,
      achievements: user.achievements
    });
  } catch (error) {
    console.error('Get user progress error:', error);
    res.status(500).json({ error: 'Failed to retrieve user progress' });
  }
}

/**
 * Get district progress for a specific district
 * GET /api/districts/:districtId/progress
 * Query params: userId (from JWT)
 */
async function getDistrictProgress(req, res) {
  try {
    const { districtId } = req.params;
    const userId = req.userId;

    // Get all destinations in this district for this user
    const allDestinations = await Destination.find({
      userId,
      districtId
    });

    // Count visited destinations
    const visitedDestinations = allDestinations.filter(dest => dest.visited);

    // Calculate progress
    const totalPlaces = allDestinations.length;
    const visitedPlaces = visitedDestinations.length;
    const completionPercentage = totalPlaces > 0 
      ? Math.round((visitedPlaces / totalPlaces) * 100)
      : 0;

    res.status(200).json({
      districtId,
      totalPlaces,
      visitedPlaces,
      completionPercentage,
      destinations: allDestinations.map(dest => ({
        id: dest._id,
        name: dest.name,
        visited: dest.visited,
        visitedAt: dest.visitedAt,
        latitude: dest.latitude,
        longitude: dest.longitude
      }))
    });
  } catch (error) {
    console.error('Get district progress error:', error);
    res.status(500).json({ error: 'Failed to retrieve district progress' });
  }
}

/**
 * Calculate and update user progress based on visited destinations
 * Helper function called after destination updates
 */
async function recalculateUserProgress(userId) {
  try {
    // Get all visited destinations for user
    const visitedDestinations = await Destination.find({
      userId,
      visited: true
    });

    // Count total places visited
    const totalPlacesVisited = visitedDestinations.length;

    // Group by districtId
    const districtMap = {};
    visitedDestinations.forEach(dest => {
      if (dest.districtId) {
        if (!districtMap[dest.districtId]) {
          districtMap[dest.districtId] = { visited: 0, total: 0 };
        }
        districtMap[dest.districtId].visited += 1;
      }
    });

    // Get total destinations per district
    const allDestinations = await Destination.find({ userId });
    allDestinations.forEach(dest => {
      if (dest.districtId) {
        if (!districtMap[dest.districtId]) {
          districtMap[dest.districtId] = { visited: 0, total: 0 };
        }
        districtMap[dest.districtId].total += 1;
      }
    });

    // Determine unlocked districts (100% visited)
    const unlockedDistricts = [];
    const achievements = [];

    Object.keys(districtMap).forEach(districtId => {
      const { visited, total } = districtMap[districtId];
      const progress = total > 0 ? Math.round((visited / total) * 100) : 0;

      achievements.push({
        districtId,
        progress,
        unlockedAt: progress === 100 ? new Date() : null
      });

      if (progress === 100) {
        unlockedDistricts.push(districtId);
      }
    });

    // District to Province mapping (simplified - would need complete mapping)
    const districtProvinceMap = {
      'colombo': 'western',
      'gampaha': 'western',
      'kalutara': 'western',
      'galle': 'southern',
      'matara': 'southern',
      'hambantota': 'southern',
      'kandy': 'central',
      'matale': 'central',
      'nuwara-eliya': 'central',
      // Add all 25 districts...
    };

    // Determine unlocked provinces
    const provinceProgress = {};
    unlockedDistricts.forEach(districtId => {
      const province = districtProvinceMap[districtId];
      if (province) {
        if (!provinceProgress[province]) {
          provinceProgress[province] = 0;
        }
        provinceProgress[province] += 1;
      }
    });

    // Province is unlocked when all its districts are unlocked
    // For now, simplified logic
    const unlockedProvinces = Object.keys(provinceProgress).filter(province => {
      // Simplified: unlock if at least 1 district unlocked (should check all districts in province)
      return provinceProgress[province] > 0;
    });

    // Update user document
    await User.findOneAndUpdate(
      { auth0Id: userId },
      {
        $set: {
          unlockedDistricts,
          unlockedProvinces,
          totalPlacesVisited,
          achievements,
          updatedAt: new Date()
        }
      }
    );

    return {
      unlockedDistricts,
      unlockedProvinces,
      totalPlacesVisited,
      achievements
    };
  } catch (error) {
    console.error('Recalculate user progress error:', error);
    throw error;
  }
}

module.exports = {
  getUserProgress,
  getDistrictProgress,
  recalculateUserProgress
};
