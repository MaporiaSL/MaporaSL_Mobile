# Architecture — MAPORIA

## Overview
MAPORIA is a mobile-first application built with Flutter. The architecture follows an **offline-first** model: local persistence for immediate user experience, and an optional sync layer for cross-device/cloud persistence.

## Client (Flutter)
- UI: Flutter widgets, responsive single codebase (Android + iOS)
- State management: **Riverpod** (recommended) — testable and modular
- Local DB: **Hive** (fast, simple) or **Drift** if SQL required
- Location: `geolocator` or `location` package
- Maps: `google_maps_flutter` (or Mapbox for offline tiles later)
- Image handling: `image_picker`, image compression library
- Share / render card: `RepaintBoundary` → `toImage()` → share plugins

## Data flow
1. **Location sampling** (mobile) → convert to geohash or cell id
2. **Local check**: is this cell new? If yes:
   - create a `VisitedTile` entry locally
   - award XP locally, update profile state
   - queue tile for sync
3. **Photo attach**: save local path + compressed copy; queue upload
4. **Sync** (optional): push local updates to backend when online

## Geo model
- **Dynamic radius**: radius adapts to movement speed
  - walking: small radius (e.g., 50–120m)
  - driving: larger radius (e.g., 200–500m)
- **Tile system**: geohash or square grid to index visited areas
- **Progress aggregation**: compute visited area per administrative boundary (city/district/province)

## Leaderboard & aggregation
- Opt-in leaderboard: client reports coverage % to server (or P2P)
- Server aggregates rankings — ensure anti-cheat via server-side verification if necessary

## Sync & backend (design)
- Keep client decoupled from backend implementation
- Design sync adapter with the following concerns:
  - Conflict resolution: latest timestamp wins; manual merge for big conflicts
  - Photo uploads: background upload with retry & progress
  - Authentication layer: guest mode vs authenticated mode

## Security & privacy
- Store only aggregated tile IDs, not raw location traces, unless user opts into route recording
- Use secure transport (HTTPS)
- Allow users to delete all data (local + server) via Settings

## Devops & CI
- GitHub Actions:
  - Run `flutter analyze` and `flutter test` on PRs
  - Optional: build debug APK on dev merges
- Releases:
  - Tag `main` and generate signed builds (Fastlane/Codemiagic recommended)

## Notes & future
- Make the geohash precision configurable for A/B testing
- Consider serverless backend (Firebase) for faster MVP
