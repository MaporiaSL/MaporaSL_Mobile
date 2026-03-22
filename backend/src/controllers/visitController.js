const mongoose = require('mongoose');
const Visit = require('../models/Visit');
const Place = require('../models/Place');
const PlaceAchievement = require('../models/PlaceAchievement');
const geolib = require('geolib');
const { getRadiusConfig } = require('../utils/geofenceUtils');

// Anti-cheat security constants (Merged from placeVisitRoutes)
const GPS_ACCURACY_THRESHOLD_M = 30;
const HEADING_TOLERANCE = 45;
const RATE_LIMIT_HOURS = 0;
const MAX_SPEED_MS = 999999;

/**
 * Record a visit with optional advanced anti-cheat validation
 */
exports.markVisit = async (req, res) => {
  try {
    const { placeId, latitude, longitude, metadata, notes, photoUrl, requestSignature } = req.body;
    const userId = req.userId;

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

    // 3. Perform Validation (Advanced if metadata provided, otherwise basic geofence)
    const { primary, failsafe, category } = getRadiusConfig(place.type || 'attraction');
    const bypassVerification = process.env.BYPASS_VERIFICATION === 'true';
    let validationResult;

    if (bypassVerification) {
      validationResult = {
        isValid: true,
        status: 'approved',
        confidence: 1.0,
        invalidReason: null,
        flaggedReason: null,
        flagSeverity: 1
      };
    } else if (metadata) {
      // Advanced validation (Ported from placeVisitRoutes)
      validationResult = await validateVisitAdvanced(
        userId,
        place,
        latitude,
        longitude,
        metadata,
        requestSignature
      );
    } else {
      // Basic geofence validation
      const distance = geolib.getDistance(
        { latitude, longitude },
        { latitude: place.latitude, longitude: place.longitude }
      );
      
      const isVerified = distance <= failsafe;
      validationResult = {
        isValid: isVerified,
        status: isVerified ? 'approved' : 'rejected',
        confidence: isVerified ? 1.0 : 0.0,
        invalidReason: !isVerified ? 'too_far' : null,
        flaggedReason: !isVerified ? 'outside_geofence' : null,
        flagSeverity: isVerified ? 1 : 5
      };
    }

    // 4. Create Visit Record
    const newVisit = new Visit({
      userId,
      placeId,
      coordinates: { latitude, longitude },
      metadata: {
        ...metadata,
        verificationTier: validationResult.isValid ? (geolib.getDistance({latitude, longitude}, {latitude: place.latitude, longitude: place.longitude}) <= primary ? 'primary' : 'failsafe') : null,
        geofenceCategory: category,
        primaryRadius: primary,
        failsafeRadius: failsafe
      },
      validation: validationResult,
      isVerified: validationResult.isValid,
      reasons: {
          rejectionReason: validationResult.invalidReason
      },
      notes: notes?.substring(0, 500) || null,
      photoUrl,
      visitedAt: new Date()
    });

    await newVisit.save();

    // 5. Update Place Stats
    await Place.findByIdAndUpdate(placeId, { $inc: { 'stats.visitCount': 1 } });

    // 6. Check achievements
    const achievementData = await checkAndUnlockAchievements(userId);

    res.status(201).json({
      message: validationResult.isValid ? 'Visit verified successfully!' : 'Visit recorded with warnings.',
      visit: newVisit,
      achievement: achievementData,
      verificationResult: validationResult
    });

  } catch (error) {
    console.error('Error marking visit:', error);
    if (error.code === 11000) {
      return res.status(400).json({ error: 'You have already visited this place.' });
    }
    res.status(500).json({ error: 'Server error marking visit.' });
  }
};

/**
 * Advanced validation logic
 */
async function validateVisitAdvanced(userId, place, lat, lng, metadata, signature) {
  const { accuracyMeters, compassHeading, isLocationSpoofed } = metadata;
  
  const validation = {
    isValid: true,
    status: 'approved',
    confidence: 1.0,
    invalidReason: null,
    flaggedReason: null,
    flagSeverity: 1,
  };

  // 1. Distance check
  const distance = geolib.getDistance({ latitude: lat, longitude: lng }, { latitude: place.latitude, longitude: place.longitude });
  const { failsafe } = getRadiusConfig(place.type);
  
  if (distance > failsafe) {
    validation.isValid = false;
    validation.status = 'rejected';
    validation.invalidReason = 'too_far';
    validation.flaggedReason = 'outside_geofence';
    validation.flagSeverity = 5;
    validation.confidence = 0.1;
    return validation;
  }

  // 2. Accuracy check
  if (accuracyMeters > GPS_ACCURACY_THRESHOLD_M) {
    validation.isValid = false;
    validation.flaggedReason = 'low_accuracy';
    validation.invalidReason = `Accuracy ${accuracyMeters}m > ${GPS_ACCURACY_THRESHOLD_M}m`;
    validation.confidence *= 0.6;
  }

  // 3. Spoofing check
  if (isLocationSpoofed) {
    validation.isValid = false;
    validation.status = 'rejected';
    validation.flaggedReason = 'spoofing_detected';
    validation.invalidReason = 'Location spoofing detected';
    validation.flagSeverity = 5;
    validation.confidence = 0;
  }

  // 4. Speed check (Optional enhancement)
  // ... can implementation speed check by querying last visit ...

  return validation;
}

/**
 * Achievement logic
 */
async function checkAndUnlockAchievements(userId) {
  try {
    const visits = await Visit.find({ userId, isVerified: true }).populate('placeId', 'category');
    // Simplified achievement check
    if (visits.length >= 5) {
       // Logic for 'Explorer' badge
    }
    return null; // For now return null or specific data
  } catch (e) {
    console.error('Achievement check failed:', e);
    return null;
  }
}

exports.getUserVisits = async (req, res) => {
  try {
    const userId = req.userId;
    const visits = await Visit.find({ userId }).populate('placeId', 'name imageUrl type');
    res.status(200).json({ visits });
  } catch (error) {
    console.error('Error fetching user visits:', error);
    res.status(500).json({ error: 'Server error fetching visits.' });
  }
};
