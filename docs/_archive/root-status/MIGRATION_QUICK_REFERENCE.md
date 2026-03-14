# Database Migration Quick Reference

## What Changed?

The **Exploration feature** no longer loads location data from mobile assets. It now exclusively uses the backend MongoDB database.

### Before ❌
```dart
// Mobile app would load this as fallback:
assets/data/places_seed_data_2026.json → JSON parsing → UI
```

### After ✅
```dart
// Mobile app now only calls backend:
ExplorationApi → GET /api/exploration/assignments → MongoDB → UI
```

## For Developers

### Running Locally

1. **Seed the database (first time only):**
   ```bash
   cd backend
   node seed-unlock-locations.js
   ```

2. **Start backend server:**
   ```bash
   npm start
   # or npm run dev
   ```

3. **Run mobile app:**
   ```bash
   flutter run
   ```

### Testing Exploration Feature

1. Launch app → Onboarding
2. Select hometown district
3. Backend creates assignments from real UnlockLocation data
4. Exploration screen shows real locations with GPS coordinates
5. Try to visit a location (will check GPS)

### Debugging

If exploration screen shows "Failed to load exploration data":

1. Check backend is running: `curl http://localhost:5000/api/health`
2. Verify JWT token is valid (check mobile auth)
3. Ensure MongoDB has UnlockLocation data:
   ```bash
   # In MongoDB shell:
   use gemified_travel
   db.unlocklocation.countDocuments()  # Should be ~200
   ```

### API Endpoints (All JWT Protected)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/exploration/assignments` | User's assigned locations |
| GET | `/api/exploration/districts` | District summary |
| POST | `/api/exploration/visit` | Record location visit |
| POST | `/api/exploration/reroll` | Request new assignments |
| POST | `/api/admin/unlock-locations/seed` | Admin: seed locations |

### Data Models

**UnlockLocation (MongoDB)**
```javascript
{
  _id: ObjectId,
  district: "Colombo",
  province: "Western", 
  name: "Gangaramaya Temple",
  type: "Buddhist Temple",
  latitude: 6.9148,
  longitude: 79.8577,
  isActive: true,
  createdAt: Date,
  updatedAt: Date
}
```

**UserDistrictAssignment (MongoDB)**
```javascript
{
  _id: ObjectId,
  userId: "auth0|12345",
  district: "Colombo",
  province: "Western",
  assignedLocationIds: [ObjectId, ObjectId, ...],
  visitedLocationIds: [ObjectId, ...],
  assignedCount: 7,
  visitedCount: 2,
  unlockedAt: Date | null
}
```

## Files Changed

| File | Changes |
|------|---------|
| `mobile/lib/features/exploration/providers/exploration_provider.dart` | Removed dev seed fallback |
| `backend/seed-unlock-locations.js` | NEW - Database seeding script |

## Removed Code

These methods no longer exist (were dev-only):
- `ExplorationNotifier._loadDevAssignmentsFromAsset()`
- `ExplorationNotifier._buildDevDistricts()`
- `ExplorationNotifier._markVisitedLocally()`

The feature now depends entirely on working backend API.

## Common Issues & Solutions

### Issue: "Unlock location catalog is empty"
**Solution:** Run `node seed-unlock-locations.js` in backend directory

### Issue: Exploration screen shows blank
**Solution:** Check mobile API URL in `.env`:
```
API_URL=http://10.0.2.2:5000/api  # Android emulator local backend
API_URL=http://localhost:5000/api  # Physical device with USB forward
```

### Issue: "Failed to load exploration data"
**Solution:** Backend likely down or JWT invalid. Check:
```bash
# Backend logs
tail -f backend.log | grep "exploration\|error"

# API reachability
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:5000/api/exploration/assignments
```

## Next Steps

All other features (Trips, Shop, Album, Profile) already use real database. Exploration now matches this architecture.

System is now **production-ready** with all data backed by MongoDB.
