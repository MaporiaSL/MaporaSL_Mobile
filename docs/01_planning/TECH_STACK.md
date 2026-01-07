# MAPORIA Technology Stack (Chosen: Express.js + MongoDB + Auth0)

> **Date**: January 1, 2026  
> **Decision**: Option 1B (Express.js + MongoDB Atlas + Auth0 + Firebase Storage/FCM). Supabase remains an alternative in docs/ALTERNATIVE_STACKS.md.

---

## Executive Summary

| Component | Technology | Why | Cost (Prototype) |
|-----------|------------|-----|------------------|
| Mobile App | Flutter (Dart) | Cross-platform, fast iteration | Free |
| Backend API | Node.js + Express (TypeScript) | Simple, flexible, industry-standard | Free (Vercel/Railway) |
| Database | MongoDB Atlas (M0) | Flexible schema, always-free tier | Free |
| Authentication | Auth0 | Secure, OAuth-ready, 7k MAU free | Free |
| File Storage | Firebase Storage | Easy SDK, 5GB free | Free |
| Maps | Mapbox | Custom styling for gamification, 50k MAU free | Free |
| Notifications | Firebase Cloud Messaging | Reliable, free | Free |
| Analytics | Firebase Analytics | Lightweight, free | Free |
| Realtime (optional) | Socket.io (self-hosted) | Add when needed | Free |
| CI/CD | GitHub Actions | Automated tests/builds | Free |

---

# 1) Frontend (Flutter)

## Why Flutter
- Single codebase for Android/iOS/Web/Desktop
- Hot reload for rapid UI iteration
- Strong widget ecosystem for maps and media
- Great fit for gamified UI/animations

## Project Structure (proposed)
```
mobile/
 lib/
    main.dart
    config/
       api_config.dart           # API base URLs, timeouts
       mapbox_config.dart        # Mapbox token/style
    core/
       constants/
       services/
          api_service.dart      # REST client (Dio)
          auth0_service.dart    # Native/Auth0 login flows
          location_service.dart
          camera_service.dart
       utils/
    data/
       models/
       datasources/
          remote/               # HTTP APIs
          local/                # Cache (Hive/shared_prefs)
       repositories/
    presentation/
       providers/                # Provider for state
       screens/                  # UI screens
       widgets/
    app/
        app.dart                  # MaterialApp setup
 pubspec.yaml
 test/
```

## Key Flutter Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  provider: ^6.0.0

  # Networking & Auth
  dio: ^5.0.0
  http: ^1.1.0
  flutter_secure_storage: ^8.0.0   # store JWT/access tokens
  flutter_appauth: ^6.0.0          # Auth0 native flows

  # Maps & Location
  mapbox_maps_flutter: ^0.2.0
  geolocator: ^9.0.0

  # Media & Storage
  image_picker: ^0.8.0
  firebase_core: ^2.0.0
  firebase_storage: ^11.0.0

  # Notifications & Analytics
  firebase_messaging: ^14.0.0
  firebase_analytics: ^10.0.0

  # Local cache
  shared_preferences: ^2.0.0
  hive: ^2.0.0

  # Utilities
  intl: ^0.18.0
  uuid: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.0.0
  build_runner: ^2.0.0
```

---

# 2) Backend (Node.js + Express + TypeScript)
- Minimal boilerplate, fast to build, huge ecosystem
- REST style for simplicity; add GraphQL later if needed
- Auth0-issued JWTs validated in middleware

## Proposed Backend Layout
```
backend/
 src/
    server.ts
    config/
       env.ts
       database.ts            # Mongo connection
       auth0.ts               # JWKS / audience / issuer
    middleware/
       auth.ts                # Validate Auth0 JWT
       errorHandler.ts
    models/                    # Mongoose schemas
    routes/                    # Express routers
    controllers/               # HTTP handlers
    services/                  # Business logic
    utils/
 package.json
 tsconfig.json
 .env.example
```

## Auth0 Integration (API)
```typescript
// middleware/auth.ts
import { auth } from 'express-oauth2-jwt-bearer';

export const requireAuth = auth({
  audience: process.env.AUTH0_AUDIENCE!,
  issuerBaseURL: `https://${process.env.AUTH0_DOMAIN}`,
});
```

## Protected Route Example
```typescript
// routes/visits.ts
import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import { getUserVisits, recordVisit } from '../controllers/visits';

const router = Router();
router.get('/', requireAuth, getUserVisits);
router.post('/', requireAuth, recordVisit);
export default router;
```

## Deployment (prototype)
- API hosting: Vercel (serverless) or Railway (always-free credits)
- Secrets: AUTH0_DOMAIN, AUTH0_AUDIENCE, MONGODB_URI stored in platform secrets

---

# 3) Database (MongoDB Atlas)
- Free M0 cluster (512MB, 3-node replica set)
- ORM: Mongoose
- Data isolation: every document stores `userId`; queries filter by `userId`

```typescript
// models/visit.ts
import { Schema, model } from 'mongoose';

const VisitSchema = new Schema({
  userId: { type: String, required: true, index: true },
  placeId: { type: String, required: true },
  visitedAt: { type: Date, default: Date.now },
});

export const Visit = model('Visit', VisitSchema);
```

---

# 4) Authentication (Auth0)
- Free tier ~7k MAU
- Native app flow via `flutter_appauth` (Authorization Code + PKCE)
- Access token (Bearer) sent to Express API; middleware validates audience/issuer

```dart
// auth0_service.dart (Flutter)
final _appAuth = FlutterAppAuth();

Future<AuthResponse?> login() async {
  final result = await _appAuth.authorizeAndExchangeCode(
    AuthorizationTokenRequest(
      'AUTH0_CLIENT_ID',
      'AUTH0_DOMAIN/authorize',
      issuer: 'https://AUTH0_DOMAIN',
      redirectUrl: 'com.maporia.app://login-callback',
      scopes: ['openid', 'profile', 'email'],
      audience: 'AUTH0_API_AUDIENCE',
    ),
  );
  return result;
}
```

---

# 5) File Storage (Firebase Storage)
- Use for avatars, trip photos, achievement badges
- Free tier: 5GB storage, 1GB/day egress
- Store public download URL in MongoDB; ensure uploads are tied to `userId`

---

# 6) Maps (Mapbox)
- Custom styling for fog/cloud reveal, game aesthetic
- Token kept in `mapbox_config.dart`; add platform-specific entries in Android/iOS

---

# 7) Notifications & Analytics
- Push: Firebase Cloud Messaging (FCM) for achievements and reminders
- Analytics: Firebase Analytics for basic usage; can add self-hosted (Plausible/Matomo) later

---

# 8) Realtime (optional later)
- Add Socket.io for live leaderboards/friend activity when needed; host on same Express instance

---

# 9) Testing & Quality
- Mobile: `flutter test`, widget tests for auth/map flows; mock HTTP with `dio_adapter`/`mockito`
- Backend: Jest/Vitest for controllers/services; Supertest for endpoints
- CI: GitHub Actions running Flutter + backend tests on PRs

---

# 10) Environments & Secrets
- Local: `.env` for API, Auth0, Mongo, Firebase
- Remote: platform secrets on Vercel/Railway; Flutter `.env` via `flutter_dotenv` if needed

---

# 11) Cost Snapshot (Prototype)
- MongoDB Atlas M0: $0
- Auth0: $0 (within free tier)
- Firebase Storage + FCM + Analytics: $0
- Vercel/Railway: $0 within limits
- Mapbox: $0 up to ~50k MAU

---

# 12) Migration Notes
- Swap MongoDB -> managed Postgres + Prisma if relational needs grow
- Swap Auth0 -> AWS Cognito/Okta if enterprise SSO required
- Move storage -> S3/Cloudinary for advanced media pipelines
- Add Redis for caching/leaderboards if realtime load increases

---

# References
- Alternative stacks: docs/ALTERNATIVE_STACKS.md
- Implementation plan: docs/IMPLEMENTATION_STRATEGY.md
