# 🎯 MAPORIA - Saturday Completion Checklist

**Project Status**: 60-70% Complete  
**Marking Date**: Saturday (This Week)  
**Current Tests**: ✅ 238/238 PASSING  
**Time Available**: ~48-72 hours  

---

## Executive Summary

### ✅ What's Already Working (60%+)
- ✅ Complete authentication system with Firebase + local app lock
- ✅ Trip/Travel management with full CRUD
- ✅ Visit verification with GPS-based location checking
- ✅ Interactive Mapbox map with district rendering
- ✅ Exploration system with XP tracking and unlocking
- ✅ User profiles and leaderboards
- ✅ Real shop system (Phase 1) with cart and checkout
- ✅ 50+ backend API endpoints
- ✅ 18 sophisticated database models
- ✅ Complete test suite (238 tests)

### 🟠 What Needs Work Before Saturday (Medium Effort - 20-30 hrs)
1. **Achievement System UI** - Backend ready, just needs display screens
2. **Places System UI** - Backend 100% ready, needs mobile integration
3. **Bug Fixes & Polish** - Code cleanup, error handling
4. **Documentation** - Marking guide, setup instructions
5. **Demo/Test Data** - Seed accounts and sample data

### ❌ What Can Wait After Saturday (Low Priority)
- Cosmetics shop
- Social sharing UI
- Travel coins currency
- Admin dashboard

---

## 📋 CRITICAL CHECKLIST (Must Have for Saturday)

These items block successful marking:

### 1. ✅ SETUP & COMPILATION
- [ ] **Mobile compiles without errors** - `flutter clean && flutter pub get && flutter build apk --debug`
  - Effort: 5 min | Priority: 🔴 CRITICAL
  - Check: No compilation errors, APK builds
  
- [ ] **Backend runs without errors** - `npm install && npm run dev`
  - Effort: 5 min | Priority: 🔴 CRITICAL
  - Check: Server starts on port 5000, connects to MongoDB
  
- [ ] **All environment variables configured**
  - Effort: 10 min | Priority: 🔴 CRITICAL
  - Check: `.env` file has all required variables (see PROJECT_COMPLETION_ANALYSIS.md section 8)

### 2. ✅ AUTHENTICATION (WORKING)
- [ ] Firebase Auth integrates correctly
  - Effort: 0 min | Priority: ✅ DONE
  - Status: Email/password login works, bypass mode for development enabled
  
- [ ] Local app lock works
  - Effort: 0 min | Priority: ✅ DONE
  - Status: Biometric + PIN authentication implemented

### 3. ✅ CORE FLOWS (WORKING)
- [ ] **Authentication Flow** - User can register/login
  - Effort: 0 min | Priority: ✅ DONE
  - Status: Firebase integration complete, development bypass mode active
  
- [ ] **Home Screen** - Shows user's profile and map
  - Effort: 0 min | Priority: ✅ DONE
  - Status: Map screen with Mapbox rendering operational
  
- [ ] **Trip Management** - Create, view, edit trips
  - Effort: 0 min | Priority: ✅ DONE
  - Status: Full CRUD implemented, validated inputs
  
- [ ] **Visit Verification** - Mark place as visited with GPS
  - Effort: 0 min | Priority: ✅ DONE
  - Status: Multi-tier geofence validation working

- [ ] **Shop System** - Browse products, add to cart, checkout
  - Effort: 0 min | Priority: ✅ DONE
  - Status: Real store phase 1 complete with manual payment

### 4. 🚨 CRITICAL BUG FIXES (MUST FIX)
- [ ] **Fix `progressProvider` is empty** 
  - Effort: 1 hour | Priority: 🔴 CRITICAL
  - Location: `mobile/lib/providers/progress_provider.dart` (file is blank)
  - Action: Either remove unused imports OR implement the provider with basic XP tracking
  - Impact: Could cause runtime errors if accessed
  
- [ ] **Verify all imports are correct**
  - Effort: 30 min | Priority: 🔴 CRITICAL
  - Action: Run `flutter analyze` and fix any import errors
  - Impact: Won't compile if imports broken
  
- [ ] **Check all API endpoints respond without 500 errors**
  - Effort: 1 hour | Priority: 🔴 CRITICAL
  - Action: Run backend, test key endpoints with Postman
  - Endpoints to test:
    - `/api/auth/register`
    - `/api/places`
    - `/api/travels`
    - `/api/visits/mark`
    - `/api/exploration/assignments`
  - Impact: Dead endpoints will fail marking evaluation

- [ ] **Test offline functionality & error handling**
  - Effort: 1 hour | Priority: 🔴 CRITICAL
  - Action: Simulate network failures, verify app doesn't crash
  - Impact: Poor UX makes bad impression on markers

---

## 🎯 HIGH PRIORITY CHECKLIST (Should Have for Saturday)

These make the project showcase better features:

### 5. 🟠 ACHIEVEMENT SYSTEM (Backend ready, needs 2-3 hours)
**Status**: Backend models complete, mobile UI missing  
**Priority**: Should implement for full demo

- [ ] **Create Achievements Display Screen**
  - Effort: 2 hours | Priority: 🟠 HIGH
  - Location: Create `mobile/lib/features/achievements/presentation/achievements_screen.dart`
  - What to show:
    - List of achievements by category (Places, Districts, Provinces)
    - Lock/unlock status with progress bars
    - Rarity badges (bronze/silver/gold)
    - Unlock date and XP earned
  - Backend endpoint ready: `GET /api/achievements` (if not exists, create simple endpoint)
  
- [ ] **Add Achievement Badges to Home Screen**
  - Effort: 1 hour | Priority: 🟠 HIGH
  - Show top 3 recent achievements in home screen
  - Add achievement notification when unlocked
  
- [ ] **Backend Achievement tracking**
  - Effort: 30 min | Priority: 🟠 HIGH
  - Verify `PlaceAchievement` model working
  - Test achieving a place through visit verification
  - Check XP accumulation in user model

### 6. 🟠 PLACES SYSTEM UI (Backend 100% ready, needs 2-3 hours)
**Status**: All backend endpoints working, mobile UI incomplete  
**Priority**: Should showcase for demonstrating completeness

- [ ] **Implement Places Discovery Screen**
  - Effort: 2 hours | Priority: 🟠 HIGH
  - Location: Create/complete `mobile/lib/features/places/presentation/places_screen.dart`
  - What to show:
    - List of places from server with pagination
    - Search bar with autocomplete
    - Category filtering (temples, beaches, restaurants, etc.)
    - District filtering
    - Place card showing: name, category, district, distance
  - Backend endpoints ready:
    - `GET /api/places` (with pagination, search, filters)
    - `GET /api/places/:id`
    - `GET /api/places/by-district/:district`
  
- [ ] **Add "Add to Trip" Functionality**
  - Effort: 1 hour | Priority: 🟠 HIGH
  - When viewing place, allow adding to existing trip
  - Integration with trip provider
  
- [ ] **Add Place Visit Recording**
  - Effort: 30 min | Priority: 🟠 MEDIUM
  - When viewing place, show "Visit" button
  - Link to visit verification system

- [ ] **Display Place Photos**
  - Effort: 1 hour | Priority: 🟠 MEDIUM
  - Show place photos in place detail screen
  - Implement cached image loading

### 7. 🟠 MAP IMPROVEMENTS (1-2 hours)
**Status**: Map working, some edge cases need polish  
**Priority**: Should fix for demo stability

- [ ] **Fix cloud overlay rendering on mobile**
  - Effort: 30 min | Priority: 🟠 MEDIUM
  - Test cloud visibility on actual device
  - Adjust opacity/rendering if needed
  
- [ ] **Ensure bounds-fit works consistently**
  - Effort: 1 hour | Priority: 🟠 MEDIUM
  - Test fitting trip route to bounds (currently has fallback)
  - Location: `mobile/lib/features/map/presentation/map_screen.dart` line 923
  - Add error logging and graceful fallback

- [ ] **Test district tapping and detail view**
  - Effort: 30 min | Priority: 🟠 MEDIUM
  - Tap district shows popup with info/places
  - Verify popup closes properly

### 8. 🟠 EXPLORATION SYSTEM POLISH (1 hour)
**Status**: Working well, just needs UI tweaks  
**Priority**: Medium - already functional

- [ ] **Display assignment tier information**
  - Effort: 30 min | Priority: 🟠 MEDIUM
  - Show whether assignment is: Same District / Same Province / Other Province
  - Display XP reward for completing each
  
- [ ] **Show reroll cooldown UI**
  - Effort: 30 min | Priority: 🟠 MEDIUM
  - Display when next reroll available
  - Show cooldown countdown

### 9. 🟠 PROFILE & LEADERBOARD (30 min)
**Status**: Working, just needs verification  
**Priority**: Medium

- [ ] **Verify leaderboard endpoint returns top users**
  - Effort: 30 min | Priority: 🟠 MEDIUM
  - Test: `GET /api/users/leaderboard`
  - Ensure profile screens show stats correctly

- [ ] **Test profile picture upload**
  - Effort: 30 min | Priority: 🟠 MEDIUM
  - Test: Edit profile with new picture
  - Verify image displays on profile screen

---

## 📝 MEDIUM PRIORITY CHECKLIST (Nice to Have)

### 10. 🟡 CODE QUALITY & TESTING
- [ ] **Run all tests** - `flutter test` from mobile/ directory
  - Effort: 5 min | Priority: 🟡 MEDIUM
  - Status: ✅ 238 tests should pass
  - Verify: `flutter test` runs without errors at end of execution
  
- [ ] **Run static analysis** - `flutter analyze`
  - Effort: 10 min | Priority: 🟡 MEDIUM
  - Fix any warnings/errors reported
  
- [ ] **Backend tests** - `npm test` (if implemented)
  - Effort: 5 min | Priority: 🟡 MEDIUM
  - Check: All backend unit tests pass

- [ ] **No console errors on app startup**
  - Effort: 15 min | Priority: 🟡 MEDIUM
  - Action: Connect device, run app, check logcat/console
  - Fix any red errors (warnings are ok)

### 11. 🟡 DOCUMENTATION FOR MARKERS
Create brief setup guide for markers to understand project:

- [ ] **Create MARKING_GUIDE.md** (15 min)
  - Purpose: Tell markers what to look at
  - Contents:
    - How to setup backend (npm install, .env)
    - How to setup mobile (flutter pub get)
    - How to run app (flutter run)
    - What features to demo
    - Key files to review
    - Expected test results

- [ ] **Create DEMO_SCRIPT.md** (15 min)
  - Step-by-step demo flow for markers
  - Example: 
    1. Start app → See login screen
    2. Register → Create trip
    3. Navigate map → Tap district
    4. View places → Mark visit with GPS
    5. Check achievements/xp
    6. Browse shop
  
- [ ] **Create FEATURES_CHECKLIST.md** (10 min)
  - Quick table showing what's implemented vs planned
  - Honest about what's 100% done vs 70% vs future work

- [ ] **Update README.md** with demo instructions (10 min)
  - Add section "For Marking" with setup steps
  - Add section "Features Overview" with what works

### 12. 🟡 TEST DATA & SEED
- [ ] **Create test user accounts**
  - Effort: 15 min | Priority: 🟡 MEDIUM
  - Create 2-3 demo users with seed data
  - Instructions: Use auth endpoint to register test accounts
  - Populate with: profile pics, trips, visits, achievements

- [ ] **Seed places from JSON** (if not already done)
  - Effort: 10 min | Priority: 🟡 MEDIUM
  - Ensure `project_resources/places_seed_data_2026.json` loaded to database
  - Verify: `GET /api/places` returns 40+ places

- [ ] **Seed pre-planned trips**
  - Effort: 15 min | Priority: 🟡 MEDIUM
  - Ensure template trips available
  - Verify: `GET /api/preplanned-trips` returns templates

### 13. 🟡 ERROR HANDLING & EDGE CASES
- [ ] **Handle network errors gracefully**
  - Effort: 1 hour | Priority: 🟡 MEDIUM
  - Disconnect phone from internet
  - Verify app shows "No connection" message, not crash
  
- [ ] **Handle missing location permission**
  - Effort: 30 min | Priority: 🟡 MEDIUM
  - Deny location permission on visit attempt
  - Verify app asks for permission, doesn't crash
  
- [ ] **Handle invalid GPS coordinates**
  - Effort: 30 min | Priority: 🟡 MEDIUM
  - Test with mock GPS (100km away from place)
  - Verify proper error message "Too far from place"

- [ ] **Smoke tests on main flows**
  - Effort: 1 hour | Priority: 🟡 MEDIUM
  - Login → Trip → Map → Visit → Shop → Profile
  - No crashes or stuck screens

---

## ⏰ TIME BREAKDOWN & PRIORITY

### If You Have 72 Hours (3 days before Saturday)
**Time: ~50 hours available**

**Must Do (6 hours)**:
1. Fix `progressProvider` - 1 hr
2. Verify all imports compile - 0.5 hr
3. Test API endpoints respond - 1 hr
4. Fix critical bugs - 2 hrs
5. No console errors check - 0.5 hr
✅ Result: Project compiles & runs without major bugs

**Should Do (20 hours)**:
1. Achievements display screen - 2 hrs
2. Places discovery screen - 2 hrs
3. Place detail screen - 1.5 hrs
4. Map polish & fixes - 1.5 hrs
5. Exploration UI tweaks - 1 hr
6. Profile verification - 0.5 hr
7. All tests passing - 0.5 hr
8. Create marking guides - 1 hr
9. Demo script - 0.5 hr
10. Test data seeding - 1 hr
11. Error handling - 3 hrs
12. Code cleanup - 2 hrs
✅ Result: Project looks polished, all features showcase-ready

**Nice To Have (10+ hours)**:
1. Cosmetics shop phase setup - 3 hrs
2. Achievement animations - 2 hrs
3. Social sharing buttons - 2 hrs
4. Admin dashboard start - 3 hrs

**Recommendation**: Focus on Must Do (6) + Should Do (20) = 26 hours leaves 22 hours buffer for debugging/fixes.

---

### If You Have 48 Hours (2 days)
**Time: ~35 hours available**

**Priority Tier 1 (MUST DO - 6 hours)**:
1. ✅ Fix progressProvider
2. ✅ Verify compilation
3. ✅ Test API endpoints
4. ✅ No console errors

**Priority Tier 2 (SHOULD DO - 15 hours)**:
1. Achievements display - 2 hrs ⭐
2. Places discovery - 2 hrs ⭐
3. Map polish - 1 hr
4. Marking guides - 1 hr
5. Test data - 1 hr
6. Error handling samples - 3 hrs
7. Code cleanup - 2 hrs
8. Final testing - 2 hrs

**Result**: 21 hours used, 14 hours buffer

**Skip for Now**:
- Cosmetics shop
- Social sharing
- Admin dashboard
- Extensive error handling

---

### If You Have 24 Hours (1 day)
**Time: ~15 hours available**

**MUST DO ONLY (6-8 hours)**:
1. Fix progressProvider - 1 hr
2. Verify compilation - 0.5 hr
3. Test APIs work - 1 hr
4. Clean up console errors - 1 hr
5. Quick marking guide - 0.5 hrs
6. Test data seed - 0.5 hr
7. One last full test run - 1 hr

**Quick Wins (2-3 hours)**:
1. Quick Places list screen (if time) - 1.5 hrs
2. Achievement list screen (if time) - 1.5 hrs

**Result**: Get project to 70% stable, accept 80% complete

---

## 🎬 DEMO FLOW FOR MARKERS

Create this flow document to show markers what to demo:

```
DEMO SEQUENCE (10 minutes)
========================

1. LOGIN/AUTH (1 min)
   - Show login screen
   - Login with demo account
   - Show home screen with map

2. MAP EXPLORATION (2 min)
   - Show interactive map with districts
   - Tap a district → Show district details popup
   - Show places in that district
   - Explain cloud overlay (fog of war)

3. TRIP CREATION (2 min)
   - Create a new trip
   - Select places to visit
   - Show trip timeline
   - Edit trip dates

4. VISIT VERIFICATION (2 min)
   - Select a place to verify
   - Show GPS-based verification
   - Explain geofence logic
   - Show visit recorded

5. PROFILE & STATS (1 min)
   - Show user profile
   - Show XP tracking
   - Show achievements (if implemented)
   - Show leaderboard

6. SHOP (1 min)
   - Browse store items
   - Add to cart
   - Show checkout flow
   - Explain manual payment phase

7. BACKEND OVERVIEW (30 sec)
   - Show 50+ API endpoints working
   - Show database with 18 models
```

---

## ✅ FINAL VERIFICATION CHECKLIST

**Day Before Marking - Run Through This**:

- [ ] App compiles: `flutter build apk --debug`
- [ ] Backend starts: `npm run dev` → Server on :5000
- [ ] No crash on login
- [ ] Can create trip
- [ ] Can view map
- [ ] Can record visit
- [ ] Can view profile
- [ ] Can open shop
- [ ] All tests pass: `flutter test`
- [ ] No red console errors
- [ ] Has marking guide: `MARKING_GUIDE.md`
- [ ] Has demo script: `DEMO_SCRIPT.md`
- [ ] README updated with setup steps

**If everything above is checked** ✅: **You're ready for marking!**

---

## 📊 Success Criteria for Marking

Markers will evaluate:

1. **Does it run?** ✅ Yes (no crashes)
2. **Does it do what it claims?** ~70% (core features work)
3. **Is code quality good?** ✅ Yes (tests pass, no analysis errors)
4. **Is it well documented?** ✅ Yes (50+ pages in docs/)
5. **Did you meet deadlines?** ✅ Yes (submitted on Saturday)

**Acceptable Score**: 70% Complete for Saturday Marking
- All core systems working
- Full backend (50+ endpoints, 18 models)
- Core mobile screens (15+ screens)
- Test infrastructure (238 tests)
- 4 major gamification systems (Map, Exploration, Visits, Shop)

**Great Score**: 80% Complete
- Everything above PLUS
- Achievement system display
- Places discovery fully working
- Polished error handling
- Comprehensive documentation

**Excellent Score**: 90%+
- Everything above PLUS
- All stretch goals  attempted
- Edge cases handled
- Outstanding code quality

---

## 🚀 Quick Start Commands

```bash
# Setup Backend
cd backend
npm install
# Create .env with MongoDB URI and Firebase credentials
npm run dev

# Setup Mobile (in another terminal)
cd mobile
flutter pub get
flutter run --device-id=emulator-5554  # Or your device ID

# Run Tests
cd mobile
flutter test

# Check Code Quality
flutter analyze

# Build for submission
flutter build apk --release
```

---

**Last Updated**: March 18, 2026  
**Status**: Project 60-70% complete, on track for Saturday  
**Recommendation**: Focus on Critical + High Priority sections first  
**Estimated Final Status**: 80-85% by Saturday with focused effort

Good luck with marking! 🎉
