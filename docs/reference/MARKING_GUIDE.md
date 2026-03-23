# MARKING GUIDE

## Quick Setup

### Backend
1. cd backend
2. npm install
3. Configure .env (MongoDB URI, Firebase/Auth values)
4. npm run dev

Expected: API starts on configured port (default 5000).

### Mobile
1. cd mobile
2. flutter pub get
3. flutter run

Expected: App launches to splash/auth flow and reaches Home.

## Suggested Demo Flow (10 Minutes)
1. Login or use configured development bypass.
2. Open map and interact with districts.
3. Open Places discovery, search/filter places, and open place details.
4. Mark a visit from place details.
5. Use Add to New Trip from place detail and create a trip.
6. Open Profile and navigate to Achievements.
7. Open Shop and show cart/checkout path.

## Key Verification Commands

### Mobile
- flutter analyze
- flutter test
- flutter build apk --debug

### Backend
- npm run dev

## Core Feature Coverage
- Auth integration (Firebase + bypass support)
- Trips CRUD
- Places discovery/search/detail
- Visit verification flow
- Achievements dashboard (backend-synced progress where available)
- Profile + settings
- Shop flow (phase 1)

## Notes for Evaluators
- Some advanced/social/admin features are intentionally marked as phase-2 scope.
- The project includes comprehensive implementation and planning docs under docs/.
