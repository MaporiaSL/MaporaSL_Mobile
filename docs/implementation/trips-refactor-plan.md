# Trip Feature Refactoring Plan (v2.0)

**Date:** January 26, 2026  
**Status:** 📋 APPROVED FOR DEVELOPMENT  
**Priority:** High  
**Dependencies:** Phase 2 (Backend), Phase 3 (Map)

---

## 🎯 Objective

Refactor the trips feature into a unified **Adventures Hub** with a single Trips tab that cleanly separates **Discover** (pre-planned system quests) from **My Journeys** (user trips) via an in-page toggle, not additional bottom-nav tabs.

Core concept:
- **Discover:** “I want to find a quest.”
- **My Journeys:** “I want to track my active quests.”

---

## 📊 Current State

### Existing Pages
- **TripsPage** - Mixed planning and viewing functionality
  - Location: `mobile/lib/features/trips/presentation/trips_page.dart`
  - Issues: Confusing UX, tries to do both planning and tracking
  
- **MemoryLanePage** - Timeline view of trips by status
  - Location: `mobile/lib/features/trips/presentation/memory_lane_page.dart`
  - Issues: Limited to viewing, cannot create trips

### Navigation Strategy
- Keep a **single Trips tab** in bottom nav.
- Inside Trips, use a top-level segmented control/tab bar: **My Journeys** | **Discover**.
- Avoid adding new bottom-nav entries.

---

## 🎨 Architecture & UX

### UI Layout (Single Trips Tab)
```
┌─────────────────────────────────────┐
│  Adventures               [Search]  │ AppBar
├─────────────────────────────────────┤
│   [  DISCOVER  ]  [  MY JOURNEYS  ] │ ← Segmented Control / TabBar (Discover default)
├─────────────────────────────────────┤
│                                     │
│  (If "My Journeys" Selected):       │
│  ┌─────────────────────────────┐    │
│  │ 🚀 Active Quest              │    │
│  │ 🌿 Wild Yala Expedition      │    │
│  │ 4/10 Objectives • 2 Days left│    │
│  │ [Continue Journey ->]        │    │
│  └─────────────────────────────┘    │
│                                     │
│  (If "Discover" Selected):          │
│  ┌─────────────────────────────┐    │
│  │ 🏷️ Filter: [Duration] [Type] │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 🏰 Ancient Cities Tour       │    │
│  │ 500 XP • 3 Days • Medium     │    │
│  │ [Preview Route] [Accept]     │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

### My Journeys (Status)
- Organize trips by status: Active (top), Planned, Completed.
- Actions: tap → detail, long-press → Edit | Share | Delete | Mark Complete.
- Pull-to-refresh, search, filter by status.
- FAB: “Plan New Trip” → switches to Discover tab.

### Discover (Pre-Planned Quests)
- System-curated trips only; users cannot create templates.
- Filters: Duration, Type, Starting Point (Colombo/Kandy/Galle/Jaffna/Trinco), Difficulty, XP.
- Cards show image, title, XP, days, difficulty.
- Preview modal: map preview (static/interactive), places list, CTA “Start Adventure”.
- “Start Adventure” → date picker → clone endpoint → creates Travel + Destinations.

---

### Page 2: Trip Status Page ("My Journeys")

**Purpose:** Manage and track personal trips

**Features:**
- View all trips organized by status (Active, Planned, Completed)
- Edit trip details
- Delete trips
- Mark trips as complete
- View trip progress and completion rate
- **Cannot create new trips** - redirects to Planning page

**Actions Available:**
- Tap trip → View TripDetailPage
- Long-press → Edit | Share | Delete | Mark Complete
- Pull-to-refresh → Reload from backend
- Filter by status
- Search trips

**UI Layout:**
```
┌─────────────────────────────────────┐
│  My Journeys              [Search]  │
├─────────────────────────────────────┤
│  🚀 Active Quests (2)               │
│  ┌─────────────────────────────┐   │
│  │ Cultural Triangle            │   │
│  │ 3 days left • 40% complete   │   │
│  └─────────────────────────────┘   │
│                                     │
│  📅 Planned Adventures (3)          │
│  ┌─────────────────────────────┐   │
│  │ Southern Coast Paradise      │   │
│  │ Starts in 14 days            │   │
│  └─────────────────────────────┘   │
│                                     │
│  ✅ Completed Journeys (5)          │
│  ...                                │
│                                     │
│  [+ Plan New Trip] ← FAB redirects  │
└─────────────────────────────────────┘
```

---

## 🗂️ Data Models

### PrePlannedTrip (Template)
```javascript
// MongoDB: preplanned_trips
{
  _id: ObjectId,
  title: String,
  description: String,
  durationDays: Number,
  xpReward: Number,          // gamification hook
  difficulty: String,        // Easy, Moderate, Hard
  places: [{ type: ObjectId, ref: 'Place' }], // real Place refs for map preview
  imageUrl: String,
  tags: [String],            // ["History", "Nature"]
  createdAt: Date
}
```

### TripModel (Instance)
```javascript
// MongoDB: travels (enhanced)
{
  // existing Phase 2 fields ...
  userId: ObjectId,
  title: String,
  startDate: Date,
  endDate: Date,
  status: { type: String, enum: ['planned', 'active', 'completed'], default: 'planned' },
  isCloned: { type: Boolean, default: false },
  originalTemplateId: { type: ObjectId, ref: 'PrePlannedTrip' },
  completionPercentage: Number // cached for UI performance
}
```

---

## 🔌 Backend Changes

### Backend Endpoints

1) **GET /api/preplanned-trips**
  - Filters: durationDays, type, startingPoint, difficulty, tags.

2) **POST /api/preplanned/:id/clone** (Deep copy)
  - Input: startDate, endDate (required).
  - Logic: create Travel, then create Destinations from Place refs with visited=false.

3) **PATCH /api/travel/:id/complete**
  - Marks a trip completed; recalculates completionPercentage.

### Database Schema

#### preplanned_trips Collection (MongoDB)
```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  durationDays: Number,
  startingPoint: String,
  destinations: [String],
  tripType: String,
  budgetLevel: String,
  estimatedCost: Number,
  imageUrl: String,
  highlights: [String],
  createdAt: Date,
  isActive: Boolean
}
```

#### travels Collection (Enhanced)
```javascript
{
  // Existing fields...
  startingPoint: String,
  tripType: String,
  budgetLevel: String,
  estimatedCost: Number,
  isCustom: Boolean,
  prePlannedTripId: ObjectId,
  travelMode: String,
  status: String // calculated based on dates
}
```

---

## 📱 UI/UX Flow

### User Journey: Discover → Clone → Track

1) User taps **Trips** tab → lands on **AdventuresHubScreen** with toggle (My Journeys | Discover).
2) User selects **Discover**, filters by duration/type, opens template preview, sees map + places, picks dates, taps **Start Adventure** → POST clone → creates Travel + Destinations.
3) Auto-switch (or snackbar) prompts user to view in **My Journeys**; trip appears under Planned. Active trips surface at top.

### User Journey: Managing Trips

1. **User taps "Status" tab**
   → Opens TripStatusPage

2. **User sees trip organized by status**
   - Active Quests (currently ongoing)
   - Planned Adventures (future trips)
   - Completed Journeys (past trips)

3. **User actions:**
   - **Tap trip** → Navigate to TripDetailPage
   - **Long-press** → Bottom sheet: Edit | Share | Delete | Mark Complete
   - **Mark complete** → Confirmation dialog → Status updated, moves to "Completed"
   - **Edit** → Opens edit form with pre-filled data
   - **Delete** → Confirmation → Removed from backend

---

## 📋 Implementation Checklist

### Phase 1: Data Layer
- [x] Create `PrePlannedTripModel` (template) with Place refs and JSON serialization
- [x] Enhance `TripModel` with status, isCloned, originalTemplateId, completionPercentage
- [x] Create `PrePlannedTripsApi` client (GET list, GET detail, POST clone)
- [x] Add `PrePlannedTripsRepository` wrapper for templates and cloning
- [x] Wire My Journeys state to ingest cloned templates (startAdventureProvider + addTrip)

### Phase 2: Backend
- [ ] Add `preplanned_trips` collection and schema (with Place refs)
- [ ] Implement GET `/api/preplanned-trips` (filters)
- [ ] Implement POST `/api/preplanned/:id/clone` (deep copy to Travel + Destinations)
- [ ] Implement PATCH `/api/travel/:id/complete`
- [ ] Migration: set `status: 'planned'` on existing travels
- [ ] Seed 5+ pre-planned trips referencing real Places

### Phase 3: Adventures Hub (Single Screen)
- [x] Rename `TripsPage` → `AdventuresHubScreen` (legacy wrapper kept for routing)
- [x] Add segmented control/tab bar: **My Journeys** | **Discover**
- [ ] My Journeys tab:
  - [x] Group by Active / Planned / Completed
  - [ ] Actions: edit, delete, mark complete, share
  - [x] FAB routes to Discover
- [ ] Discover tab:
  - [x] Filter chips (Duration, Type, Starting Point, Difficulty)
  - [x] TemplateTripCard list with preview CTA
  - [x] Preview modal with places list
  - [x] “Start Adventure” → date picker → clone API

### Phase 4: Trip Detail & Map (after Phase 3)
- [ ] Show template origin badge if cloned
- [ ] Display destinations (from cloned Places) with completion toggle
- [ ] Map preview with markers (Phase 3 map dependency)
- [ ] Add “Mark Complete” CTA

### Phase 5: Content & Seeds
- [ ] Create 5 curated templates using existing Places
- [ ] Ensure coverage: Cultural, Beach, Wildlife, Hill Country, City
- [ ] Add XP and difficulty per template
- [ ] Expand curated set later (Phase 5+) to 10–15 templates

### Phase 6: Testing
- [ ] Unit tests for models
- [ ] Integration tests for pre-planned trips API (list + clone)
- [ ] Widget tests: AdventuresHubScreen tabs
- [ ] E2E: Discover → Preview → Start Adventure → appears in My Journeys

---

## 🎨 Naming Conventions

### Page Names
| Old Name | New Name | Nav Label |
|----------|----------|-----------|
| TripsPage | AdventuresHubScreen | "Trips" (single tab) |
| MemoryLanePage | (merge into My Journeys tab) | - |
| TripDetailPage | (unchanged) | - |

### File Locations
```
mobile/lib/features/trips/presentation/
  ├── adventures_hub_screen.dart (renamed from trips_page.dart)
  ├── trip_detail_page.dart
  └── widgets/
      ├── template_trip_card.dart (new)
      ├── trip_filters.dart (new)
      ├── adventures_tab_bar.dart (new)
      ├── adventure_trip_card.dart
      └── ...
```

---

## 🚀 Migration Strategy

### User Impact
- Existing trips remain unchanged
- New fields (`startingPoint`, `tripType`, etc.) are optional
- Users can edit old trips to add metadata
- No data loss

### Rollout Plan
1) Backend first: endpoints + seeding templates.
2) Frontend: release AdventuresHub with toggle; no nav changes needed.
3) User education: in-app hint describing Discover vs My Journeys.
4) Monitor: track discover → clone conversion and completion rate.

---

## 📊 Success Metrics

- **Adoption:** % of users who try pre-planned trips vs custom
- **Customization rate:** % of pre-planned trips that are customized
- **Completion rate:** % of planned trips marked as complete
- **Time to plan:** Average time to create a trip (pre-planned vs custom)
- **Trip diversity:** Distribution of trip types, starting points

---

## 🔮 Future Enhancements

### Phase 9+ (Post-Launch)
- [ ] AI-powered trip recommendations based on user preferences
- [ ] Community-shared trips (users can publish their custom trips)
- [ ] Trip collaboration (invite friends to co-plan)
- [ ] Expense tracking per trip
- [ ] Photo albums linked to trips
- [ ] Trip reviews and ratings
- [ ] Seasonal/event-based trip suggestions
- [ ] Integration with booking services
- [ ] Offline trip access

---

## 📝 Notes

### Design Considerations
- Keep pre-planned trips updated seasonally
- Ensure filters are performant with 100+ trips
- Cache pre-planned trips client-side for offline browsing
- Use optimistic updates when marking trips complete
- Show loading skeletons during trip creation

### Technical Debt
- Remove old `_navigateToCreateTrip()` placeholders
- Clean up unused imports after renaming
- Update documentation screenshots
- Add JSDoc comments to new API endpoints

---

## 👥 Stakeholders

- **Product Owner:** Define curated trip content
- **Backend Team:** Implement pre-planned trips API, seed data
- **Frontend Team:** Build TripPlanningPage tabs, refactor navigation
- **Design Team:** Create trip card designs, filter UI, illustrations
- **QA Team:** Test all user flows, edge cases

---

**End of Refactoring Plan**  
Next: Implementation Phase 1 - Data Layer
