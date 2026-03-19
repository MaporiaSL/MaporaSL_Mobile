# Map Screen Refactoring: Visual & Behavioral Guide

## State Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    MAP SCREEN STATES                         │
└─────────────────────────────────────────────────────────────┘

                         ┌──────────────────┐
                         │   INIT STATE     │
                         │   Cartoon Map    │
                         │   No Selection   │
                         └────────┬─────────┘
                                  │
                         User Tap on District
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ DISTRICT FOCUS   │
                         │ Vector Map       │
                         │ + Spotlight      │
                         │ + Markers        │
                         └────────┬─────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
          User Tap Marker    Tap Boundary   Tap Exit
                    │             │             │
                    ▼             ▼             ▼
           ┌─────────────┐  ┌────────────┐  ┌──────────┐
           │ LOCATION    │  │ IGNORED    │  │  BACK TO │
           │ SELECTED    │  │ (no action)│  │  INIT    │
           │ Detail Card │  └────────────┘  └──────────┘
           └──────┬──────┘
                  │
         Click Verify Button
                  │
                  ▼
         ┌─────────────────┐
         │ DynamicVisit    │
         │ Sheet Opens     │
         │ Camera Request  │
         │ Verification   │
         └────────┬────────┘
                  │
         Success / Cancel
                  │
                  ▼
         ┌──────────────────┐
         │ Back to Detail   │
         │ Card (Updated)   │
         └────────┬─────────┘
                  │
         Tap Close or
         Select Different Location
                  │
                  ▼
         ┌──────────────────┐
         │ Back to District │
         │ Focus / Init     │
         └──────────────────┘
```

---

## Visual Hierarchy: Before vs After

### BEFORE: Satellite Map Approach

```
┌─────────────────────────────────────────┐
│ 📡 Satellite Imagery Background         │
│                                         │
│  [Difficult to read text]               │
│  [Hard to distinguish boundaries]       │
│                                         │
│  🔴 Marker (hard to see on terrain)     │
│  [No visual distinction visited vs not]  │
│                                         │
│  [No focal highlighting]                │
│  [Unmarked boundary area]               │
│                                         │
│  [User pans freely, gets lost]          │
└─────────────────────────────────────────┘
```

**Problems**:
- ❌ Low contrast markers
- ❌ Text illegible (place names)
- ❌ Districts hard to distinguish
- ❌ No clear visual hierarchy
- ❌ Heavy bandwidth usage

---

### AFTER: Vector Map with Spotlight

```
┌─────────────────────────────────────────┐
│ 🗺️ Street Map [CLEAR READABLE TEXT]     │
│                                         │
│ ⬛ Outside District                     │
│    (darkened, can't interact)           │
│                                         │
│    🟢 ≈≈≈≈≈ DISTRICT BOUNDARY ≈≈≈≈≈   │
│   ╱  Bright Green 3px Line             │
│  ╱   Subtle Green Fill (0.08 opacity)  │
│                                         │
│    🟢 Visited Marker   (Larger, Green) │
│    🔴 Unvisited Marker (Red, Smaller)  │
│                                         │
│    [Clear Place Names Below Map]        │
│    [Distinct Street Visualization]      │
└─────────────────────────────────────────┘
```

**Improvements**:
- ✅ High contrast markers
- ✅ Clear readable text
- ✅ District boundaries obvious
- ✅ Visual hierarchy clear
- ✅ Lightweight data transfer
- ✅ Smooth interactions

---

## Marker Styling System

### Visited Location Marker
```
┌─────────────────────┐
│   Visited Marker    │
├─────────────────────┤
│ Size:      2.0      │
│ Color:     #10B981  │ (Emerald Green)
│ Opacity:   1.0      │
│ Icon:      ✓ Check  │
│ Z-Index:   Higher   │
│ Shadow:    Dark     │
└─────────────────────┘

Visual: Prominent, clear, indicates completion
```

### Unvisited Location Marker
```
┌─────────────────────┐
│  Unvisited Marker   │
├─────────────────────┤
│ Size:      1.6      │
│ Color:     #EF4444  │ (Red)
│ Opacity:   0.85     │
│ Icon:      📍 Pin   │
│ Z-Index:   Lower    │
│ Shadow:    Light    │
└─────────────────────┘

Visual: Subtle, indicates work needed
```

---

## District Spotlight Effect Visualization

### Layer Stack (bottom to top)

```
┌─────────────────────────────────────┐
│ LAYER 3: Outside Mask (z: 1000)      │  ← Renders LAST (on top)
│ ┌───────────────────────────────────┤
│ │ Solid Black, Opacity: 1.0          │
│ │ Covers entire world except hole    │
│ │                                    │
│ │  ⬛⬛⬛⬛⬛ ┌─────────┐⬛⬛⬛⬛⬛      │
│ │  ⬛⬛⬛⬛⬛ │District │⬛⬛⬛⬛⬛      │
│ │  ⬛⬛⬛⬛⬛ └─────────┘⬛⬛⬛⬛⬛      │
│ └───────────────────────────────────┤
│                                      │
├─────────────────────────────────────┤
│ LAYER 2: District Line (z: 500)      │
│ ┌───────────────────────────────────┤
│ │ Bright Green (#22C55E), Width: 3px │
│ │ Opacity: 0.9                       │
│ │ Outlines district boundary clearly │
│ │                                    │
│ │         ┌──────────┐               │
│ │         │ 🟢🟢🟢🟢🟢 │               │
│ │         │ 🟢      🟢 │              │
│ │         │ 🟢      🟢 │              │
│ │         │ 🟢🟢🟢🟢🟢 │              │
│ │         └──────────┘               │
│ └───────────────────────────────────┤
│                                      │
├─────────────────────────────────────┤
│ LAYER 1: District Fill (z: 100)      │
│ ┌───────────────────────────────────┤
│ │ Light Green (#22C55E)              │
│ │ Opacity: 0.08 (very subtle)        │
│ │ Creates soft glow effect           │
│ │                                    │
│ │         ┌──────────┐               │
│ │         │ 🤍🤍🤍🤍🤍 │               │
│ │         │ 🤍      🤍 │  (imperceptible
│ │         │ 🤍      🤍 │   green tint)
│ │         │ 🤍🤍🤍🤍🤍 │               │
│ │         └──────────┘               │
│ └───────────────────────────────────┤
│                                      │
├─────────────────────────────────────┤
│ LAYER 0: Vector Street Map (z: 0)    │  ← Renders FIRST (bottom)
│ ┌───────────────────────────────────┤
│ │ Mapbox Streets v12                 │
│ │ Shows roads, labels, landmarks     │
│ │                                    │
│ │ ┌────┐  ┌────┐  ┌────┐            │
│ │ │Road│  │Road│  │Road│  ...       │
│ │ │    │  │    │  │    │            │
│ │ │Bnd │  │Bnd │  │Bnd │            │
│ │ └────┘  └────┘  └────┘            │
│ └───────────────────────────────────┤
└─────────────────────────────────────┘
```

**Rendering Order**:
1. Street Map (background)
2. District fill (subtle glow)
3. District line (bright border)
4. Outside mask (vignette effect)

---

## Interaction Flows

### Flow 1: Simple District Selection

```
User Views Cartoon Map
         │
         ▼
   Tap on District
    (e.g., "Colombo")
         │
         ▼
   _isDistrictFocused = true
   selectedDistrict = "Colombo"
   selectedProvince = "Western"
         │
         ▼
   ┌─────────────────────┐
   │ _DistrictVectorMap  │
   │ Shows:              │
   │ - Streets layer     │
   │ - District boundary │
   │ - Spotlight effect  │
   │ - Markers (10-50)   │
   └─────────────────────┘
         │
         ▼
   Camera Animates to
   District Bounds
   (700ms easing)
         │
         ▼
   Map Bounds Locked
   (min: 7.5 zoom,
    max: 13.5 zoom,
    pan within district)
```

### Flow 2: Tap Same District Twice = Exit

```
In District Focus View (Colombo)
         │
         ▼
   User Taps on
   District Again
   _normalizeKey("Colombo") ==
   _normalizeKey(selectedDistrict)
         │
         ▼
   Detected: Same District
   _isDistrictFocused == true
         │
         ▼
   _exitDistrictFocus():
   - selectedDistrict = null
   - selectedProvince = null
   - _isDistrictFocused = false
   - _selectedLocation = null
         │
         ▼
   Return to CartoonMapCanvas
   (Entire Sri Lanka view)
         │
         ▼
   Reset Camera to Default
   Bounds Unlocked
```

### Flow 3: Marker Interaction

```
In District Focus View
         │
         ▼
   User Taps Marker
         │
         ▼
   Multi-Marker Check:
   - Get all locations within
     160 meters of tap point
         │
         ▼─────────────────────────┐
         │                         │
    Single Marker?           Multiple Markers?
         │                         │
         ▼                         ▼
   Direct Selection        Show Bottom Sheet
                          (List all nearby places)
         │                         │
         ▼                         ▼
   _selectedLocation =      User Selects One
   location                 │
         │                  ▼
         └──────────────────┘
                  │
                  ▼
         Detail Card Appears
         (Bottom of screen)
         │
         ├─ Photo (if available)
         ├─ Name & Type
         ├─ Description
         └─ [Verify] Button
                  │
                  ▼
         User Taps Verify
                  │
                  ▼
    DynamicVisitSheet.show(
      isExploration: true,
      explorationLocation: location
    )
```

---

## Data Flow Architecture

### Provider Chain

```
┌─────────────────────────────────────────┐
│      explorationProvider (Riverpod)     │
│  Manages: Assignments, State, Errors    │
└────────────┬──────────────────────────────┘
             │
             │.watch() call
             │
             ▼
┌─────────────────────────────────────────┐
│         ExplorationState                │
│  - List<DistrictAssignment> assignments │
│  - bool isVerifying                     │
│  - String? error                        │
│  - bool isLoaded                        │
└────────────┬──────────────────────────────┘
             │
             │ Transformed to:
             │
             ▼
┌─────────────────────────────────────────┐
│    DistrictAssignment (per district)    │
│  - String district ("Colombo")          │
│  - String province ("Western")          │
│  - int assignedCount (50)               │
│  - int visitedCount (23)                │
│  - List<ExplorationLocation> locations  │
│  - CoordinateBounds bounds              │
│  - Coordinates? center                  │
└────────────┬──────────────────────────────┘
             │
             │ Contains:
             │
             ▼
┌─────────────────────────────────────────┐
│      ExplorationLocation                │
│  - String id                            │
│  - String name ("Sigiriya")             │
│  - double latitude (7.9570)             │
│  - double longitude (80.7598)           │
│  - String type ("Ancient Rock")         │
│  - String description                   │
│  - List<String> photos                  │
│  - bool visited (false)                 │
└─────────────────────────────────────────┘
```

### State Updates

```
Initial Load:
  BG Task: explorationProvider.loadAssignments()
  ↓
  HTTP GET /api/explorer/{travelId}/assignments
  ↓
  Parse Response → List<DistrictAssignment>
  ↓
  Stored in State
  ↓
  MapScreen watches & rebuilds
  ↓
  Passes to CartoonMapCanvas

District Focus:
  User Taps District
  ↓
  setState() updates _isDistrictFocused
  ↓
  Conditional build returns _DistrictVectorMap
  ↓
  Mapbox SDK loads layers
  ↓
  Markers render

Verification:
  User Taps Verify
  ↓
  DynamicVisitSheet shows
  ↓
  User takes photo
  ↓
  explorationProvider.verify(locationId)
  ↓
  isVerifying = true → show spinner
  ↓
  HTTP POST /api/explorer/{travelId}/verify
  ↓
  Success: location.visited = true
  ↓
  isVerifying = false
  ↓
  Detail card updates (button disabled)
  ↓
  Marker re-renders (green, larger)
```

---

## Marker System: Icon Setup

### Required Asset Files

```
assets/
├── images/
│   ├── markers/
│   │   ├── marker-visited.png
│   │   │   Size: 40×40 pixels
│   │   │   Icon: Green checkmark
│   │   │   Background: Transparent
│   │   │
│   │   └── marker-unvisited.png
│   │       Size: 40×40 pixels
│   │       Icon: Red location pin
│   │       Background: Transparent
│   │
│   └── ... other assets ...
│
└── geojson/
    ├── boundaries/
    │   └── LK-districts.geojson
    │       Format: FeatureCollection
    │       Features: District polygons
    │       Required Props: NAME_1 or name
    │
    └── ... other GeoJSON files ...
```

### pubspec.yaml Configuration

```yaml
flutter:
  assets:
    # NEW: Add these lines
    - assets/images/markers/
    - assets/geojson/boundaries/
    
    # Keep existing assets
    - assets/images/...
    - assets/...
```

---

## Boundary Enforcement Example

### Before User Enters District

```
┌──────────────────────────────────────────┐
│  Sri Lanka Cartoon Map                   │
│  (Entire Island Visible)                 │
│                                          │
│  ┌─────────┐  ┌──────────┐              │
│  │ Western │  │ Central  │              │
│  │ Colombo │  │ Kandy    │  ← Can pan  │
│  └─────────┘  └──────────┘    to any   │
│       │            │          district  │
│       └────────────┘                    │
│        Free Navigation                  │
└──────────────────────────────────────────┘
```

### After User Enters District

```
┌──────────────────────────────────┐
│  ⬛ Outside Colombo (Darkened)   │
│ ┌──────────────────────────────┐ │
│ │  Colombo District (Active)   │ │
│ │  ┌────────────────────────┐  │ │
│ │  │ Street Map             │  │ │
│ │  │ [Roads, Labels, etc.]  │  │ │
│ │  │                        │  │ │
│ │  │  🟢 Marker             │  │ │
│ │  │  🟢 Marker             │  │ │
│ │  │                        │  │ │
│ │  └────────────────────────┘  │ │
│ │  Green Border (3px)          │ │
│ └──────────────────────────────┘ │
│        Bounded Navigation         │
│ (min: 7.5, max: 13.5 zoom level) │
└──────────────────────────────────┘
```

---

## Camera Animation Sequence

```
┌─ Time 0ms: Initial Camera State
│  { center: [80.7718, 7.8731], zoom: 9.5 }
│
├─ Time 100ms: Animation Starts
│  Start easeTo(districtCamera, 700ms)
│
├─ Time 350ms: Halfway Through
│  Smooth interpolation to target
│  (CurveInterpolator used by Mapbox)
│
├─ Time 700ms: Animation Complete
│  { center: [80.7598, 7.9570], zoom: 10.8 }
│  District centered & zoomed
│
└─ Time 701ms+: User Can Interact
   Tap gestures respond
   Bounds locked
```

---

## Error Handling Scenarios

### Scenario 1: GeoJSON Not Found

```
_loadDistrictGeoJson():
  try:
    loadString('assets/geojson/boundaries/LK-districts.geojson')
  catch:
    _selectedDistrictGeoJson = null
    _outsideMaskGeoJson = null
    Result: No spotlight, just markers

Fallback: Map still works with markers and center-point camera
```

### Scenario 2: District Feature Not Found

```
_findDistrictFeature(geoJson):
  Loop through features
  Check: normalized(feature.properties.NAME_1) == normalized(assignment.district)
  
  if not found:
    Try fuzzy match (contains check)
  
  if still not found:
    Return null
  
  Result: Spotlight not applied, but markers still visible
```

### Scenario 3: Multiple Markers Overlap

```
User taps map near multiple markers
  │
  └─ Calculate distance to each:
     - Marker A: 85 meters
     - Marker B: 142 meters
     - Marker C: 320 meters
  
  Filter: distance <= 160 meters
  Result: [Marker A, Marker B]
  
  Display BottomSheet:
    [ ] Marker A Name
    [ ] Marker B Name
  
  User Selects: Marker A
  Detail card appears
```

---

## Performance Metrics

### Typical Operation Costs

| Operation | Time | Memory |
|-----------|------|--------|
| Load GeoJSON (cached) | 0ms (in-memory) | 500 KB |
| Render street map layer | 50-100ms | 2-5 MB |
| Add GeoJSON layer | 20-40ms | 100 KB |
| Create markers (50 locations) | 150-300ms | 500 KB |
| Tap detection | <10ms | Negligible |
| Camera animation (700ms) | 700ms | Negligible |
| Hot reload district | 200-400ms | Previous + new |

### Memory Footprint

```
Base State:
  - Riverpod provider cache: 200 KB
  - GeoJSON cache: 500 KB
  - Widget tree: 50 KB

Per District Instance:
  - Mapbox GL renderer: 3-5 MB
  - Layer cache: 200 KB
  - Marker annotations: 50 KB per 10 markers
  
Total (worst case):
  - 50+ markers in district: ~6 MB
  - Multiple districts cached: +3-5 MB each
```

---

## Testing Checklist

- [ ] District selection highlights correct boundary
- [ ] Tapping same district twice exits focus
- [ ] Markers appear with correct colors
- [ ] Visited markers are larger (2.0 vs 1.6)
- [ ] Tapping marker shows detail card
- [ ] Multi-marker detection shows bottom sheet
- [ ] Detail card photo loads or shows fallback
- [ ] Verify button works on unvisited locations
- [ ] Verify button disabled on visited locations
- [ ] Camera bounds prevent panning outside
- [ ] Zoom constraints enforced (7.5-13.5)
- [ ] Camera animation smooth (700ms)
- [ ] Error messages appear on network errors
- [ ] GeoJSON loads from correct asset path
- [ ] Marker assets load correctly

