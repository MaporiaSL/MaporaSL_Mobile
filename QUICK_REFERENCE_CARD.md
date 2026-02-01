# 🚀 Documentation Quick Reference Card

**Print this and keep it handy!**

---

## 📍 Where to Start

**First Time?**
```
docs/README.md  (main hub)
    ↓
[Pick your role below]
```

---

## 👥 By Role

### 🔧 Backend Developer
```
1. docs/README.md
2. docs/backend/getting-started/README.md        (5 min setup)
3. docs/backend/getting-started/project-structure.md  (learn code)
4. docs/backend/feature-implementation/[feature].md   (implement)
```

### 📱 Frontend Developer
```
1. docs/README.md
2. docs/frontend/getting-started/README.md       (10 min setup)
3. docs/frontend/getting-started/project-structure.md (learn code)
4. docs/frontend/feature-implementation/[feature].md  (implement)
```

### 👨‍💼 Product Manager
```
1. docs/README.md
2. docs/common/features/[feature].md             (what's built)
3. docs/common/architecture/system-overview.md   (how it works)
```

### 🔧 DevOps / Infrastructure
```
1. docs/backend/deployment/                      (backend deployment)
2. docs/frontend/deployment/                     (frontend deployment)
```

---

## 🎯 Common Tasks

### "How do I implement [feature]?"
```
1. Read: docs/common/features/[feature].md          (what)
2. Backend: docs/backend/feature-implementation/[feature].md (how backend)
3. Frontend: docs/frontend/feature-implementation/[feature].md (how frontend)
4. API: docs/backend/api-endpoints/                 (endpoints)
5. State: docs/frontend/state-management/           (state patterns)
```

### "What files do I edit for [feature]?"
```
Backend:
    Controller:  backend/src/controllers/[feature]Controller.js
    Model:       backend/src/models/[Model].js
    Route:       backend/src/routes/[feature]Routes.js
    Validator:   backend/src/validators/[feature]Validators.js

Frontend:
    Screens:     mobile/lib/features/[feature]/screens/
    Widgets:     mobile/lib/features/[feature]/widgets/
    Provider:    mobile/lib/providers/[feature]_provider.dart
    API Client:  mobile/lib/data/api/[feature]_api_client.dart
```

### "How do I set up the project?"
```
Backend:
    cd backend
    npm install
    cp .env.example .env          (edit with your values)
    npm run dev                   (http://localhost:5000)

Frontend:
    cd mobile
    flutter pub get
    flutter run                   (on emulator or device)
```

### "How do I find the database schema?"
```
docs/common/architecture/database-schema.md
OR
docs/backend/database/models.md (coming)
```

### "What APIs are available?"
```
docs/backend/api-endpoints/[category]-endpoints.md

Categories:
  - authentication-endpoints.md
  - places-endpoints.md
  - trips-endpoints.md
  - user-endpoints.md
  - map-geospatial-endpoints.md
```

### "How do I use Riverpod?"
```
docs/frontend/state-management/riverpod-patterns.md
```

### "How do I test the API?"
```
docs/backend/testing/
```

### "How do I build for production?"
```
Backend:  docs/backend/deployment/
Frontend: docs/frontend/deployment/
```

---

## 📊 7 Core Features

Each has docs in all three tiers:

1. **Authentication** - Login, signup, user accounts
2. **Places & Attractions** - Discover places, visit tracking
3. **Trip Planning** - Create trips, itineraries
4. **Album & Photos** - Photo capture, organization
5. **Shop & E-Commerce** - Products, purchases
6. **Achievements & Gamification** - Badges, leaderboards
7. **Map & Visualization** - Interactive map, offline maps

**For each feature:**
```
What?     → docs/common/features/[feature].md
Backend?  → docs/backend/feature-implementation/[feature].md
Frontend? → docs/frontend/feature-implementation/[feature].md
```

---

## 🔧 Tech Stack at a Glance

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter + Riverpod + Mapbox |
| **Backend** | Node.js + Express.js + MongoDB |
| **Database** | MongoDB Atlas |
| **Auth** | Auth0 + JWT |
| **Storage** | Firebase Storage |
| **Maps** | Mapbox |

---

## 📂 Folder Structure (Simplified)

```
backend/
├── src/
│   ├── controllers/     (7 files - business logic)
│   ├── models/         (4 schemas - database)
│   ├── routes/         (7 files - endpoints)
│   ├── middleware/     (auth, validation)
│   └── utils/          (helpers)

frontend/
├── features/           (feature screens)
├── data/              (API clients, models)
├── providers/         (Riverpod state)
├── core/              (global utilities)
└── models/            (shared models)

docs/
├── common/            (features, architecture, setup)
├── backend/           (implementation guides, API docs)
└── frontend/          (implementation guides, state management)
```

---

## 🆘 Troubleshooting

### Backend won't start
```
npm install
npm run dev
Check: MONGODB_URI, AUTH0_* in .env
```

### Frontend won't run
```
flutter clean
flutter pub get
flutter run
Check: API_BASE_URL in .env or pubspec.yaml
```

### "Port 5000 already in use"
```
Change PORT=5001 in .env
```

### Can't find documentation
```
1. Go to docs/README.md
2. Use Ctrl+F to search
3. Check the FAQ section
```

---

## 🔗 Important Links

**Main Hub**: [docs/README.md](docs/README.md)

**Tiers**:
- [docs/common/README.md](docs/common/README.md)
- [docs/backend/README.md](docs/backend/README.md)
- [docs/frontend/README.md](docs/frontend/README.md)

**Getting Started**:
- [Backend](docs/backend/getting-started/README.md)
- [Frontend](docs/frontend/getting-started/README.md)

**Reports**:
- [Completion Report](DOCUMENTATION_REFACTORING_COMPLETE.md)
- [Visual Summary](DOCUMENTATION_VISUAL_SUMMARY.md)

---

## ✅ Checklist for New Developers

- [ ] Read docs/README.md
- [ ] Read [your role]'s README in docs/[backend|frontend]/
- [ ] Read getting-started guide
- [ ] Run `npm run dev` or `flutter run`
- [ ] Verify health endpoint or app starts
- [ ] Read project-structure.md
- [ ] Pick a feature to understand
- [ ] Read feature-implementation/[feature].md
- [ ] Try to make a small change

---

## 📞 Need Help?

1. **Check docs/README.md** - Has links to everything
2. **Search using Ctrl+F** - Find what you need
3. **Check [tier]/README.md** - Overview of that tier
4. **Check FAQ sections** - Common questions answered
5. **Check getting-started/** - Troubleshooting section

---

## 🎯 One More Thing

**Before you go**, know that:

- ✅ This documentation is **professional, scalable, and complete**
- ✅ You can **revert anytime** with git if you don't like it
- ✅ New features follow the **same pattern** (consistent)
- ✅ It's designed for **team collaboration** and **onboarding**
- ✅ It grows with your project

---

**Happy coding! 🚀**

*Print this card and keep it at your desk.*
