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

### Two Modes

#### 1. Pre-Planned Trips

* System-provided curated trips
* User adds:

  * Dates
  * Notes

#### 2. Custom Trip Planning

* Select places manually
* Define:

  * Duration
  * Visit order
  * Travel days

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

---

## In-App Camera & Photo Album

* Custom camera UI (Instagram-like)
* App-branded overlays
* Photos automatically:

  * Geotagged
  * Saved to album
  * Linked to map location

---

## Place Catalog

* Official places
* Community-added places

Each place includes:

* Images
* Description
* Location
* Contributor credits

---

## Add New Place (User Contribution)

* Users submit:

  * Place name
  * Description
  * Images
  * GPS location

* Goes into **admin review queue**

---

## Social Sharing

Users can share:

* Unlocked districts
* Achievements
* Map snapshots
* Trip summaries

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

* Admin dashboard (web)
* Review new places
* Approve / reject submissions

---

# 11. Security & Privacy

* Location used only during visit check
* Photos private by default
* GDPR-friendly deletion

---

# 12. Implementation Roadmap

### Phase 1 – Foundation

* Auth
* Map UI
* DB setup

### Phase 2 – Core Gameplay

* Visit logic
* Achievements
* Cloud system

### Phase 3 – Trips & Media

* Trip planner
* Camera
* Album

### Phase 4 – Social & Polish

* Sharing
* Animations
* Performance

---

**End of Documentation**
