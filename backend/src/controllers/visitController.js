const Visit = require('../models/Visit');
const Place = require('../models/Place');
const geolib = require('geolib');

const { getRadiusConfig } = require('../utils/geofenceUtils');

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

    // 3. Dynamic Geofence Validation
    let isVerified = false;
    let rejectionReason = null;
    let verificationTier = null;
    
    // Get dynamic radius based on place type
    const { primary, failsafe, category } = getRadiusConfig(place.type || 'attraction');

    if (place.location && place.location.coordinates) {
      const placeLat = place.location.coordinates[1];
      const placeLng = place.location.coordinates[0];

      const distance = geolib.getDistance(
        { latitude, longitude },
        { latitude: placeLat, longitude: placeLng }
      );

      if (distance <= primary) {
        isVerified = true;
        verificationTier = 'primary';
      } else if (distance <= failsafe) {
        isVerified = true;
        verificationTier = 'failsafe';
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
      metadata: { 
        verificationTier,
        geofenceCategory: category,
        primaryRadius: primary,
        failsafeRadius: failsafe
      }
    });

    await newVisit.save();

    res.status(201).json({
      message: isVerified ? 'Visit verified successfully!' : 'Visit recorded but not verified.',
      visit: newVisit,
      verificationResult: {
        isVerified,
        tier: verificationTier,
        category,
        primaryRadius: primary,
        failsafeRadius: failsafe
      }
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
