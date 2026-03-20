# Profile Setup Migration Evidence - 2026-03-20

## Scope
- Migration script: `backend/scripts/backfill-profile-setup-completion.js`
- Dry run command: `npm run migrate:profile-setup-backfill:dry`
- Write run command: `npm run migrate:profile-setup-backfill`

## Dry Run Results
- Mode: `DRY RUN (no writes)`
- Before:
  - total: `7`
  - completed: `1`
  - notCompleted: `6`
  - missingCompletedAt: `0`
- After (projected):
  - total: `7`
  - completed: `2`
  - notCompleted: `5`
  - missingCompletedAt: `0`
- Changes (projected):
  - Marked completed: `1`
  - Marked incomplete: `5`
  - Set completedAt timestamp: `1`
  - Total documents updated: `6`

## Write Run Results
- Mode: `WRITE`
- Before:
  - total: `7`
  - completed: `1`
  - notCompleted: `6`
  - missingCompletedAt: `0`
- After:
  - total: `7`
  - completed: `2`
  - notCompleted: `5`
  - missingCompletedAt: `0`
- Changes:
  - Marked completed: `1`
  - Marked incomplete: `5`
  - Set completedAt timestamp: `1`
  - Total documents updated: `6`

## Random User Sample Validation (Post-Write)
Sample query used aggregation `$sample: { size: 3 }` on `User` with projection for setup fields.

- User 1:
  - _id: `69a92c6a42c36b84a3200743`
  - email: `wathiladk@gmail.com`
  - name: `Wathila Karunathiake`
  - hometownDistrict: `Hambantota`
  - profileSetupCompleted: `false`
  - profileSetupCompletedAt: `null`
- User 2:
  - _id: `69aa7b00d4ae0c614509c85a`
  - email: `hemamalijayasekara123@gmail.com`
  - name: `Hemamali Jayasekara`
  - hometownDistrict: `Colombo`
  - profileSetupCompleted: `false`
  - profileSetupCompletedAt: `null`
- User 3:
  - _id: `69748eaa3d5898f18ed81c43`
  - email: `test@maporia.com`
  - name: `Test User`
  - hometownDistrict: `null`
  - profileSetupCompleted: `false`
  - profileSetupCompletedAt: `null`

Validation notes:
- Sample records are consistent with setup gating rules (records with incomplete setup fields remain `profileSetupCompleted: false`).
- Migration counters between dry-run and write-run are consistent.

## Mobile Validation for Setup Gating Behavior
The following suites validate app behavior after migration and setup localization changes:
- `flutter test test/features/profile/presentation/first_time_profile_setup_screen_test.dart`
- `flutter test test/features/home/presentation/home_screen_guard_test.dart`

Result:
- Both suites passed in this run.
