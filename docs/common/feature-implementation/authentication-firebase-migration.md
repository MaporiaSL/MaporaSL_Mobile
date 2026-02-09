# Firebase Authentication Migration Plan
**Last Updated**: February 5, 2026

---

## Goal
Migrate authentication from Auth0 to **Firebase Authentication** to support a native in‑app login flow and simplify Flutter integration.

---

## Scope
### Backend
- Replace Auth0 JWT validation with Firebase Admin SDK
- Keep existing API endpoints: `/api/auth/register`, `/api/auth/me`, `/api/auth/logout`
- Continue storing the external auth ID in the **existing `auth0Id` field** (temporary, will rename later)

### Mobile
- Use Firebase Auth (email/password or providers)
- Avoid browser redirects
- Use Firebase ID token for all API calls

---

## Migration Steps
### 1) Documentation
- Add Firebase setup guide
- Update authentication feature docs
- Update API endpoint docs

### 2) Backend Changes
- Add `firebase-admin` dependency
- Create Firebase Admin initializer
- Update JWT middleware to validate Firebase ID tokens
- Update auth controller to use Firebase `uid`
- Update `.env` to include Firebase credentials

### 3) Mobile Changes (Next)
- Add `firebase_core` and `firebase_auth`
- Create `FirebaseAuthService`
- Replace Auth0 login flow
- Attach Firebase ID token to API calls

---

## Backend File Map
| File | Change |
|------|--------|
| `backend/src/config/firebaseAdmin.js` | Add Firebase Admin initialization |
| `backend/src/middleware/auth.js` | Replace Auth0 JWT logic with Firebase token verification |
| `backend/src/controllers/authController.js` | Use Firebase `uid` for user ID |
| `backend/src/routes/authRoutes.js` | Protect `/register` with token (optional but recommended) |
| `backend/.env` | Add Firebase service account fields |
| `backend/package.json` | Add `firebase-admin`, remove Auth0 libs |

---

## Notes
- The database field `auth0Id` will temporarily store the **Firebase `uid`** to avoid a large schema rename now.
- Later we can rename it to `authProviderId` once migration is stable.

---

## Success Criteria
- Mobile login works in-app (no browser redirects)
- Backend accepts Firebase ID tokens
- Authenticated endpoints work with Firebase users
- User records are created and fetched correctly
