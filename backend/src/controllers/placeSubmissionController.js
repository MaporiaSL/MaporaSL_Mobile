const crypto = require('crypto');
const path = require('path');
const Place = require('../models/Place');
const PlaceSubmission = require('../models/PlaceSubmission');
const UserBadge = require('../models/UserBadge');
const User = require('../models/User');
const { getStorage } = require('../config/firebase');

const BADGE_RULES = [
  { name: 'Explorer', icon: 'compass', threshold: 1 },
  { name: 'Local Guide', icon: 'pin', threshold: 5 },
  { name: 'Place Curator', icon: 'map', threshold: 10 },
  { name: 'Community Legend', icon: 'trophy', threshold: 20 },
];

function normalizeText(value, maxLen) {
  return String(value || '').trim().slice(0, maxLen);
}

function normalizeCategory(value) {
  return String(value || '').trim().toLowerCase();
}

function normalizePhotos(files) {
  if (!Array.isArray(files)) return [];
  return files.filter((file) => file && file.buffer && file.originalname);
}

function toTitleCase(value) {
  return String(value || '')
    .toLowerCase()
    .split(' ')
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function haversineDistanceKm(lat1, lon1, lat2, lon2) {
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return 6371 * c;
}

function normalizeNameForMatch(name) {
  return String(name || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

async function uploadPhotosToStorage(userId, files) {
  const bucket = getStorage();
  const uploaded = [];

  for (const file of files) {
    const ext = path.extname(file.originalname || '').toLowerCase() || '.jpg';
    const fileName = `${crypto.randomUUID()}${ext}`;
    const storagePath = `users/${userId}/submissions/${fileName}`;
    const storageFile = bucket.file(storagePath);

    await storageFile.save(file.buffer, {
      metadata: {
        contentType: file.mimetype,
        metadata: {
          originalName: file.originalname,
          uploadedBy: userId,
          uploadType: 'place-submission',
        },
      },
    });

    await storageFile.makePublic();
    uploaded.push(`https://storage.googleapis.com/${bucket.name}/${storagePath}`);
  }

  return uploaded;
}

async function awardBadgesForApprovedCount(userId, approvedCount) {
  const existing = await UserBadge.findOne({ userId });
  const existingBadges = existing?.badges || [];
  const existingNames = new Set(existingBadges.map((b) => b.name));

  const newlyAwarded = [];
  for (const rule of BADGE_RULES) {
    if (approvedCount >= rule.threshold && !existingNames.has(rule.name)) {
      newlyAwarded.push({
        name: rule.name,
        icon: rule.icon,
        earnedAt: new Date(),
        contributionCount: approvedCount,
      });
    }
  }

  if (newlyAwarded.length === 0) {
    return [];
  }

  if (!existing) {
    await UserBadge.create({ userId, badges: newlyAwarded });
  } else {
    existing.badges.push(...newlyAwarded);
    await existing.save();
  }

  return newlyAwarded;
}

function badgePreviewForNextApproval(approvedCount) {
  return BADGE_RULES.filter((rule) => approvedCount + 1 >= rule.threshold);
}

async function findDuplicatePlaceForSubmission(submission) {
  const normalizedSubmissionName = normalizeNameForMatch(submission.placeName);

  const candidates = await Place.find({
    district: { $regex: `^${submission.district}$`, $options: 'i' },
    province: { $regex: `^${submission.province}$`, $options: 'i' },
    isActive: true,
  })
    .sort({ createdAt: -1 })
    .limit(50);

  let bestMatch = null;
  let bestDistance = Number.POSITIVE_INFINITY;

  for (const candidate of candidates) {
    const distance = haversineDistanceKm(
      submission.latitude,
      submission.longitude,
      candidate.latitude,
      candidate.longitude,
    );

    const normalizedCandidateName = normalizeNameForMatch(candidate.name);
    const nameExact = normalizedCandidateName === normalizedSubmissionName;
    const nameClose =
      normalizedCandidateName.includes(normalizedSubmissionName) ||
      normalizedSubmissionName.includes(normalizedCandidateName);

    if ((nameExact || nameClose) && distance <= 1.2 && distance < bestDistance) {
      bestMatch = candidate;
      bestDistance = distance;
    }
  }

  return bestMatch;
}

async function promoteSubmissionToPlace(submission) {
  const duplicate = await findDuplicatePlaceForSubmission(submission);
  const submitter = await User.findOne({ auth0Id: submission.userId });

  if (duplicate) {
    const mergedPhotos = Array.from(new Set([...(duplicate.photos || []), ...(submission.photos || [])]));
    const mergedIds = new Set((duplicate.mergedSubmissionIds || []).map((id) => id.toString()));
    mergedIds.add(submission._id.toString());

    duplicate.photos = mergedPhotos.slice(0, 20);
    duplicate.source = 'user-contributed';
    duplicate.verified = true;
    duplicate.mergedSubmissionIds = Array.from(mergedIds);
    if (!duplicate.sourceSubmissionId) {
      duplicate.sourceSubmissionId = submission._id;
    }
    duplicate.updatedAt = new Date();

    await duplicate.save();
    return { place: duplicate, merged: true };
  }

  const created = await Place.create({
    name: submission.placeName,
    description: submission.description,
    category: submission.category,
    district: toTitleCase(submission.district),
    province: toTitleCase(submission.province),
    latitude: submission.latitude,
    longitude: submission.longitude,
    location: {
      type: 'Point',
      coordinates: [submission.longitude, submission.latitude],
    },
    photos: submission.photos,
    source: 'user-contributed',
    contributor: {
      auth0Id: submission.userId,
      username: submitter?.name || submitter?.email || submission.userId,
    },
    sourceSubmissionId: submission._id,
    mergedSubmissionIds: [submission._id],
    verified: true,
    isActive: true,
    seasonality: submission.season || 'year-round',
    accessibility: {
      difficulty: submission.difficulty === 'hard' ? 'difficult' : submission.difficulty,
      entryFee: submission.entryFee > 0 ? `${submission.entryFee} LKR` : 'Free',
    },
  });

  return { place: created, merged: false };
}

async function submitPlace(req, res) {
  try {
    const userId = req.userId;
    const {
      placeName,
      description,
      category,
      province,
      district,
      latitude,
      longitude,
      season,
      difficulty,
      entryFee,
      wheelchairAccessible,
      contact,
    } = req.body;

    const files = normalizePhotos(req.files);

    if (!placeName || !description || !category || !province || !district) {
      return res.status(400).json({
        error: 'Missing required fields: placeName, description, category, province, district',
      });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    if (Number.isNaN(lat) || Number.isNaN(lng)) {
      return res.status(400).json({ error: 'Latitude and longitude must be valid numbers' });
    }

    if (files.length < 2) {
      return res.status(400).json({ error: 'At least 2 photos are required' });
    }

    const photoUrls = await uploadPhotosToStorage(userId, files);

    const submission = await PlaceSubmission.create({
      userId,
      placeName: normalizeText(placeName, 120),
      description: normalizeText(description, 4000),
      category: normalizeCategory(category),
      province: toTitleCase(normalizeText(province, 80)),
      district: toTitleCase(normalizeText(district, 80)),
      latitude: lat,
      longitude: lng,
      photos: photoUrls,
      season: normalizeText(season || 'year-round', 50),
      difficulty: normalizeText(difficulty || 'moderate', 30),
      entryFee: Number(entryFee || 0),
      wheelchairAccessible: String(wheelchairAccessible).toLowerCase() === 'true',
      contact: contact ? normalizeText(contact, 120) : null,
      status: 'pending',
      submittedAt: new Date(),
    });

    res.status(201).json({
      message: 'Place submitted successfully. Pending admin review.',
      submission: {
        id: submission._id,
        placeName: submission.placeName,
        status: submission.status,
        submittedAt: submission.submittedAt,
      },
    });
  } catch (error) {
    console.error('Submit place error:', error);
    res.status(500).json({ error: 'Failed to submit place' });
  }
}

function mapSubmissionSummary(s, extra = {}) {
  return {
    id: s._id,
    placeName: s.placeName,
    description: s.description,
    category: s.category,
    province: s.province,
    district: s.district,
    latitude: s.latitude,
    longitude: s.longitude,
    status: s.status,
    submittedAt: s.submittedAt,
    reviewedAt: s.reviewedAt,
    approvedAt: s.approvedAt,
    rejectionReason: s.rejectionReason,
    photoUrl: Array.isArray(s.photos) && s.photos.length > 0 ? s.photos[0] : '',
    photoUrls: Array.isArray(s.photos) ? s.photos : [],
    promotedPlaceId: s.promotedPlaceId || null,
    ...extra,
  };
}

async function getMySubmissions(req, res) {
  try {
    const submissions = await PlaceSubmission.find({ userId: req.userId })
      .sort({ submittedAt: -1 })
      .lean();

    res.status(200).json({
      submissions: submissions.map((s) => mapSubmissionSummary(s)),
    });
  } catch (error) {
    console.error('Get my submissions error:', error);
    res.status(500).json({ error: 'Failed to fetch submissions' });
  }
}

async function getPendingSubmissions(req, res) {
  try {
    const submissions = await PlaceSubmission.find({ status: 'pending' })
      .sort({ submittedAt: 1 })
      .limit(200)
      .lean();

    const approvedCounts = await PlaceSubmission.aggregate([
      { $match: { status: 'approved' } },
      { $group: { _id: '$userId', count: { $sum: 1 } } },
    ]);

    const countMap = new Map(approvedCounts.map((item) => [item._id, item.count]));

    res.status(200).json({
      submissions: submissions.map((s) => {
        const approvedCount = countMap.get(s.userId) || 0;
        return mapSubmissionSummary(s, {
          userId: s.userId,
          approvalBadgePreview: badgePreviewForNextApproval(approvedCount),
          currentApprovedCount: approvedCount,
        });
      }),
    });
  } catch (error) {
    console.error('Get pending submissions error:', error);
    res.status(500).json({ error: 'Failed to fetch pending submissions' });
  }
}

async function resubmitSubmission(req, res) {
  try {
    const { id } = req.params;
    const submission = await PlaceSubmission.findById(id);

    if (!submission) {
      return res.status(404).json({ error: 'Submission not found' });
    }
    if (submission.userId !== req.userId) {
      return res.status(403).json({ error: 'Forbidden: Cannot edit another user submission' });
    }
    if (submission.status !== 'rejected') {
      return res.status(400).json({ error: 'Only rejected submissions can be resubmitted' });
    }

    const files = normalizePhotos(req.files);

    if (req.body.placeName != null) submission.placeName = normalizeText(req.body.placeName, 120);
    if (req.body.description != null) submission.description = normalizeText(req.body.description, 4000);
    if (req.body.category != null) submission.category = normalizeCategory(req.body.category);
    if (req.body.province != null) submission.province = toTitleCase(normalizeText(req.body.province, 80));
    if (req.body.district != null) submission.district = toTitleCase(normalizeText(req.body.district, 80));

    if (req.body.latitude != null) {
      const lat = parseFloat(req.body.latitude);
      if (!Number.isNaN(lat)) submission.latitude = lat;
    }
    if (req.body.longitude != null) {
      const lng = parseFloat(req.body.longitude);
      if (!Number.isNaN(lng)) submission.longitude = lng;
    }

    if (files.length > 0) {
      if (files.length < 2) {
        return res.status(400).json({ error: 'At least 2 photos are required when uploading new photos' });
      }
      submission.photos = await uploadPhotosToStorage(req.userId, files);
    }

    if (!Array.isArray(submission.photos) || submission.photos.length < 2) {
      return res.status(400).json({ error: 'Submission must contain at least 2 photos' });
    }

    submission.status = 'pending';
    submission.rejectionReason = null;
    submission.reviewedBy = null;
    submission.reviewedAt = null;
    submission.approvedAt = null;
    submission.promotedPlaceId = null;
    submission.submittedAt = new Date();

    await submission.save();

    res.status(200).json({
      message: 'Submission resubmitted successfully',
      submission: mapSubmissionSummary(submission),
    });
  } catch (error) {
    console.error('Resubmit submission error:', error);
    res.status(500).json({ error: 'Failed to resubmit submission' });
  }
}

async function reviewSubmission(req, res) {
  try {
    const { id } = req.params;
    const { status, rejectionReason } = req.body;

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ error: 'status must be approved or rejected' });
    }

    const submission = await PlaceSubmission.findById(id);
    if (!submission) {
      return res.status(404).json({ error: 'Submission not found' });
    }

    if (submission.status === status && status !== 'rejected') {
      return res.status(200).json({
        message: `Submission already ${status}`,
        submission: mapSubmissionSummary(submission),
        newlyAwardedBadges: [],
      });
    }

    submission.status = status;
    submission.reviewedBy = req.userId;
    submission.reviewedAt = new Date();
    submission.rejectionReason = status === 'rejected' ? normalizeText(rejectionReason, 240) : null;
    submission.approvedAt = status === 'approved' ? new Date() : null;

    let promotionResult = null;
    let newlyAwardedBadges = [];

    if (status === 'approved') {
      promotionResult = await promoteSubmissionToPlace(submission);
      submission.promotedPlaceId = promotionResult.place._id;

      const approvedCount = await PlaceSubmission.countDocuments({
        userId: submission.userId,
        status: 'approved',
      });
      newlyAwardedBadges = await awardBadgesForApprovedCount(submission.userId, approvedCount);
    } else {
      submission.promotedPlaceId = null;
    }

    await submission.save();

    res.status(200).json({
      message: 'Submission reviewed successfully',
      submission: mapSubmissionSummary(submission),
      promotedPlace: promotionResult
        ? {
            id: promotionResult.place._id,
            merged: promotionResult.merged,
            name: promotionResult.place.name,
          }
        : null,
      newlyAwardedBadges,
    });
  } catch (error) {
    console.error('Review submission error:', error);
    res.status(500).json({ error: 'Failed to review submission' });
  }
}

module.exports = {
  submitPlace,
  getMySubmissions,
  getPendingSubmissions,
  resubmitSubmission,
  reviewSubmission,
};
