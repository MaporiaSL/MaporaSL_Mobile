# Authentication API Endpoints

**Base URL**: `http://localhost:5000` (Dev) / `http://10.0.2.2:5000` (Android Emulator)  
**Version**: 1.0.1

---

## Overview

Authentication endpoints handle user registration, login verification, and profile retrieval. Auth0 is used as the identity provider, and these endpoints sync user data with MongoDB.

---

## Authentication Headers

All endpoints except `POST /api/auth/register` require JWT authentication.

```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

---

## Endpoints

### Register User

Sync user from Auth0 to MongoDB database. Call this after Auth0 login to create/update user record.

**Endpoint**: `POST /api/auth/register`  
**Auth**: Not required  
**Controller**: `authController.registerUser`

#### Request

```json
{
  "auth0Id": "auth0|123456789",
  "email": "user@example.com",
  "name": "John Doe",
  "profilePicture": "https://example.com/avatar.jpg"
}
```

#### Response (201 Created)

```json
{
  "message": "User registered successfully",
  "user": {
    "_id": "60a7b8c9d1e2f3g4h5i6j7k8",
    "auth0Id": "auth0|123456789",
    "email": "user@example.com",
    "name": "John Doe",
    "profilePicture": "https://example.com/avatar.jpg",
    "unlockedDistricts": [],
    "unlockedProvinces": [],
    "totalPlacesVisited": 0,
    "createdAt": "2026-02-01T10:30:00.000Z",
    "updatedAt": "2026-02-01T10:30:00.000Z"
  }
}
```

#### Response (200 OK) - User Already Exists

```json
{
  "message": "User already exists",
  "user": { ... }
}
```

#### Error Responses

**400 Bad Request**:
```json
{
  "error": "Missing required fields: auth0Id, email, name"
}
```

**500 Internal Server Error**:
```json
{
  "error": "Failed to register user"
}
```

#### cURL Example

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "auth0Id": "auth0|123456789",
    "email": "john@example.com",
    "name": "John Doe"
  }'
```

---

### Get Current User

Retrieve current authenticated user's profile from MongoDB.

**Endpoint**: `GET /api/auth/me`  
**Auth**: Required (JWT)  
**Controller**: `authController.getMe`

#### Request

No request body. User ID extracted from JWT token.

#### Response (200 OK)

```json
{
  "_id": "60a7b8c9d1e2f3g4h5i6j7k8",
  "auth0Id": "auth0|123456789",
  "email": "user@example.com",
  "name": "John Doe",
  "profilePicture": "https://example.com/avatar.jpg",
  "unlockedDistricts": ["colombo", "kandy"],
  "unlockedProvinces": ["western", "central"],
  "achievements": [
    {
      "districtId": "colombo",
      "progress": 75,
      "unlockedAt": "2026-01-15T10:00:00.000Z"
    }
  ],
  "totalPlacesVisited": 15,
  "createdAt": "2025-12-01T08:00:00.000Z",
  "updatedAt": "2026-02-01T10:30:00.000Z"
}
```

#### Error Responses

**401 Unauthorized**:
```json
{
  "error": "Unauthorized - Invalid or missing token"
}
```

**404 Not Found**:
```json
{
  "error": "User not found"
}
```

**500 Internal Server Error**:
```json
{
  "error": "Failed to fetch user profile"
}
```

#### cURL Example

```bash
curl http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Logout

Logout current user (placeholder endpoint - actual logout handled by Auth0 on client).

**Endpoint**: `POST /api/auth/logout`  
**Auth**: Required (JWT)  
**Controller**: `authController.logoutUser`

#### Request

No request body.

#### Response (200 OK)

```json
{
  "message": "Logged out successfully"
}
```

#### Error Responses

**401 Unauthorized**:
```json
{
  "error": "Unauthorized"
}
```

#### cURL Example

```bash
curl -X POST http://localhost:5000/api/auth/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Development Notes

### Dev Mode Auth Bypass

When `NODE_ENV !== 'production'`, authentication is bypassed with a mock user:

```javascript
// In middleware/auth.js
if (process.env.NODE_ENV !== 'production') {
  req.user = { auth0Id: 'auth0|dev-user-123' };
  return next();
}
```

**To Enable JWT Validation**: Set `NODE_ENV=production` in `.env`

---

## Integration Examples

### Frontend (Flutter)

```dart
// After Auth0 login
final credentials = await authService.login();

// Sync to backend
final response = await apiClient.post('/api/auth/register', data: {
  'auth0Id': credentials.user.id,
  'email': credentials.user.email,
  'name': credentials.user.name,
  'profilePicture': credentials.user.picture,
});

// Get user profile
final user = await apiClient.get('/api/auth/me');
print(user['totalPlacesVisited']);
```

---

## See Also

- [Authentication Feature Implementation](../../common/feature-implementation/authentication.md)
- [Auth0 Setup Guide](../../common/setup-guides/auth0-setup.md)
- [User Model Documentation](../database/models.md#user-model)
