# MAPORIA Development Changelog

> **Purpose**: Track all major changes, decisions, and milestones in the project

---

## [January 24, 2026] - Phase 1 Complete: Authentication & User Management

### Added
- **Backend Infrastructure**
  - Express.js server with health endpoint
  - MongoDB Atlas connection with Mongoose ORM
  - Auth0 JWT validation middleware (`checkJwt`, `extractUserId`)
  - User model with schema (auth0Id, email, name, profilePicture, timestamps)
  - Authentication controller (registerUser, getMe, logoutUser)
  - Auth routes: `POST /api/auth/register`, `GET /api/auth/me`, `POST /api/auth/logout`
  - Error handling with proper HTTP status codes (201, 200, 401, 404, 409, 500)
  - CORS, Helmet, Morgan logging middleware

- **Configuration & Documentation**
  - `.env.example` template for backend setup
  - `.gitignore` for backend (node_modules, .env, logs, coverage)
  - Backend package.json with dependencies (Express, Mongoose, express-jwt, jwks-rsa)
  - `docs/02_implementation/PHASE1_DETAILED_PLAN.md` - Step-by-step implementation guide
  - `docs/02_implementation/AUTH_FEATURE_SPEC.md` - API contracts & testing matrix

### Completed Tasks
- ✅ Step 1: Backend project structure initialized
- ✅ Step 2: MongoDB Atlas connection configured & validated
- ✅ Step 3: User model with indexes created
- ✅ Step 4: Auth0 JWT middleware implemented
- ✅ Step 5: Auth controller with full business logic
- ✅ Step 6: Auth routes with protection
- ✅ Step 7: Server integration with error handling
- ✅ Step 9: All endpoints tested & verified (register, me, logout)

### Testing & Validation
- ✅ MongoDB connection established (Atlas)
- ✅ Health check endpoint responds
- ✅ Auth0 token retrieval (Client Credentials flow)
- ✅ JWT validation on protected routes
- ✅ User registration with duplicate handling
- ✅ User profile retrieval (GET /me)
- ✅ Logout endpoint response

### Technical Details
- **Backend Stack**: Node.js + Express.js + MongoDB + Auth0 (JWT RS256)
- **Database**: MongoDB Atlas (Cloud)
- **Auth**: Auth0 with JWKS-RSA for public key validation
- **Middleware Chain**: helmet → cors → morgan → express.json → JWT validation → route handlers
- **Error Handling**: Structured JSON responses with proper HTTP status codes
- **Data Isolation**: All queries scoped by `userId` (from Auth0 `sub` claim)

### Security Measures Implemented
- ✅ RS256 JWT signature validation against Auth0 public keys
- ✅ CORS configured for localhost development
- ✅ Helmet security headers enabled
- ✅ MongoDB unique indexes on auth0Id and email
- ✅ Sensitive credentials in `.env` (not committed)

### Decisions Made
- **Auth Approach**: Auth0 (external provider) instead of custom JWT
  - **Rationale**: No need to manage secrets, built-in security, OAuth/OIDC support for future integrations
- **Database**: MongoDB Atlas instead of local
  - **Rationale**: Managed service, scalable, free tier sufficient for MVP, easier deployment
- **Skip Tests in Phase 1**: Focus on functionality over coverage for speed
  - **Note**: Can add Jest tests in Phase 1.1 if needed

### Known Limitations / Future Improvements
- Tests not yet implemented (Step 8 - optional)
- No rate limiting on auth endpoints (can add `express-rate-limit` if needed)
- No email verification flow (can add later via Auth0 rules)
- No refresh token handling (Auth0 handles this on frontend)
- No password reset (Auth0 handles this)

### Next Actions (Phase 2)
1. Create Travel & Destination models with userId scoping
2. Implement CRUD endpoints for travel data
3. Add input validation with `express-validator`
4. Frontend: Auth0 Flutter SDK integration
5. Map integration (Mapbox) for travel visualization

---

## [January 7, 2026] - Project Restructure & Documentation Setup

### Added
- **Documentation Structure**
  - Created `docs/01_planning/` - Planning and strategy documents
  - Created `docs/02_implementation/` - Step-by-step implementation guides
  - Created `docs/03_architecture/` - Technical architecture documentation
  - Created `docs/04_api/` - API reference documentation
  - Created `docs/05_setup_guides/` - Environment setup guides
  - Created `docs/06_meeting_notes/` - Team meeting notes and decisions
  - Created `docs/README.md` - Documentation index and navigation

- **Planning Documents**
  - PROJECT_SOURCE_OF_TRUTH.md - Complete feature specification
  - TECH_STACK.md - Technology decisions (Express.js + MongoDB + Auth0)
  - ALTERNATIVE_STACKS.md - Alternative technology options
  - IMPLEMENTATION_STRATEGY.md - Testing and implementation approach

### Changed
- **Project Structure**: Reorganized documentation into logical folders
- **State Management**: Noted that project uses Riverpod instead of initially planned Provider

### Decisions Made
- **Tech Stack Finalized**: Option 1B (Express.js + MongoDB + Auth0 + Firebase)
  - **Rationale**: Professional architecture with separate services, all free tier, easier to explain and learn
  - **Backend**: Node.js + Express.js (TypeScript)
  - **Database**: MongoDB Atlas M0 (free forever)
  - **Auth**: Auth0 (7k MAU free tier)
  - **Storage**: Firebase Storage (5GB free)
  - **Maps**: Mapbox (50k MAU free)
  - **Notifications**: Firebase Cloud Messaging
  - **Hosting**: Vercel/Railway (free tier)

### Security Concerns Identified
- ⚠️ **CRITICAL**: Mapbox API token exposed in `mobile/lib/main.dart` (line 12)
  - **Action Required**: Move to environment variables
  - **Priority**: HIGH

### Current Status
- **Backend**: Empty folder - needs setup
- **Frontend**: Basic Flutter structure exists with some started features
  - Existing features: home, map, profile, settings
  - Using: Riverpod for state management, Google Fonts, Mapbox
- **Documentation**: ✅ Organized and structured

### Next Actions
1. Move sensitive keys to environment variables
2. Setup backend project structure
3. Begin Phase 1: Authentication & User Management
4. Create detailed implementation guides

---

## [January 1, 2026] - Project Inception

### Added
- Initial project setup
- Flutter mobile app skeleton
- Basic folder structure

### Decisions Made
- Project name: MAPORIA (Gemified Travel Portfolio)
- Target platforms: Android (primary), iOS (secondary), Web
- Primary language: Dart (Flutter)

---

## Template for Future Entries

```markdown
## [YYYY-MM-DD] - Title

### Added
- What was added

### Changed
- What was changed

### Removed
- What was removed

### Fixed
- What bugs were fixed

### Security
- Security-related changes

### Decisions Made
- Important technical decisions with rationale

### Breaking Changes
- Any breaking changes

### Next Actions
- What needs to be done next
```

---

## Version History

| Version | Date | Phase | Status |
|---------|------|-------|--------|
| 0.1.0 | 2026-01-01 | Inception | Complete |
| 0.2.0 | 2026-01-07 | Documentation & Planning | Complete |
| 0.3.0 | TBD | Phase 1: Auth Setup | Not Started |

---

**Note**: All team members should update this file when making significant changes or decisions.
