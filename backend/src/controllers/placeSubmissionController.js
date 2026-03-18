const crypto = require('crypto');
const path = require('path');
const PlaceSubmission = require('../models/PlaceSubmission');
const UserBadge = require('../models/UserBadge');
const { getStorage } = require('../config/firebase');

const BADGE_RULES = [
  { name: 'Explorer', icon: '🧭', threshold: 1 },
  { name: 'Local Guide', icon: '📍', threshold: 5 },
  { name: 'Place Curator', icon: '🗺️', threshold: 10 },
  { name: 'Community Legend', icon: '🏆', threshold: 20 },
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
      province: normalizeText(province, 80),
      district: normalizeText(district, 80),
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

async function getMySubmissions(req, res) {
  try {
    const submissions = await PlaceSubmission.find({ userId: req.userId })
      .sort({ submittedAt: -1 })
      .lean();

    res.status(200).json({
      submissions: submissions.map((s) => ({
        id: s._id,
        placeName: s.placeName,
        description: s.description,
        status: s.status,
        submittedAt: s.submittedAt,
        reviewedAt: s.reviewedAt,
        approvedAt: s.approvedAt,
        rejectionReason: s.rejectionReason,
        photoUrl: Array.isArray(s.photos) && s.photos.length > 0 ? s.photos[0] : '',
      })),
    });
  } catch (error) {
    console.error('Get my submissions error:', error);
    res.status(500).json({ error: 'Failed to fetch submissions' });
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

    submission.status = status;
    submission.reviewedBy = req.userId;
    submission.reviewedAt = new Date();
    submission.rejectionReason = status === 'rejected' ? normalizeText(rejectionReason, 240) : null;
    submission.approvedAt = status === 'approved' ? new Date() : null;
    await submission.save();

    let newlyAwardedBadges = [];
    if (status === 'approved') {
      const approvedCount = await PlaceSubmission.countDocuments({
        userId: submission.userId,
        status: 'approved',
      });
      newlyAwardedBadges = await awardBadgesForApprovedCount(submission.userId, approvedCount);
    }

    res.status(200).json({
      message: 'Submission reviewed successfully',
      submission: {
        id: submission._id,
        status: submission.status,
        reviewedAt: submission.reviewedAt,
      },
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
  reviewSubmission,
};
