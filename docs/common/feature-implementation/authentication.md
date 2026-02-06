# Authentication Feature Implementation

**Feature**: User Authentication & Authorization  
**Last Updated**: February 5, 2026

---

## Overview

Authentication in MAPORIA uses **Firebase Authentication** with **Firebase ID tokens** for API authorization. The backend validates tokens and syncs user data with MongoDB.

Supported sign-in methods:

- Email + Password
- Google OAuth (Firebase provider)

---

## Google Login (Firebase OAuth)

Google Sign-In uses Firebase Auth and the same backend token validation
pipeline as email/password. The only change is how the Flutter app obtains
the Firebase ID token.

### Firebase Console Setup

1. Enable **Google** provider in Firebase Authentication.
2. Add Android SHA-1/SHA-256 fingerprints in Firebase project settings.
3. Download updated `google-services.json` (Android) and
   `GoogleService-Info.plist` (iOS).
4. Ensure the OAuth consent screen is configured in Google Cloud.

### Android Configuration

- Place `google-services.json` in `mobile/android/app/`.
- Ensure Gradle applies the Google Services plugin.
- Confirm the app package name matches Firebase settings.

### iOS Configuration

- Place `GoogleService-Info.plist` in `mobile/ios/Runner/`.
- Add the **REVERSED_CLIENT_ID** under `CFBundleURLTypes` in `Info.plist`.

### Flutter Integration

Add dependency:

```yaml
dependencies:
  google_sign_in: ^6.2.1
```

Auth service flow:

```dart
final googleUser = await GoogleSignIn().signIn();
final googleAuth = await googleUser?.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth?.accessToken,
  idToken: googleAuth?.idToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

### Backend Impact

No backend changes are required beyond existing Firebase ID token validation.
All API calls still use the Firebase ID token via the `Authorization` header.

---

## Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Frontend)     │
└────────┬────────┘
         │ 1. Login with Firebase Auth
         ▼
┌─────────────────┐
│   Firebase      │  ← External Identity Provider
│ (firebase.google.com)
└────────┬────────┘
         │ 2. Returns ID Token
         ▼
┌─────────────────┐
│  Flutter App    │
│  Stores ID token│
└────────┬────────┘
         │ 3. API calls with ID token in header
         ▼
┌─────────────────┐
│  Backend API    │
│  (Express.js)   │
└────────┬────────┘
         │ 4. Validates ID token
         ▼
┌─────────────────┐
│    MongoDB      │  ← Stores user profile & gamification data
│   User Model    │
└─────────────────┘
```

---

## Backend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **User.js** | User model schema | `backend/src/models/User.js` |
| **authController.js** | Auth logic | `backend/src/controllers/authController.js` |
| **authRoutes.js** | Auth endpoints | `backend/src/routes/authRoutes.js` |
| **auth.js** | ID token middleware | `backend/src/middleware/auth.js` |
| **.env** | Firebase config | `backend/.env` |

### 1. User Model (`backend/src/models/User.js`)

**Key Fields**:
- `firebaseUid`: External auth UID (Firebase `uid`, unique, indexed)
- `email`: User email (unique, indexed)
- `name`: Display name
- `profilePicture`: Avatar URL
- `unlockedDistricts`, `unlockedProvinces`: Gamification progress
- `achievements`: Achievement tracking array
- `totalPlacesVisited`: Counter for achievements

**Where to Make Changes**:
- **Add new user fields**: Add to schema definition
- **Add gamification logic**: Modify schema or add methods
- **Change validation**: Update field validators

```javascript
// Example: Add new field
const userSchema = new mongoose.Schema({
  // ... existing fields ...
  newField: {
    type: String,
    default: null
  }
});
```

### 2. Auth Controller (`backend/src/controllers/authController.js`)

**Functions**:
- `registerUser(req, res)`: Create/update user from Firebase data
- `getMe(req, res)`: Get current user profile
- `logoutUser(req, res)`: Logout (placeholder)

**Where to Make Changes**:
- **Modify registration logic**: Edit `registerUser` function
- **Add user profile updates**: Create new controller function
- **Change user response format**: Modify return statements

**Example: Get current user**:
```javascript
exports.getMe = async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.userId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch user' });
  }
};
```

### 3. Auth Routes (`backend/src/routes/authRoutes.js`)

**Endpoints**:
- `POST /api/auth/register` - Register/sync user (protected)
- `GET /api/auth/me` - Get current user (protected)
- `POST /api/auth/logout` - Logout (protected)

**Where to Make Changes**:
- **Add new auth endpoint**: Add route with controller function
- **Change middleware**: Modify middleware chain

**Example: Add route**:
```javascript
router.post('/update-profile', checkJwt, extractUserId, updateUserProfile);
```

### 4. ID Token Middleware (`backend/src/middleware/auth.js`)

**Functions**:
- `checkJwt`: Validates Firebase ID token using Firebase Admin SDK
- `extractUserId`: Extracts `uid` and attaches to `req.userId`

**Where to Make Changes**:
- **Change token validation**: Modify `checkJwt` configuration
- **Add custom claims**: Modify `extractUserId` to extract additional data
- **Dev mode bypass**: Edit mock user in dev environment

**Current Dev Bypass**:
```javascript
// In checkJwt middleware
if (process.env.NODE_ENV !== 'production') {
  req.user = { uid: 'dev-user-123' }; // Mock user
  return next();
}
```

---

## Frontend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **auth_service.dart** | Firebase Auth integration | `mobile/lib/core/services/auth_service.dart` |
| **auth_provider.dart** | Auth state management | `mobile/lib/providers/auth_provider.dart` |
| **api_client.dart** | HTTP client with ID token | `mobile/lib/core/services/api_client.dart` |
| **login_screen.dart** | Login UI | `mobile/lib/features/auth/screens/login_screen.dart` |

### 1. Auth Service (`mobile/lib/core/services/auth_service.dart`)

**Purpose**: Manages Firebase Auth integration and token storage.

**Key Methods**:
- `login()`: Initiates Firebase login flow
- `logout()`: Clears tokens and logs out
- `getAccessToken()`: Retrieves Firebase ID token for API calls
- `getIdToken()`: Gets user identity token
- `isAuthenticated()`: Checks if user is logged in

**Where to Make Changes**:
- **Change Firebase config**: Update Firebase project settings
- **Add social login**: Enable providers in Firebase Auth
- **Change token storage**: Modify secure storage logic

### 2. Auth Provider (`mobile/lib/providers/auth_provider.dart`)

**Purpose**: Riverpod state provider for authentication state.

**State**:
- `isAuthenticated`: Boolean auth status
- `user`: Current user object
- `isLoading`: Loading indicator

**Where to Make Changes**:
- **Add user profile updates**: Create new state methods
- **Change auth flow**: Modify login/logout logic
- **Add error handling**: Enhance error states

**Example: Auth provider pattern**:
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
```

### 3. API Client (`mobile/lib/core/services/api_client.dart`)

**Purpose**: HTTP client that automatically attaches ID tokens to requests.

**Where to Make Changes**:
- **Add token refresh logic**: Implement token refresh
- **Change API base URL**: Modify base URL constant
- **Add request interceptors**: Enhance Dio interceptors

**Example: Token attachment**:
```dart
final token = await authService.getAccessToken();
options.headers['Authorization'] = 'Bearer $token';
```

### 4. Login Screen (`mobile/lib/features/auth/screens/login_screen.dart`)

**Purpose**: UI for login/register flow.

**Where to Make Changes**:
- **Change UI design**: Modify Widget tree
- **Add social login buttons**: Add Firebase provider buttons
- **Change login flow**: Modify onPressed handlers

---

## API Endpoints

See detailed API documentation:
- [Auth Endpoints](../../backend/api-endpoints/auth-endpoints.md)

**Summary**:
- `POST /api/auth/register` - Register/sync user with MongoDB
- `GET /api/auth/me` - Get current user profile
- `POST /api/auth/logout` - Logout (clears server-side session if needed)

---

## Configuration

### Backend Environment Variables

**File**: `backend/.env`

```env
# Firebase Admin Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account@your-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# Environment
NODE_ENV=development  # Use 'production' to enforce token validation
```

**Where to Make Changes**:
- **Switch Firebase project**: Update `FIREBASE_PROJECT_ID`
- **Rotate service account**: Update `FIREBASE_CLIENT_EMAIL` + `FIREBASE_PRIVATE_KEY`
- **Enable/disable dev bypass**: Change `NODE_ENV`

### Frontend Environment

**File**: `mobile/lib/core/config/env_config.dart` or `.env`

```dart
// Use FlutterFire CLI to generate firebase_options.dart
// Then initialize Firebase with FirebaseOptions.currentPlatform
```

---

## Common Modifications

### 1. Add Email Verification

**Backend** (`authController.js`):
```javascript
exports.registerUser = async (req, res) => {
  const { email, emailVerified } = req.body;
  const authId = req.userId;
  
  if (!emailVerified) {
    return res.status(400).json({ error: 'Email not verified' });
  }
  
  // ... existing logic
};
```

**Frontend** (check before API calls):
```dart
if (!user.emailVerified) {
  showEmailVerificationDialog();
  return;
}
```

### 2. Add User Roles/Permissions

**Backend** (`User.js`):
```javascript
const userSchema = new mongoose.Schema({
  // ... existing fields ...
  role: {
    type: String,
    enum: ['user', 'admin', 'moderator'],
    default: 'user'
  }
});
```

**Middleware** (`backend/src/middleware/checkRole.js`):
```javascript
exports.checkAdmin = async (req, res, next) => {
  const user = await User.findOne({ firebaseUid: req.userId });
  if (user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  next();
};
```

### 3. Add Profile Updates

**Backend** (`authController.js`):
```javascript
exports.updateProfile = async (req, res) => {
  const { name, profilePicture } = req.body;
  const user = await User.findOneAndUpdate(
    { firebaseUid: req.userId },
    { name, profilePicture },
    { new: true }
  );
  res.json(user);
};
```

**Route** (`authRoutes.js`):
```javascript
router.patch('/profile', checkJwt, extractUserId, updateProfile);
```

**Frontend** (`auth_service.dart`):
```dart
Future<void> updateProfile(String name, String? profilePicture) async {
  await apiClient.patch('/api/auth/profile', data: {
    'name': name,
    'profilePicture': profilePicture,
  });
}
```

---

## Testing

### Backend Testing

```bash
# Test registration
curl -X POST http://localhost:5000/api/auth/register \
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","name":"Test User"}'

# Test get current user (with Firebase ID token)
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_ID_TOKEN"
```

### Frontend Testing

```dart
// Test login
await authService.login();

// Test get user
final user = await authService.getCurrentUser();
print(user.email);

// Test logout
await authService.logout();
```

---

## Troubleshooting

### "Unauthorized" Error

**Cause**: ID token missing or invalid

**Solutions**:
- Check if token is stored after login
- Verify Firebase project credentials between frontend and backend
- Check if `NODE_ENV=production` (disables dev bypass)

### "User not found" after login

**Cause**: User not synced to MongoDB

**Solution**: Ensure `/api/auth/register` is called after Firebase login:
```dart
// After Firebase login
await apiClient.post('/api/auth/register', data: {
  'email': credentials.user.email,
  'name': credentials.user.name,
});
```

### Token Expired

**Cause**: ID token expired (typically about 1 hour)

**Solution**: Implement token refresh or re-login

---

## See Also

- [Firebase Auth Setup Guide](../setup-guides/firebase-auth-setup.md)
- [Auth API Endpoints](../../backend/api-endpoints/auth-endpoints.md)
- [Frontend API Integration](../../frontend/api-integration/README.md)
- [User Model Documentation](../../backend/database/models.md#user-model)
