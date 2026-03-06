const express = require('express');
const mongoose = require('mongoose');
const { checkJwt, extractUserId } = require('../middleware/auth');
const Place = require('../models/Place');
const PlaceVisit = require('../models/PlaceVisit');
const PlaceAchievement = require('../models/PlaceAchievement');

const router = express.Router();

router.use((req, res, next) => {
  console.log(`[PlaceVisitRoutes] ${req.method} ${req.originalUrl}`);
  next();
});

// Anti-cheat security constants
const GEOFENCE_RADIUS_M = 200; // Must be within 200m of place
const GPS_ACCURACY_THRESHOLD_M = 30; // GPS accuracy must be < 30m
const HEADING_TOLERANCE = 45; // degrees (±45° from direction to place)
const RATE_LIMIT_HOURS = 1; // Can't visit same place twice within 1 hour
const MAX_SPEED_MS = 30; // ~108 km/h - suspicious if exceeded
const MIN_HEADING_FACING = 80; // degrees of arc user must face place

// ================================================================
// POST /api/places/:id/visit
// Record a place visit with anti-cheat validation
// ================================================================
router.post('/:id/visit', checkJwt, extractUserId, async (req, res) => {
  try {
    const { id: placeId } = req.params;
    const userId = req.userId;
    const { notes, photoUrl, metadata, requestSignature } = req.body;

    console.log('[PlaceVisit] Incoming visit request', {
      placeId,
      userId,
      hasMetadata: !!metadata,
      hasSignature: !!requestSignature,
      hasPhoto: !!photoUrl,
      notesLength: notes?.length || 0,
    });

    if (!mongoose.Types.ObjectId.isValid(placeId)) {
      return res.status(400).json({ error: 'Invalid place id' });
    }

    // ========== INPUT VALIDATION ==========
    if (!metadata) {
      return res.status(400).json({ error: 'Metadata required for visit recording' });
    }

    const {
      latitude,
      longitude,
      accuracyMeters,
      compassHeading,
      deviceModel,
      osVersion,
      photoExifLat,
      photoExifLon,
      isLocationSpoofed,
    } = metadata;

    // ========== VERIFY PLACE EXISTS ==========
    const place = await Place.findById(placeId);
    if (!place) {
      console.warn(`[PlaceVisit] Place not found for id=${placeId}`);
      return res.status(404).json({ error: 'Place not found' });
    }

    // ========== ANTI-CHEAT VALIDATION ==========
    const validation = await validateVisit(
      userId,
      place,
      latitude,
      longitude,
      accuracyMeters,
      compassHeading,
      photoExifLat,
      photoExifLon,
      isLocationSpoofed,
      deviceModel,
      osVersion,
      requestSignature
    );

    // ========== RATE LIMITING CHECK ==========
    const lastVisit = await PlaceVisit.findOne({
      userId,
      placeId,
      visitedAt: { $gte: new Date(Date.now() - RATE_LIMIT_HOURS * 3600 * 1000) },
    });

    if (lastVisit) {
      validation.beingThrottled = true;
      validation.flaggedReason = validation.flaggedReason || 'rate_limited';
      validation.flagSeverity = Math.max(validation.flagSeverity, 4);
      validation.isValid = false;
      validation.invalidReason = `Cannot visit same place more than once per ${RATE_LIMIT_HOURS} hour(s)`;
    }

    // ========== CREATE VISIT RECORD ==========
    const visitRecord = new PlaceVisit({
      placeId,
      userId,
      notes: notes?.substring(0, 500) || null, // Limit note length
      photoUrl,
      metadata,
      validation,
      visitedAt: new Date(), // Server timestamp (authoritative)
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
    });

    const savedVisit = await visitRecord.save();

    // ========== UPDATE PLACE STATS ==========
    await Place.findByIdAndUpdate(
      placeId,
      {
        $inc: { 'stats.visitCount': 1 },
        $push: { 'stats.recentVisitors': userId },
      },
      { new: true }
    );

    // ========== CHECK ACHIEVEMENTS ==========
    const achievementData = await checkAndUnlockAchievements(userId);

    // ========== RETURN RESPONSE ==========
    res.status(201).json({
      visit: {
        id: savedVisit._id,
        placeId: savedVisit.placeId,
        userId: savedVisit.userId,
        visitedAt: savedVisit.visitedAt,
        notes: savedVisit.notes,
        photoUrl: savedVisit.photoUrl,
        validation: savedVisit.validation,
        // Include user coordinates for error display
        userCoordinates: {
          latitude: latitude,
          longitude: longitude,
        },
      },
      achievement: achievementData,
      message: validation.isValid ? 'Visit recorded successfully' : 'Visit recorded with warnings',
    });
  } catch (error) {
    console.error('Error recording place visit:', error);
    res.status(500).json({ error: 'Failed to record visit' });
  }
});

// ================================================================
// GET /api/places/:id/visits
// Get visit history for a place (public leaderboard)
// ================================================================
router.get('/:id/visits', async (req, res) => {
  try {
    const { id: placeId } = req.params;
    const limit = Math.min(parseInt(req.query.limit) || 20, 100);
    const skip = parseInt(req.query.skip) || 0;

    const visits = await PlaceVisit.find({
      placeId,
      'validation.isValid': true, // Only show approved visits
    })
      .select('userId visitedAt photoUrl notes validation.confidence')
      .sort({ visitedAt: -1 })
      .limit(limit)
      .skip(skip)
      .populate('userId', 'displayName photoUrl')
      .exec();

    const totalCount = await PlaceVisit.countDocuments({
      placeId,
      'validation.isValid': true,
    });

    res.json({
      visits,
      totalCount,
      limit,
      skip,
    });
  } catch (error) {
    console.error('Error fetching visit history:', error);
    res.status(500).json({ error: 'Failed to fetch visit history' });
  }
});

// ================================================================
// GET /api/users/:userId/visit-stats
// Get comprehensive visit statistics for a user
// ================================================================
router.get('/users/:userId/stats', checkJwt, extractUserId, async (req, res) => {
  try {
    const { userId } = req.params;

    // Verify user is requesting their own stats or is admin
    if (req.userId !== userId && req?.auth?.admin !== true) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const visits = await PlaceVisit.find({
      userId,
      'validation.isValid': true,
    }).populate('placeId', 'category district province');

    const achievements = await PlaceAchievement.find({
      userId,
      isUnlocked: true,
    });

    // Calculate statistics
    const stats = {
      totalVisits: visits.length,
      uniquePlaces: new Set(visits.map((v) => v.placeId.toString())).size,
      uniqueDistricts: new Set(
        visits.map((v) => v.placeId.district)
      ).size,
      visitsByCategory: {},
      visitsByDistrict: {},
      achievementsUnlocked: achievements.length,
      lastVisitAt: visits[0]?.visitedAt || null,
    };

    // Aggregate by category and district
    visits.forEach((visit) => {
      const cat = visit.placeId.category || 'other';
      const dist = visit.placeId.district || 'unknown';
      stats.visitsByCategory[cat] = (stats.visitsByCategory[cat] || 0) + 1;
      stats.visitsByDistrict[dist] = (stats.visitsByDistrict[dist] || 0) + 1;
    });

    res.json(stats);
  } catch (error) {
    console.error('Error fetching visit stats:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

// ================================================================
// ANTI-CHEAT VALIDATION FUNCTION
// ================================================================
async function validateVisit(
  userId,
  place,
  latitude,
  longitude,
  accuracyMeters,
  compassHeading,
  photoExifLat,
  photoExifLon,
  isLocationSpoofed,
  deviceModel,
  osVersion,
  requestSignature
) {
  const validation = {
    isValid: true,
    status: 'approved',
    confidence: 1.0,
    gpsAccuracyValid: false,
    geoFencingValid: false,
    headingValid: true,
    photoExifValid: true,
    deviceSignatureSuspicious: false,
    beingThrottled: false,
    speedValid: true,
    invalidReason: null,
    flaggedReason: null,
    flagSeverity: 1,
  };

  // ========== 1. GPS ACCURACY CHECK ==========
  if (accuracyMeters < GPS_ACCURACY_THRESHOLD_M) {
    validation.gpsAccuracyValid = true;
  } else {
    validation.gpsAccuracyValid = false;
    validation.flaggedReason = 'low_accuracy';
    validation.flagSeverity = 2;
    validation.isValid = false;
    validation.invalidReason = `GPS accuracy ${accuracyMeters}m exceeds threshold ${GPS_ACCURACY_THRESHOLD_M}m`;
    validation.confidence *= 0.6;
  }

  // ========== 2. GEOFENCING CHECK ==========
  const distance = haversineDistance(
    latitude,
    longitude,
    place.latitude,
    place.longitude
  );

  if (distance <= GEOFENCE_RADIUS_M) {
    validation.geoFencingValid = true;
  } else {
    validation.geoFencingValid = false;
    validation.flaggedReason = 'outside_geofence';
    validation.flagSeverity = 5; // Critical
    validation.isValid = false;
    validation.invalidReason = `User is ${distance.toFixed(0)}m away from place (max: ${GEOFENCE_RADIUS_M}m)`;
    validation.confidence *= 0.1;
  }

  // ========== 3. HEADING VALIDATION ==========
  if (compassHeading !== null && compassHeading !== undefined) {
    const directionToPlace = calculateBearing(
      latitude,
      longitude,
      place.latitude,
      place.longitude
    );
    const headingDiff = angleDifference(compassHeading, directionToPlace);

    if (headingDiff <= HEADING_TOLERANCE) {
      validation.headingValid = true;
    } else {
      validation.headingValid = false;
      validation.flaggedReason = 'wrong_heading';
      validation.flagSeverity = 2;
      validation.confidence *= 0.75;
    }
  }

  // ========== 4. PHOTO EXIF VALIDATION ==========
  if (photoExifLat && photoExifLon) {
    const photoDistance = haversineDistance(
      parseFloat(photoExifLat),
      parseFloat(photoExifLon),
      place.latitude,
      place.longitude
    );

    if (photoDistance <= 50) {
      // Allow 50m variance in photo location
      validation.photoExifValid = true;
    } else {
      validation.photoExifValid = false;
      validation.flaggedReason = 'photo_location_mismatch';
      validation.flagSeverity = 3;
      validation.confidence *= 0.7;
    }
  }

  // ========== 5. DEVICE FINGERPRINT CHECK ==========
  if (isLocationSpoofed) {
    validation.deviceSignatureSuspicious = true;
    validation.flaggedReason = 'location_spoofing_detected';
    validation.flagSeverity = 5; // Critical
    validation.isValid = false;
    validation.invalidReason = 'Location spoofing app detected on device';
    validation.confidence *= 0.1;
  }

  // Check for known spoof apps in user agent
  const suspiciousPatterns = ['mock', 'fake', 'spoof', 'gps.mock'];
  if (suspiciousPatterns.some((p) => osVersion?.toLowerCase().includes(p))) {
    validation.deviceSignatureSuspicious = true;
    validation.confidence *= 0.7;
  }

  // ========== 6. SPEED CHECK (Distance vs Time) ==========
  const lastValidVisit = await PlaceVisit.findOne({
    userId,
    'validation.isValid': true,
    visitedAt: { $exists: true },
  })
    .sort({ visitedAt: -1 })
    .select('placeId visitedAt');

  if (lastValidVisit && lastValidVisit.placeId) {
    const lastPlace = await Place.findById(lastValidVisit.placeId).select(
      'latitude longitude'
    );
    if (lastPlace) {
      const distanceBetweenPlaces = haversineDistance(
        lastPlace.latitude,
        lastPlace.longitude,
        place.latitude,
        place.longitude
      );
      const timeSinceLastVisit = (
        Date.now() - lastValidVisit.visitedAt.getTime()
      ) / 1000; // seconds
      const speed = distanceBetweenPlaces / timeSinceLastVisit; // m/s

      if (speed > MAX_SPEED_MS) {
        validation.speedValid = false;
        validation.flaggedReason = 'impossible_speed';
        validation.flagSeverity = 4;
        validation.confidence *= 0.5;
      } else {
        validation.speedValid = true;
      }
    }
  }

  // ========== 7. REQUEST SIGNATURE VERIFICATION ==========
  // In production, verify HMAC signature to prevent replay attacks
  if (requestSignature) {
    const isSignatureValid = verifyRequestSignature(
      requestSignature,
      userId,
      place._id
    );
    if (!isSignatureValid) {
      validation.flaggedReason = 'invalid_signature';
      validation.flagSeverity = 5;
      validation.invalidReason = 'Invalid request signature (replay attack detected)';
      validation.isValid = false;
      validation.confidence = 0;
    }
  } else {
    validation.flaggedReason = validation.flaggedReason || 'missing_signature';
    validation.flagSeverity = Math.max(validation.flagSeverity, 4);
    validation.invalidReason = validation.invalidReason || 'Missing request signature';
    validation.isValid = false;
    validation.confidence *= 0.5;
  }

  // ========== FINAL DECISION ==========
  // If any critical flag (severity 5), reject
  if (validation.flagSeverity >= 5 && !validation.isValid) {
    validation.status = 'rejected';
    validation.confidence = Math.max(0, validation.confidence);
  } else if (validation.flagSeverity >= 3) {
    // If moderate flags, mark as suspicious but may approve
    validation.status = 'suspicious';
    validation.isValid = validation.confidence >= 0.5;
  } else {
    validation.status = validation.isValid ? 'approved' : 'suspicious';
  }

  return validation;
}

// ================================================================
// HELPER FUNCTIONS
// ================================================================

/**
 * Haversine formula: Calculate distance between two coordinates
 * Returns distance in meters
 */
function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000; // Earth radius in meters
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Calculate bearing (direction) from point 1 to point 2
 * Returns bearing in degrees (0-360)
 */
function calculateBearing(lat1, lon1, lat2, lon2) {
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const lat1Rad = (lat1 * Math.PI) / 180;
  const lat2Rad = (lat2 * Math.PI) / 180;

  const y = Math.sin(dLon) * Math.cos(lat2Rad);
  const x =
    Math.cos(lat1Rad) * Math.sin(lat2Rad) -
    Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLon);

  const bearing = (Math.atan2(y, x) * 180) / Math.PI;
  return (bearing + 360) % 360; // Normalize to 0-360
}

/**
 * Calculate angular difference between two bearings
 * Returns difference in degrees (0-180)
 */
function angleDifference(angle1, angle2) {
  let diff = Math.abs(angle1 - angle2);
  if (diff > 180) {
    diff = 360 - diff;
  }
  return diff;
}

/**
 * Verify request signature (HMAC-based replay attack prevention)
 */
function verifyRequestSignature(signature, userId, placeId) {
  // In production: verify HMAC signature
  // signature = HMAC-SHA256(userId + placeId + timestamp, SECRET_KEY)
  // For now, basic validation
  return signature && signature.length === 64; // SHA256 hex = 64 chars
}

/**
 * Check and unlock achievements for user
 */
async function checkAndUnlockAchievements(userId) {
  let unlockedAchievement = null;

  try {
    const visits = await PlaceVisit.find({
      userId,
      'validation.isValid': true,
    }).populate('placeId', 'category');

    // Check temple achievement (10 temples)
    const templeVisits = visits.filter(
      (v) => v.placeId.category === 'temple'
    ).length;
    if (templeVisits >= 10) {
      const templeAchievement = await PlaceAchievement.findOneAndUpdate(
        { userId, title: 'Temple Explorer' },
        {
          isUnlocked: true,
          unlockedAt: new Date(),
          currentProgress: templeVisits,
        },
        { upsert: true, new: true }
      );
      if (templeAchievement.isUnlocked && !templeAchievement.unlockedAt) {
        unlockedAchievement = templeAchievement;
      }
    }

    // Add more achievement checks here

    return unlockedAchievement;
  } catch (error) {
    console.error('Error checking achievements:', error);
    return null;
  }
}

module.exports = router;
