# MAPORIA Development Changelog

> **Purpose**: Track all major changes, decisions, and milestones in the project

---

## [January 7, 2026] - Project Restructure & Documentation Setup

### Added
- **Documentation Structure**
  - Created `docs/01_planning/` - Planning and strategy documents
  - Created `docs/02_implementation/` - Step-by-step implementation guides
  - Created `docs/03_architecture/` - Technical architecture documentation
  - Created `docs/04_api/` - API reference documentation
  - Created `docs/05_setup_guides/` - Environment setup guides
  - Created `docs/06_meeting_notes/` - Team meeting notes and decisions
  - Created `docs/README.md` - Documentation index and navigation

- **Planning Documents**
  - PROJECT_SOURCE_OF_TRUTH.md - Complete feature specification
  - TECH_STACK.md - Technology decisions (Express.js + MongoDB + Auth0)
  - ALTERNATIVE_STACKS.md - Alternative technology options
  - IMPLEMENTATION_STRATEGY.md - Testing and implementation approach

### Changed
- **Project Structure**: Reorganized documentation into logical folders
- **State Management**: Noted that project uses Riverpod instead of initially planned Provider

### Decisions Made
- **Tech Stack Finalized**: Option 1B (Express.js + MongoDB + Auth0 + Firebase)
  - **Rationale**: Professional architecture with separate services, all free tier, easier to explain and learn
  - **Backend**: Node.js + Express.js (TypeScript)
  - **Database**: MongoDB Atlas M0 (free forever)
  - **Auth**: Auth0 (7k MAU free tier)
  - **Storage**: Firebase Storage (5GB free)
  - **Maps**: Mapbox (50k MAU free)
  - **Notifications**: Firebase Cloud Messaging
  - **Hosting**: Vercel/Railway (free tier)

### Security Concerns Identified
- ⚠️ **CRITICAL**: Mapbox API token exposed in `mobile/lib/main.dart` (line 12)
  - **Action Required**: Move to environment variables
  - **Priority**: HIGH

### Current Status
- **Backend**: Empty folder - needs setup
- **Frontend**: Basic Flutter structure exists with some started features
  - Existing features: home, map, profile, settings
  - Using: Riverpod for state management, Google Fonts, Mapbox
- **Documentation**: ✅ Organized and structured

### Next Actions
1. Move sensitive keys to environment variables
2. Setup backend project structure
3. Begin Phase 1: Authentication & User Management
4. Create detailed implementation guides

---

## [January 1, 2026] - Project Inception

### Added
- Initial project setup
- Flutter mobile app skeleton
- Basic folder structure

### Decisions Made
- Project name: MAPORIA (Gemified Travel Portfolio)
- Target platforms: Android (primary), iOS (secondary), Web
- Primary language: Dart (Flutter)

---

## Template for Future Entries

```markdown
## [YYYY-MM-DD] - Title

### Added
- What was added

### Changed
- What was changed

### Removed
- What was removed

### Fixed
- What bugs were fixed

### Security
- Security-related changes

### Decisions Made
- Important technical decisions with rationale

### Breaking Changes
- Any breaking changes

### Next Actions
- What needs to be done next
```

---

## Version History

| Version | Date | Phase | Status |
|---------|------|-------|--------|
| 0.1.0 | 2026-01-01 | Inception | Complete |
| 0.2.0 | 2026-01-07 | Documentation & Planning | Complete |
| 0.3.0 | TBD | Phase 1: Auth Setup | Not Started |

---

**Note**: All team members should update this file when making significant changes or decisions.
