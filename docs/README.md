# MAPORIA - Documentation Index

> **Last Updated**: January 7, 2026  
> **Purpose**: Central index for all project documentation

---

## 📁 Documentation Structure

### 01_planning/
**Purpose**: High-level planning, architecture decisions, and strategy documents

- [PROJECT_SOURCE_OF_TRUTH.md](01_planning/PROJECT_SOURCE_OF_TRUTH.md) - Complete feature specification and requirements
- [TECH_STACK.md](01_planning/TECH_STACK.md) - Chosen technology stack (Express.js + MongoDB + Auth0)
- [ALTERNATIVE_STACKS.md](01_planning/ALTERNATIVE_STACKS.md) - Other technology options considered
- [IMPLEMENTATION_STRATEGY.md](01_planning/IMPLEMENTATION_STRATEGY.md) - Testing strategy and implementation approach

### 02_implementation/
**Purpose**: Step-by-step implementation guides for each feature

- Phase 1: Authentication & User Management
- Phase 2: Map Integration & Place Management
- Phase 3: Visit Tracking & Achievements
- Phase 4: Trip Planning
- Phase 5: Social Features & Sharing
- Phase 6: Admin Panel & Moderation

### 03_architecture/
**Purpose**: Technical architecture documentation

- Database schemas and relationships
- API design patterns
- Security implementation
- Data flow diagrams
- System architecture diagrams

### 04_api/
**Purpose**: API documentation and endpoints

- REST API reference
- Request/Response examples
- Authentication flows
- Error handling
- Rate limiting

### 05_setup_guides/
**Purpose**: Environment setup and configuration

- Local development setup
- Backend setup (Express.js + MongoDB + Auth0)
- Flutter environment setup
- Firebase configuration
- Mapbox configuration
- Deployment guides

### 06_meeting_notes/
**Purpose**: Team meeting notes and decisions

- Weekly progress meetings
- Technical decision records
- Sprint planning
- Retrospectives

---

## 🚀 Quick Start

### For New Team Members

1. **Start here**: Read [PROJECT_SOURCE_OF_TRUTH.md](01_planning/PROJECT_SOURCE_OF_TRUTH.md)
2. **Understand the stack**: Read [TECH_STACK.md](01_planning/TECH_STACK.md)
3. **Setup environment**: Follow guides in `05_setup_guides/`
4. **Implementation**: Check current phase in `02_implementation/`

### For Developers

1. Check `02_implementation/` for current development phase
2. Refer to `03_architecture/` for system design
3. Use `04_api/` for API integration
4. Follow coding standards in `CONTRIBUTING.md`

### For Project Managers

1. Review `01_planning/` for project scope
2. Check `02_implementation/` for progress tracking
3. Read `06_meeting_notes/` for team updates

---

## 📋 Documentation Standards

### File Naming Convention

```
[PHASE]_[FEATURE]_[TYPE].md

Examples:
- PHASE1_AUTH_IMPLEMENTATION.md
- PHASE2_MAPBOX_SETUP.md
- ARCHITECTURE_DATABASE_SCHEMA.md
- API_AUTH_ENDPOINTS.md
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

### Phase 1: Authentication & User Management (CURRENT)
- [ ] Backend setup (Express.js + MongoDB + Auth0)
- [ ] User registration
- [ ] User login
- [ ] Token management
- [ ] Data isolation testing

### Phase 2: Map Integration (PLANNED)
- [ ] Mapbox setup
- [ ] Sri Lanka map rendering
- [ ] Province/district boundaries
- [ ] Place markers

### Phase 3-6: (PLANNED)
See implementation folder for detailed breakdown

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
