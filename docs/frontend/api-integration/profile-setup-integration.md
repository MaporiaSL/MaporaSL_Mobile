# Mobile Integration: Profile Setup Contract

## Purpose

This note aligns mobile setup UX with backend profile setup contract.

Backend reference:
- `docs/backend/api-endpoints/profile-setup-contract.md`

## Endpoints Consumed

- `GET /api/auth/me`
- `POST /api/auth/register`
- `POST /api/profile/:userId`
- `POST /api/profile/:userId/avatar`

Additional profile surfaces:
- `GET /api/profile/:userId`
- `GET /api/profile/:userId/contributions`

## Mobile Handling Rules

1. Route gating
- Use `profileSetupRequired` to route users into setup wizard.
- Do not rely only on local persisted setup flags.

2. Required and optional fields
- Render `requiredFields` and `optionalFields` from API metadata.
- Required fields must block setup completion when missing/invalid.

3. Field-level validation
- Render server `fieldErrors` inline by field key.
- Preserve server message text to avoid mismatch with backend validation.

4. Avatar upload flow
- Avatar is optional.
- If avatar upload fails, allow explicit retry without losing setup progress.
- Do not block editing required fields because of avatar failure.

5. Session resiliency
- Shared auth interceptor performs one forced refresh and one retry on `401`.
- If refresh/retry fails, UI should fail gracefully and keep user recoverable.

6. Profile statistics rendering
- The profile response now exposes contribution stats used by `My Profile` summary cards:
  - `unlockedDistrictsCount`
  - `unlockedProvincesCount`
  - `totalPlacesVisited`
- Mobile parsing must treat missing values as `0` to preserve backward compatibility.

7. Place submission coordinates
- Manual latitude/longitude entry has been removed from the mobile form.
- The app resolves coordinates automatically from place name + district + province using geocoding.
- If geocoding cannot resolve coordinates, mobile blocks submit and shows a recoverable validation message.

8. Localization consistency
- User-facing strings for Profile and Place Submission flows are now sourced via `ProfileSetupLocalizations`.
- Setup, profile overview, contribution states, leaderboard states, and place submission feedback should not introduce new hardcoded user text.

## Event and Telemetry Expectations

Current profile telemetry event names:
- `setup_started`
- `setup_completed`
- `avatar_upload_failed`
- `avatar_upload_retried`
- `avatar_upload_retry_succeeded`
- `avatar_upload_retry_failed`

Keep event names stable for dashboard continuity.

## Test Expectations

- Setup widget tests cover:
  - required vs optional labels
  - inline `fieldErrors`
  - avatar retry path
- Home guard tests cover:
  - sign-in required
  - setup required
  - blocked state
  - allowed core navigation
- Profile and place submission tests cover:
  - profile contribution controls and error states
  - auto-location required submission flow
  - localized labels/messages wired through shared localization resource
- Auth interceptor tests cover:
  - one retry on `401`
  - no retry loop
  - graceful fallback on refresh failure
