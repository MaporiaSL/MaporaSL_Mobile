const admin = require('firebase-admin');

let firebaseApp;

const REQUIRED_ENV_VARS = [
  'FIREBASE_TYPE',
  'FIREBASE_PROJECT_ID',
  'FIREBASE_PRIVATE_KEY_ID',
  'FIREBASE_PRIVATE_KEY',
  'FIREBASE_CLIENT_EMAIL',
  'FIREBASE_CLIENT_ID',
  'FIREBASE_AUTH_URI',
  'FIREBASE_TOKEN_URI',
  'FIREBASE_AUTH_PROVIDER_X509_CERT_URL',
  'FIREBASE_CLIENT_X509_CERT_URL',
  'FIREBASE_UNIVERSE_DOMAIN',
  'FIREBASE_STORAGE_BUCKET',
];

const validateEnvVars = () => {
  const missing = REQUIRED_ENV_VARS.filter(
    (key) => !process.env[key] || process.env[key].trim() === ''
  );

  if (missing.length > 0) {
    throw new Error(
      `Missing Firebase environment variables: ${missing.join(', ')}`
    );
  }
};

const validatePrivateKey = (key) => {
  if (!key.startsWith('-----BEGIN PRIVATE KEY-----')) {
    throw new Error('FIREBASE_PRIVATE_KEY does not start with BEGIN PRIVATE KEY');
  }

  if (!key.includes('-----END PRIVATE KEY-----')) {
    throw new Error('FIREBASE_PRIVATE_KEY missing END PRIVATE KEY');
  }
};

const initializeFirebase = () => {
  if (firebaseApp) {
    return firebaseApp;
  }

  try {
    validateEnvVars();

    const privateKey = process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');

    validatePrivateKey(privateKey);

    const serviceAccount = {
      type: process.env.FIREBASE_TYPE,
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: privateKey,
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: process.env.FIREBASE_AUTH_URI,
      token_uri: process.env.FIREBASE_TOKEN_URI,
      auth_provider_x509_cert_url:
        process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
      client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
      universe_domain: process.env.FIREBASE_UNIVERSE_DOMAIN,
    };

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    });

    console.log('Firebase Admin SDK initialized successfully');
    return firebaseApp;
  } catch (error) {
    console.error('Firebase Admin initialization failed');
    console.error(error.message);
    throw error;
  }
};

const getStorage = () => {
  if (!firebaseApp) {
    initializeFirebase();
  }
  return admin.storage().bucket();
};

module.exports = {
  initializeFirebase,
  getStorage,
};