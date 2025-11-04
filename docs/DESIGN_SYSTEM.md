# MAPORIA — Design System

This document is the single source of truth for all branding, visual design, and UI/UX patterns.

## 1. Brand & Voice
- **Name:** MAPORIA
- **Tagline:** your telescope to Sri Lanka
- **Tone & Voice:** Friendly, encouraging, exploratory. We use microcopy to explain privacy and celebrate users with confetti/animated badges on new unlocks.

## 2. Design Vision
MAPORIA’s design embodies **exploration, authenticity, and pride of discovery**. It must feel adventurous yet calm—a mix of *nature, travel, and modern digital clarity.*

> “You’re not checking in — you’re uncovering Sri Lanka.”

---

## 3. Visual Identity

### Color Palette
- **Accent (Primary):** Teal — `#00897B`
- **Accent (Secondary):** Amber — `#FFC107`
- **Theme Palette:** Nature-inspired (greens, earthy browns, ocean blues).
- **Theme Modes:** Light, Dark, and optionally “Travel Mode” (sepia-tinted).

### Typography
- **Primary:** *Poppins* (friendly & clean).
- **Secondary:** *Inter* for body text.

### Logo & Iconography
- **Logo:** (To be added later) — abstract compass or telescope shape.
- **Iconography:** Fluent or Feather icons with soft rounded corners.

---

## 4. Layout & Navigation

### Philosophy
- **Map First:** The exploration map is the core interface.
- **Minimal Navigation:** Bottom bar with 3–5 icons.

### Primary Navigation
Bottom bar with main tabs:
1.  Map (primary)
2.  Logs / Activity
3.  Add (FAB)
4.  Profile / Progress
5.  Settings (option in profile or bottom sheet)

### Screen Designs
-   **Map Screen:** Full-screen map with floating action buttons (current location, quick add). Visited overlay is a subtle pastel fill.
-   **Profile:** Header with XP/level, map mini with coverage, and badges grid.

---

## 5. Components Library

| Component | Description | Implementation |
|---|---|---|
| **Card** | For photos, badges, share previews | `Card()` with elevation & soft corners |
| **Button** | Rounded corners, high-contrast text | Material 3 + custom accent color |
| **Dialog / Sheet** | For new unlocks, progress updates | Use modal bottom sheets |
| **List Items** | Reusable rows for settings, catalog | `ListTile` with icons and text |
| **Share Cards** | 1080×1080 template. Clean text over blurred photo with user name, stats, and date. |

---

## 6. UX Principles
- **Authentic:** No fake progress; reflect real movement.
- **Transparent:** Clearly show how XP and unlocks work.
- **Rewarding:** Micro-animations and sounds on achievements.
- **Privacy-first:** GPS use must feel safe and optional.
- **Exploration-driven:** Always invite the user to see “what’s next.”

## 7. Animations & Micro-interactions
- Small celebratory animation on unlock (0.5–1s).
- Smooth map tile reveal (fade + scale).
- Haptics (vibration) for mobile unlocks.

## 8. Accessibility
- Minimum text contrast: WCAG AA compliant.
- Colorblind-friendly palette.
- Large tap targets and text settings.
- ARIA-like semantic elements for screen readers.