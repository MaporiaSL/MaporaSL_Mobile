# Profile Setup API Contract

## Scope

This contract defines backend response semantics for first-time profile setup and validation alignment between:
- `GET /api/auth/me`
- `POST /api/auth/register`
- `POST /api/profile/:userId`

Source of truth:
- `backend/src/controllers/authController.js`
- `backend/src/controllers/profileController.js`

## Contract Fields

### `profileSetupRequired` (boolean)

Returned by auth endpoints to indicate whether setup wizard must be shown.

Rules:
- `true`: user must complete setup before core navigation.
- `false`: user can access core app.

### `requiredFields` (string[])

Fields that must be present/valid for setup completion.

Current required fields:
- `name`
- `hometownDistrict`
- `preferredLanguage`

### `optionalFields` (string[])

Fields allowed but not required for setup completion.

Current optional fields:
- `travelInterests`
- `avatarUrl`
- `bio`

### `fieldErrors` (object)

Field-keyed validation errors returned on `400` payload validation failures.

Example:

```json
{
  "error": "Invalid profile payload",
  "fieldErrors": {
    "name": "Name must be at least 2 characters",
    "hometownDistrict": "District is required"
  }
}
```

### Profile Stats Fields (`GET /api/profile/:userId`)

Profile responses now include aggregate contribution/engagement counters:
- `unlockedDistrictsCount` (number)
- `unlockedProvincesCount` (number)
- `totalPlacesVisited` (number)

Rules:
- Fields are always numeric in successful responses.
- Values default to `0` when no contributions/visits are recorded.
- Clients should tolerate these fields being absent on legacy deployments and apply safe defaults.

## Endpoint Behavior

### `POST /api/auth/register`

- Validates profile setup payload.
- On field validation failure:
  - `400` with `error` and `fieldErrors`.
- On existing user:
  - `200` with `profileSetupRequired`.
- On new user:
  - `201` with `profileSetupRequired: true`.

### `GET /api/auth/me`

- Returns authenticated user data and setup contract metadata:
  - `profileSetupRequired`
  - `requiredFields`
  - `optionalFields`

### `POST /api/profile/:userId`

- Validates profile update payload.
- On payload validation failure:
  - `400` with `error` and `fieldErrors`.
- When `completeSetup: true` is submitted:
  - Enforces required field completeness.
  - Returns `400` with setup-specific `fieldErrors` if incomplete.
- On success:
  - Returns profile payload with `requiredFields` and `optionalFields`.

### `GET /api/profile/:userId`

- Returns full profile data for authenticated user and includes profile stats fields.
- Expected mobile-facing stats keys:
  - `unlockedDistrictsCount`
  - `unlockedProvincesCount`
  - `totalPlacesVisited`

## Backward Compatibility Notes

- Clients must handle unknown `fieldErrors` keys gracefully.
- New required/optional fields may be appended in future versions; mobile should not hardcode assumptions without fallback handling.
- `profileSetupRequired` should remain source-of-truth for gating over local-only flags.
