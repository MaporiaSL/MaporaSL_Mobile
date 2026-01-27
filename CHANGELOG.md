# MAPORIA Development Changelog

> **Purpose**: Track all major changes, decisions, and milestones in the project

---

## [January 27, 2026] - Places Feature Planning & Spec

### Added
- **Places System Planning** - Comprehensive feature specification for tourist attractions/locations
  - Core feature: Curated list of 50-100 Sri Lankan tourist attractions (foundational to trip planning)
  - User contributions: Locals/tourists can submit new places with photos and metadata
  - Admin verification workflow: Multi-step approval process to ensure legitimacy and quality
  - Gamification: Badges and leaderboard for contributors (Explorer, Local Guide, Curator, Legend)
  
- **Documentation**:
  - `docs/06_implementation/PLACES_FEATURE_SPEC.md` - Complete feature spec with data models, workflows, and success metrics
  - `docs/06_implementation/PLACES_IMPLEMENTATION_PLAN.md` - 6-phase step-by-step implementation guide (50+ pages)
  - `project_resorces/places_seed_data.json` - Initial 42 curated Sri Lankan attractions with full metadata

- **Updated Project Docs**:
  - `docs/01_planning/PROJECT_SOURCE_OF_TRUTH.md` - Added Places as critical foundation, updated roadmap phases 1-5

### Design Notes
- Places system is **not a standalone page** but foundational infrastructure used by every trip planner
- Each place stores: category, location, accessibility info, photos, ratings, contributor metadata
- Two sources: curated system places + user-verified community contributions
- API endpoints planned: list/search places, submit place, admin approval workflow

### Next Actions
- Backend Phase 2: Create Place & PlaceRequest models, API endpoints, photo upload
- Frontend Phase 3: Place discovery UI, integration with trip creation
- Admin Phase 5: Dashboard for reviewing submissions, badge system

---

## [January 26, 2026] - Mobile Trips UX Fixes

### Added
- Restored Memory Lane timeline UI and status grouping after corruption.
- Swapped inline trip creation dialog for navigation to CreateTripPage.

### Changed
- Trip creation/edit now enforces title + at least one destination and end date >= start.
- Trip edits use upsert flow to prevent duplicates in memory.
- Status chips and labels now use derived timeline status to avoid string/enum mismatches (fixes detail chip crash).

### Notes
- Development auth bypass remains for local testing; emulator hits backend via 10.0.2.2.

---

## [January 24, 2026] - Phase 2 Complete: Travel & Destination Data Management

### Added
- **Travel Management System**
  - Travel model with fields: userId, title, description, startDate, endDate, locations
  - Travel controller with 5 CRUD functions (create, list, getSingle, update, delete)
  - Travel input validators: validateCreateTravel, validateUpdateTravel
  - Cascade delete: deleting travel automatically deletes all associated destinations
  - Pagination and sorting support on travel list endpoint

- **Destination Management System**
  - Destination model with fields: userId, travelId, name, latitude, longitude, notes, visited
  - Destination controller with 5 CRUD functions (nested resources)
  - Destination input validators: validateCreateDestination, validateUpdateDestination
  - Nested route structure: `/api/travel/:travelId/destinations`
  - Dual ownership verification (userId + travelId)

- **API Endpoints (10 Total)**
  - Travel: POST/GET/GET/:id/PATCH/:id/DELETE/:id (5 endpoints)
  - Destination: POST/GET/GET/:id/PATCH/:id/DELETE/:id (5 nested endpoints)
  - All endpoints protected by JWT middleware
  - All endpoints scoped by userId from JWT token
  - Proper error responses: 201, 200, 400, 401, 404, 500

- **Input Validation**
  - Travel: Title (min 3), dates (ISO8601, endDate > startDate), locations (array)
  - Destination: Name (min 2), coordinates (-90/90 lat, -180/180 lon), visited (boolean)
  - All validators return 400 with detailed error messages

- **Documentation**
  - PHASE2_COMPLETION_SUMMARY.md with full implementation details
  - Updated PHASE2_DETAILED_PLAN.md marking all 9 steps complete

### Completed Tasks
- ✅ Step 1: express-validator package installed
- ✅ Step 2: Travel model created with indexes and validation hooks
- ✅ Step 3: Destination model created with nested relationships
- ✅ Step 4: Input validators for both models
- ✅ Step 5: Travel controller with all CRUD operations
- ✅ Step 6: Destination controller with nested resource handling
- ✅ Step 7: Routes for both travel and destinations with mergeParams
- ✅ Step 8: Routes wired into server with JWT middleware chain
- ✅ Step 9: API endpoints tested and verified

### Testing & Validation
- ✅ Server boots without errors with new routes
- ✅ Health endpoint responds (unprotected)
- ✅ Travel endpoints protected by JWT (401 without token)
- ✅ Routes wired correctly with proper middleware order
- ✅ Nested destination routes configured with mergeParams: true
- ✅ Error handling chain working (404 for missing resources)

### Technical Details
- **Model Indexes**: Single on userId; compound on (userId, startDate) for travel; (userId, travelId) for destinations
- **Cascade Delete**: Deleting travel removes all associated destinations
- **Data Isolation**: All queries filtered by userId from JWT sub claim
- **Nested Resources**: `/api/travel/:travelId/destinations/:destId` structure
- **Error Handling**: Comprehensive status codes and error messages

### Database Schema
**Travel Collection:**
- userId (indexed)
- title (string, required, min 3)
- description (string)
- startDate (Date, required)
- endDate (Date, required, > startDate)
- locations (array of strings)
- createdAt, updatedAt (timestamps)

**Destination Collection:**
- userId (indexed)
- travelId (ObjectId, indexed, references Travel)
- name (string, required, min 2)
- latitude (number, -90 to 90)
- longitude (number, -180 to 180)
- notes (string)
- visited (boolean)
- createdAt, updatedAt (timestamps)

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
