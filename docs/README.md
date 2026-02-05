# MAPORIA Documentation Hub

> **Last Updated**: February 1, 2026  
> **Project**: Gemified Travel Portfolio  
> **Status**: Complete restructuring into three-tier documentation

---

## 📚 Documentation Overview

Welcome to MAPORIA's comprehensive documentation hub. This documentation is organized into **three tiers** to serve different audiences:

### 🎯 Quick Navigation

| Tier | Purpose | Audience | Start Here |
|------|---------|----------|-----------|
| **Common** | Shared feature specs, architecture, setup | Everyone | [Go to Common →](common/README.md) |
| **Backend** | Implementation details, API, database | Backend Developers | [Go to Backend →](backend/README.md) |
| **Frontend** | UI implementation, state management | Flutter Developers | [Go to Frontend →](frontend/README.md) |

---

## 🚀 Quick Start by Role

### 👨‍💼 Project Managers / Product Owners
1. Read [MAPORIA Overview](common/README.md) to understand features
2. Check [Database Schema](common/architecture/database-schema.md) to see data structure
3. Review [Feature Specs](common/features/) to understand what's built

### 👨‍💻 Backend Developers
1. Start with [Backend Getting Started](backend/getting-started/README.md)
2. Review [Backend Project Structure](backend/getting-started/project-structure.md)
3. Choose a feature from [Feature Implementation Guides](backend/feature-implementation/)
4. Reference [API Endpoints](backend/api-endpoints/) documentation
5. Check [Database Documentation](backend/database/)

### 📱 Flutter/Frontend Developers
1. Start with [Frontend Getting Started](frontend/getting-started/README.md)
2. Review [Frontend Project Structure](frontend/getting-started/project-structure.md)
3. Choose a feature from [Feature Implementation Guides](frontend/feature-implementation/)
4. Check [State Management Patterns](frontend/state-management/riverpod-patterns.md)
5. Reference [API Integration Guide](frontend/api-integration/dio-client-setup.md)

### 🔧 DevOps / Infrastructure
1. Backend [Deployment Guide](backend/deployment/README.md)
2. Frontend [Deployment Guide](frontend/deployment/README.md)

---

## 📁 Three-Tier Documentation Structure

### 📌 Common Documentation
**Location**: [docs/common/](common/)  
**Contains**: Feature specifications, database schema, architecture, setup guides  
**Updated By**: Entire team

```
common/
├── README.md                          # Overview & quick links
├── features/                          # What users can do
│   ├── authentication.md
│   ├── places-attractions.md
│   ├── trip-planning.md
│   ├── album-photos.md
│   ├── shop-ecommerce.md
│   └── achievements-gamification.md
├── architecture/                      # How systems connect
│   ├── system-overview.md
│   ├── database-schema.md
│   └── api-design-principles.md
└── setup-guides/                      # Environment setup
    ├── local-development.md
   ├── firebase-auth-setup.md
    └── environment-variables.md
```

### 🔧 Backend Documentation
**Location**: [docs/backend/](backend/)  
**Contains**: Implementation details, API docs, database models, where to make changes  
**Audience**: Backend developers  
**Updated By**: Backend team

```
backend/
├── README.md                          # Backend overview
├── getting-started/                   # For new backend devs
│   ├── README.md
│   ├── quick-setup.md
│   └── project-structure.md
├── feature-implementation/            # WHERE TO MAKE CHANGES
│   ├── authentication.md              # Controllers, routes, models
│   ├── places-attractions.md
│   ├── trip-planning.md
│   ├── album-photos.md
│   ├── shop-ecommerce.md
│   └── achievements-gamification.md
├── api-endpoints/                     # API documentation
│   ├── authentication-endpoints.md
│   ├── places-endpoints.md
│   ├── trips-endpoints.md
│   ├── user-endpoints.md
│   └── map-geospatial-endpoints.md
├── database/                          # Database & models
│   ├── models.md
│   ├── relationships.md
│   └── indexes-optimization.md
├── middleware-validation/             # Auth, validation, error handling
│   ├── jwt-authentication.md
│   ├── input-validators.md
│   └── error-handling.md
├── utilities-helpers/                 # Shared functions
│   ├── geospatial-functions.md
│   └── data-transformers.md
├── testing/                           # Testing strategies
│   ├── test-setup.md
│   ├── controller-tests.md
│   └── integration-tests.md
└── deployment/                        # Production & deployment
    ├── README.md
    ├── environment-config.md
    ├── database-migration.md
    └── production-checklist.md
```

### 📱 Frontend Documentation
**Location**: [docs/frontend/](frontend/)  
**Contains**: UI implementation, screens, state management, where to make changes  
**Audience**: Flutter developers  
**Updated By**: Frontend team

```
frontend/
├── README.md                          # Frontend overview
├── getting-started/                   # For new Flutter devs
│   ├── README.md
│   ├── quick-setup.md
│   └── project-structure.md
├── feature-implementation/            # WHERE TO MAKE CHANGES
│   ├── authentication.md              # Screens, providers, logic
│   ├── places-attractions.md
│   ├── trip-planning.md
│   ├── album-photos.md
│   ├── shop-ecommerce.md
│   ├── achievements-gamification.md
│   └── map-visualization.md
├── state-management/                  # Riverpod patterns
│   ├── riverpod-overview.md
│   ├── riverpod-patterns.md
│   └── async-data-handling.md
├── ui-components/                     # Design & widgets
│   ├── design-system.md
│   ├── custom-widgets.md
│   └── screen-layouts.md
├── api-integration/                   # Calling APIs
│   ├── dio-client-setup.md
│   ├── api-calling-patterns.md
│   └── error-handling.md
├── location-maps/                     # Maps & GPS
│   ├── mapbox-integration.md
│   ├── gps-location-handling.md
│   └── offline-maps.md
├── offline-first/                     # Caching & sync
│   ├── local-caching.md
│   ├── sync-strategy.md
│   └── offline-functionality.md
├── testing/                           # Testing strategies
│   ├── widget-tests.md
│   ├── integration-tests.md
│   └── test-examples.md
└── deployment/                        # Build & release
    ├── README.md
    ├── android-build.md
    ├── ios-build.md
    ├── web-deployment.md
    └── release-process.md
```

---

## 🔗 Cross-Reference Guide

### When implementing a feature, follow this path:

1. **Read the Feature Spec**
   - Location: `common/features/[feature-name].md`
   - Understand: What users can do, requirements, data involved

2. **Backend Implementation**
   - Read: `backend/feature-implementation/[feature-name].md` 
   - Learn: Which files to modify, what to change, how it fits together

3. **Frontend Implementation**
   - Read: `frontend/feature-implementation/[feature-name].md`
   - Learn: Which screens to modify, what providers to create, UI changes

4. **API Reference** (if needed)
   - Location: `backend/api-endpoints/`
   - Understand: Request/response formats, error codes

---

## 📊 Feature Documentation Index

Each feature has documentation across the three tiers:

### Authentication
- **What**: User login, signup, logout, session management
- Common: Feature spec (to be created in common/features/)
- Backend: [API Reference](backend/api-endpoints/api-reference.md) (see auth section)
- Frontend: Implementation guide (to be created)

### Places & Attractions
- **What**: Discover places, visit locations, community contributions
- Common: [Feature Spec](common/features/places.md) ✅
- Backend: [API Reference](backend/api-endpoints/api-reference.md) (see destinations section)
- Frontend: Implementation guide (to be created)

### Trip Planning
- **What**: Create custom trips, pre-planned itineraries, route planning
- Common: [Feature Spec](common/features/trip-plan.md) ✅
- Backend: [API Reference](backend/api-endpoints/api-reference.md) (see travel section)
- Frontend: Implementation guide (to be created)

### Album & Photos
- **What**: Photo capture, geotagging, albums, memories
- Common: [Feature Spec](common/features/album.md) ✅
- Backend: [API Reference](backend/api-endpoints/api-reference.md) (see destinations section)
- Frontend: Implementation guide (to be created)

### Shop & E-Commerce
- **What**: In-app shop, product catalog, purchases, orders
- Common: [Feature Spec](common/features/shop.md) ✅
- Backend: [Implementation Guide](backend/feature-implementation/shop-implementation.md) ✅
- Frontend: Implementation guide (to be created)

### Achievements & Gamification
- **What**: Badges, leaderboards, progress tracking, rewards
- Common: Feature spec (to be created)
- Backend: [API Reference](backend/api-endpoints/api-reference.md) (see user progress section)
- Frontend: Implementation guide (to be created)

### Map & Visualization
- **What**: Interactive map, fog-of-war, district reveal, offline maps
- Common: [Database Schema](common/architecture/database-schema.md) ✅
- Backend: [API Reference](backend/api-endpoints/api-reference.md) (see map & geo sections)
- Frontend: Implementation guide (to be created)

---

## 🛠️ Technology Stack Reference

| Component | Technology | Documentation |
|-----------|-----------|-----------------|
| **Frontend** | Flutter (Dart) | [Frontend Docs](frontend/) |
| **Backend** | Node.js + Express.js | [Backend Docs](backend/) |
| **Database** | MongoDB | [Database Docs](backend/database/) |
| **Authentication** | Firebase Auth + ID tokens | [Auth Docs](backend/middleware-validation/jwt-authentication.md) |
| **File Storage** | Firebase Storage | [Setup Guide](common/setup-guides/) |
| **Maps** | Mapbox | [Maps Integration](frontend/location-maps/mapbox-integration.md) |
| **State Management** | Riverpod | [Riverpod Guide](frontend/state-management/riverpod-patterns.md) |

---

## 📖 How to Use This Documentation

### ✅ Best Practices

1. **Start with your role's "Getting Started"**
   - Backend devs → [Backend Getting Started](backend/getting-started/README.md)
   - Frontend devs → [Frontend Getting Started](frontend/getting-started/README.md)

2. **Use feature guides when implementing**
   - Pick a feature from your tier's feature-implementation folder
   - It will tell you exactly where to make changes

3. **Cross-reference when needed**
   - Links between tiers help you understand the full picture
   - Backend API docs help frontend devs consume APIs correctly

4. **Keep docs updated**
   - If you change code, update the corresponding documentation
   - Backend changes → Update `docs/backend/`
   - Frontend changes → Update `docs/frontend/`

---

## 📞 Documentation Maintenance

### Who Updates What
- **Backend changes**: Backend developer updates `docs/backend/` tier
- **Frontend changes**: Frontend developer updates `docs/frontend/` tier
- **Feature changes**: Both teams update `docs/common/` tier features
- **Architecture changes**: Team lead updates `docs/common/architecture/`

### When to Update
- When adding a new feature → Create docs in all three tiers
- When refactoring → Update affected feature guides
- When fixing bugs → Update if the workaround is unclear
- When finding gaps → Document the missing piece

---

## 🔄 Navigation Shortcuts

### Jump to Common Docs
- [Features](common/features/) - What the app does
- [Architecture](common/architecture/) - How it's built
- [Setup Guides](common/setup-guides/) - Get started

### Jump to Backend Docs
- [Getting Started](backend/getting-started/) - New to backend?
- [Feature Implementation](backend/feature-implementation/) - Making changes?
- [API Endpoints](backend/api-endpoints/) - API details?
- [Database](backend/database/) - Schema & models?

### Jump to Frontend Docs
- [Getting Started](frontend/getting-started/) - New to frontend?
- [Feature Implementation](frontend/feature-implementation/) - Making changes?
- [State Management](frontend/state-management/) - Riverpod?
- [UI Components](frontend/ui-components/) - Building screens?
- ✅ [phase3-backend-completion.md](completion-logs/phase3-backend-completion.md) - Phase 3 backend completion details
- ✅ [phase4-trips-completion.md](completion-logs/phase4-trips-completion.md) - Phase 4 trips completion details

### api/
**Purpose**: API documentation and endpoints

- ✅ [api-reference.md](api/api-reference.md) - Complete REST API reference with examples
  - 3 Auth endpoints (register, me, logout)
  - 5 Travel endpoints (full CRUD)
  - 5 Destination endpoints (nested CRUD)
  - 4 Map endpoints (GeoJSON, boundary, terrain, stats)
  - 2 Geo endpoints (nearby search, bounds search)
  - Request/response examples
  - Error handling documentation
  - cURL test examples

### setup-guides/
**Purpose**: Environment setup and configuration

- ✅ [local-development.md](setup-guides/local-development.md) - Complete local setup from scratch
- ✅ [firebase-auth-setup.md](setup-guides/firebase-auth-setup.md) - Firebase Auth configuration
- 📋 testing-guide.md - Testing workflows (To be created)
- 📋 deployment.md - Production deployment guide (To be created)

### meeting-notes/
**Purpose**: Team meeting notes and decisions

- Weekly progress meetings
- Technical decision records
- Sprint planning
- Retrospectives

### legacy-implementation/
**Purpose**: Archived implementation files (pre-reorganization)

- Archived documentation from consolidation on Jan 29, 2026
- See `_archive/` subfolder for old files

---

## 🚀 Quick Start

### For New Team Members

1. **Start here**: Read [project-source-of-truth.md](core/project-source-of-truth.md) ⭐ ESSENTIAL
2. **Understand the stack**: Read [tech-stack.md](core/tech-stack.md) ⭐ ESSENTIAL
3. **Setup environment**: Follow [local-development.md](setup-guides/local-development.md)
4. **Configure Firebase Auth**: Follow [firebase-auth-setup.md](setup-guides/firebase-auth-setup.md)
5. **API Reference**: Check [api-reference.md](api/api-reference.md)
6. **Features**: Browse [features/](features/) folder for all feature specifications

### For Developers

1. Check [implementation/](implementation/) for current development phase
2. Refer to [database-schema.md](architecture/database-schema.md) for database design
3. Use [api-reference.md](api/api-reference.md) for API integration
4. Browse [features/](features/) for feature specifications and code examples
5. Follow setup guides in [setup-guides/](setup-guides/)
6. Review completion logs in [completion-logs/](completion-logs/)

### For Project Managers

1. Review [core/](core/) for project scope and requirements ⭐ START HERE
2. Check [implementation/](implementation/) for progress tracking
3. Read [meeting-notes/](meeting-notes/) for team updates
4. Check [completion-logs/](completion-logs/) for completed phases

---

## 📋 Documentation Standards

### File Naming Convention

All files use **kebab-case** naming:

```
Examples:
- phase1-auth-implementation.md
- phase2-mapbox-setup.md
- database-schema.md
- api-auth-endpoints.md
- shop-implementation.md
```

### Folder Naming Convention

All folders use **kebab-case** naming without number prefixes:

```
Examples:
- core/ (most important - project foundations)
- implementation/
- features/
- feature-implementation-plans/
- setup-guides/
- completion-logs/
```

### Document Structure

All implementation docs should include:

1. **Overview** - What this document covers
2. **Prerequisites** - What needs to be done first
3. **Step-by-Step Guide** - Detailed instructions
4. **Code Examples** - Working code snippets
5. **Testing** - How to test the implementation
6. **Common Issues** - Troubleshooting guide
7. **Next Steps** - What comes after

### Code Documentation

- All functions must have JSDoc/DartDoc comments
- Complex logic requires inline comments
- API endpoints documented with examples
- Database schemas include field descriptions

---

## 🔄 Current Development Status

### Completed Phases ✅
- Phase 1: Authentication & User Management
- Phase 2: Travel Data Management
- Phase 3: Map Integration (Backend)

### In Progress 🔄
- Phase 3: Map Integration (Frontend)
- Phase 4: Trip Planning
- Shop Feature Implementation

### Planned 📋
- Phase 5: Social Features & Sharing
- Phase 6: Admin Panel & Moderation
- Advanced achievements & daily challenges
- AR features for place discovery

See [implementation/](implementation/) folder for detailed phase plans.

---

## 📝 How to Contribute to Documentation

### Adding New Documentation

1. Determine the appropriate folder (`01_planning/`, `02_implementation/`, etc.)
2. Follow the naming convention
3. Use the provided templates (see `TEMPLATES/` section below)
4. Update this index file

### Updating Existing Documentation

1. Make changes with tracked revisions
2. Update "Last Updated" date
3. Document changes in CHANGELOG.md

### Documentation Review Process

1. All docs must be reviewed by at least one team member
2. Technical docs require tech lead approval
3. API docs must match actual implementation

---

## 📚 Templates

### Implementation Document Template

```markdown
# [Phase X] - [Feature Name] Implementation

> **Phase**: X  
> **Status**: Not Started / In Progress / Complete  
> **Assigned To**: Name  
> **Last Updated**: Date

## Overview
Brief description of what this implements

## Prerequisites
- [ ] Prerequisite 1
- [ ] Prerequisite 2

## Implementation Steps

### Step 1: [Action]
Detailed instructions...

```[language]
// Code example
```

### Step 2: [Action]
...

## Testing
How to verify this works

## Common Issues
- Issue 1: Solution
- Issue 2: Solution

## Next Steps
What to do after completing this
```

### API Documentation Template

```markdown
# [Endpoint Category] API

## [Endpoint Name]

**Method**: GET/POST/PUT/DELETE  
**Path**: `/api/v1/resource`  
**Auth**: Required / Optional

### Request
```json
{
  "field": "value"
}
```

### Response (Success 200)
```json
{
  "success": true,
  "data": {}
}
```

### Response (Error 4xx/5xx)
```json
{
  "success": false,
  "error": "Error message"
}
```

### Examples
...
```

---

## 🔗 External Resources

### Official Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Manual](https://docs.mongodb.com/)
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)
- [Mapbox Documentation](https://docs.mapbox.com/)

### Learning Resources
- [Flutter & Firebase Course](https://fireship.io/courses/flutter-firebase/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [REST API Design](https://restfulapi.net/)

---

## 📧 Contact

- **Project Lead**: [Name]
- **Tech Lead**: [Name]
- **Backend Team**: [Names]
- **Frontend Team**: [Names]

---

## 📅 Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-01-07 | 1.0 | Initial documentation structure created | Team |
| | | | |

---

**Note**: This is a living document. Keep it updated as the project evolves.
