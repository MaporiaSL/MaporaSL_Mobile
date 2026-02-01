# Achievements & Gamification Implementation

**Feature**: Progress Tracking & Rewards  
**Last Updated**: February 1, 2026

---

## Overview

The Achievements feature tracks user progress exploring Sri Lanka through district unlocking, place visits, and milestone rewards. Progress is stored in the User model and visualized in the app.

---

## Architecture

```
User visits Destination
         ↓
districtId extracted
         ↓
User.unlockedDistricts[] updated
User.totalPlacesVisited++ 
         ↓
Check achievement thresholds
         ↓
Award achievement & XP
```

---

## Backend Implementation

### Files to Modify

| File | Purpose | Location |
|------|---------|----------|
| **User.js** | Achievement tracking | `backend/src/models/User.js` |
| **userController.js** | User stats logic | `backend/src/controllers/userController.js` |
| **destinationController.js** | Visit tracking | `backend/src/controllers/destinationController.js` |

### 1. User Model (`backend/src/models/User.js`)

**Achievement Fields** (Already Implemented):
```javascript
unlockedDistricts: { type: [String], default: [] },
unlockedProvinces: { type: [String], default: [] },
achievements: [{
  districtId: { type: String, required: true },
  progress: { type: Number, default: 0 },
  unlockedAt: { type: Date, default: null }
}],
totalPlacesVisited: { type: Number, default: 0 }
```

**Where to Make Changes**:
- **Add XP system**: Add `experiencePoints`, `level` fields
- **Add badges**: Add `badges` array
- **Add streaks**: Add `visitStreak`, `lastVisitDate` fields

**Example: Add XP and levels**:
```javascript
const userSchema = new mongoose.Schema({
  // ... existing fields ...
  experiencePoints: { type: Number, default: 0, min: 0 },
  level: { type: Number, default: 1, min: 1 },
  badges: [{
    badgeId: String,
    name: String,
    unlockedAt: Date,
    tier: { type: String, enum: ['bronze', 'silver', 'gold'] }
  }],
  visitStreak: {
    current: { type: Number, default: 0 },
    longest: { type: Number, default: 0 },
    lastVisit: Date
  }
});
```

### 2. Destination Controller (`backend/src/controllers/destinationController.js`)

**Where to Add Achievement Logic**:

In `createDestination` or `updateDestination` when marking as visited:

```javascript
exports.markDestinationVisited = async (req, res) => {
  const dest = await Destination.findByIdAndUpdate(
    req.params.destId,
    { visited: true, visitedAt: new Date() },
    { new: true }
  );
  
  // Achievement logic
  const user = await User.findOne({ auth0Id: req.user.auth0Id });
  
  // 1. Unlock district if not already unlocked
  if (dest.districtId && !user.unlockedDistricts.includes(dest.districtId)) {
    user.unlockedDistricts.push(dest.districtId);
  }
  
  // 2. Increment visit counter
  user.totalPlacesVisited += 1;
  
  // 3. Update visit streak
  const today = new Date().setHours(0, 0, 0, 0);
  const lastVisit = user.visitStreak.lastVisit 
    ? new Date(user.visitStreak.lastVisit).setHours(0, 0, 0, 0) 
    : 0;
  
  if (lastVisit === today - 86400000) { // Yesterday
    user.visitStreak.current += 1;
  } else if (lastVisit !== today) {
    user.visitStreak.current = 1;
  }
  
  if (user.visitStreak.current > user.visitStreak.longest) {
    user.visitStreak.longest = user.visitStreak.current;
  }
  user.visitStreak.lastVisit = new Date();
  
  // 4. Award XP
  user.experiencePoints += 10; // Base XP per visit
  
  // 5. Check for level up
  const newLevel = Math.floor(user.experiencePoints / 100) + 1;
  if (newLevel > user.level) {
    user.level = newLevel;
    // Trigger level up event
  }
  
  await user.save();
  
  res.json({ 
    destination: dest, 
    user: {
      unlockedDistricts: user.unlockedDistricts,
      totalPlacesVisited: user.totalPlacesVisited,
      experiencePoints: user.experiencePoints,
      level: user.level,
      visitStreak: user.visitStreak
    }
  });
};
```

### 3. User Controller (Create)

**File**: `backend/src/controllers/userController.js`

```javascript
exports.getUserAchievements = async (req, res) => {
  const user = await User.findOne({ auth0Id: req.user.auth0Id });
  
  // Calculate completion percentage
  const totalDistricts = 25; // Sri Lanka has 25 districts
  const completionPercent = (user.unlockedDistricts.length / totalDistricts) * 100;
  
  res.json({
    unlockedDistricts: user.unlockedDistricts,
    totalPlacesVisited: user.totalPlacesVisited,
    achievements: user.achievements,
    experiencePoints: user.experiencePoints,
    level: user.level,
    badges: user.badges,
    visitStreak: user.visitStreak,
    stats: {
      districtCompletion: completionPercent,
      totalDistricts: totalDistricts,
      unlockedCount: user.unlockedDistricts.length
    }
  });
};
```

**Route** (`backend/src/routes/userRoutes.js`):
```javascript
router.get('/achievements', checkJwt, extractUserId, getUserAchievements);
```

---

## Frontend Implementation

### Files to Create/Modify

| File | Purpose | Location |
|------|---------|----------|
| **achievements_screen.dart** | Achievement UI | `mobile/lib/features/achievements/screens/achievements_screen.dart` (to create) |
| **achievements_provider.dart** | Achievement state | `mobile/lib/features/achievements/providers/achievements_provider.dart` (to create) |
| **district_map_widget.dart** | Visual district map | `mobile/lib/features/achievements/widgets/district_map_widget.dart` (to create) |
| **achievement_badge_widget.dart** | Badge display | `mobile/lib/features/achievements/widgets/achievement_badge_widget.dart` (to create) |

### 1. Achievements Screen (To Create)

**Purpose**: Display user's progress and achievements.

**UI Components**:
- Level progress bar
- XP counter
- District completion percentage
- Unlocked districts list
- Badges gallery
- Visit streak counter

**Example**:
```dart
class AchievementsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Achievements')),
      body: Column(
        children: [
          // Level & XP
          LevelProgressCard(
            level: achievements.level,
            currentXP: achievements.experiencePoints,
            nextLevelXP: achievements.level * 100,
          ),
          
          // Districts
          DistrictCompletionCard(
            unlockedCount: achievements.unlockedDistricts.length,
            totalCount: 25,
          ),
          
          // Badges
          BadgesGrid(badges: achievements.badges),
          
          // Streak
          VisitStreakCard(
            current: achievements.visitStreak.current,
            longest: achievements.visitStreak.longest,
          ),
        ],
      ),
    );
  }
}
```

### 2. Achievements Provider (To Create)

```dart
class AchievementsNotifier extends StateNotifier<AchievementsState> {
  AchievementsNotifier(this._apiClient) : super(AchievementsState.initial());
  
  final ApiClient _apiClient;
  
  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true);
    
    final response = await _apiClient.get('/api/user/achievements');
    
    state = state.copyWith(
      unlockedDistricts: response['unlockedDistricts'],
      totalPlacesVisited: response['totalPlacesVisited'],
      experiencePoints: response['experiencePoints'],
      level: response['level'],
      badges: response['badges'],
      visitStreak: VisitStreak.fromJson(response['visitStreak']),
      isLoading: false,
    );
  }
}
```

---

## Achievement Definitions

### District Achievements

| Achievement | Requirement | XP Reward |
|-------------|-------------|-----------|
| District Explorer | Unlock 1 district | 50 XP |
| District Wanderer | Unlock 5 districts | 200 XP |
| District Master | Unlock 15 districts | 500 XP |
| Island Explorer | Unlock all 25 districts | 1000 XP |

### Visit Achievements

| Achievement | Requirement | XP Reward |
|-------------|-------------|-----------|
| First Steps | Visit 1 place | 10 XP |
| Adventurer | Visit 10 places | 100 XP |
| Explorer | Visit 50 places | 500 XP |
| Wanderlust | Visit 100 places | 1000 XP |

### Streak Achievements

| Achievement | Requirement | XP Reward |
|-------------|-------------|-----------|
| Week Warrior | 7-day visit streak | 200 XP |
| Month Master | 30-day visit streak | 800 XP |
| Year Legend | 365-day streak | 5000 XP |

---

## Implementing Badge System

### Backend Badge Logic

**Create badge definitions**:
```javascript
const BADGES = {
  temple_explorer: {
    id: 'temple_explorer',
    name: 'Temple Explorer',
    description: 'Visit 10 temples',
    tiers: {
      bronze: { requirement: 10, xp: 100 },
      silver: { requirement: 25, xp: 250 },
      gold: { requirement: 50, xp: 500 }
    }
  },
  beach_lover: {
    id: 'beach_lover',
    name: 'Beach Lover',
    description: 'Visit 10 beaches',
    tiers: {
      bronze: { requirement: 10, xp: 100 },
      silver: { requirement: 25, xp: 250 },
      gold: { requirement: 50, xp: 500 }
    }
  }
};
```

**Check badge eligibility**:
```javascript
async function checkAndAwardBadges(userId) {
  const user = await User.findOne({ auth0Id: userId });
  
  // Count temple visits
  const templeVisits = await Destination.countDocuments({
    userId,
    visited: true,
    category: 'temple'
  });
  
  // Award temple badge
  const templateBadge = BADGES.temple_explorer;
  for (const [tier, config] of Object.entries(templateBadge.tiers)) {
    if (templeVisits >= config.requirement) {
      const badgeExists = user.badges.find(b => 
        b.badgeId === templateBadge.id && b.tier === tier
      );
      
      if (!badgeExists) {
        user.badges.push({
          badgeId: templateBadge.id,
          name: templateBadge.name,
          tier,
          unlockedAt: new Date()
        });
        user.experiencePoints += config.xp;
      }
    }
  }
  
  await user.save();
}
```

---

## Leaderboard Feature

### Backend Leaderboard Endpoint

```javascript
exports.getLeaderboard = async (req, res) => {
  const { category = 'xp', limit = 10 } = req.query;
  
  let sortField;
  switch (category) {
    case 'xp':
      sortField = { experiencePoints: -1 };
      break;
    case 'places':
      sortField = { totalPlacesVisited: -1 };
      break;
    case 'districts':
      sortField = { 'unlockedDistricts': -1 }; // Sort by array length
      break;
  }
  
  const leaderboard = await User.find()
    .sort(sortField)
    .limit(parseInt(limit))
    .select('name profilePicture experiencePoints level totalPlacesVisited unlockedDistricts');
  
  res.json({ leaderboard });
};
```

### Frontend Leaderboard Screen

```dart
ListView.builder(
  itemCount: leaderboard.length,
  itemBuilder: (ctx, index) {
    final user = leaderboard[index];
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePicture),
        child: Text('#${index + 1}'),
      ),
      title: Text(user.name),
      subtitle: Text('Level ${user.level}'),
      trailing: Text('${user.experiencePoints} XP'),
    );
  },
)
```

---

## API Endpoints

**To Create**:
- `GET /api/user/achievements` - Get user achievements
- `GET /api/leaderboard?category=xp&limit=10` - Get leaderboard
- `POST /api/achievements/claim/:achievementId` - Claim achievement reward

---

## Testing

### Backend Testing

```bash
# Get achievements
curl http://localhost:5000/api/user/achievements \
  -H "Authorization: Bearer TOKEN"

# Get leaderboard
curl "http://localhost:5000/api/leaderboard?category=xp&limit=10"
```

### Frontend Testing

```dart
test('Load achievements', () async {
  await ref.read(achievementsProvider.notifier).loadAchievements();
  final achievements = ref.read(achievementsProvider);
  
  expect(achievements.level, greaterThan(0));
  expect(achievements.unlockedDistricts, isNotEmpty);
});
```

---

## See Also

- [User Model Documentation](../../backend/database/models.md#user-model)
- [Destination Implementation](./places.md)
- [Frontend State Management](../../frontend/state-management/)
