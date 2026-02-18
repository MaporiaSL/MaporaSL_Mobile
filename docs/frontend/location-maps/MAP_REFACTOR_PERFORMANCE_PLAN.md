# Map Refactor: Performance & Light Theme Implementation Plan

**Status**: Phase 1 Complete | Phase 2 Starting  
**Date**: February 17, 2026  
**Focus**: Removing jank, smooth scrolling, light theme consistency

---

## ✅ Phase 1: Complete (Reroll Removal + Light Theme Update)

### What Was Done
1. **Removed all reroll UI/UX**:
   - Removed reroll modals, confirmation codes, reason forms
   - Removed info button and related onboarding screens referencing reroll
   - Kept backend support for possible admin use (untouched)

2. **Switched to light theme** (consistent with app-wide changes):
   - Map canvas: Light ocean (#E8F4F8), teal borders (#00A6B2)
   - Bottom sheet: White surface, light padding
   - Text: Dark slate (#0F172A) with proper contrast
   - Icons: Teal primary, success green, error red
   - Progress bars: Teal indicators on light backgrounds

3. **Aligned with AppTheme + AppColors**:
   - Removed hard-coded dark colors (cyan, red text, black overlays)
   - Applied global theme tokens: `AppColors.primary`, `AppColors.textDark`, etc.
   - Typography now uses `Theme.of(context).textTheme` + Fraunces/Inter fonts

4. **Simplified animations**:
   - Removed parallax + 3D tilt transforms (CPU-heavy on mid-tier devices)
   - Removed pulse animation controller (unnecessary jank)
   - Reduced cross-fade duration (220ms → 200ms)
   - Removed box shadows from dark theme; using flat card design

---

## 🔍 Phase 1 Audit: Performance Bottlenecks Identified

### Current Map Code Analysis

**CartoonMapCanvas** ([mobile/lib/features/map/presentation/widgets/cartoon_map_canvas.dart](mobile/lib/features/map/presentation/widgets/cartoon_map_canvas.dart)):
- ✅ GeoJSON parsing happens once on init (good)
- ✅ Path caching implemented (prevents re-computation)
- ⚠️ `_rebuildPathCache()` rebuilds entire path map on size change (could be optimized)
- ⚠️ Tap detection runs full polygon point-in-polygon check (O(n) per tap, ~25 districts)

**MapScreen** ([mobile/lib/features/map/presentation/map_screen.dart](mobile/lib/features/map/presentation/map_screen.dart)):
- ⚠️ **Removed 3D transforms** (Matrix4 rotation, translation) - **Major jank source**
- ⚠️ **Removed pulse animation** - unnecessary repaints every 1.4s
- ⚠️ **Removed parallax gesture handling** - setState() on every pan update (CPU spikes)
- ✅ AnimatedCrossFade for panel state (efficient)
- ✅ Lazy location list with ListView.builder (good for many locations)

**CartoonMapPainter** ([mobile/lib/features/map/presentation/painters/cartoon_map_painter.dart](mobile/lib/features/map/presentation/painters/cartoon_map_painter.dart)):
- ⚠️ Draws all districts on every frame (not culled)
- ⚠️ Draws shadows on all labels (expensive shadow blur)
- ⚠️ Draws rim light and extrusion effects unconditionally

---

## 🎯 Phase 2: Rendering Optimization (2–4 days)

### Performance Goals
- **No frame drops below 60 FPS** on Android 10+ devices
- **Tap response time** < 100ms (tap → panel update)
- **Memory usage** < 150MB for map + canvas
- **First load** < 1.5s

### Tasks

#### 2.1 Painter Optimization
- [ ] **Remove expensive effects** (rim light, extrusion depth, fog shadows)
  - These are dark-theme-specific and not needed in light theme
  - Saves ~20% paint time

- [ ] **Simple stroke + fill** approach:
  - Fill district with base color (unlocked/locked/highlighted)
  - Stroke with light teal border (1.5px width)
  - No complex gradients or layering
  - No shadow blur on text labels (just white background pill)

- [ ] **Implement layer caching**:
  ```dart
  // Separate repaints for:
  // 1. Base map (districts with fill)
  // 2. Borders (thin outlines)
  // 3. Labels (only visible labels, not all 25)
  // 4. Highlight (only selected district)
  ```

#### 2.2 Canvas Batching
- [ ] **RepaintBoundary** wrapping (already done, but verify it's effective)
- [ ] **Remove willChange: true** (forces GPU cache invalidation; set false if static)
- [ ] **Batch district redraws** by visibility (don't redraw off-screen)

#### 2.3 GeoJSON Optimization
- [ ] **Cache parsed GeoJSON paths in singleton**:
  ```dart
  class MapPathCache {
    static final _instance = MapPathCache._internal();
    static MapPathCache get instance => _instance;
    
    Map<String, List<Path>> _provincePaths = {};
    Map<String, List<Path>> _districtPaths = {};
    
    void initialize(provinces, districts) { /* ... */ }
  }
  ```
- [ ] **Lazy load** district-level GeoJSON only when needed
- [ ] **Pre-compute** label positions once (store in regions_data.dart)

#### 2.4 Gesture Handling
- [ ] **Debounce tap detection** (add 50ms debounce to prevent double-taps)
- [ ] **Cache tap results** (district ID per coordinate, not recalculate per tap)
- [ ] **Simplify polygon hit detection**:
  - Use bounding boxes first (quick O(1) reject)
  - Only run point-in-polygon for likely candidates

---

## 🎨 Phase 3: UI Architecture Refactor (3–5 days)

### Current Issues
- `MapScreen` mixes canvas + panels + state all in one widget
- Bottom sheet is a simple `AnimatedCrossFade` (works, but not scalable)
- No lazy loading of assignments list beyond what Riverpod provides

### Refactoring

#### 3.1 Split into Focused Widgets
```
MapScreen (main, state management, scaffold)
├─ MapCanvasWidget (canvas, tap detection, rendering)
├─ MapHUDWidget (top-left stats, fixed position, minimal repaints)
└─ DistrictPanelSheet (bottom sheet, assignments, actions)
    └─ LocationListBuilder (lazy list with caching)
```

#### 3.2 State Management Cleanup
- [ ] Create `MapStateNotifier` (Riverpod) for:
  - `selectedDistrict`
  - `selectedProvince`
  - `panelExpanded` state
  
- [ ] Use Riverpod selectors for fine-grained rebuilds:
  ```dart
  ref.watch(explorationProvider.select((state) => state.assignments))
  ref.watch(mapProvider.select((state) => state.selectedDistrict))
  ```

- [ ] Avoid `setState()` entirely; use Riverpod state updates

#### 3.3 Location List Optimization
- [ ] **Implement item caching**:
  ```dart
  ListView.builder(
    itemExtent: 60, // fixed height for layout pre-computation
    itemBuilder: (_, i) => _LocationCard(location: locations[i]),
  )
  ```
- [ ] **Swipe-to-dismiss** support (for fast actions)
- [ ] **Caching image thumbnails** (if location has preview photo)

---

## 📱 Phase 4: Light Theme Polish (1–2 days)

### Remaining Tasks
- [ ] Test on Android emulator (light theme rendering)
- [ ] Verify text contrast (dark text on light backgrounds)
- [ ] Check card shadows (none, per premium minimal)
- [ ] Icon colors (teal, success green, error red)
- [ ] Loading spinner (use theme color, not default)

### Minor Visual Tweaks
- [ ] Map canvas background: Off-white (#F5F6F4) or light blue (#E8F4F8)?
- [ ] District borders: Teal or slate gray?
- [ ] Selected district highlight: Teal glow or just darker fill?

---

## ✨ Phase 5: Smooth Interaction & Motion (2–3 days)

### Interaction Patterns
- [ ] **Tap-to-panel response** (< 100ms)
  - Use `onTapDown` for immediate feedback (no delay)
  - Panel slides in via `AnimatedCrossFade` (200ms)

- [ ] **District selection feedback**:
  - Visual outline on tap
  - Scale animation (1.0 → 1.02 → 1.0)
  - Color change (immediate)

- [ ] **Panel expand/collapse**:
  - Use `DraggableScrollableSheet` (if available) or simple height animation
  - Smooth inertial scroll for location list
  - No jank on scroll

- [ ] **District unlock celebration**:
  - Optional confetti (light confetti, not heavy)
  - Badge scale-in (200ms)
  - Toast notification (brief, 2s)

---

## 🧪 Phase 6: QA & Validation (2–3 days)

### Device Testing Matrix
- **Android 10 (mid-tier, Snapdragon 665+)**: Target 60 FPS
- **Android 12+ (high-tier)**: Target 120 FPS
- **Tablet** (iPad Air, Samsung Tab): Responsive layout

### Performance Profiling
- [ ] Use Flutter DevTools (timeline, memory, CPU)
- [ ] Run in profile mode (`flutter run --release`)
- [ ] Measure:
  - First load time (≤ 1.5s)
  - Frame rate (≥ 60 FPS on mid-tier)
  - Memory delta during district selection (< 5MB)

### Accessibility
- [ ] High-contrast mode testing
- [ ] Screen reader (TalkBack) navigation
- [ ] Tap targets (≥ 48x48 dp)

### Visual QA
- [ ] Light theme consistency across all screens
- [ ] Typography hierarchy clear (Fraunces headings, Inter body)
- [ ] Icon colors correct (primary, success, error)
- [ ] No jagged borders, smooth drawing

---

## Files to Modify (Phase 2–6)

| File | Phase | Change |
|------|-------|--------|
| `cartoon_map_painter.dart` | 2 | Remove shadows, rim light, extrusion; simplify draw logic |
| `cartoon_map_canvas.dart` | 2–3 | Add path cache singleton, optimize hit detection |
| `map_screen.dart` | 3–5 | Split into focused widgets, use Riverpod selectors |
| `regions_data.dart` | 2 | Pre-compute label positions |
| `map_visual_theme.dart` | 4 | Light theme values (already done) |

---

## Success Checklist

- ✅ Reroll removed (Phase 1)
- ✅ Light theme applied (Phase 1)
- ✅ No parallax/3D transforms (Phase 1)
- ⏳ Painter optimized (Phase 2)
- ⏳ Path caching implemented (Phase 2)
- ⏳ UI split into widgets (Phase 3)
- ⏳ Riverpod state management (Phase 3)
- ⏳ 60+ FPS on mid-tier device (Phase 6)
- ⏳ < 100ms tap response (Phase 6)

---

## Next Steps

Proceed to **Phase 2: Rendering Optimization** when ready.

Start with:
1. Simplify `CartoonMapPainter` (remove effects)
2. Implement path cache singleton
3. Test on device → measure frame rate

