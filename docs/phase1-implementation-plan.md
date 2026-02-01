# Map Feature - Phase 1 Implementation Plan
## Cartoonish Map Foundation

**Status:** Starting Fresh ✨  
**Branch:** `map-feature`  
**Snapshot Commit:** `f40959a` - Previous implementation for reference

---

## Objective
Build a visually appealing, cartoon-style interactive map of Sri Lanka that serves as the foundation for the trip-tracking feature. Focus on visual design and basic interactivity first, data integration later.

---

## Architecture Overview

```
MapScreen (main screen)
├── AppBar (title + info button)
├── CartoonMapCanvas (custom painted map)
│   ├── Districts painted with colors
│   ├── Landmarks as icons
│   └── Interactive tap zones
└── InfoPanel (bottom sheet)
    ├── Selected region info
    ├── Progress indicator
    └── Quick stats
```

---

## Detailed Implementation Checklist

### ✅ Done
- [x] Reset map_screen.dart to minimal state
- [x] Created regions_data.dart with 9 provinces
- [x] Created redesign plan document

### 🔄 Phase 1.1: Cartoon Map Painter (Priority: HIGH)
- [ ] Create `cartoon_map_painter.dart`
  - Paint Sri Lanka background
  - Draw district boundaries
  - Color each district
  - Add coast/water styling
  
- [ ] Create `cartoon_map_canvas.dart`
  - CustomPaint widget
  - Use CartoonMapPainter
  - Handle tap detection
  - Display selected region highlight

**Estimated Effort:** 4-6 hours

### 🔄 Phase 1.2: Landmarks & Icons
- [ ] Create `landmarks_painter.dart`
  - Paint landmarks as icons
  - Use Unicode symbols or simple shapes
  - Position at region centers
  
- [ ] Update `cartoon_map_canvas.dart`
  - Layer landmarks on top
  - Show landmark names on hover

**Estimated Effort:** 2-3 hours

### 🔄 Phase 1.3: Interactive Info Panel
- [ ] Create `info_panel.dart` component
  - Display selected region info
  - Show landmarks in region
  - Dummy statistics
  - Progress bar (0% for now)
  
- [ ] Update `map_screen.dart`
  - Manage selectedRegion state
  - Update info panel on tap
  - Add smooth transitions

**Estimated Effort:** 2-3 hours

### 🔄 Phase 1.4: Polish & Animations
- [ ] Add animations
  - Region selection fade-in
  - Info panel slide-up animation
  - Color transitions
  
- [ ] Fine-tune styling
  - Adjust colors and contrast
  - Border styling
  - Font hierarchy
  
- [ ] Add visual feedback
  - Hover effects (web)
  - Tap ripple effects
  - State indicators

**Estimated Effort:** 2-3 hours

---

## File Structure (Phase 1)

```
mobile/lib/features/map/
├── presentation/
│   ├── map_screen.dart                 ✅ Fresh start
│   └── widgets/
│       ├── cartoon_map_canvas.dart     🔄 TODO
│       ├── info_panel.dart             🔄 TODO
│       └── landmark_overlay.dart       🔄 TODO
├── utils/
│   ├── cartoon_map_painter.dart        🔄 TODO
│   ├── landmarks_painter.dart          🔄 TODO
│   └── colors.dart                     🔄 TODO
└── data/
    └── regions_data.dart               ✅ Done
```

---

## Design Specifications

### Color Palette
- Western: #FF6B6B (Red)
- Central: #4ECDC4 (Teal)
- Northern: #FFE66D (Yellow)
- Eastern: #95E1D3 (Mint)
- Southern: #A8E6CF (Green)
- North Central: #FFB6B9 (Pink)
- North Western: #FEC8D8 (Peach)
- Sabaragamuwa: #FFDDC1 (Light Peach)
- Uva: #FFFFB5 (Light Yellow)

### Typography
- Title: Bold, 20px
- Region Name: Bold, 18px
- Landmark: Regular, 14px
- Description: Regular, 13px, Grey

### Spacing
- Padding: 16px
- Gap between elements: 8-12px
- Corner radius: 12px

---

## Implementation Order

1. **Start with CartoonMapPainter** - Most complex, critical path
2. **Build CartoonMapCanvas widget** - Brings painter to life
3. **Create InfoPanel** - Simple UI, quick win
4. **Add Landmarks** - Visual enhancement
5. **Polish animations** - Last but important

---

## Success Criteria (Phase 1)

- [ ] All 9 Sri Lanka provinces visible and distinct
- [ ] Tap on region updates the info panel
- [ ] Smooth selection transitions
- [ ] No Mapbox dependencies
- [ ] Works on phone and tablet
- [ ] No crashes or lint errors
- [ ] Responsive to screen size

---

## Data Flow (Phase 1 - Local Only)

```
MapScreen
  ├─ selectedRegion (state)
  ├─ CartoonMapCanvas
  │   ├─ Get regions from regions_data.dart
  │   ├─ Paint districts
  │   ├─ Detect tap
  │   └─ Call onRegionTapped()
  └─ InfoPanel
      ├─ Display selectedRegion details
      ├─ Show landmarks
      └─ Display dummy progress
```

---

## Known Limitations (Phase 1)

⚠️ These are intentional - we'll add in Phase 2+:
- No real trip data
- No GPS/location tracking
- No route visualization
- No API integration
- No Mapbox
- No zoom/pan
- No animations (basic only)
- No theme switching

---

## Testing Plan

### Manual Testing
1. Open map screen
2. Tap each region in sequence
3. Verify info panel updates
4. Verify no crashes
5. Test on different screen sizes

### Visual Testing
- [ ] Regions render correctly
- [ ] Colors match spec
- [ ] Text is readable
- [ ] Transitions are smooth

---

## Next: Start Implementation
Ready to begin with `CartoonMapPainter`! 🎨

