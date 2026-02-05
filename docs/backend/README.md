# MAPORIA - Backend Documentation

> **Purpose**: Backend implementation guides, API details, database schemas  
> **Audience**: Backend developers (Node.js + Express.js)  
> **Tech Stack**: Node.js + Express.js + MongoDB + Mongoose  
> **Last Updated**: February 1, 2026

---

## 📚 Table of Contents

- [Getting Started](#-getting-started)
- [Feature Implementation](#-feature-implementation)
- [API Documentation](#-api-documentation)
- [Database & Models](#-database--models)
- [Architecture](#-architecture)
- [Testing & Deployment](#-testing--deployment)

---

## 🚀 Getting Started

**New to this backend? Start here!**

### Quick Setup (5 minutes)

1. **Install dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Set up environment variables**
   - Copy `.env.example` to `.env`
   - Fill in your MongoDB URI, Firebase Auth credentials, etc.
   - See [Environment Variables](../common/setup-guides/environment-variables.md)

3. **Start development server**
   ```bash
   npm run dev
   ```

Server runs on `http://localhost:5000`

### 📖 Detailed Getting Started
- **[Quick Setup](getting-started/quick-setup.md)** - Environment, dependencies, running server
- **[Project Structure](getting-started/project-structure.md)** - File organization, folder meanings

---

## 🎯 Feature Implementation

**"Where do I make changes?"** → See [Common Feature Implementation](../common/feature-implementation/)

Backend implementation guides are now consolidated with frontend guides in the common documentation.

### 📋 Quick Reference: Backend Files by Feature

| Feature | Controller | Model | Route | Middleware/Validators |
|---------|------------|-------|-------|----------------------|
| **Authentication** | `authController.js` | `User.js` | `authRoutes.js` | `auth.js`, `extractUserId.js` |
| **Places & Attractions** | `destinationController.js`, `geoController.js` | `Destination.js` | `destinationRoutes.js`, `geoRoutes.js` | - |
| **Trip Planning** | `travelController.js` | `Travel.js`, `PrePlannedTrip.js` | `travelRoutes.js` | - |
| **Album & Photos** | *To be created* | *To be created* | *To be created* | - |
| **Shop & E-Commerce** | *Planned* | *Planned* | *Planned* | - |
| **Achievements** | In `User.js` model | `User.js` | *To be created* | - |
| **Maps & Geospatial** | `mapController.js`, `geoController.js` | Uses `Destination.js` | `mapRoutes.js`, `geoRoutes.js` | - |

**All backend files located in**: `backend/src/`

### Detailed Implementation Guides

See [Common Feature Implementation](../common/feature-implementation/) for step-by-step guides on:
- [Authentication](../common/feature-implementation/authentication.md)
- [Places](../common/feature-implementation/places.md)
- [Trips](../common/feature-implementation/trips.md)
- [Album](../common/feature-implementation/album.md)
- [Shop](../common/feature-implementation/shop-implementation.md)
- [Achievements](../common/feature-implementation/achievements.md)
- [Maps](../common/feature-implementation/maps.md)

---

## 🔌 API Documentation

All API endpoints follow RESTful conventions.

### Quick Reference

**[API Endpoints Quick Reference](api-endpoints/README.md)** - All endpoints at a glance

### Detailed Endpoint Documentation

| Documentation | Description | Link |
|--------------|-------------|------|
| **Authentication Endpoints** | Register, login, get user profile | [Auth Endpoints](api-endpoints/auth-endpoints.md) |
| **Full API Reference** | Complete API documentation with examples | [API Reference](api-endpoints/api-reference.md) |

### API Sections in Full Reference

The [Full API Reference](api-endpoints/api-reference.md) includes:
- Authentication (3 endpoints)
- Trips/Travel (5 endpoints)
- Destinations (5 endpoints)
- Maps & GeoJSON (4 endpoints)
- Geospatial Queries (2 endpoints)

### API Format

All endpoints follow this pattern:
```
[HTTP METHOD] /api/[resource]/[id]/[sub-resource]
```

**Example**:
```
GET    /api/travel/123/destinations        - Get trip's places
POST   /api/travel                         - Create new trip
PUT    /api/travel/123                     - Update trip
DELETE /api/travel/123                     - Delete trip
```

### Response Format

**Success** (200, 201):
```json
{
  "success": true,
  "data": { /* resource data */ }
}
```

**Error** (400, 404, 500):
```json
{
  "success": false,
  "error": "Error message",
  "details": { /* details if applicable */ }
}
```

---

## 🗄️ Database & Models

Backend uses MongoDB with Mongoose ORM.

### Data Models

| Model | Collection | Purpose | Docs |
|-------|-----------|---------|------|
| **User** | `users` | User accounts, auth, progress | [Models](database/models.md) |
| **Travel** | `travels` | Trip logs, history | [Models](database/models.md) |
| **Destination** | `destinations` | Places, attractions | [Models](database/models.md) |
| **PrePlannedTrip** | `preplannedtrips` | Itineraries, tours | [Models](database/models.md) |
| **Shop** | `shop_*` (5 collections) | Products, orders, carts | [Models](database/models.md) |

### Key Documentation

- **[Complete Schema](database/models.md)** - All fields, types, relationships
- **[Relationships](database/relationships.md)** - How models connect
- **[Indexes & Optimization](database/indexes-optimization.md)** - Performance tuning

### Using Mongoose

When adding a new field to a model:

1. Update the schema in `backend/src/models/[Model].js`
2. Add validation if needed
3. Update API endpoint logic
4. Create database migration if needed
5. Update documentation

---

## 🏗️ Architecture

### Server Setup

**File**: `backend/src/server.js`

- Express app initialization
- Middleware setup (CORS, helmet, JWT, etc.)
- Route registration
- Database connection
- Error handling

### Middleware

**Location**: `backend/src/middleware/`

| Middleware | Purpose | Uses |
|-----------|---------|------|
| **auth.js** | JWT validation, user extraction | All protected routes |
| **validation.js** | Input validation | Feature-specific |
| **errorHandler.js** | Error formatting | Global error handling |

See [Middleware & Validation](middleware-validation/) for details.

### Utilities

**Location**: `backend/src/utils/`

- `geospatial.js` - Map calculations, distance, boundaries
- `transformers.js` - Data format conversions
- `validators.js` - Common validation functions

See [Utilities & Helpers](utilities-helpers/) for details.

---

## ✅ Testing & Deployment

### Testing

- **[Test Setup](testing/test-setup.md)** - Jest configuration, running tests
- **[Controller Tests](testing/controller-tests.md)** - Testing API logic
- **[Integration Tests](testing/integration-tests.md)** - Testing full workflows

### Deployment

- **[Environment Config](deployment/environment-config.md)** - Production variables
- **[Database Migration](deployment/database-migration.md)** - Updating live data
- **[Production Checklist](deployment/production-checklist.md)** - Before going live

---

## 📊 Backend Project Structure

```
backend/
├── src/
│   ├── server.js                    # Express app setup
│   │
│   ├── config/
│   │   └── db.js                    # MongoDB connection
│   │
│   ├── controllers/                 # Business logic (7 files)
│   │   ├── authController.js        # Auth logic
│   │   ├── userController.js        # User progress
│   │   ├── travelController.js      # Trip logs
│   │   ├── destinationController.js # Places
│   │   ├── mapController.js         # Map data
│   │   ├── geoController.js         # Geospatial
│   │   └── preplannedTripsController.js  # Itineraries
│   │
│   ├── models/                      # Mongoose schemas (4 models)
│   │   ├── User.js
│   │   ├── Travel.js
│   │   ├── Destination.js
│   │   └── PrePlannedTrip.js
│   │
│   ├── routes/                      # Endpoint definitions (7 files)
│   │   ├── authRoutes.js
│   │   ├── userRoutes.js
│   │   ├── travelRoutes.js
│   │   ├── destinationRoutes.js
│   │   ├── mapRoutes.js
│   │   ├── geoRoutes.js
│   │   └── preplannedTripsRoutes.js
│   │
│   ├── middleware/                  # Middleware functions
│   │   ├── auth.js                  # JWT validation
│   │   ├── validation.js
│   │   └── errorHandler.js
│   │
│   ├── validators/                  # Input validation
│   │   └── *.Validators.js
│   │
│   └── utils/                       # Helper functions
│       ├── geospatial.js
│       ├── transformers.js
│       └── ...
│
├── .env                             # Environment variables (GITIGNORED)
├── .env.example                     # Template
├── package.json
└── README.md
```

---

## 🔄 Quick Navigation

### I want to...

| Task | Read This |
|------|-----------|
| **Set up backend locally** | [Quick Setup](getting-started/quick-setup.md) |
| **Understand folder structure** | [Project Structure](getting-started/project-structure.md) |
| **Implement a feature** | Feature guide in [Feature Implementation](feature-implementation/) |
| **See what API endpoints exist** | [API Endpoints](api-endpoints/) folder |
| **Understand the database** | [Database Docs](database/) folder |
| **Test my code** | [Testing Guides](testing/) |
| **Deploy to production** | [Deployment](deployment/) |
| **Find how to do X in code** | Search [Feature Implementation](feature-implementation/) |

---

## 🔗 Useful Links

### Within Backend Docs
- 📋 [Feature Implementation](feature-implementation/) - Where to make changes
- 🔌 [API Endpoints](api-endpoints/) - What APIs exist
- 🗄️ [Database](database/) - Schema & models
- 🛡️ [Middleware](middleware-validation/) - Auth & validation
- ⚙️ [Utilities](utilities-helpers/) - Helper functions

### To Other Tiers
- 📌 [Common Features](../common/features/) - What you're implementing
- 📱 [Frontend Implementation](../frontend/feature-implementation/) - How frontend uses your APIs
- 🔧 [Frontend API Integration](../frontend/api-integration/) - How frontend calls your APIs

### External Resources
- [Express.js Docs](https://expressjs.com/)
- [Mongoose Docs](https://mongoosejs.com/)
- [MongoDB Docs](https://docs.mongodb.com/)
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)

---

## ✨ Tips for Success

1. **Read the feature spec first**
   - Go to [Common Features](../common/features/)
   - Understand what the feature is supposed to do
   - Then come back to the backend feature implementation guide

2. **Follow existing patterns**
   - Look at similar features
   - Follow the same code organization
   - Use the same validation approach

3. **Test as you code**
   - See [Testing](testing/)
   - Test your endpoints before sending to frontend

4. **Keep documentation updated**
   - When you add a new endpoint, update [API Endpoints](api-endpoints/)
   - When you change a model, update [Database Docs](database/)
   - When you add a utility, document it in [Utilities](utilities-helpers/)

5. **Use the feature guides**
   - They're written with code examples
   - They show you exactly which files to modify
   - They follow the same pattern for every feature

---

## ❓ FAQ

**Q: How do I run the backend?**  
A: `npm run dev` (development) or `npm start` (production)  
See [Quick Setup](getting-started/quick-setup.md)

**Q: Where do I add a new API endpoint?**  
A: 
1. Add logic to controller: `backend/src/controllers/[name]Controller.js`
2. Add route: `backend/src/routes/[name]Routes.js`
3. Document it: `docs/backend/api-endpoints/[name]-endpoints.md`

**Q: How do I add a new database field?**  
A:
1. Update schema: `backend/src/models/[Model].js`
2. Update validator if needed: `backend/src/validators/`
3. Update controller logic if needed
4. Document it: `docs/backend/database/models.md`

**Q: How do I handle authentication in an endpoint?**  
A: See [JWT Authentication](middleware-validation/jwt-authentication.md)

**Q: Where are environment variables stored?**  
A: See `backend/.env` (create from `.env.example`)  
See [Environment Config](../common/setup-guides/environment-variables.md)

---

## 🚀 Next Steps

### If you're new
1. ✅ You're reading this (Backend Docs overview)
2. → Read [Quick Setup](getting-started/quick-setup.md) to run the server
3. → Read [Project Structure](getting-started/project-structure.md) to understand organization
4. → Read a feature spec in [Common Features](../common/features/)
5. → Follow the backend feature implementation guide

### If you're implementing a feature
1. → Go to [Feature Implementation](feature-implementation/)
2. → Find your feature
3. → Follow the step-by-step instructions
4. → Reference [API Endpoints](api-endpoints/) and [Database](database/) as needed

### If you need help
1. → Check the [Quick Navigation](#-quick-navigation)
2. → Search [Feature Implementation](feature-implementation/)
3. → Check [FAQ](#-faq)

---

**Ready to code? Pick your starting point:**

→ [🎯 Quick Setup](getting-started/quick-setup.md) | [📂 Project Structure](getting-started/project-structure.md) | [🎮 Feature Implementation](feature-implementation/)
