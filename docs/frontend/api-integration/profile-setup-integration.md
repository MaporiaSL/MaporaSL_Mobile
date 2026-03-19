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
- Auth interceptor tests cover:
  - one retry on `401`
  - no retry loop
  - graceful fallback on refresh failure
