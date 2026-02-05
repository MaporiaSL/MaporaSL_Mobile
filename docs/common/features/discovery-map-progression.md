# Discovery Map Progression

Version: 1.0
Last Updated: February 5, 2026
Status: Draft

## Summary
Each user receives a personalized set of exploration locations per district. Users unlock a district only after physically visiting all locations assigned to them in that district. The location catalog is separate from trip-planning places and can grow over time.

## Goals
- Provide a personalized exploration map per user.
- Require on-site visits to unlock locations, districts, and provinces.
- Ensure each district has a minimum of 3 and maximum of 7 assigned locations per user.
- Allow the location catalog to expand without redeploying the app.
- Support sharing milestones and map progress through the Sharing feature.

## Non-Goals
- Replace trip-planning places or itineraries.
- Provide routing or guided tours (may be added later).

## Key Rules
- Assignment happens at account creation.
- Assignments remain fixed after account creation, even if hometown changes.
- One-time reroll per account is allowed before 35% total exploration.
- Each district gets a random number of locations between 3 and 7 (inclusive).
- Locations are drawn from the Unlock Location Catalog (separate dataset).
- A district is unlocked only when all assigned locations for that district are visited.
- Province unlock occurs when all districts in that province are unlocked.
- Users select a hometown district during onboarding and can update it in Profile settings.

## Personalization Requirements
- The number of assigned locations is randomized per user and per district.
- Assignment is weighted so districts nearer to the user’s hometown are more likely to receive higher counts.
- The weighting parameters are configurable and can be tuned without app updates.

## Data Sources
### Unlock Location Catalog (separate from trip planning)
- Stored in a database collection.
- Seeded from [project_resorces/places_seed_data_2026.json](../../project_resorces/places_seed_data_2026.json).
- Includes district, province, location name, type, latitude, longitude.
- Each district must have at least 3 active locations.

## User Progress Data
Track per user:
- Assigned locations per district.
- Visited locations.
- Unlocked districts.
- Unlocked provinces.
- Metadata for anti-cheat and audit (timestamps, device hints).

## Rewards and XP
- Assign lower XP for locations nearer to the user’s hometown district.
- Assign higher XP for distant districts to encourage exploration.
- XP scaling uses distance tiers plus a small random bonus.
- XP weights and bonus range are configurable without app updates.
- Use a shared XP pool with source tags for map exploration vs general visits.
- Track XP events in a ledger for auditing and rollback.

## Reroll Policy
- Show a dedicated “Your Exploration Map” onboarding screen after account creation.
- Show a summary view with a “View Details” drill-down for full assignments.
- Provide options to view assigned locations and perform the one-time reroll.
- Warn users that reroll is irreversible and resets progress.
- Block reroll after 35% total exploration (global assigned locations visited).
- Reroll eligibility is based only on exploration progress.
- If reroll occurs, all assigned locations and progress reset to zero.
- Reroll wipes exploration XP earned from assigned locations.
- Reroll subtracts XP tagged as map exploration from the shared XP pool.
- Reroll resets exploration badges tied to location unlocks.
- Reroll resets all exploration counters tied to the map progression feature only.
- Do not reset XP or badges earned from trip planning or general place visits.
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
- Show a district list with province filter tabs.
- Default filter: All provinces.

## Unlock Flow
1. User account created.
2. System assigns a set of locations per district based on rules and weighting.
3. Map displays assigned locations for each district.
4. User visits locations; system verifies visit and marks location complete.
5. When all assigned locations in a district are complete, district unlocks.
6. Province unlocks when all districts in the province are unlocked.

## Sharing Hooks (See Sharing Feature)
- Share unlocked location.
- Share unlocked district or province.
- Share badge/achievement and total exploration count.
- Share branded map snapshot with unlocked areas.

## Anti-Cheat (Moderate)
- Require GPS accuracy threshold.
- Enforce cooldown between unlocks.
- Reject implausible travel speed between unlocks.
- Record timestamp and location proof for each unlock.
- Use device integrity checks if available.
- Allow admin overrides for support cases.
- Label admin-override unlocks in the UI.

## Open Decisions
None.
