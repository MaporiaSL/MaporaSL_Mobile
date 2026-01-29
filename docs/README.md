# MAPORIA - Documentation Index

> **Last Updated**: January 29, 2026  
> **Purpose**: Centralized index for all project documentation

---

## 📁 Documentation Structure

### core/
**Purpose**: Core project documentation - source of truth, architecture decisions, and strategy (MOST IMPORTANT)

- [project-source-of-truth.md](core/project-source-of-truth.md) - Complete feature specification and requirements ⭐
- [tech-stack.md](core/tech-stack.md) - Chosen technology stack (Express.js + MongoDB + Auth0) ⭐
- [alternative-stacks.md](core/alternative-stacks.md) - Other technology options considered
- [implementation-strategy.md](core/implementation-strategy.md) - Testing strategy and implementation approach

### implementation/
**Purpose**: Step-by-step implementation guides for each phase

- ✅ [phase1-detailed-plan.md](implementation/phase1-detailed-plan.md) - Authentication & User Management (COMPLETE)
- ✅ [phase2-detailed-plan.md](implementation/phase2-detailed-plan.md) - Travel Data Management (COMPLETE)
- 🔄 [phase3-detailed-plan.md](implementation/phase3-detailed-plan.md) - Map Integration (Backend COMPLETE, Frontend IN PROGRESS)
- 🔄 [phase4-detailed-plan.md](implementation/phase4-detailed-plan.md) - Trip Planning (IN PROGRESS)
- 📋 [trips-page-plan.md](implementation/trips-page-plan.md) - Trips page implementation
- 📋 [trips-refactor-plan.md](implementation/trips-refactor-plan.md) - Trips feature refactoring

### features/
**Purpose**: Comprehensive feature specifications for all platform features

- 🛍️ [shop.md](features/shop.md) - E-commerce & In-App Shop (hybrid model, 21 endpoints, 7 phases)
- 📍 [places.md](features/places.md) - Tourist attractions system with community contributions and gamification
- 🗺️ [trip-plan.md](features/trip-plan.md) - Custom trips + pre-planned itineraries with timeline and status management
- 📸 [album.md](features/album.md) - Photo capture, organization, geotagging, and map integration

### feature-implementation-plans/
**Purpose**: Detailed implementation plans with code examples for each feature

- 🛍️ [shop-implementation.md](feature-implementation-plans/shop-implementation.md) - Shop implementation (backend models, services, Flutter UI, admin dashboard with full code)

### architecture/
**Purpose**: Technical architecture documentation

- ✅ [database-schema.md](architecture/database-schema.md) - Complete database schema, relationships, indexes

### completion-logs/
**Purpose**: Phase completion summaries and progress tracking

- ✅ [phase1-completion-summary.md](completion-logs/phase1-completion-summary.md) - Phase 1 completion details
- ✅ [phase2-completion-summary.md](completion-logs/phase2-completion-summary.md) - Phase 2 completion details
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
- ✅ [auth0-setup.md](setup-guides/auth0-setup.md) - Auth0 configuration step-by-step
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
4. **Configure Auth0**: Follow [auth0-setup.md](setup-guides/auth0-setup.md)
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
- [Auth0 Docs](https://auth0.com/docs)
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
