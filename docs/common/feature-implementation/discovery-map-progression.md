# Discovery Map Progression - Implementation Plan

Version: 1.0
Last Updated: February 5, 2026
Status: Draft

## Scope
Implement personalized per-user location assignments per district, visit verification, and unlock tracking. Integrate with a scalable unlock-location catalog stored in the database.

## Phase 1: Data Model and Catalog
### 1. Unlock Location Catalog (new collection)
- Collection: UnlockLocations
- Fields:
  - id
  - district
  - province
  - name
  - type
  - latitude
  - longitude
  - isActive
  - createdAt, updatedAt

### 2. User Assignment Storage (hybrid)
- User summary fields:
  - hometownDistrict
  - unlockedDistricts
  - unlockedProvinces
  - explorationStats: { totalAssigned, totalVisited }
  - assignmentFixedAt
  - rerollUsedAt
  - lastRerollReason
  - lastRerollAt
  - xpLedger[]
  - xpLedgerRetention: keep all entries

### XP Ledger Entry Fields
- timestamp
- source (mapExploration or generalVisit)
- amount
- location { latitude, longitude, accuracyMeters } (for map exploration)
- New collection: UserDistrictAssignments
  - userId
  - district
  - province
  - assignedLocationIds[]
  - visitedLocationIds[]
  - visitedLocationProofs[] { locationId, visitedAt, accuracyMeters, source }
    - source values: gps, gps_verified, admin_override
    - admin_override requires reason
  - assignedCount
  - visitedCount
  - unlockedAt
  - createdAt, updatedAt

### 3. Seed Import
- Import [project_resorces/places_seed_data_2026.json](../../project_resorces/places_seed_data_2026.json) into UnlockLocations.
- Validate that each district has at least 3 active locations.

## Phase 2: Assignment Algorithm
### Inputs
- User hometownDistrict
- UnlockLocations by district
- Configurable weighting parameters

### Output
- Per-district assigned count (3 to 7)
- Per-district list of assigned locations

### Algorithm Outline
1. For each district, compute a weight based on distance from hometown.
2. Use weighted randomness to select a count between 3 and 7.
3. Randomly select distinct locations from the district catalog to match the count.
4. Persist to UserDistrictAssignments and update user summary.

## Reroll Policy
- One reroll per account.
- Allowed only when total exploration < 35% (global assigned locations visited).
- Reroll eligibility is based only on exploration progress.
- Reroll resets assignments and progress to zero.
- Reroll wipes exploration XP earned from assigned locations.
- Reroll subtracts XP tagged as map exploration from the shared XP pool.
- Reroll resets exploration badges tied to location unlocks.
- Reroll resets all exploration counters tied to the map progression feature only.
- Do not reset XP or badges earned from trip planning or general place visits.
- Show a dedicated “Your Exploration Map” onboarding screen after account creation.
- Use a summary view with a “View Details” drill-down for full assignments.
- Include a warning modal before confirming reroll.
- Require typing a 6-character confirmation code shown in the modal before executing reroll.
- Code uses a random mix of letters and numbers.
- Code matching is case-insensitive.
- Code expires after 2 minutes.
- Allow regenerating a new code on request.
- Regenerating a code resets the 2-minute timer.
- Limit to 3 regenerations per session.
- Log reroll actions with timestamp and optional user reason.
- Collect reason from a selectable list with optional free-text.
- Reason selection is required.
- Free-text is required only when “Other” is selected.
- Prompt for reroll reason before code entry.

### Reroll Reason Options
- Assigned places are hard to reach.
- Prefer different types of places.
- Too many nearby places; want more variety.
- Not enough places in my area.
- Too many places overall.
- Assigned list feels repetitive.
- Privacy or comfort concerns.
- Other (free text).

## Onboarding Details View
- District list with province filter tabs.
- Default filter: All provinces.

## Rewards and XP
- XP reward scales with distance from hometown district.
- Same district: lowest XP.
- Same province: low XP.
- Other provinces: highest XP.
- Apply a small random bonus on top of the tier.
- XP weights and bonus range are configurable.
- Use a shared XP pool with source tags for map exploration vs general visits.
- Track XP events in a ledger for auditing and rollback.
  - Default values (tunable):
    - Same district: base 10 + bonus 0-4
    - Same province: base 12 + bonus 0-4
    - Other provinces: base 15 + bonus 0-4

### Weighting Model (configurable)
- Same district: highest weight
- Same province: high weight
- Other provinces: low weight

## Phase 3: API Endpoints
### Admin/Seed
- POST /api/admin/unlock-locations/seed
 - POST /api/admin/exploration/override
  - Overrides bypass cooldown
  - Overrides mark progress only (no XP)
  - Overrides count toward district unlocks
  - No limit on overrides
  - Admin-only access

### User
- GET /api/exploration/assignments
- GET /api/exploration/districts
- POST /api/exploration/visit

## Phase 4: Visit Verification (Moderate Anti-Cheat)
- Validate GPS accuracy threshold (<= 50m).
 - Enforce global cooldown between successful unlocks (5 minutes).
- Show a brief message when a user tries too soon.
- Reject visits with implausible travel speed.
- Store timestamped proof for each visit.
- Optional device integrity checks when available.
- Require 3 GPS samples within the allowed radius for gps_verified.
- Allowed radius: 100 meters.
- Sample interval: 2 seconds.
- Show a white scanning waiting screen during verification.

## Phase 5: Mobile UI
- Show assigned locations on district map.
- Mark visited locations.
- Lock/unlock state for districts and provinces.
- Provide progress indicators per district.
- Label admin-override unlocks in the UI.
- Show the label in the location detail panel only.
- Show admin overrides as “Support Verified” events in the exploration timeline.
- Place the exploration timeline in the Profile/Achievements area.

## Phase 6: Sharing Hooks
- Emit unlock events for places, districts, and provinces.
- Provide data to Sharing feature for branded assets.

## Testing Plan
- Unit tests for assignment algorithm (counts, randomness, weighting).
- Integration tests for visit verification logic.
- Mobile UI tests for lock/unlock state updates.

## Review Checklist
- Data: UnlockLocations seeded; each district has >= 3 active locations.
- Personalization: weighted assignment and hometown rule verified.
- Reroll: one-time rule, 35% cutoff, reset behavior, and audit fields confirmed.
- XP: shared pool tagging and ledger behavior validated for reroll subtraction.
- Anti-cheat: 3-sample verification, 100m radius, 2s interval, <= 50m accuracy.
- Cooldown: global 5-minute cooldown with user messaging.
- Admin: override flow, reason requirement, and no-XP progress rules.
- UX: onboarding summary + details view and warning flows ready.
- Sharing: support verification tag applied and always shown.

## Open Decisions
None.
