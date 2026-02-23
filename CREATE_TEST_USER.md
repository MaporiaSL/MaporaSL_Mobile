# Quick Start: Create Test User in MongoDB

Use this guide to create a test user for development/testing without Firebase Auth.

## Option A: MongoDB Compass (GUI - Easiest)

1. **Open MongoDB Compass**
2. Connect to your MongoDB instance
3. Navigate to: `database_name` → `users` collection
4. Click **Insert Document** (green `+` button)
5. Replace the template with:

```json
{
  "_id": { "$oid": "507f1f77bcf86cd799439011" },
  "auth0Id": "test-user-123",
  "name": "Test User",
  "email": "test@example.com",
  "profilePicture": "",
  "createdAt": new Date()
}
```

6. Click **Insert**

---

## Option B: MongoDB Atlas Dashboard

1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Click your cluster → **Browse Collections**
3. Select your database → `users` collection
4. Click **Insert Document**
5. Paste the JSON above
6. Click **Insert**

---

## Option C: MongoDB CLI / Command Line

```bash
mongosh "your-connection-string"
use your_database_name
db.users.insertOne({
  auth0Id: "test-user-123",
  name: "Test User",
  email: "test@example.com", 
  profilePicture: "",
  createdAt: new Date()
})
```

Expected output:
```
{ acknowledged: true, insertedId: ObjectId(...) }
```

---

## Verify User Was Created

1. Open ProfileScreen in app
2. You should see: "Test User" with email "test@example.com"
3. Stats will show: 0 submitted, 0 approved, 0% approval rate

---

## Before Production

⚠️ **IMPORTANT**: Remove this test fallback before deploying!

In `profile_providers.dart`, change back to:
```dart
return userId;  // Not the fallback
```

This ensures only authenticated users can access profiles in production.
