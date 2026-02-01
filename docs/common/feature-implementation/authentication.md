# Authentication Feature Implementation

**Feature**: User Authentication & Authorization  
**Last Updated**: February 1, 2026

---

## Overview

Authentication in MAPORIA uses **Auth0** as the identity provider with **JWT tokens** for API authorization. The backend validates tokens and syncs user data with MongoDB.

---

## Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Frontend)     │
└────────┬────────┘
         │ 1. Login with Auth0
         ▼
┌─────────────────┐
│     Auth0       │  ← External Identity Provider
│  (auth0.com)    │
└────────┬────────┘
         │ 2. Returns JWT
         ▼
┌─────────────────┐
│  Flutter App    │
│  Stores JWT     │
└────────┬────────┘
         │ 3. API calls with JWT in header
         ▼
┌─────────────────┐
│  Backend API    │
│  (Express.js)   │
└────────┬────────┘
         │ 4. Validates JWT
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
| **auth.js** | JWT middleware | `backend/src/middleware/auth.js` |
| **.env** | Auth0 config | `backend/.env` |

### 1. User Model (`backend/src/models/User.js`)

**Key Fields**:
- `auth0Id`: External Auth0 identifier (unique, indexed)
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
- `registerUser(req, res)`: Create/update user from Auth0 data
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
    const user = await User.findOne({ auth0Id: req.user.auth0Id });
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
- `POST /api/auth/register` - Register/sync user (public)
- `GET /api/auth/me` - Get current user (protected)
- `POST /api/auth/logout` - Logout (protected)

**Where to Make Changes**:
- **Add new auth endpoint**: Add route with controller function
- **Change middleware**: Modify middleware chain

**Example: Add route**:
```javascript
router.post('/update-profile', checkJwt, extractUserId, updateUserProfile);
```

### 4. JWT Middleware (`backend/src/middleware/auth.js`)

**Functions**:
- `checkJwt`: Validates JWT token using Auth0 JWKS
- `extractUserId`: Extracts `auth0Id` from JWT and attaches to `req.user`

**Where to Make Changes**:
- **Change token validation**: Modify `checkJwt` configuration
- **Add custom claims**: Modify `extractUserId` to extract additional data
- **Dev mode bypass**: Edit mock user in dev environment

**Current Dev Bypass**:
```javascript
// In checkJwt middleware
if (process.env.NODE_ENV !== 'production') {
  req.user = { auth0Id: 'auth0|dev-user-123' }; // Mock user
  return next();
}
```

---

## Frontend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **auth_service.dart** | Auth0 integration | `mobile/lib/core/services/auth_service.dart` |
| **auth_provider.dart** | Auth state management | `mobile/lib/providers/auth_provider.dart` |
| **api_client.dart** | HTTP client with JWT | `mobile/lib/core/services/api_client.dart` |
| **login_screen.dart** | Login UI | `mobile/lib/features/auth/screens/login_screen.dart` |

### 1. Auth Service (`mobile/lib/core/services/auth_service.dart`)

**Purpose**: Manages Auth0 SDK integration and token storage.

**Key Methods**:
- `login()`: Initiates Auth0 login flow
- `logout()`: Clears tokens and logs out
- `getAccessToken()`: Retrieves JWT for API calls
- `getIdToken()`: Gets user identity token
- `isAuthenticated()`: Checks if user is logged in

**Where to Make Changes**:
- **Change Auth0 config**: Modify domain/client ID
- **Add social login**: Update Auth0 configuration
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

**Purpose**: HTTP client that automatically attaches JWT tokens to requests.

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
- **Add social login buttons**: Add Auth0 connection buttons
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
# Auth0 Configuration
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_AUDIENCE=https://api.maporia.com
AUTH0_ISSUER=https://your-tenant.auth0.com/

# Environment
NODE_ENV=development  # Use 'production' to enable JWT validation
```

**Where to Make Changes**:
- **Switch Auth0 tenant**: Update `AUTH0_DOMAIN`
- **Change API audience**: Update `AUTH0_AUDIENCE`
- **Enable/disable dev bypass**: Change `NODE_ENV`

### Frontend Environment

**File**: `mobile/lib/core/config/env_config.dart` or `.env`

```dart
static const auth0Domain = 'your-tenant.auth0.com';
static const auth0ClientId = 'your-client-id';
static const auth0Audience = 'https://api.maporia.com';
```

---

## Common Modifications

### 1. Add Email Verification

**Backend** (`authController.js`):
```javascript
exports.registerUser = async (req, res) => {
  const { auth0Id, email, emailVerified } = req.body;
  
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
  const user = await User.findOne({ auth0Id: req.user.auth0Id });
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
    { auth0Id: req.user.auth0Id },
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
  -H "Content-Type: application/json" \
  -d '{"auth0Id":"auth0|123","email":"test@example.com","name":"Test User"}'

# Test get current user (with JWT)
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
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

**Cause**: JWT token missing or invalid

**Solutions**:
- Check if token is stored after login
- Verify Auth0 domain/audience match between frontend and backend
- Check if `NODE_ENV=production` (disables dev bypass)

### "User not found" after login

**Cause**: User not synced to MongoDB

**Solution**: Ensure `/api/auth/register` is called after Auth0 login:
```dart
// After Auth0 login
await apiClient.post('/api/auth/register', data: {
  'auth0Id': credentials.user.id,
  'email': credentials.user.email,
  'name': credentials.user.name,
});
```

### Token Expired

**Cause**: JWT expired (default 24h)

**Solution**: Implement token refresh or re-login

---

## See Also

- [Auth0 Setup Guide](../setup-guides/auth0-setup.md)
- [Auth API Endpoints](../../backend/api-endpoints/auth-endpoints.md)
- [Frontend API Integration](../../frontend/api-integration/README.md)
- [User Model Documentation](../../backend/database/models.md#user-model)
