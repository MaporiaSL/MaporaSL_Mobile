const admin = require('firebase-admin');

let firebaseApp;

const REQUIRED_ENV_VARS = [
  'FIREBASE_PROJECT_ID',
  'FIREBASE_PRIVATE_KEY_ID',
  'FIREBASE_PRIVATE_KEY',
  'FIREBASE_CLIENT_EMAIL',
  'FIREBASE_STORAGE_BUCKET',
];

const initializeFirebase = () => {
  // Check if already initialized
  if (firebaseApp) return firebaseApp;
  if (admin.apps.length) {
    firebaseApp = admin.apps[0];
    console.log('Firebase Admin SDK already initialized, reusing existing app');
    return firebaseApp;
  }

  // Validate env vars
  const missing = REQUIRED_ENV_VARS.filter(
    (key) => !process.env[key]?.trim()
  );

  if (missing.length) {
    throw new Error(
      `Missing Firebase environment variables: ${missing.join(', ')}`
    );
  }

  // Prepare private key
  const privateKey = process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');

  if (
    !privateKey.startsWith('-----BEGIN PRIVATE KEY-----') ||
    !privateKey.includes('-----END PRIVATE KEY-----')
  ) {
    throw new Error('Invalid FIREBASE_PRIVATE_KEY format');
  }

  const service = {
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: privateKey,
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
  };

  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert(service),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  });

  console.log('Firebase Admin SDK initialized successfully');
  return firebaseApp;
};

const getStorage = () => {
  if (!firebaseApp) initializeFirebase();
  // Explicitly pass bucket name in case app was initialized without storageBucket
  return admin.storage().bucket(process.env.FIREBASE_STORAGE_BUCKET);
};

module.exports = {
  admin,
  initializeFirebase,
  getStorage,
};