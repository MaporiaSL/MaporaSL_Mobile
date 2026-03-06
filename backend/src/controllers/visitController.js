const Visit = require('../models/Visit');
const Place = require('../models/Place');
const geolib = require('geolib');

// Standard geofence threshold for verification (in meters)
const GEOFENCE_RADIUS_METERS = 250;

exports.markVisit = async (req, res) => {
  try {
    const { placeId, latitude, longitude } = req.body;
    const userId = req.user.id;

    if (!placeId || latitude == null || longitude == null) {
      return res.status(400).json({ error: 'Missing required parameters (placeId, latitude, longitude).' });
    }

    // 1. Check if place exists
    const place = await Place.findById(placeId);
    if (!place) {
      return res.status(404).json({ error: 'Place not found.' });
    }

    // 2. Check for duplicate visit
    const existingVisit = await Visit.findOne({ userId, placeId });
    if (existingVisit) {
      return res.status(400).json({ error: 'You have already visited this place.' });
    }

    // 3. Coordinate validation
    let isVerified = false;
    let rejectionReason = null;

    if (place.location && place.location.coordinates) {
      const placeLat = place.location.coordinates[1];
      const placeLng = place.location.coordinates[0];

      const distance = geolib.getDistance(
        { latitude, longitude },
        { latitude: placeLat, longitude: placeLng }
      );

      if (distance <= GEOFENCE_RADIUS_METERS) {
        isVerified = true;
      } else {
        rejectionReason = 'too_far';
      }
    } else {
      rejectionReason = 'invalid_coords';
    }

    // 4. Save visit
    const newVisit = new Visit({
      userId,
      placeId,
      coordinates: { latitude, longitude },
      isVerified,
      rejectionReason,
    });

    await newVisit.save();

    res.status(201).json({
      message: isVerified ? 'Visit verified successfully!' : 'Visit recorded but not verified.',
      visit: newVisit,
      distanceToPlace: rejectionReason === 'too_far' ? 'More than 250m away' : 'Within 250m',
    });

  } catch (error) {
    console.error('Error marking visit:', error);
    if (error.code === 11000) {
       return res.status(400).json({ error: 'You have already visited this place.' });
    }
    res.status(500).json({ error: 'Server error marking visit.' });
  }
};

exports.getUserVisits = async (req, res) => {
  try {
    const userId = req.user.id;
    const visits = await Visit.find({ userId }).populate('placeId', 'name imageUrl type');
    
    res.status(200).json({ visits });
  } catch (error) {
    console.error('Error fetching user visits:', error);
    res.status(500).json({ error: 'Server error fetching visits.' });
  }
};
