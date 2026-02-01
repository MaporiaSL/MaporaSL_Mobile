# MAPORIA - Common Documentation

> **Purpose**: Shared feature specifications, architecture, and setup guides  
> **Audience**: Everyone (Product Owners, Backend, Frontend, QA)  
> **Last Updated**: February 1, 2026

---

## 📚 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Setup Guides](#-setup-guides)
- [Quick Navigation](#-quick-navigation)

---

## 🎯 Features

Common feature specifications define **what users can do** and **how the system works**. These documents are independent of implementation details.

### 📋 Core Features

| Feature | Description | Status | Documentation |
|---------|-------------|--------|-----------------|
| **Authentication** | Login, signup, logout, user accounts | ✅ Complete | [Read](features/authentication.md) |
| **Places & Attractions** | Discover locations, visit tracking, community contributions | ✅ Complete | [Read](features/places-attractions.md) |
| **Trip Planning** | Custom trips, pre-planned itineraries, route planning | ✅ Complete | [Read](features/trip-planning.md) |
| **Album & Photos** | Photo capture, organization, geotagging | ✅ Complete | [Read](features/album-photos.md) |
| **Shop & E-Commerce** | In-app shop, products, purchases, orders | ✅ Complete | [Read](features/shop-ecommerce.md) |
| **Achievements & Gamification** | Badges, leaderboards, progress, rewards | ✅ Complete | [Read](features/achievements-gamification.md) |

### 🎮 What's Included in Each Feature Doc

Each feature specification includes:
- **User Stories**: What users can do
- **Requirements**: Functional & non-functional requirements
- **Data Model**: Key entities and relationships
- **User Flows**: Step-by-step interactions
- **Success Criteria**: How to know it's working
- **Links**: Where to implement (Backend & Frontend)

---

## 🏗️ Architecture

Architecture documentation explains **how components connect** and **why certain choices were made**.

### 📖 Architecture Guides

| Document | Purpose | Read |
|----------|---------|------|
| **System Overview** | How all features fit together, component relationships | [Read](architecture/system-overview.md) |
| **Database Schema** | Complete MongoDB schema, collections, relationships, indexes | [Read](architecture/database-schema.md) |
| **API Design Principles** | REST conventions, naming patterns, versioning strategy | [Read](architecture/api-design-principles.md) |

### 🔑 Key Architecture Decisions

- **Frontend**: Flutter (cross-platform, hot reload, rich UI)
- **Backend**: Node.js + Express.js (JavaScript ecosystem, real-time capable)
- **Database**: MongoDB (flexible schema, geospatial queries for maps)
- **Authentication**: Auth0 + JWT (secure, scalable, industry standard)
- **State Management**: Riverpod (modern, reactive, testable)

See [Tech Stack](core/tech-stack.md) for detailed rationale.

---

## 🛠️ Setup Guides

Setup guides help developers **configure their environment** and **get the project running locally**.

### 📖 Setup Documentation

| Guide | Purpose | For Whom |
|-------|---------|----------|
| **Local Development** | Set up backend + frontend locally | Everyone |
| **Auth0 Setup** | Configure authentication service | Backend devs |
| **Environment Variables** | Required config values and defaults | Backend & Frontend |

### 🚀 Quick Start

**New to the project?**

1. [Local Development Setup](setup-guides/local-development.md) - Get everything running
2. [Auth0 Configuration](setup-guides/auth0-setup.md) - Set up authentication
3. [Environment Variables](setup-guides/environment-variables.md) - Configure your environment

---

## 🔄 Quick Navigation

### For Backend Developers
- **Implementing a feature?** → Read the feature spec in this folder, then go to [Backend Feature Implementation](../backend/feature-implementation/)
- **Need API endpoint details?** → Check [Backend API Endpoints](../backend/api-endpoints/)
- **Working with database?** → Review [Database Schema](architecture/database-schema.md), then [Backend Database Docs](../backend/database/)

### For Frontend Developers  
- **Implementing a feature?** → Read the feature spec in this folder, then go to [Frontend Feature Implementation](../frontend/feature-implementation/)
- **Need to call an API?** → Check [Backend API Endpoints](../backend/api-endpoints/), then [Frontend API Integration](../frontend/api-integration/)
- **Building UI?** → Check [Frontend UI Components](../frontend/ui-components/)

### For Product Owners / PMs
- **Want to understand features?** → Read [Features](#-features) section
- **Need technical overview?** → Read [System Overview](architecture/system-overview.md)
- **Want to know tech choices?** → Read [Tech Stack](core/tech-stack.md)

---

## 📊 Documentation Map

```
common/
├── features/                     # Feature specs (what users can do)
│   ├── authentication.md
│   ├── places-attractions.md
│   ├── trip-planning.md
│   ├── album-photos.md
│   ├── shop-ecommerce.md
│   └── achievements-gamification.md
│
├── architecture/                 # How systems connect
│   ├── system-overview.md
│   ├── database-schema.md
│   └── api-design-principles.md
│
└── setup-guides/                 # Environment setup
    ├── local-development.md
    ├── auth0-setup.md
    └── environment-variables.md

To implement a feature:
1. Read common/features/[name].md (what)
2. Read backend/feature-implementation/[name].md (backend where & how)
3. Read frontend/feature-implementation/[name].md (frontend where & how)
```

---

## 🎯 How to Use Common Documentation

### Reading a Feature Specification

When you open a feature doc like `features/trip-planning.md`, you'll find:

1. **Overview** - What the feature is about
2. **User Stories** - What users can do (As a user, I want to...)
3. **Requirements** - Technical requirements
4. **Data Model** - Key entities (Travel, Destination, PrePlannedTrip, etc.)
5. **User Flow** - Step-by-step interactions
6. **Success Criteria** - How to test if it works
7. **Implementation Links** - Where to implement this feature
   - Backend: `See [Backend Implementation](../backend/feature-implementation/trip-planning.md)`
   - Frontend: `See [Frontend Implementation](../frontend/feature-implementation/trip-planning.md)`

### Understanding the System

**New to the project?** Start with this path:

1. Read this page (you are here!)
2. Read [System Overview](architecture/system-overview.md) - Understand how components connect
3. Pick a feature that interests you - Read its spec in [Features](#-features)
4. Go to your tier (Backend or Frontend) and read how to implement it

---

## 🔗 Cross-References

### Common Docs to Backend Docs
- Feature specs link to backend implementations
- Data models link to database schemas
- API contracts link to endpoint documentation

**Example**: 
- Read `features/places-attractions.md` to understand the feature
- Then go to `backend/feature-implementation/places-attractions.md` to see backend code details
- Then check `backend/api-endpoints/places-endpoints.md` for API endpoint specifics

### Common Docs to Frontend Docs
- Feature specs link to frontend implementations
- Data models link to state management patterns
- User flows link to screen layouts

**Example**:
- Read `features/trip-planning.md` to understand the feature
- Then go to `frontend/feature-implementation/trip-planning.md` to see UI details
- Then check `frontend/state-management/` for how to manage state

---

## 📝 Core Documentation (Legacy - for Reference)

The original "core" documents are archived but still valuable:

| Document | Purpose |
|----------|---------|
| [project-source-of-truth.md](core/project-source-of-truth.md) | Original feature specifications |
| [tech-stack.md](core/tech-stack.md) | Technology choices and rationale |
| [implementation-strategy.md](core/implementation-strategy.md) | Original testing and implementation approach |
| [alternative-stacks.md](core/alternative-stacks.md) | Alternative tech considered |

**Why these exist**: These are historical documents from project inception. Modern feature specs are in the `features/` folder above.

---

## ❓ FAQ

**Q: Where do I find the database schema?**  
A: [architecture/database-schema.md](architecture/database-schema.md)

**Q: How do I set up the project locally?**  
A: [setup-guides/local-development.md](setup-guides/local-development.md)

**Q: Where do I find implementation details for a feature?**  
A: 
1. Read the feature spec here (e.g., `features/trip-planning.md`)
2. Then go to your tier's documentation:
   - Backend: `../backend/feature-implementation/trip-planning.md`
   - Frontend: `../frontend/feature-implementation/trip-planning.md`

**Q: What's the difference between this (Common) and Backend/Frontend docs?**  
A:
- **Common** = What (feature specs, architecture)
- **Backend** = How in the backend (which files, which code to write)
- **Frontend** = How in the frontend (which screens, which providers)

---

## 🚀 Next Steps

### If you're new to the project
1. ✅ You're reading this (Common Docs overview)
2. → Read [System Overview](architecture/system-overview.md)
3. → Pick a feature and read its spec
4. → Go to your role's tier (Backend/Frontend)

### If you're implementing a feature
1. → Find the feature in [Features](#-features) section
2. → Read the feature specification
3. → Go to your tier's feature implementation guide
4. → Follow the "where to make changes" instructions
5. → Reference the API/UI docs as needed

### If you need a specific answer
1. → Use this page's [Quick Navigation](#-quick-navigation)
2. → Check the [FAQ](#-faq)
3. → Search through the docs (Ctrl+F)

---

## 📞 Questions or Feedback?

- **Feature question?** → Check the feature spec
- **Architecture question?** → Check System Overview & Database Schema
- **Setup question?** → Check setup guides
- **Can't find what you need?** → Check the main README.md for more options

---

**Ready to dive deeper? Pick your next step:**

→ [🏗️ System Overview](architecture/system-overview.md) | [🎮 Features](features/) | [🔧 Setup Guides](setup-guides/)
