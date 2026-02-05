# Map Feature Redesign Plan

## Overview
Complete redesign of the map feature from scratch with a cartoonish/stylized appearance, starting with the visual foundation before adding functionality.

## Phase 1: Cartoonish Map Foundation (Current)

### Goals
- Create a visually appealing, cartoon-style map of Sri Lanka
- Establish the base UI/UX pattern
- NO interactions yet (no rotation, zoom lock, etc.)
- NO trip data integration yet
- Focus: **Visual design first**

### Features to Implement
1. **Cartoonish Map Background**
   - SVG or custom painted districts/regions
   - Colorful, playful design
   - Landmarks illustrated as icons
   - Water/coastline styled

2. **Map Regions/Districts**
   - Draw/display all 9 provinces or districts with different colors
   - Add region names
   - Highlight on tap (visual feedback)

3. **Bottom Info Panel (Static)**
   - Display currently selected region name
   - Show some fun facts (no data binding yet)
   - Basic progress indicator (dummy values)

4. **Top AppBar (Simple)**
   - Title: "Discover Sri Lanka"
   - Settings/Info button only

### What We're NOT Doing Yet
- ❌ Mapbox integration
- ❌ Real GPS/location data
- ❌ Trip data binding
- ❌ Route visualization
- ❌ Real statistics/analytics
- ❌ Theme switching
- ❌ Gesture controls

### Tech Stack for Phase 1
- Flutter widgets (CustomPaint or SVG)
- Local hardcoded data (regions, landmarks)
- Stateful widget for interaction
- Mock data only

---

## Phase 2: Trip Data Integration

### Goals
- Connect to backend trip data
- Display visited vs unvisited destinations
- Show trip progress
- Implement trip-specific analytics

### Features
- Fetch trip GeoJSON from backend
- Overlay trip route on cartoonish map
- Highlight visited destinations
- Show trip statistics panel
- Display location briefs when tapped

---

## Phase 3: Advanced Interactions

### Goals
- Add user interactions carefully
- Implement controlled gestures
- Add animations

### Features
- Tap to select region/destination
- Swipe to navigate
- Pinch to zoom (optional)
- No rotation/tilt

---

## Phase 4: Polish & Optimization

### Goals
- Performance optimization
- Animation refinement
- Accessibility
- Testing

---

## File Structure (Phase 1)

```
mobile/lib/features/map/
├── presentation/
│   ├── map_screen.dart                 (Main screen - CartoonMapScreen)
│   ├── widgets/
│   │   ├── cartoon_map_canvas.dart     (CustomPaint widget)
│   │   ├── region_selector.dart        (Region interaction)
│   │   └── info_panel.dart             (Bottom info display)
│   └── models/
│       └── cartoon_models.dart         (Local data models)
├── utils/
│   └── map_painter.dart                (CustomPaint painting logic)
└── data/
    └── regions_data.dart               (Sri Lanka regions data)
```

---

## Current Status
- ✅ Snapshot created (commit: f40959a)
- 🔄 Starting Phase 1: Cartoonish Map Foundation

## Next Steps
1. Create CartoonMapScreen (simplified map_screen.dart)
2. Implement regions_data.dart with hardcoded region info
3. Build CartoonMapCanvas with CustomPaint
4. Add basic info panel
5. Test interactivity (tap to select region)
