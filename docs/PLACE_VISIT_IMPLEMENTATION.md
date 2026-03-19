# Place Visit System - Implementation Guide

## Architecture Overview

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  MOBILE CLIENT (Flutter)                                        â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                                  â”‚
â”‚  1. Map Screen (map_screen.dart)                               â”‚
â”‚     â””â”€ Shows districts and locations                            â”‚
â”‚     â””â”€ User taps location â†’ Show MarkVisitModal               â”‚
â”‚                                                                  â”‚
â”‚  2. Mark Visit Modal (mark_visit_modal.dart)                   â”‚
â”‚     â””â”€ Collects metadata (GPS, compass, device info)           â”‚
â”‚     â””â”€ User confirms â†’ PlaceVisitNotifier.recordVisit()       â”‚
â”‚                                                                  â”‚
â”‚  3. Place Visit Provider (place_visit_provider.dart)           â”‚
â”‚     â””â”€ Manages state (isVerifying, lastVisit, etc)            â”‚
â”‚     â””â”€ Calls repository                                         â”‚
â”‚                                                                  â”‚
â”‚  4. Place Visit Repository (place_visit_repository.dart)       â”‚
â”‚     â””â”€ Collects VisitMetadata (GPS, heading, device data)     â”‚
â”‚     â””â”€ Generates request signature                             â”‚
â”‚     â””â”€ Calls POST /api/places/:id/visit                       â”‚
â”‚                                                                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚ POST /api/places/:id/visit
                         â”‚ { placeId, metadata, signature }
                         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  BACKEND (Node.js/Express)                                      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                                  â”‚
â”‚  1. placeVisitRoutes.js                                        â”‚
â”‚     â””â”€ POST /:id/visit â†’ validateVisit() â†’ checkAchievements()â”‚
â”‚                                                                  â”‚
â”‚  2. Anti-Cheat Validation                                       â”‚
â”‚     âœ“ GPS accuracy check (< 30m)                              â”‚
â”‚     âœ“ Geofencing (< 200m from place)                          â”‚
â”‚     âœ“ Heading validation (facing place)                        â”‚
â”‚     âœ“ Photo EXIF validation                                    â”‚
â”‚     âœ“ Device fingerprinting (spoof detection)                  â”‚
â”‚     âœ“ Speed validation (distance vs time)                      â”‚
â”‚     âœ“ Request signature verification (replay attack)           â”‚
â”‚                                                                  â”‚
â”‚  3. Database (MongoDB)                                          â”‚
â”‚     â””â”€ PlaceVisit model (stores metadata + validation)         â”‚
â”‚     â””â”€ PlaceAchievement model (user achievements)             â”‚
â”‚     â””â”€ Updates Place.stats.visitCount                          â”‚
â”‚                                                                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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
node backend/scripts/seed/seed-places.js
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
3. **Heading Check**: User must face towards place (Â±45Â°)
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
| temples | Temple Explorer | 10 | ðŸ•‰ï¸ | 100 pts |
| beaches | Beach Bum | 10 | ðŸ–ï¸ | 100 pts |
| mountains | Mountain Climber | 10 | â›°ï¸ | 100 pts |
| historical | Historic Hunter | 10 | ðŸ›ï¸ | 100 pts |
| wildlife | Wildlife Watcher | 10 | ðŸ¦ | 100 pts |
| all_districts | All Districts Explorer | 25 | ðŸ—ºï¸ | 500 pts |
| visit_count | Legendary Traveler | 50 | ðŸ‘‘ | 300 pts |
| photos | Photo Collector | 10 | ðŸ“· | 100 pts |
| streak | On a Roll | 7 | ðŸ”¥ | 200 pts |

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
   - Within 30m â†’ Should pass âœ…
   - Beyond 30m â†’ Should fail âŒ

2. **Geofence**:
   - Within 200m of place â†’ Should pass âœ…
   - Beyond 200m â†’ Should fail âŒ

3. **Rate Limit**:
   - First visit â†’ Should pass âœ…
   - Second visit within 1h â†’ Should fail âŒ

4. **Spoofing Detection**:
   - Normal device â†’ Should pass âœ…
   - With FakeGPS app â†’ Should fail âŒ

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

âœ… **DO:**
- âœ… Verify signatures server-side
- âœ… Use HTTPS only in production
- âœ… Rate limit API endpoints
- âœ… Log all suspicious visits
- âœ… Use server timestamps (never trust client time)
- âœ… Validate all metadata on backend

âŒ **DON'T:**
- âŒ Trust client-side timestamps
- âŒ Allow multiple visits in same location instantly
- âŒ Disable geofence checks
- âŒ Store unvalidated GPS coordinates
- âŒ Use weak request signatures
- âŒ Accept visits from spoofing devices

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

