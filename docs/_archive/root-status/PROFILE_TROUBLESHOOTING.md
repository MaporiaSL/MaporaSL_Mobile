# Profile Loading Troubleshooting Guide

If you're seeing "Profile not found" error, follow these steps to diagnose and fix the issue.

## Step 1: Check Authentication Status

1. Open the app
2. Go to Profile screen
3. Tap the **Debug (?)** button in top-right
4. Check **Firebase User** field:
   - If it shows a UID → User is authenticated ✅
   - If it shows "NULL" → User is NOT logged in ❌

### Fix: If User NOT Logged In
- Go back and ensure you've logged in through the Auth/Login screen first
- Check app logs: `flutter logs | grep -i auth`

---

## Step 2: Verify Backend is Running

1. Open terminal in `backend/` folder
2. Verify MongoDB is running (MongoDB Atlas or local)
3. Start Node.js server:
   ```bash
   npm start
   ```
4. You should see: `Server running on port 5000`

### Fix: If Backend Not Running
- Install dependencies: `npm install`
- Start server: `npm start`
- Check for MongoDB connection errors in console logs

---

## Step 3: Check Database Connection

In backend terminal, you should see:
```
MongoDB connected successfully
Server running on port 5000
```

If you see MongoDB connection error:
1. Ensure MongoDB Atlas cluster is active (or local MongoDB is running)
2. Check connection string in `.env` file
3. Verify database name is correct

---

## Step 4: Verify User Record Exists in Database

The backend API expects a user record in MongoDB's `users` collection.

### Check if User Exists:

**Using MongoDB Compass or MongoDB Atlas Dashboard:**
1. Go to Clusters → Browse Collections
2. Navigate to `users` collection
3. Find a document with matching **auth0Id** or **Firebase UID**

### Fix: If User Record Not Found

Option A - Create a test user in MongoDB:
```javascript
db.users.insertOne({
  auth0Id: "your-firebase-uid-here",
  name: "Test User",
  email: "test@example.com",
  profilePicture: "",
  createdAt: new Date()
})
```

Option B - Let backend auto-create on first login:
- Modify `backend/src/routes/authRoutes.js` to create user record on first login

---

## Step 5: Check API Endpoint

Once user is logged in and backend is running:

**Test the API manually with Postman/Insomnia:**

```
GET http://localhost:5000/api/profile/{userId}

Headers:
Authorization: Bearer {firebase-id-token}
```

Expected Response (200):
```json
{
  "user": {
    "id": "firebase-uid",
    "name": "User Name",
    "email": "user@example.com",
    "avatarUrl": ""
  },
  "stats": {
    "totalSubmitted": 0,
    "approvedCount": 0,
    "approvalRate": 0
  },
  "badges": [],
  "leaderboardRank": 0,
  "impactCount": 0
}
```

If you get **404 User not found**: User record doesn't exist in database (see Step 4)

If you get **401 Unauthorized**: Firebase token is invalid or expired

---

## Step 6: Check Network Configuration

The app expects backend at: `http://10.0.2.2:5000`

### If running on Android Emulator:
- `10.0.2.2` automatically routes to host machine localhost ✅

### If running on Physical Device:
- Change API URL to your machine's IP address
- Find IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Update `mobile/lib/core/config/app_config.dart`:
  ```dart
  static const String apiBaseUrl = 'http://YOUR_IP:5000';
  ```

### If running on iOS Simulator:
- `localhost:5000` should work
- Or use your machine IP like on Android

---

## Step 7: Enable Detailed Logging

Add to `profile_providers.dart` to see detailed logs:

```bash
flutter run -v  # Verbose mode
flutter logs | grep -E "DEBUG|ERROR|profile"
```

---

## Common Error Messages & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| "User not authenticated" | Firebase user is null | Log in first via Auth screen |
| "401 Unauthorized" | Invalid/expired token | Token fetch failed, restart app |
| "User not found" | No user record in DB | Create user record in MongoDB |
| "Connection timeout" | Backend not running | Start `npm start` in backend folder |
| "Cannot reach server" | Wrong API URL | Check IP config for device type |

---

## Debug Screen Reference

When you tap the **Debug (?)** button, you'll see:

1. **Firebase User** - Your Firebase UID (should not be NULL)
2. **Firebase Email** - Your login email
3. **API Base URL** - Should be `http://10.0.2.2:5000` (or your device IP)
4. **Profile Endpoint** - Shows what API will be called

---

## Next Steps

After fixing the issue:

1. The profile should load and show your stats
2. You can add places (Place Submission feature)
3. Earn badges as your contributions get approved
4. Your rank will appear on leaderboard

**Still having issues?** Check these:
- [ ] Firebase user is authenticated (not NULL)
- [ ] Backend server is running on port 5000
- [ ] MongoDB is connected successfully
- [ ] User record exists in users collection
- [ ] API endpoint responds with 200 status
- [ ] Network URL is correct for your device type
