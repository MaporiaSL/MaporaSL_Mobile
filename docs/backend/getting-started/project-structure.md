# Backend - Project Structure

**Understanding the codebase organization**

---

## 📚 Quick Links

- [Main Structure](#-main-structure) - Overview
- [Key Directories](#-key-directories) - Detailed breakdown
- [File Organization](#-file-organization) - Naming conventions
- [Back to Getting Started](README.md)

---

## 🏗️ Main Structure

```
backend/
├── src/                         # Application code
│   ├── server.js                # Express app setup (START HERE)
│   ├── config/                  # Configuration
│   ├── controllers/             # Business logic (7 files)
│   ├── models/                  # Database schemas (4 files)
│   ├── routes/                  # API endpoints (7 files)
│   ├── middleware/              # Authentication, validation
│   ├── validators/              # Input validation
│   └── utils/                   # Helper functions
├── .env                         # Environment variables (GITIGNORED)
├── .env.example                 # Template for .env
├── package.json                 # Dependencies
├── package-lock.json            # Locked versions
└── README.md
```

---

## 📂 Key Directories

### `server.js` - Entry Point
**File**: `backend/src/server.js`

Where everything starts:
- Express app initialization
- Middleware setup (CORS, helmet, JWT)
- Route registration
- Database connection
- Error handling

**When to edit**: Adding global middleware, new route groups

### `config/` - Configuration
**Location**: `backend/src/config/`

```
config/
└── db.js              # MongoDB connection setup
```

**When to edit**: Changing database connection, adding config

### `controllers/` - Business Logic
**Location**: `backend/src/controllers/`

Each controller handles a feature:

```
controllers/
├── authController.js          # User login/signup/logout
├── userController.js          # User progress, achievements
├── travelController.js        # Trip logs (travels)
├── destinationController.js   # Places, attractions
├── mapController.js           # Map data, GeoJSON
├── geoController.js           # Geospatial queries
└── preplannedTripsController.js # Pre-made itineraries
```

**File Pattern**: 
```javascript
// Each controller exports functions like:
module.exports = {
  getAll,      // GET all resources
  getById,     // GET single resource
  create,      // POST create resource
  update,      // PUT update resource
  delete       // DELETE remove resource
};
```

**When to edit**: Adding feature logic, new endpoints

### `models/` - Database Schemas
**Location**: `backend/src/models/`

MongoDB schemas using Mongoose:

```
models/
├── User.js                 # User accounts, progress
├── Travel.js               # Trip logs
├── Destination.js          # Places, attractions
└── PrePlannedTrip.js       # Pre-made itineraries
```

**File Pattern**:
```javascript
// Each model defines:
const schema = new mongoose.Schema({
  // fields
});
module.exports = mongoose.model('ModelName', schema);
```

**When to edit**: Adding fields, changing data structure

### `routes/` - API Endpoints
**Location**: `backend/src/routes/`

Define HTTP endpoints:

```
routes/
├── authRoutes.js          # /api/auth/*
├── userRoutes.js          # /api/users/*
├── travelRoutes.js        # /api/travel/*
├── destinationRoutes.js   # /api/travel/:id/destinations/*
├── mapRoutes.js           # /api/travel/:id/map/*
├── geoRoutes.js           # /api/destinations/*
└── preplannedTripsRoutes.js # /api/preplanned-trips/*
```

**File Pattern**:
```javascript
const express = require('express');
const router = express.Router();

// Define routes
router.get('/', controller.getAll);
router.post('/', controller.create);
router.get('/:id', controller.getById);

module.exports = router;
```

**When to edit**: Adding new endpoints, changing routes

### `middleware/` - Middleware Functions
**Location**: `backend/src/middleware/`

```
middleware/
├── auth.js              # JWT validation, user extraction
├── validation.js        # Input validation
└── errorHandler.js      # Global error handling
```

**Common middleware**:
- `checkJwt` - Validate JWT token
- `extractUserId` - Get user ID from token
- `validateInput` - Validate request body

**When to edit**: Changing auth logic, validation rules, error handling

### `validators/` - Input Validation
**Location**: `backend/src/validators/`

Validation rules for each feature:

```
validators/
├── authValidators.js
├── travelValidators.js
├── destinationValidators.js
└── ...
```

**When to edit**: Adding validation rules, new fields

### `utils/` - Helper Functions
**Location**: `backend/src/utils/`

```
utils/
├── geospatial.js        # Distance, boundary calculations
├── transformers.js      # Data format conversions
└── (other helpers)
```

**When to edit**: Adding utility functions, refactoring common logic

---

## 📋 File Organization

### How to Find Something

**Q: Where do I add a new endpoint?**
- Controller: `src/controllers/[feature]Controller.js`
- Route: `src/routes/[feature]Routes.js`
- Validator: `src/validators/[feature]Validators.js`

**Q: Where do I add a new database field?**
- Model: `src/models/[Model].js`
- Validator: `src/validators/[feature]Validators.js`
- Controller: `src/controllers/[feature]Controller.js`

**Q: Where do I add helper functions?**
- Utility: `src/utils/[feature].js`
- Or: `src/utils/helpers.js`

---

## 🔄 Request Flow

When a request comes in:

```
1. HTTP Request
   ↓
2. server.js receives request
   ↓
3. Middleware processes (CORS, helmet, JWT)
   ↓
4. Route matches: routes/authRoutes.js, travelRoutes.js, etc.
   ↓
5. Validation: validators check input
   ↓
6. Controller executes: controllers/[name]Controller.js
   ↓
7. Model queries: models/[Model].js
   ↓
8. Database returns data
   ↓
9. Response sent back
```

---

## 📊 Example: Adding a Feature

Let's say you want to add a "reviews" feature for places.

### 1. Add to Model
```
Edit: src/models/Destination.js
Add: reviews array field to schema
```

### 2. Add Validation
```
Edit/Create: src/validators/reviewValidators.js
Add: validation rules for review data
```

### 3. Add Controller Logic
```
Edit: src/controllers/destinationController.js
Add: addReview(), getReviews() functions
```

### 4. Add Routes
```
Edit: src/routes/destinationRoutes.js
Add: POST /reviews, GET /reviews routes
```

### 5. Document API
```
Edit/Create: docs/backend/api-endpoints/places-endpoints.md
Add: POST review endpoint documentation
```

---

## 🛠️ Common Tasks

### Running the server
```bash
npm run dev        # Development (with auto-reload)
npm start          # Production
```

### Restarting the server
```
Ctrl+C (stop)
npm run dev (start again)
```

### Adding a package
```bash
npm install package-name
```

### Running tests
```bash
npm test
```

---

## 🔗 Related Documentation

- [Backend Overview](../README.md) - Full backend docs
- [Feature Implementation](../feature-implementation/) - Step-by-step guides
- [API Endpoints](../api-endpoints/) - All endpoints documented
- [Database Schema](../database/models.md) - Data models

---

**Next: Implement your first feature → [Feature Implementation](../feature-implementation/)**
