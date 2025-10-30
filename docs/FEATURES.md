# MAPORIA — Features & Gamification

This file documents the functional design and logic for all major features.

## Core Features

### 1. Exploration Tracking Map
- **Goal:** Automatically mark areas as visited as the user physically moves.
- **User flow:** App requests location permission. Map shows current location + visited overlay. On move, app computes and marks new cells/tiles.
- **Implementation:** Use `geolocator`. Convert location to geohash. Store in local DB. Visualize with polygon overlays.

### 2. Geotagged Photos
- **Goal:** Attach photos to visited locations automatically.
- **User flow:** User captures or picks a photo. Photo is auto-tagged with current tile and timestamp.
- **Implementation:** Use `image_picker` and compress client-side.

### 3. Profile & Progress
- **Goal:** Show stats: total tiles, % coverage, XP, badges.
- **User flow:** Profile displays map mini, stats, and badges grid.
- **Implementation:** Compute coverage % by (visited_tiles / total_tiles) for a boundary.

### 4. Shareable Cards
- **Goal:** Generate a visually appealing image summarizing an achievement.
- **User flow:** User taps Share → chooses template → export image.
- **Implementation:** Use `RepaintBoundary` to render widget to image.

### 5. Catalog of Historical Places
- **Goal:** Curated POI list of historical/cultural places.
- **User flow:** Catalog accessible from map. When near a site, user sees info.
- **Implementation:** Maintain a JSON or remote dataset of POIs with coordinates.

### 6. Settings
- **Features:** Theme selection, privacy toggles (leaderboard, export/delete data), sync toggles.

---

## Gamification & Progress Logic

This section defines how exploration is measured, rewarded, and ranked.

### 1. Core Concepts
- **Tile / Cell:** Small geographic unit (geohash or square cell) used to index visited areas.
- **Dynamic Radius:** Radius adapts to user's current speed (e.g., walking: 50–120m, driving: 250–600m) to control when a tile is marked "visited".

### 2. Tile Visit Logic
1.  Sample GPS point (e.g., every 5–15 seconds).
2.  Compute effective radius based on speed.
3.  Convert location to tile.
4.  If tile is new: add to visited list, award XP, mark timestamp.

### 3. Aggregation (District/Province Unlocks)
- **Logic:** `coverage% = (visitedTiles_in_boundary / totalTiles_in_boundary) * 100`
- **Thresholds (Configurable):** City: 10%, District: 25%, Province: 50%.

### 4. XP and Leveling
- **Base XP per tile:** 5 XP (example)
- **Modifiers:**
    - First tile in new district: +25 XP
    - Photo attached: +10 XP
    - Daily streak: +2% bonus
- **Leveling Formula (Example):** `requiredXP = floor(100 * (1.25^level))`

### 5. Badges
Predefined milestones checked locally:
-   **Explorer I:** 100 tiles visited
-   **District Finder:** 10% of a district
-   **Historian:** Visit 25 cataloged historical places

### 6. Leaderboard (Opt-in)
- **Ranking Metric:** **% of Sri Lanka explored** (coverage%).
- **Anti-Cheat:** Detect GPS teleportation (improbable jumps). Rate-limit server submissions.