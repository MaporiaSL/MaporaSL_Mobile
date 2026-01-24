# Phase 1: Detailed Implementation Plan - Authentication & User Management

## Overview
Build a secure authentication system using Express.js, MongoDB, and Auth0 JWT tokens with per-user data isolation.

---

## Feature Breakdown

### Feature 1: User Registration & Sync
- **Goal**: Create user record in MongoDB after Auth0 signup
- **Endpoint**: `POST /api/auth/register`
- **Input**: auth0Id (from JWT `sub`), email, name, optional profilePicture
- **Output**: User object with `_id`, timestamps
- **Validation**: Email uniqueness, auth0Id uniqueness, required fields
- **Error handling**: 409 if user exists, 400 for invalid input, 500 for server errors

### Feature 2: Get Current User Profile
- **Goal**: Retrieve authenticated user's profile
- **Endpoint**: `GET /api/auth/me`
- **Auth**: JWT Bearer token required
- **Output**: User object
- **Validation**: JWT signature, expiry, audience
- **Error handling**: 401 for invalid/missing token, 404 if user not in DB

### Feature 3: Logout
- **Goal**: Signal client-side token cleanup (stateless logout)
- **Endpoint**: `POST /api/auth/logout`
- **Auth**: JWT Bearer token required
- **Output**: Confirmation message
- **Error handling**: 401 for invalid token

### Feature 4: Data Isolation Middleware
- **Goal**: Enforce `userId` scoping on all protected routes
- **Implementation**: Middleware that attaches `req.userId` from JWT `sub` claim
- **Usage**: All future models/routes will filter by `userId`
- **Test**: Verify a user cannot access another user's data

---

## Dependencies & Versions

**Backend (Node.js 18+)**
```json
{
  "express": "^4.18.2",
  "dotenv": "^16.3.1",
  "mongoose": "^8.0.3",
  "cors": "^2.8.5",
  "helmet": "^7.1.0",
  "express-jwt": "^8.4.1",
  "jwks-rsa": "^3.1.0",
  "morgan": "^1.10.0"
}
```

**Dev Dependencies**
```json
{
  "nodemon": "^3.0.2",
  "jest": "^29.7.0",
  "supertest": "^6.3.3"
}
```

---

## Setup Checklist (Prerequisites)

### 1. Auth0 Account & API Setup
- [ ] Create Auth0 account at [auth0.com](https://auth0.com)
- [ ] Create API in Auth0 Dashboard (Applications → APIs → Create)
  - [ ] Note the **Identifier** (e.g., `https://gemified-travel-api`)
  - [ ] Verify signing algorithm is **RS256**
- [ ] Create a test application (Regular Web Application)
  - [ ] Note Client ID
  - [ ] Configure Allowed Callback URLs (for future mobile app)
- [ ] Get your **Tenant Domain** (e.g., `your-tenant.us.auth0.com`)

### 2. MongoDB Instance
- [ ] Option A: Local MongoDB
  - [ ] Download from [mongodb.com/community](https://www.mongodb.com/try/download/community)
  - [ ] Install and run `mongod` locally
  - [ ] URI: `mongodb://localhost:27017/gemified-travel`
- [ ] Option B: MongoDB Atlas (Free Tier)
  - [ ] Create account at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
  - [ ] Create M0 (free) cluster
  - [ ] Create database user (record username/password)
  - [ ] Whitelist IP (0.0.0.0/0 for dev, specific IPs for prod)
  - [ ] Copy connection string: `mongodb+srv://user:pass@cluster.mongodb.net/gemified-travel`

### 3. Development Environment
- [ ] Node.js 18+ installed
- [ ] npm or yarn installed
- [ ] Code editor (VS Code) with recommended extensions
- [ ] Git initialized and ready to commit

### 4. Testing Tools (Optional, for manual testing)
- [ ] Postman or VS Code REST Client extension
- [ ] Or: curl commands in terminal

---

## Implementation Steps

### Step 1: Initialize Backend Project Structure
**Files to create:**
- `backend/package.json`
- `backend/.env.example`
- `backend/.gitignore`
- `backend/src/server.js`

**What happens:**
- Define project metadata, scripts, dependencies
- Document env variables without secrets
- Create Express server entry point with middleware stack

**Validation:**
- `npm install` completes without errors
- Check [backend/package.json](backend/package.json) has all dependencies

---

### Step 2: Set Up Configuration & Database Connection
**Files to create:**
- `backend/src/config/db.js` – MongoDB connection
- `backend/src/config/env.js` – Centralized env validation (optional but recommended)

**What happens:**
- Load and validate environment variables
- Create MongoDB connection helper
- Handle connection errors gracefully

**Validation:**
- Create `.env` file (from `.env.example`)
- Run `node src/config/db.js` manually to test connection
- Verify console logs "MongoDB Connected"

---

### Step 3: Create User Model & Schema
**Files to create:**
- `backend/src/models/User.js`

**What happens:**
- Define User schema with fields: `auth0Id`, `email`, `name`, `profilePicture`, `createdAt`, `updatedAt`
- Add indexes on `auth0Id` and `email` (for query performance)
- Add pre-save hook to update `updatedAt`

**Validation:**
- Write a simple test: create and save a user object
- Verify indexes are created in MongoDB

---

### Step 4: Implement Auth0 JWT Middleware
**Files to create:**
- `backend/src/middleware/auth.js`

**What happens:**
- Create `checkJwt` middleware: validates JWT signature against Auth0 public keys
- Create `extractUserId` middleware: extracts `sub` claim and attaches to `req.userId`
- Export both for use in protected routes

**Validation:**
- Unit test: mock JWT with valid/invalid signatures
- Verify `req.userId` is set correctly after middleware

---

### Step 5: Create Auth Controller (Business Logic)
**Files to create:**
- `backend/src/controllers/authController.js`

**What happens:**
- Implement `registerUser`: create or retrieve user
- Implement `getMe`: fetch current user by auth0Id
- Implement `logoutUser`: return success message

**Validation:**
- Unit tests: each function with happy path + error cases
- Mock User model to avoid DB dependency

---

### Step 6: Create Auth Routes
**Files to create:**
- `backend/src/routes/authRoutes.js`

**What happens:**
- Define route handlers: `POST /register`, `GET /me`, `POST /logout`
- Apply middleware: `checkJwt` and `extractUserId` on protected routes
- Wire up controllers

**Validation:**
- Routes defined correctly
- Middleware chain is correct

---

### Step 7: Integrate Routes into Server
**Edit:**
- `backend/src/server.js`

**What happens:**
- Import and mount auth routes
- Add error handler middleware
- Test server startup

**Validation:**
- Run `npm run dev`
- Health check: `curl http://localhost:5000/health`
- Response: `{ "status": "ok", "timestamp": "..." }`

---

### Step 8: Create Test Suite
**Files to create:**
- `backend/test/auth.controller.test.js` – Controller unit tests
- `backend/test/auth.integration.test.js` – Integration tests with mock JWT

**What happens:**
- Unit tests: registerUser, getMe, logoutUser (with mocked User model)
- Integration tests: POST register, GET me with valid/invalid tokens
- Test error scenarios: 401, 404, 409, 500

**Validation:**
- Run `npm test`
- All tests pass
- Coverage > 80%

---

### Step 9: API Testing (Manual or Automated)
**How to test:**

**Test 1: Register User**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "auth0Id": "auth0|1234567890",
    "email": "test@example.com",
    "name": "Test User",
    "profilePicture": null
  }'
```

**Test 2: Get Current User (requires valid Auth0 JWT)**
```bash
# First get a real Auth0 token from Auth0 Dashboard or via OAuth flow
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer <your_auth0_token>"
```

**Test 3: Logout**
```bash
curl -X POST http://localhost:5000/api/auth/logout \
  -H "Authorization: Bearer <your_auth0_token>"
```

**Validation:**
- Register returns 201 with user object
- Me returns 200 with user or 401 without token
- Logout returns 200

---

### Step 10: Finalize Documentation & Commit
**Files to update:**
- [docs/02_implementation/PHASE1_BACKEND_SETUP.md](docs/02_implementation/PHASE1_BACKEND_SETUP.md) – Setup & run guide
- [docs/02_implementation/AUTH_FEATURE_SPEC.md](docs/02_implementation/AUTH_FEATURE_SPEC.md) – API contracts
- [CHANGELOG.md](CHANGELOG.md) – Mark Phase 1 complete

**What happens:**
- Document exact setup steps for next dev
- Record API contracts
- Create git commit: "Phase 1: Auth & User Management"

**Validation:**
- Documentation is accurate and complete
- All team members can follow setup guide
- Git history shows clear milestone

---

## Folder Structure (Final)

```
backend/
├── src/
│   ├── config/
│   │   ├── db.js              # MongoDB connection
│   │   └── env.js             # Env validation (optional)
│   ├── middleware/
│   │   └── auth.js            # JWT validation & userId extraction
│   ├── models/
│   │   └── User.js            # User schema
│   ├── controllers/
│   │   └── authController.js  # Auth business logic
│   ├── routes/
│   │   └── authRoutes.js      # Auth endpoints
│   └── server.js              # Express app entry
├── test/
│   ├── auth.controller.test.js
│   └── auth.integration.test.js
├── .env                       # (Git ignored, created locally)
├── .env.example               # Template
├── .gitignore
├── package.json
└── README.md                  # Local dev guide
```

---

## Testing Strategy

### Unit Tests (Isolated)
- Test each controller function independently
- Mock User model
- Test happy path + error cases
- Examples: registerUser with new/existing user, getMe with valid/invalid auth0Id

### Integration Tests (End-to-End)
- Mock Auth0 JWT tokens
- Test full request → controller → response flow
- Test middleware chain (JWT validation → userId extraction)
- Test all HTTP status codes

### Security Tests
- Invalid JWT signature → 401
- Expired JWT → 401
- Missing JWT → 401
- Malformed token → 401

### Data Validation
- Missing required fields → 400
- Duplicate email → 409
- Duplicate auth0Id → 409

---

## Success Criteria (Definition of Done)

- [ ] All files created per folder structure
- [ ] `npm install` succeeds
- [ ] `.env` configured with Auth0 + MongoDB credentials
- [ ] `npm run dev` starts server on port 5000
- [ ] Health check endpoint responds
- [ ] All 3 auth endpoints respond (200/201/401/404/409 as expected)
- [ ] Unit tests pass (>80% coverage)
- [ ] Integration tests pass
- [ ] Documentation updated
- [ ] Committed to git with clear message

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| MongoDB connection refused | Ensure MongoDB is running (local or Atlas) |
| Auth0 token invalid | Verify JWT audience, issuer, domain match `.env` |
| "useNewUrlParser deprecated" | Use mongoose 8+ without those options |
| CORS errors | Check `CLIENT_ORIGIN` in `.env` matches frontend URL |
| Missing env variables | Copy `.env.example` to `.env` and fill in values |
| Jest tests fail | Install dev dependencies: `npm install --save-dev jest supertest` |

---

## Next Phase (Phase 2)
After Phase 1 completes:
- Create Travel & Destination models with userId filtering
- Implement travel CRUD endpoints
- Add map API integration
- Frontend Auth0 SDK setup

---

## Timeline Estimate
- Steps 1-3: 30 min (project setup)
- Steps 4-6: 1-2 hours (middleware + controllers + routes)
- Step 7: 15 min (server integration)
- Step 8: 1-2 hours (tests)
- Step 9: 30 min (manual testing)
- Step 10: 15 min (docs + commit)

**Total: ~4-6 hours for full Phase 1 (solo dev)**

---

## Who Does What (Team Coordination)
- **Backend Dev**: Steps 1-10
- **Frontend Dev**: Prepare Auth0 mobile app config (parallel work)
- **DevOps** (if applicable): Set up production MongoDB Atlas

