# MAPORIA Implementation Strategy & Discussion

> **Date**: January 1, 2026  
> **Purpose**: Align on implementation approach, architecture decisions, and testing strategy

---

## 🎯 Executive Summary

Your approach is **absolutely correct**:
- ✅ Start with authentication & data isolation
- ✅ Build all features on top of this foundation
- ✅ 100% possible to test locally and fully
- ✅ This is the standard approach for multi-user mobile apps

---

## Part 1: Why Starting with Auth + Data Isolation is Right

### Foundation-First Principle

Authentication is the **critical foundation** because:

1. **All data must be scoped to users**
   - Every place visit → belongs to a user
   - Every trip → belongs to a user
   - Every photo → belongs to a user
   - Every achievement → belongs to a user

2. **Security & Privacy**
   - Without auth, there's no data isolation
   - User A could see User B's data
   - Violates GDPR, breaks trust

3. **Enables Other Features**
   - Trip planning requires knowing whose trip it is
   - Social sharing requires knowing the sharer
   - Achievements require user context
   - Moderation requires admin access control

### Correct Dependency Chain

```
Phase 1: Authentication & User Management
         ↓
Phase 2: User-Scoped Data Models (Visits, Trips, Photos)
         ↓
Phase 3: Gamification Features (Achievements, Cloud System)
         ↓
Phase 4: Trip Planning & Media
         ↓
Phase 5: Social & Sharing
         ↓
Phase 6: Admin & Moderation
```

---

## Part 2: Local Testing Strategy (YOU CAN TEST FULLY LOCALLY)

### Great News: Flutter is Perfect for Local Testing

You can test everything locally without deploying. Here's how:

#### Option A: Recommended - Full Local Stack

```
┌─────────────────┐
│  Flutter App    │  (Android Emulator or iOS Simulator)
└────────┬────────┘
         │
         │ (localhost)
         ↓
┌──────────────────────┐
│  Supabase Local      │  (via Docker)
│  - PostgreSQL        │
│  - Auth Service      │
│  - Storage (S3)      │
└──────────────────────┘
```

**Setup Required**:
```bash
# 1. Install Docker
# 2. Run Supabase locally
supabase start

# 3. Run Flutter on emulator
flutter emulators launch android_emulator
flutter run

# 4. All communication happens on localhost:54321
```

**Advantages**:
- Test auth flows completely
- Test data isolation
- Test database queries
- Test file uploads
- Zero internet needed
- Matches production setup
- 100% reproducible

#### Option B: Mock Backend (Faster Initial Development)

If you want to start even faster:

```dart
// lib/data/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
}

// Implementation can be swapped:
class MockAuthRepository implements AuthRepository {
  // Fake data, no backend needed
}

class SupabaseAuthRepository implements AuthRepository {
  // Real backend
}
```

**Advantages**:
- Start UI/UX development immediately
- No backend setup required initially
- Easy to swap to real backend later

**Disadvantages**:
- Doesn't test real API communication
- Harder to discover backend issues

#### Option C: Hybrid (Best for Development)

1. **Week 1-2**: Use **MockAuthRepository** to build login UI
2. **Week 2-3**: Setup Supabase locally, switch to **SupabaseAuthRepository**
3. **Week 3+**: Add more features on real backend

---

## Part 3: Testing Mobile Apps Locally

### You CAN Test Without Deploying

#### Android Testing

```bash
# 1. Start Android Emulator
flutter emulators launch Pixel_5_API_31

# 2. Run app in debug mode
flutter run -v

# 3. Use DevTools for debugging
flutter pub global activate devtools
devtools
```

#### iOS Testing

```bash
# 1. Start iOS Simulator
open -a Simulator

# 2. Run app
flutter run -d "iPhone 14"

# 3. Use Xcode debugger if needed
```

#### Web Testing (Fastest for Development)

```bash
# Test login flow instantly in browser
flutter run -d chrome

# Access DevTools: http://localhost:9100
```

#### Device Testing (Optional, for Real GPS Testing)

```bash
# If you have a physical device
adb devices  # List connected Android devices
flutter run  # Will auto-select device
```

### What You CAN Test Locally

| Feature | Android Emulator | iOS Simulator | Web | Physical Device |
|---------|-----------------|---------------|-----|-----------------|
| Auth Login/Register | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| User Data Isolation | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Database Operations | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| UI/UX Flow | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| API Communication | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| File Upload/Download | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| GPS/Location* | ⚠️ Mock | ⚠️ Mock | ❌ No | ✅ Yes |
| Camera/Photos* | ⚠️ Emulator | ⚠️ Simulator | ❌ No | ✅ Yes |
| Push Notifications* | ⚠️ Limited | ⚠️ Limited | ❌ No | ✅ Yes |

**Note**: * = Platform-specific features can be mocked for initial development

### Mocking GPS for Testing

```dart
// lib/core/services/location_service.dart
abstract class LocationService {
  Future<GeoPoint> getCurrentLocation();
}

// Mock for development
class MockLocationService implements LocationService {
  @override
  Future<GeoPoint> getCurrentLocation() async {
    return GeoPoint(
      latitude: 6.9271,  // Colombo coordinates
      longitude: 80.7789,
    );
  }
}

// Real Supabase location service
class RealLocationService implements LocationService {
  @override
  Future<GeoPoint> getCurrentLocation() async {
    // Real GPS using geolocator package
  }
}
```

---

## Part 4: Data Isolation Architecture

### Database Schema Pattern

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Visits table (USER-SCOPED)
CREATE TABLE visits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_id UUID NOT NULL,
  visited_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Trips table (USER-SCOPED)
CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  status TEXT DEFAULT 'planned',  -- 'planned', 'completed'
  created_at TIMESTAMP DEFAULT NOW()
);

-- Photos table (USER-SCOPED)
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_id UUID,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Row Level Security (RLS) in Supabase

```sql
-- Users can only see their own data
ALTER TABLE visits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own visits"
  ON visits FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own visits"
  ON visits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Same for trips, photos, etc.
```

### Dart Implementation

```dart
// lib/data/repositories/visit_repository.dart
class VisitRepository {
  final SupabaseClient _supabase;

  VisitRepository(this._supabase);

  // Get CURRENT USER's visits only
  Future<List<Visit>> getUserVisits() async {
    final user = _supabase.auth.currentUser;
    
    if (user == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('visits')
        .select()
        .eq('user_id', user.id)  // ← Filter by current user
        .order('visited_at', ascending: false);

    return (response as List)
        .map((json) => Visit.fromJson(json))
        .toList();
  }

  // Create visit for CURRENT USER only
  Future<Visit> recordVisit(String placeId) async {
    final user = _supabase.auth.currentUser;
    
    if (user == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('visits')
        .insert({
          'user_id': user.id,  // ← Automatically scoped
          'place_id': placeId,
          'visited_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return Visit.fromJson(response);
  }
}
```

---

## Part 5: Questions to Discuss & Agree On

Before starting implementation, we should align on:

### 1. Authentication Method
- [ ] Email + Password only?
- [ ] Google OAuth too?
- [ ] Apple Sign-In (iOS requirement)?
- [ ] Phone number authentication?

### 2. User Profile Data
- [ ] What fields does a user profile need?
  - Name
  - Avatar/Profile picture
  - Bio/Description
  - Preferences (theme, language)
  - Privacy settings (public/private profile)

### 3. Admin User Roles
- [ ] Super Admin (everything)
- [ ] Content Moderator (reviews places)
- [ ] Support (helps users)
- [ ] How to assign roles?

### 4. Data Privacy & Deletion
- [ ] Can users delete their account? (GDPR)
- [ ] What happens to their data?
  - Option A: Soft delete (keep for audit)
  - Option B: Hard delete (remove completely)
  - Option C: Anonymize

### 5. Offline Support
- [ ] Should app work offline?
- [ ] Sync when connection restored?
- [ ] Or require internet for everything?

### 6. Testing Approach
- [ ] Unit tests on repositories?
- [ ] Widget tests for UI?
- [ ] Integration tests with real backend?
- [ ] Test coverage target (%)?

### 7. Backend Infrastructure
- [ ] Supabase free tier sufficient?
- [ ] Or custom backend preferred?
- [ ] Database backup strategy?

---

## Part 6: Recommended Week 1 Roadmap

### Week 1 Implementation Plan

```
Day 1-2: Setup & Architecture
├─ Create project structure
├─ Setup Supabase locally (Docker)
├─ Create Flutter app scaffolding
└─ Define auth state management with Provider

Day 3-4: Authentication
├─ Login screen UI
├─ Register screen UI
├─ Email validation
├─ Password strength rules
├─ Error handling & user feedback

Day 5: Data Isolation Testing
├─ Create 2 test users
├─ Create user-scoped data models
├─ Test: User A sees only User A's data
├─ Test: User B sees only User B's data
└─ Test: Logout → No access to data

Day 6-7: Polish & Documentation
├─ Add loading states
├─ Add error screens
├─ Add password reset flow (optional)
├─ Update documentation
└─ Code review & refactoring
```

---

## Part 7: Tools & Environment Setup

### Required Tools

```bash
# Flutter (if not installed)
flutter doctor  # Check setup

# Backend
docker --version  # For Supabase local

# Testing
flutter test  # Unit & widget tests
```

### Project Structure (Recommended)

```
mobile/lib/
├── main.dart
├── core/
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── services/
│   │   └── supabase_service.dart
│   └── utils/
│       └── validators.dart
├── data/
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── models/
│       └── user.dart
└── presentation/
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   └── home/
    │       └── home_screen.dart
    └── widgets/
        └── custom_widgets.dart
```

---

## Part 8: Success Criteria for Phase 1

✅ **Authentication Phase Complete When**:
- [ ] User can register with email/password
- [ ] User can login with email/password
- [ ] User can logout
- [ ] Passwords are validated (strength rules)
- [ ] Email is validated (format & uniqueness)
- [ ] Authenticated state persists across app restarts
- [ ] User A's data is completely isolated from User B
- [ ] RLS policies prevent cross-user data access
- [ ] All tested locally without deployment

---

## Next Steps

1. **Agree on the 7 discussion points** (Part 5)
2. **Confirm Week 1 roadmap** (Part 6)
3. **Setup local Supabase** (Part 3)
4. **Create project structure** (Part 7)
5. **Start implementation** with test users

---

**Ready to start implementation? Let's align on the discussion points first! 🚀**
