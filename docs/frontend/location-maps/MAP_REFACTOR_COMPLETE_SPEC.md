# MAP PAGE COMPLETE REFACTOR SPECIFICATION

**Version**: 1.0  
**Date**: February 16, 2026  
**Status**: Discovery & Planning  
**Author**: AI Assistant  

---

## 📋 Table of Contents

1. [Map Page Architecture](#map-page-architecture)
2. [Core Functionalities](#core-functionalities)
3. [UI/UX Components](#uiux-components)
4. [Data Flow & Integration](#data-flow--integration)
5. [Premium Minimal Design Principles](#premium-minimal-design-principles)
6. [Interaction Patterns](#interaction-patterns)
7. [State Management](#state-management)
8. [Implementation Roadmap](#implementation-roadmap)

---

## Map Page Architecture

### Current State (Pre-Refactor)
- ✅ Cartoonish local GeoJSON-based map rendering
- ✅ District/province selection with tap detection
- ✅ Exploration assignments (discovery map progression)
- ✅ Material3 theme integration
- ⚠️ Outdated UI (pre-2026 aesthetic)
- ⚠️ Hard-coded color scheme & typography
- ⚠️ Limited feedback & state visualization
- ⚠️ No real-time location verification UI

### Post-Refactor Vision
The map page becomes the **central hub** for user exploration across Sri Lanka:
- Premium minimal aesthetic with clean hierarchy
- Real-time, responsive interaction feedback
- Deep integration with exploration/achievement systems
- Seamless map canvas + bottom sheet interaction
- Modern typography (Fraunces + Inter)
- Cool slate + pearl + electric teal palette

---

## Core Functionalities

### 1. **Interactive Map Rendering** (Primary Canvas)

#### What It Does
- Displays stylized Sri Lanka map with all 9 provinces and 25 districts
- Shows district boundaries, landmarks, and geospatial features
- Renders district visuals based on unlock state (locked/unlocked/visited)

#### User Interactions
- **Tap District** → Updates bottom panel with district details
- **Pinch Zoom** → Scale map (if enabled; consider UX trade-off)
- **Pan/Drag** → Parallax or shift map slightly (optional, premium touch)
- **Double Tap** → Center on province or reset view
- **Long Press** → Show context menu or quick info

#### Visual States per District
| State | Visual Indication | Color/Effect | Interaction |
|-------|-------------------|-------------|-------------|
| **Locked** | Fogged/blurred, lock icon | Desaturated, dim overlay | Tap → Show required locations |
| **In Progress** | Partial reveal, progress ring | Semi-transparent tint | Tap → Show assignments & progress |
| **Unlocked** | Fully revealed, distinct color | Bright, electric teal accent | Tap → Show achievements & stats |
| **Province Complete** | Glow/halo effect | Gold/copper highlight | Tap → Show milestone reward |

#### Technical Implementation
- **Canvas Rendering**: CustomPainter (cartoon_map_painter.dart) with GeoJSON boundaries
- **Hit Detection**: Point-in-polygon algorithm for tap handling
- **Performance**: Offscreen caching, layer batching (if needed)
- **Accessibility**: High contrast mode, tap hints, screen reader support

---

### 2. **Bottom Sheet / Action Panel** (Secondary Surface)

#### What It Shows

When a district is selected, a rich bottom sheet displays:

**Header**
- District name (or province) in large, bold Fraunces display
- Province tag
- Visual breadcrumb (West > District Name)

**Progress Section**
- Visual progress bar: `visited / assigned` locations
- Numeric breakdown: "3 of 5 locations visited"
- Unlock meter: "Visit remaining location(s) to unlock this district"

**Assigned Locations List**
- **Card per location** with:
  - Location name (bold, primary color)
  - Location type/category (icon + text, muted color)
  - Distance from user (if GPS enabled)
  - Verification status: checkmark (visited), clock (assigned), lock (future)
  - Last visited date (if applicable)
- **Swipe-able** for quick dismiss or secondary action
- **Tap to View** → Navigate to place detail or open location in Maps

**Achievement Section** (if district is unlocked)
- Display badge(s) earned for unlocking
- Brief achievement description
- XP reward info
- Share button for social

**Action Buttons**
- **Primary**: "Verify Location" (if GPS nearby) OR "Start Exploration"
- **Secondary**: "Share Progress" or "View Details" (drill-down)
- Dismiss/Collapse: Swipe down or top indicator

#### Interaction Patterns
- **Swipe up** → Expand to full-screen detail
- **Swipe down** → Collapse to peek state
- **Tap location** → Navigate to verification or detail
- **Tap share** → Generate shareable card with MAPORIA branding

---

### 3. **Real-Time Location Verification** (GPS Integration)

#### What It Does
- **Background GPS Monitoring**: Continuously track user location (when permission granted)
- **Proximity Detection**: Detect when user approaches an assigned location
- **Auto-Notification**: Toast or banner when location is close
- **Manual Verification**: "Verify Now" button to mark location as visited
- **Anti-Cheat**: Log verification attempt (timestamp, accuracy, device)

#### Verification Flow
```
User approaches location
  ↓
Map detects proximity (50-100m radius, configurable)
  ↓
[Option A] Auto-trigger verification UI
  ↓
[Option B] User taps "Verify Location" button
  ↓
Location verified (GPS coords within tolerance)
  ↓
✅ Location marked visited
  ↓
Animate location card (checkmark, green highlight)
  ↓
Show mini-celebration (toast, haptic, sound)
  ↓
Update progress bar
  ↓
Check if district unlocked
  ↓
[If unlocked] Show unlock modal + share prompt
```

#### UI Components
- **Proximity Badge**: Small floating badge showing distance to nearest location
- **Verification Modal**: Dialog confirming location + asking for optional photo
- **Unlock Toast**: Animated toast when district/province unlocked
- **Share Prompt**: Modal offering to share unlock on social

---

### 4. **District/Province Information & Stats** (Details Modal)

#### What It Shows

**Full-Screen Modal** (on tap of district name or "View Details"):

- **Header Image**: District photo or representative landmark illustration
- **District Overview**: Name, province, short description, population, area
- **Key Landmarks**: 2-3 thumbnail cards with famous places
- **Visitor Stats**: "123 explorers visited here", "Unlocked on Feb 10, 2026"
- **Achievement History**: Timeline of when user unlocked this district
- **Related Trips**: List pre-planned trips in this district
- **Exploration Assignments**: Detailed breakdown of all assigned locations (maps embed)
- **Leaderboard Widget**: "You're ranked #42 in district exploration"

#### Interaction
- Scroll to reveal all content
- Tap landmark card → Navigate to place detail
- Tap trip → Go to trip screen
- Tap location on mini-map → Auto-scroll location card

---

### 5. **Achievements & Milestones** (In-Context)

#### What It Shows

**On Map Canvas**:
- Small achievement indicator on newly unlocked districts (gold star, glow)
- Toast when province unlocked
- Cumulative stats widget (fixed, upper-left): "Districts: 5/25, XP: 120/200"

**In Bottom Sheet** (if district unlocked):
- Achievement badge icon + name + description
- XP earned: "+50 XP"
- Shareable achievement card preview
- "Earned on Feb 12, 2026" timestamp

#### Milestone Notifications
```
District Unlocked → Modal (confetti, big text, share CTA)
Province Unlocked → Full-screen reward screen with shareability
Landmark Collection → Toast with sticker/badge
```

---

### 6. **Social Sharing Hooks** (Branding + Integration)

#### What Can Be Shared

1. **Unlocked Location**: "I just unlocked 🔓 West Province! Help me explore Sri Lanka in MAPORIA 🗺️"
2. **District Unlock**: "🎉 Achieved 'Western Explorer'! Visited 5 locations in West. #MAPORIA #Travel"
3. **Province Unlock**: "✨ I unlocked Western Province! Only 8/9 to go. Join me in MAPORIA!"
4. **Map Snapshot**: Unlocked areas + user name + timestamp

#### Share Card Design
- MAPORIA logo and branding (color: electric teal)
- User's name and achievement
- Map thumbnail (unlocked districts)
- Call-to-action: "Download MAPORIA & join my journey"
- Social platform icons (Instagram, Twitter, etc.)

#### Integration
- Share button on every unlock modal
- Share button in bottom sheet (sticky)
- Share from profile achievements screen (separate feature)

---

### 7. **Exploration Onboarding & Reroll** (One-Time Flows)

#### Onboarding (First Launch)

**Screen Flow**:
1. **Intro Modal**: "Welcome to Exploration Mode! Your personalized map is ready."
2. **Hometown Selection**: Dropdown to select hometown district (pre-selected by geo if available)
3. **Assignment Summary**: Visual list of all assigned locations (drill-down scrollable)
   - Shows count per district (e.g., "West: 5 locations")
   - Option to expand and see map pins
4. **Start CTA**: "Begin Exploration" button to dismiss and navigate to map

#### Reroll (One-Time, <35% Exploration)

**Reroll Flow** (accessible from settings or map info button):
1. **Eligibility Check**: If >35% explored, show disabled state with message
2. **Warning Modal**:
   - Headline: "Reset your exploration assignments?"
   - Body: "This will erase all progress and assign new locations."
   - Confirmation: "I understand, generate new assignments"
3. **Confirmation Code**:
   - Show random 6-char code (e.g., "A7K9X2")
   - User types code to confirm
   - Code expires after 2 minutes
4. **Reroll Reason** (Optional form):
   - Dropdown: "Too easy", "Too hard", "Not interested", "Other"
   - Free-text field if "Other" selected
5. **Success**: Toast + modal showing new assignments

---

### 8. **Status HUD / Persistent UI** (Always Visible)

#### Top-Left Corner (Persistent Widget)
```
Level 5
███████░ 120/200 XP
Districts: 8/25 | Provinces: 1/9
```
- Tap to view full achievements screen
- Gets updated real-time as locations verified

#### Bottom Indicator (When Scrolled)
- Small floating button with district count animation
- "5/25 districts explored" with progress ring

#### Map Legend (Accessible)
- Icon key for district states (locked, unlocked, milestone)
- Color palette explanation
- Tap to toggle visibility

---

## UI/UX Components

### 1. **Map Canvas**
- **Size**: Full screen minus AppBar
- **Background**: Premium minimal background color (#F5F6F4)
- **Borders**: Subtle outline dividers between districts
- **Labels**: Large district names (Fraunces), clear typography hierarchy
- **Overlays**: Milestone badges, glow effects for recently unlocked

### 2. **Bottom Sheet**
- **Peek Height**: 120px (collapsed state)
- **Drag Handle**: White/grey line indicator at top
- **Radius**: 24px (premium minimal)
- **Backdrop**: Slight blur to map (optional, performance consideration)
- **Content Padding**: 16px horizontal, 24px vertical

### 3. **Progress Card**
- **Container**: White (light) / dark surface (dark mode)
- **Border**: 1px #DFE4EA (light) or #2A3441 (dark)
- **Radius**: 14px
- **Elevation**: 0 (premium minimal, no shadows by default)
- **Text**: Inter medium for labels, Fraunces semi-bold for values

### 4. **Location List Item**
- **Container**: Muted background (#F0F2F5 light, #1B2430 dark)
- **Padding**: 12px
- **Radius**: 12px
- **Spacing**: 8px gap between items
- **Icons**: Teal for unlocked, grey for locked, green for visited
- **Typography**: Inter 14px for name, 12px for type

### 5. **Achievement Badge**
- **Shape**: Circle or custom shape
- **Border**: Copper/gold accent
- **Glow**: Subtle shadow + light effect
- **Animation**: Scale up on unlock
- **Tooltip**: Hover/long-press shows description

### 6. **Buttons**
- **Primary**: Electric teal (#00A6B2), white text, 14px radius
- **Secondary**: Outlined, teal border, transparent bg
- **Disabled**: Greyed out, no interaction

### 7. **Modals & Dialogs**
- **Blur Backdrop**: Yes, with 60% opacity
- **Content Area**: 24px padding, white/dark surface
- **Radius**: 20px
- **Animation**: Fade + scale in (200ms)

---

## Data Flow & Integration

### State Providers (Riverpod)

```dart
// Exploration state
final explorationProvider = StateNotifierProvider<ExplorationNotifier, ExplorationState>(
  (ref) => ExplorationNotifier(ref.watch(apiClientProvider)),
);

// Map-specific state
final mapStateProvider = StateNotifierProvider<MapStateNotifier, MapState>(
  (ref) => MapStateNotifier(),
);

// Location verification
final locationVerificationProvider = StateNotifierProvider<LocationVerificationNotifier, LocationVerificationState>(
  (ref) => LocationVerificationNotifier(ref.watch(gpsProvider)),
);

// Achievement notifications
final achievementToastProvider = StateProvider<AchievementEvent?>((ref) => null);
```

### API Endpoints Called

| Endpoint | Method | Purpose | Called When |
|----------|--------|---------|-------------|
| `/api/exploration/assignments` | GET | Load user's district assignments | Map screen loads |
| `/api/exploration/verify-location/:locId` | POST | Mark location as visited | User verifies |
| `/api/exploration/reroll` | POST | Generate new assignments | User opts for reroll |
| `/api/user/achievements` | GET | Fetch unlock history & stats | Bottom sheet opens |
| `/api/leaderboard?category=exploration` | GET | Rank comparison | Optional, on demand |

### Local Caching
- Cache assignments in Riverpod (invalidate on refresh)
- Cache district details in local db (sync on app launch)
- Cache GeoJSON boundaries in device storage (update quarterly)

---

## Premium Minimal Design Principles

### Color Usage
- **Primary (Teal)**: Hero actions, unlocks, progress indicators
- **Pearl**: Surfaces, backgrounds, neutral containers
- **Slate**: Text, borders, secondary information
- **Accent (Copper)**: Achievements, milestones, special states
- **Functional Colors**: Green (success), red (error), yellow (warning)

### Typography
- **Display (Fraunces)**: District names, achievement titles, headers
- **Body (Inter)**: Descriptions, lists, labels, body copy
- **Weight Hierarchy**: w600 (bold), w500 (medium), w400 (regular)

### Spacing & Sizing
- **Base Unit**: 4px (scale: 4, 8, 12, 16, 20, 24, 32)
- **Border Radius**: 12px (list items), 14px (inputs), 20px (modals), 24px (large containers)
- **Shadows**: None by default (flat design); subtle (0.5dp) on interaction

### Motion
- **Transitions**: 200ms easing (ease-out preferred)
- **Animations**: Scale + fade on unlock, slide on appearance, bounce on tap
- **Feedback**: Haptic (short vibration on verify), audio cue (optional)

---

## Interaction Patterns

### 1. **District Selection Flow**
```
MapCanvas
  ├─ User taps district
  ├─ MapNotifier updates selectedDistrict state
  ├─ Bottom sheet animates in (200ms slide)
  ├─ Bottom sheet fetches assignments via API
  ├─ Progress bar animates (1000ms ease)
  └─ Location list appears (staggered 50ms offset)
```

### 2. **Verification Success Flow**
```
LocationCard
  ├─ User taps "Verify Location"
  ├─ Permission check (location/camera)
  ├─ GPS detection runs
  ├─ If accurate:
  │  ├─ Location card highlights (green)
  │  ├─ Checkmark icon scales in
  │  ├─ Progress bar increments (animated)
  │  └─ Success toast appears
  └─ If inaccurate:
     ├─ Error message shown
     ├─ Card shakes (feedback)
     └─ Retry CTA offered
```

### 3. **Unlock Flow**
```
LocationVerified
  ├─ Check if all locations for district verified
  ├─ If yes:
  │  ├─ District state → "unlocked"
  │  ├─ Full-screen modal appears (confetti optional)
  │  ├─ Achievement badge shown
  │  ├─ XP earned display
  │  └─ Share CTA prominently shown
  └─ Map visual updates (glow, color change)
     └─ Splash haptic feedback
```

### 4. **Tablet/Responsive**
- Map takes 60% width, bottom sheet 40% (side-by-side)
- Details modal spans full screen centered
- HUD widgets reposition to avoid gestures

---

## State Management

### MapState (Riverpod)
```dart
class MapState {
  final String? selectedDistrictId;
  final String? selectedProvinceId;
  final bool isBottomSheetExpanded;
  final Map<String, DistrictProgress> districtProgress; // userId -> progress
  final bool isLoadingAssignments;
  final String? error;
  
  // Derived getters
  bool get isDistrictLocked => /* check explorationState */;
  DistrictData? get selectedDistrictData => /* lookup from regions_data */;
  List<ExplorationLocation> get assignedLocations => /* filter by selectedDistrictId */;
}
```

### MapNotifier Actions
- `selectDistrict(districtId)` → Updates state, fetches data
- `collapseBottomSheet()` → Toggles expanded state
- `clearSelection()` → Resets to neutral
- `refreshAssignments()` → Re-fetches API

### Side Effects (via ref.listen)
- Achievement unlock → Show modal
- Location verified → Real-time progress update
- Error → Show snackbar
- Reroll success → Navigate & reset map

---

## Implementation Roadmap

### Phase 1: Foundation (3–4 days)
- [ ] Update app_theme.dart (if not already done)
- [ ] Refactor app_colors.dart with new palette
- [ ] Create map_state_provider.dart + MapStateNotifier
- [ ] Rebuild map_screen.dart layout and structure
- [ ] Connect to explorationProvider

### Phase 2: Enhanced Canvas (2–3 days)
- [ ] Update cartoon_map_painter.dart with premium colors
- [ ] Integrate district state visualization (locked/unlocked/visited)
- [ ] Add animation for selection feedback
- [ ] Optimize performance (caching, layer batching)

### Phase 3: Bottom Sheet & Components (3–4 days)
- [ ] Rebuild _DistrictActionPanel into modern bottom sheet
- [ ] Create LocationListItem widget with new design
- [ ] Build ProgressCard component
- [ ] Create AchievementBadge widget
- [ ] Wire to explorationProvider data

### Phase 4: Verification & GPS (2–3 days)
- [ ] Integrate location_verification_provider.dart
- [ ] Build VerificationModal component
- [ ] Real-time proximity detection UI
- [ ] Toast/notification system for unlocks

### Phase 5: Onboarding & Modals (2–3 days)
- [ ] Create ExplorationOnboardingScreen
- [ ] Build DistrictDetailsModal
- [ ] Build AchievementUnlockModal
- [ ] Build RerollScreen

### Phase 6: Social Sharing & Polish (2–3 days)
- [ ] Create ShareCardWidget
- [ ] Wire to share_feature API
- [ ] Test animations and transitions
- [ ] Accessibility audit
- [ ] Dark mode testing

**Total Estimate**: 14–20 days (depends on parallelization and scope adjustments)

---

## Open Questions & Decisions

1. **Map Zoom Feature**: Enable pinch-zoom or keep fixed view? (Trade-off: UX vs simplicity)
2. **Parallax/3D Tilt**: Use 3D matrix transforms for parallax on drag? (Premium feel vs performance)
3. **Auto-Verification**: Auto-trigger verification modal on proximity, or require user tap?
4. **Landmark Labels**: Show all landmark names on map, or only on selection?
5. **Offline Mode**: Support offline map viewing? (Cache boundaries locally)
6. **Haptic Feedback**: Enabled for all actions or only major milestones?
7. **Achievement Animations**: Confetti on district unlock or subtle celebration?
8. **Tablet Layout**: Side-by-side or full-screen modal?

---

## Success Criteria

- ✅ All 25 districts rendered and tapable
- ✅ Performance: <100ms tap-to-sheet response
- ✅ Bottom sheet smooth scroll with >60fps
- ✅ Location verification works end-to-end (GPS + API)
- ✅ Achievement unlocks trigger notifications & modals
- ✅ Share functionality generates branded cards
- ✅ Dark mode fully supported
- ✅ Accessibility: WCAG AA compliance
- ✅ No Mapbox dependency (GeoJSON-based)
- ✅ Premium minimal design system applied consistently

---

## References

- [Discovery Map Progression](discovery-map-progression.md)
- [Achievements & Gamification](../common/feature-implementation/achievements.md)
- [Sharing Feature](../common/features/sharing.md)
- [Phase 1 Implementation Plan](phase1-implementation-plan.md)
- [App Theme (Updated)](../../mobile/lib/core/theme/app_theme.dart)
- [App Colors (Updated)](../../mobile/lib/core/constants/app_colors.dart)

