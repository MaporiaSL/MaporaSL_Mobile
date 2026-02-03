const path = require('path');
const Album = require('../models/Album');

const { v4: uuidv4 } = require('uuid');
const { getStorage } = require('../config/firebase');

function generateStoragePath(userId, originalName, albumId = null) {
  const ext = path.extname(originalName);
  const uniqueId = uuidv4();
  const basePath = albumId 
    ? `users/${userId}/albums/${albumId}` 
    : `users/${userId}/photos`;
  return `${basePath}/${uniqueId}${ext}`;
}

async function getSignedUrl(storagePath) {
  const bucket = getStorage();
  const file = bucket.file(storagePath);
  
  // Generate signed URL valid for 7 days
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 7 * 24 * 60 * 60 * 1000 // 7 days
  });
  
  return url;
}