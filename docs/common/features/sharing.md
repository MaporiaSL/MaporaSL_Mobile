# Sharing

Version: 1.0
Last Updated: February 5, 2026
Status: Draft

## Summary
A standalone feature that lets users share achievements, exploration progress, and branded map snapshots to social platforms. It integrates with multiple features but remains a separate module.

## Goals
- Enable branded sharing of exploration milestones.
- Provide templates for sharing badges, unlocked areas, and stats.
- Support sharing from multiple feature surfaces.

## Shareable Items
- Unlocked place (with location name and district).
- Unlocked district.
- Unlocked province.
- Badges and achievements.
- Total exploration markers unlocked.
- Map snapshots showing unlocked areas.

## Rules
- Allow sharing even when unlocks were granted via admin override.
- Include a subtle “Verified by Support” tag in shares for admin overrides.
- Tag is always shown and cannot be hidden.

## Branding Requirements
- Consistent MAPORIA logo and color treatment.
- Optional watermark toggle (on by default).
- Share cards optimized for common social aspect ratios.

## Entry Points
- Exploration unlock toast or modal.
- Profile achievements screen.
- Map progress screen.
- Trip summary screen (future).

## Privacy Controls
- Share only aggregate stats by default.
- Opt-in for sharing precise location.
- Allow users to disable social sharing prompts.

## Dependencies
- Discovery Map Progression events.
- Achievements and badge system.
- Map rendering for snapshot generation.

## Non-Goals
- In-app social feed.
- Direct messaging.
