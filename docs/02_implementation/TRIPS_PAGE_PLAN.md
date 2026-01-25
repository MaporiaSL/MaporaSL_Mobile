Trips Page Implementation Plan

Feature: Trips Management Page (Frontend)

Status: 📋 ALIGNED & APPROVED

Created: January 25, 2026

Target Duration: 8-12 hours

Platform: Flutter (iOS/Android)

Table of Contents

Overview

Design Mockup (Gamified)

Architecture

Step-by-Step Implementation

Dependencies

Testing Strategy

Success Criteria

Overview

The Trips page is the Quest Log of MAPORIA. It serves as the player's inventory of adventures. Unlike a standard calendar app, this page emphasizes Exploration Progress and Collection.

Key Features

Adventure Cards: Visual cards showing trip name, dates, and "Exploration %".

Smart Filters: Search by name, filter by status (Upcoming/Active/Completed).

Quick Actions: Long-press to Share (Portfolio export) or Delete.

Player Stats: Summary of total "World Coverage" at the top.

Empty State: "Start Your Journey" onboarding.

Pull to Refresh: Sync with backend.

User Experience Flow

First Visit → Empty state with "Start New Adventure" CTA.

Has Trips → List of Adventure Cards.

Tap Card → Navigate to Map Mode (Phase 4).

FAB → Open "New Adventure" form.

Design Mockup (Gamified)

Layout Structure

┌─────────────────────────────────────┐
│  My Adventures            [Search]  │ AppBar
├─────────────────────────────────────┤
│  🏆 Explorer Stats                  │
│  • 12 Trips Logged                  │
│  • 45 Places Discovered             │
│  • Level 5 Traveler                 │
├─────────────────────────────────────┤
│  [All] [Active] [Completed]         │ Filter Chips
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │ 🏔️ Kandy Expedition          │  │ Trip Card
│  │ Dec 1 - Dec 15, 2025          │  │
│  │ 12 Objectives • 8 Cleared     │  │
│  │ [Exploration Bar 67%]         │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│              [+] FAB                │ Create Trip
└─────────────────────────────────────┘


Visual Style

Active Trips: Highlighted with an Amber border (Quest Active).

Progress Bar: Not just a line, but segmented blocks or a thick colored bar.

Typography: Clean, bold headings.

Architecture

Folder Structure

(Unchanged from original - Standard Clean Architecture)

mobile/lib/features/trips/
├── data/
│   ├── models/
├── domain/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/
