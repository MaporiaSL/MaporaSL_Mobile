# MAPORIA – Gemified Travel Portfolio Mobile App

> **Source of Truth & Technical Documentation (v1.0)**

This document acts as the **single source of truth** for the MAPORIA mobile application. It is written so that **any developer, designer, examiner, or stakeholder** can fully understand:

* What the app is
* What problems it solves
* What features it contains
* How those features are implemented
* What technologies are used
* How data flows through the system

---

## 📁 Documentation Structure (Logical Files)

This single document represents multiple `.md` files merged for clarity:

1. `01_project_overview.md`
2. `02_core_concepts_gamification.md`
3. `03_feature_breakdown.md`
4. `04_technical_stack.md`
5. `05_system_architecture.md`
6. `06_data_models_and_db_design.md`
7. `07_map_and_gps_logic.md`
8. `08_trip_planning_system.md`
9. `09_social_sharing_and_media.md`
10. `10_admin_and_moderation.md`
11. `11_security_and_privacy.md`
12. `12_implementation_roadmap.md`

---

# 01. Project Overview

## Project Name

**MAPORIA** – A Gemified Travel Portfolio of Sri Lanka

## Project Type

Mobile-first travel portfolio & exploration game

## Target Platform

* Android (Primary)
* iOS (Secondary)

## Core Idea

MAPORIA transforms real-world travel across Sri Lanka into a **game-like experience** where users:

* Unlock districts and provinces
* Earn achievements
* Build a visual travel portfolio
* Share branded progress on social media

The app encourages **physical travel**, **exploration**, and **cultural discovery** rather than virtual check-ins.

---

# 02. Core Concepts & Gamification

## Gamification Model

### World Structure

* **Country** → Sri Lanka
* **Provinces** → 9
* **Districts** → 25
* **Places** → Multiple per district

### Fog / Cloud Mechanism

* All districts start **covered by clouds**
* Clouds clear progressively as places are visited

| Progress | Cloud Visibility |
| -------- | ---------------- |
| 0%       | 100% clouds      |
| 25%      | 75% clouds       |
| 50%      | 50% clouds       |
| 75%      | 25% clouds       |
| 100%     | Fully revealed   |

### Unlock Logic

* Visiting all places in a district → **District unlocked**
* Unlocking all districts in a province → **Province unlocked**

---

# 03. Feature Breakdown

---

## Places System (Core Foundation)

**Status**: 📋 Planning Phase – Ready for implementation  
**Criticality**: 🔴 CRITICAL – Central to all trip planning

This is not a dedicated UI page, but a **foundational data system** that every user encounters when planning trips.

### Why Places Matter

- **Every trip creation** starts by selecting places from this list
- **Discover mode** allows exploration by category/location
- **Community contributions** keep list growing and fresh
- **Admin curation** ensures quality and legitimacy

### Feature Highlight: Gamified Contributions

Users who suggest new places earn:
- 🏅 Badges: Explorer (1), Local Guide (5), Curator (10), Legend (20+)
- 📊 Public profile stats: "Places Contributed"
- 👥 Leaderboard position
- 🎖️ Special recognition on contributed place cards

### Documentation References

- **Feature Spec**: [PLACES_FEATURE_SPEC.md](../06_implementation/PLACES_FEATURE_SPEC.md)
- **Implementation Plan**: [PLACES_IMPLEMENTATION_PLAN.md](../06_implementation/PLACES_IMPLEMENTATION_PLAN.md)
- **Seed Data**: [places_seed_data.json](../../project_resorces/places_seed_data.json) (42 curated places)

---

## Authentication Flow

* App Launch

  * If not logged in → Login / Register screen
  * If logged in → Home Map Screen

Authentication supports:

* Email + Password
* OAuth (Google – optional)

---

## Home Screen – Interactive Sri Lanka Map

### Map Characteristics

* Powered by **Mapbox**
* Fully custom-styled (not satellite or default map)
* Cartoon / game-themed aesthetic
* Clouds rendered as overlay layers

### Map Interactions

* Tap District → Popup Panel
* Popup contains:

  * District description
  * Achievement-style place timeline
  * Progress indicator

---

## Location Visit Verification

### Logic

1. User opens place from district panel
2. App requests GPS permission
3. GPS coordinates compared with place geotag
4. If within allowed radius → Mark as visited

### Result

* Achievement unlocked
* Clouds partially removed
* Progress saved permanently

---

## Achievements System

* Each place has an achievement badge
* Special achievements:

  * District completion
  * Province completion
  * Country completion

Achievements are:

* Shareable
* Visual (badges, animations)

---

## Trip Planning System

### Integration with Places System

**All trips are built from the Places catalog**. When creating a custom trip:

1. User selects dates and trip theme
2. Searches/filters Places catalog
3. Adds selected places to trip itinerary
4. System calculates route, distance, duration
5. Trip saved with place references

### Two Modes

#### 1. Pre-Planned Trips (System-Curated)

* MAPORIA team creates themed itineraries
* Examples:
  - "Cultural Triangle Heritage Tour" (Sigiriya → Dambulla → Kandy)
  - "South Coast Beach Escape" (Mirissa → Unawatuna → Galle)
  - "Highland Adventure" (Ella → Horton Plains → Nuwara Eliya)

* User adapts:
  - Dates
  - Pace (add/remove days)
  - Notes and preferences

#### 2. Custom Trip Planning

* User selects individual places from catalog
* Reorder places on map
* System suggests optimal route
* Define:
  - Duration
  - Travel order
  - Notes per place

---

## Trips Overview

* Planned trips (editable)
* Completed trips (read-only)

Each trip shows:

* Mini Sri Lanka map
* Route visualization
* Distance
* Duration
* Places visited
* Trip photos

---

## In-App Camera & Photo Album

* Custom camera UI (Instagram-like)
* App-branded overlays
* Photos automatically:

  * Geotagged
  * Saved to album
  * Linked to map location

---

## Place Catalog (Core System Foundation)

**Critical Note**: The Places system is a **foundational feature** that powers trip planning. Every time a user creates or plans a trip, they select destinations from this Places list.

### System Architecture

**Two Data Sources**:

1. **Curated Places** (System-seeded)
   - 50-100 major tourist attractions
   - Manually researched and verified by developers
   - Pre-loaded at app launch
   - Categories: waterfall, mountain, beach, temple, historical, forest, garden, city, etc.

2. **User-Contributed Places** (Community-sourced)
   - Locals and tourists can suggest new places
   - Requires submission form with photos and metadata
   - Admin verification before official listing
   - Gamification rewards for verified contributions

### Each Place Stores

* **Metadata**: Name, description, category, province, district
* **Location**: GPS coordinates (lat/long), address
* **Media**: Photos (2+ required for submissions)
* **Accessibility**: Season, difficulty, duration, entry fee, wheelchair access
* **Ratings**: User ratings and review count
* **Contributor**: Who added it (system vs user + date)
* **Tags**: Search keywords (e.g., #UNESCO, #hiking, #scenic)

### Place Discovery Features

* Search by name, category, province
* Filter by: difficulty, rating, season, accessibility
* Geospatial queries: "Find places near me"
* Trending: Most-added to trips, highest-rated, newly added

---

## Add New Place (User Contribution – Verified Submission)

### User Submission Workflow

1. User taps "Suggest a Place" button
2. Fills form with:
   - Place name
   - Detailed description (min 50 chars)
   - Category (dropdown)
   - Province/District (cascading selectors)
   - Exact location (map pin + coordinates)
   - **At least 2 clear photos**
   - Optional: season, difficulty, entry fee, contact

3. Form validates and uploads photos to cloud storage
4. Submission enters **admin review queue** with status: `pending`

### Admin Verification Process

**Admin Dashboard**:
- Review pending submissions with photo gallery
- Verify against known locations (Google Maps, etc.)
- Check for duplicates
- Validate legitimacy (public access, no restrictions)
- Approve or reject with preset reasons

**After Approval**:
- Place added to official list (status: `verified`)
- Contributor gets achievement badge
- User stat updated: "Places Contributed"
- Notification sent to contributor
- Place shows contributor credit in metadata

**After Rejection**:
- Submission deleted
- Contributor notified with reason
- Can resubmit with corrections

### Security & Verification

* **Spam Prevention**: Rate limit submissions per user
* **Duplicate Detection**: Check name + location match
* **Location Validation**: Coordinates within Sri Lanka bounds
* **Photo Validation**: Manual review for actual location match
* **Content Safety**: Check for restricted areas (national security, private property)

---

## User Profile & Contributions Stats

### Profile Section: "My Contributions"

For users who submit places, their profile displays:

- **Total Places Submitted**: Count of suggestions sent for review
- **Approved Count**: Places successfully verified by admin
- **Approval Rate**: Percentage of submissions approved
- **Badges Earned**: Visual badges for contribution milestones
- **Contributed Places List**: Show all approved places with contributor credit
- **Leaderboard Rank**: Position among all contributors

### Achievement Progression

As users contribute verified places:

| Contributions | Badge | Icon |
|---|---|---|
| 1 approved | Explorer | 🏅 |
| 5 approved | Local Guide | 🎖️ |
| 10 approved | Place Curator | 👑 |
| 20+ approved | Community Legend | 🌟 |

### Impact Metrics

- See how many users have added your contributed places to their trips
- View where people are visiting your suggested locations
- Get notifications when your place is used/reviewed

---

## Social Sharing

Users can share:

* Unlocked districts
* Achievements & badges
* Map snapshots
* Trip summaries
* **Contributed places** (if a curator)

All content includes MAPORIA branding.

---

# 04. Technical Stack

## Frontend

* **Flutter** (Dart)

## Maps

* **Mapbox SDK**

## Backend (Free Tier Friendly)

### Option 1 (Recommended)

* **Supabase**

  * PostgreSQL DB
  * Auth
  * Storage

### Option 2

* **Neon (Postgres)** + Custom API

## Media Storage

* Supabase Storage (S3-compatible)

---

# 05. System Architecture

```
Flutter App
   |
   |-- Auth (Supabase)
   |-- Mapbox SDK
   |-- API Calls
   |
Supabase Backend
   |
   |-- PostgreSQL
   |-- Storage
   |-- Edge Functions
```

---

# 06. Data Models (High Level)

## User

* id
* name
* email
* avatar

## Place

* id
* name
* district_id
* description
* lat
* lng
* created_by

## Visit

* user_id
* place_id
* timestamp

## Trip

* id
* user_id
* status (planned/completed)

---

# 07. Map & GPS Logic

* GPS radius validation
* Offline-safe visit caching
* Anti-spoofing tolerance

---

# 08. Trip Visualization

* Route drawing using Mapbox Directions API
* Distance calculation
* Stats overlay

---

# 09. Social & Media Integration

* Image export with branding
* Share intents (Android / iOS)

---

# 10. Admin & Moderation

### Place Submission Review (New)

**Dedicated Admin Dashboard**:
- List pending place submissions with status badges
- Photo gallery viewer with contributor info
- Verification checklist:
  - ✅ Place exists (cross-reference Google Maps)
  - ✅ Coordinates accurate
  - ✅ No duplicate
  - ✅ Public/legitimate location
  - ✅ Photos match location
  - ✅ Legal/safe to visit

**Actions**:
- Approve → Place added to catalog, contributor notified + badge earned
- Reject → Submission deleted, contributor notified with reason
- Request Changes → Send feedback to contributor, keep submission pending

### Community Moderation

- Flag inappropriate places
- Report low-quality submissions
- Community upvoting/downvoting
- Contributor reputation tracking

---

# 11. Security & Privacy

* Location used only during visit check
* Photos private by default
* GDPR-friendly deletion
* **Place submission photos**: Stored securely, validated for authenticity

---

# 12. Implementation Roadmap

### Phase 1 – Foundation

* Auth
* Map UI
* DB setup
* **Places API + seed data import** (50-100 curated locations)

### Phase 2 – Core Gameplay

* Visit logic
* Achievements
* Cloud system
* **Place discovery UI** (search, filter, detail view, integration with trip creation)

### Phase 3 – Trips & Media

* Trip planner (integrated with Places system)
* Camera
* Album
* **User place submission form** with photo upload

### Phase 4 – Admin & Moderation

* Admin dashboard (web)
* **Place submission review workflow** (approve/reject/changes)
* Contributor stats & badges
* Leaderboard

### Phase 5 – Social & Polish

* Sharing
* Animations
* Performance
* **Gamification UI** (badges, profile contributions section)

---

**End of Documentation**
