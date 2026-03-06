# Place Visit System - Implementation Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  MOBILE CLIENT (Flutter)                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Map Screen (map_screen.dart)                               │
│     └─ Shows districts and locations                            │
│     └─ User taps location → Show MarkVisitModal               │
│                                                                  │
│  2. Mark Visit Modal (mark_visit_modal.dart)                   │
│     └─ Collects metadata (GPS, compass, device info)           │
│     └─ User confirms → PlaceVisitNotifier.recordVisit()       │
│                                                                  │
│  3. Place Visit Provider (place_visit_provider.dart)           │
│     └─ Manages state (isVerifying, lastVisit, etc)            │
│     └─ Calls repository                                         │
│                                                                  │
│  4. Place Visit Repository (place_visit_repository.dart)       │
│     └─ Collects VisitMetadata (GPS, heading, device data)     │
│     └─ Generates request signature                             │
│     └─ Calls POST /api/places/:id/visit                       │
│                                                                  │
└────────────────────────┬──────────────────────────────────────┘
                         │ POST /api/places/:id/visit
                         │ { placeId, metadata, signature }
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  BACKEND (Node.js/Express)                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. placeVisitRoutes.js                                        │
│     └─ POST /:id/visit → validateVisit() → checkAchievements()│
│                                                                  │
│  2. Anti-Cheat Validation                                       │
│     ✓ GPS accuracy check (< 30m)                              │
│     ✓ Geofencing (< 200m from place)                          │
│     ✓ Heading validation (facing place)                        │
│     ✓ Photo EXIF validation                                    │
│     ✓ Device fingerprinting (spoof detection)                  │
│     ✓ Speed validation (distance vs time)                      │
│     ✓ Request signature verification (replay attack)           │
│                                                                  │
│  3. Database (MongoDB)                                          │
│     └─ PlaceVisit model (stores metadata + validation)         │
│     └─ PlaceAchievement model (user achievements)             │
│     └─ Updates Place.stats.visitCount                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Integration Steps

### Step 1: Update Map Screen to Show Mark Visit Button

**File**: `mobile/lib/features/map/presentation/map_screen.dart`

Add mark visit button to the `_DistrictActionPanel`:

```dart
RaisedButton.icon(
  onPressed: locked ? null : () {
    // Show mark visit modal for first location
    if (locations.isNotEmpty) {
      final location = locations[0];
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => MarkVisitModal(
          placeId: location.id,
          placeName: location.name,
          latitude: location.latitude,
          longitude: location.longitude,
          description: location.description,
          category: location.category,
        ),
      );
    }
  },
  icon: const Icon(Icons.location_on),
  label: const Text('Mark as Visited'),
)
```

### Step 2: Wire Auth Token to Provider

**File**: `mobile/lib/features/places/providers/place_visit_provider.dart`

Replace `'YOUR_TOKEN_HERE'` with actual auth token:

```dart
// Get actual Firebase token
final authProvider = ref.watch(authNotifierProvider); // Your auth provider
final token = authProvider.user?.getIdToken() ?? '';

final repo = ref.watch(placeVisitRepositoryProvider(token));
```

### Step 3: Update Trip Model to Include Visit References

**File**: `mobile/lib/features/trips/data/models/trip_model.dart`

Add place visits field (optional, to link visits to trips):

```dart
/// List of place visit IDs associated with this trip (optional)
final List<String>? placeVisitIds;
```

### Step 4: Connect Backend Route

**File**: `backend/src/server.js`

Mount the place visit routes:

```javascript
const placeVisitRoutes = require('./routes/placeVisitRoutes');
app.use('/api/places', placeVisitRoutes);
```

### Step 5: Seed Initial Places (if not done)

```bash
cd backend
node seed-places.js
```

---

## Anti-Cheat Validation Flow

### Client Side (Mobile)

1. **User taps "Mark as Visited"**
2. **Collect Metadata**:
   - GPS: latitude, longitude, accuracy
   - Compass: heading (direction user is facing)
   - Device: model, OS version, sensors
   - Time: measurement duration
3. **Generate Signature**: HMAC-SHA256(userId + placeId + timestamp, SECRET)
4. **Send Request**:
   ```json
   {
     "placeId": "507f...",
     "notes": "Beautiful place!",
     "photoUrl": "https://...",
     "metadata": {
       "latitude": 6.927079,
       "longitude": 80.771453,
       "accuracyMeters": 15,
       "compassHeading": 45,
       "deviceModel": "SM-A15",
       "osVersion": "Android 13",
       "isLocationSpoofed": false
     },
     "requestSignature": "ab12cd34ef56..."
   }
   ```

### Server Side (Backend)

1. **Validate GPS Accuracy**: Must be < 30m
2. **Geofence Check**: Must be within 200m of place coordinates
3. **Heading Check**: User must face towards place (±45°)
4. **Photo EXIF**: If photo provided, GPS data must match
5. **Device Fingerprint**: Check for spoof apps/ROMs
6. **Speed Validation**: Distance/time ratio must be realistic
7. **Request Signature**: Verify HMAC to prevent replay attacks
8. **Rate Limiting**: User can't visit same place twice in 1 hour

**Validation Result**:
```json
{
  "validation": {
    "isValid": true,
    "status": "approved",
    "confidence": 0.98,
    "gpsAccuracyValid": true,
    "geoFencingValid": true,
    "headingValid": true,
    "photoExifValid": true,
    "deviceSignatureSuspicious": false,
    "beingThrottled": false,
    "speedValid": true
  }
}
```

---

## Achievement System

### Achievement Categories

| Category | Title | Threshold | Badge | Reward |
|----------|-------|-----------|-------|--------|
| temples | Temple Explorer | 10 | 🕉️ | 100 pts |
| beaches | Beach Bum | 10 | 🏖️ | 100 pts |
| mountains | Mountain Climber | 10 | ⛰️ | 100 pts |
| historical | Historic Hunter | 10 | 🏛️ | 100 pts |
| wildlife | Wildlife Watcher | 10 | 🦁 | 100 pts |
| all_districts | All Districts Explorer | 25 | 🗺️ | 500 pts |
| visit_count | Legendary Traveler | 50 | 👑 | 300 pts |
| photos | Photo Collector | 10 | 📷 | 100 pts |
| streak | On a Roll | 7 | 🔥 | 200 pts |

### Auto-Unlock Logic

After recording a visit:

1. **Count category visits**: Temples, beaches, etc.
2. **Check thresholds**: If count >= threshold, unlock
3. **Award points**: Add rewards to user score
4. **Notify user**: Show achievement popup
5. **Update leaderboard**: Sort by total points

---

## Database Schema

### PlaceVisit (MongoDB)

```javascript
{
  _id: ObjectId,
  placeId: ObjectId,             // Reference to Place
  userId: String,                 // Firebase UID
  notes: String,                  // Optional user notes
  photoUrl: String,               // Optional photo
  metadata: {
    latitude: Number,
    longitude: Number,
    accuracyMeters: Number,
    compassHeading: Number,
    deviceModel: String,
    osVersion: String,
    isLocationSpoofed: Boolean,
    sensorProvider: String,
  },
  validation: {
    isValid: Boolean,
    status: String,               // 'approved', 'suspicious', 'rejected'
    confidence: Number,           // 0.0-1.0
    gpsAccuracyValid: Boolean,
    geoFencingValid: Boolean,
    headingValid: Boolean,
    // ... more fields
  },
  achievementId: ObjectId,        // If achievement unlocked
  achievementTitle: String,
  tripId: ObjectId,               // Optional trip link
  likesCount: Number,
  likedBy: [String],
  ipAddress: String,
  userAgent: String,
  visitedAt: Date,               // SERVER TIMESTAMP (authoritative)
  createdAt: Date,
  updatedAt: Date,
}
```

### PlaceAchievement (MongoDB)

```javascript
{
  _id: ObjectId,
  userId: String,         // Firebase UID
  title: String,         // 'Temple Explorer', 'All Districts', etc.
  description: String,
  badgeEmoji: String,
  category: String,      // 'temples', 'all_districts', 'visit_count'
  threshold: Number,     // e.g., 10 (visit 10 temples)
  currentProgress: Number,
  isUnlocked: Boolean,
  unlockedAt: Date,
  rewards: {
    points: Number,
    coins: Number,
  },
  notificationSent: Boolean,
  createdAt: Date,
  updatedAt: Date,
}
```

---

## Environment Variables

### Mobile (.env)

```env
BACKEND_URL=http://localhost:5000
```

### Backend (.env)

```env
MONGODB_URI=mongodb://localhost/gemified_travel
JWT_SECRET=your_secret_key
ANTI_CHEAT_ENABLED=true
GEOFENCE_RADIUS_M=200
GPS_ACCURACY_THRESHOLD_M=30
RATE_LIMIT_HOURS=1
MAX_SPEED_MS=30
```

---

## Testing Checklist

### Mobile Testing

- [ ] Can launch app and see map
- [ ] Clicking location shows Mark Visit modal
- [ ] Modal collects GPS data (shows accuracy)
- [ ] Can add optional notes
- [ ] Can submit visit
- [ ] See loading spinner while verifying
- [ ] Receive success/warning message
- [ ] Achievement popup shows on unlock
- [ ] Recent visits appear in history

### Backend Testing

```bash
# Test API endpoint
curl -X POST http://localhost:5000/api/places/507f.../visit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "placeId": "507f...",
    "metadata": {
      "latitude": 6.927079,
      "longitude": 80.771453,
      "accuracyMeters": 15,
      "compassHeading": 45,
      "deviceModel": "Test",
      "osVersion": "Android 13",
      "isLocationSpoofed": false,
      "collectionTimeMs": 2500,
      "sensorProvider": "gps"
    }
  }'

# Check database
db.placevisits.findOne()
db.placeachievements.findOne()
```

### Anti-Cheat Testing

1. **GPS Accuracy**: 
   - Within 30m → Should pass ✅
   - Beyond 30m → Should fail ❌

2. **Geofence**:
   - Within 200m of place → Should pass ✅
   - Beyond 200m → Should fail ❌

3. **Rate Limit**:
   - First visit → Should pass ✅
   - Second visit within 1h → Should fail ❌

4. **Spoofing Detection**:
   - Normal device → Should pass ✅
   - With FakeGPS app → Should fail ❌

---

## Troubleshooting

### "GPS accuracy too low" Error

- User in building or urban canyon
- Solution: Move to open area, wait for better GPS signal

### "Outside geofence" Error

- User too far from place
- Solution: Move closer to place (within 200m)

### "Location spoofing detected" Error

- Device running mock location app
- Solution: Disable mock location apps, use real GPS

### Achievement Not Unlocking

- Check: `db.placevisits.countDocuments({userId, 'validation.isValid': true})`
- Count must be >= threshold
- Check `placeId.category` matches achievement category

### Database Connection Error

- Check: `echo $MONGODB_URI` in backend
- Ensure MongoDB is running: `mongod`
- Check database with: `mongo gemified_travel`

---

## Security Best Practices

✅ **DO:**
- ✅ Verify signatures server-side
- ✅ Use HTTPS only in production
- ✅ Rate limit API endpoints
- ✅ Log all suspicious visits
- ✅ Use server timestamps (never trust client time)
- ✅ Validate all metadata on backend

❌ **DON'T:**
- ❌ Trust client-side timestamps
- ❌ Allow multiple visits in same location instantly
- ❌ Disable geofence checks
- ❌ Store unvalidated GPS coordinates
- ❌ Use weak request signatures
- ❌ Accept visits from spoofing devices

---

## Future Enhancements

- [ ] Machine learning model to detect impossible travel patterns
- [ ] Photo quality verification using vision API
- [ ] Social features (like, comment on visits)
- [ ] Leaderboards by district/category
- [ ] Seasonal achievements
- [ ] Difficulty-based challenges
- [ ] Visit history with photos
- [ ] Badges for consecutive days
