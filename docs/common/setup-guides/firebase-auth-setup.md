# Firebase Authentication Setup Guide
**Last Updated**: February 5, 2026

---

## Overview
This project is migrating from Auth0 to **Firebase Authentication** to enable a **native in‑app login flow** (no external browser redirects) and simpler Flutter integration.

---

## 1) Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Create a new project (or use an existing one)
3. Enable **Authentication** → **Sign‑in method** → **Email/Password** (and any other providers you want)

---

## 2) Add Apps to Firebase
### Android (Flutter)
1. Add Android app in Firebase console
2. Use package name from `android/app/build.gradle`
3. Download `google-services.json`
4. Place it in `mobile/android/app/google-services.json`

### iOS (Optional for now)
1. Add iOS app in Firebase console
2. Download `GoogleService-Info.plist`
3. Place it in `mobile/ios/Runner/GoogleService-Info.plist`

---

## 3) Backend: Service Account
1. Firebase console → **Project Settings** → **Service Accounts**
2. Generate a new private key (JSON)
3. Copy these fields into `backend/.env`:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account@your-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

> Make sure the private key uses `\n` for newlines.

---

## 4) Mobile Dependencies
Add these packages to `mobile/pubspec.yaml`:
- `firebase_core`
- `firebase_auth`

Then initialize Firebase in `main.dart` before running the app.

---

## 5) Token Flow (Backend Integration)
1. User logs in with Firebase (in-app)
2. Mobile gets Firebase ID token
3. Backend validates token with Firebase Admin SDK
4. Backend uses Firebase `uid` as the user identifier

---

## Troubleshooting
- **Invalid token**: Check Firebase project ID matches backend service account
- **Missing token**: Ensure Authorization header is `Bearer <ID_TOKEN>`
- **Permission errors**: Verify service account JSON is correct

---

## Next Steps
- Implement Firebase Admin SDK in backend
- Implement Firebase Auth flow in Flutter
- Replace Auth0 references in documentation