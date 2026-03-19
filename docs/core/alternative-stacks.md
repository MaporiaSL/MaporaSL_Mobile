# MAPORIA Alternative Tech Stacks - Professional Architecture

> **For University Project Prototypes**  
> **Date**: January 1, 2026  
> **Goal**: Professional separate-services architecture with FREE tiers

---

## Why Separate Services? (Professional Approach)

```
Monolithic Backend (Supabase):
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   Supabase      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Auth            â”‚
â”‚ Database        â”‚
â”‚ Storage         â”‚
â”‚ Realtime        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Problems:
âŒ Vendor lock-in
âŒ Harder to replace components
âŒ Less flexible

---

Microservices/Separated Stack:
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Auth Service â”‚  â”‚ Database     â”‚  â”‚ Storage      â”‚
â”‚ (Auth0/JWT)  â”‚  â”‚ (MongoDB)    â”‚  â”‚ (Firebase/S3)â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Benefits:
âœ… Professional architecture
âœ… Easy to replace any component
âœ… Scale independently
âœ… Matches real-world systems
âœ… Better for learning
âœ… Prepare for enterprise migration
```

---

# Option 1: RECOMMENDED - MongoDB + Custom Express API + Separate Services

## Stack Overview

```
Flutter App
    â†“
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         Express.js API (Node.js)                â”‚
â”‚         Your custom backend server              â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                â”‚                 â”‚
       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
       â”‚                 â”‚  â”‚                â”‚
       â†“                 â†“  â†“                â†“
    MongoDB         Firebase         Auth0/JWT
    (Database)      (Storage)        (Auth)
    Atlas           Storage
```

## Component Breakdown

### 1. **Backend API: Express.js** (FREE)

```
Why Express.js?
âœ… Simple, lightweight
âœ… Perfect for learning
âœ… Large ecosystem
âœ… Easy to deploy
âœ… Great documentation
âœ… Industry standard for startups
âœ… Free hosting options
```

### 2. **Database: MongoDB Atlas** (FREE)

```
Free tier:
âœ… 512MB storage
âœ… Unlimited requests
âœ… 3 replicas
âœ… Auto-backup
âœ… M0 cluster (always free)

Perfect for:
âœ… University projects
âœ… Prototypes
âœ… Up to ~100k users
âœ… Document-based data (flexible schema)
```

### 3. **Authentication: Multiple Options**

| Option | Cost | Setup | Best For |
|--------|------|-------|----------|
| **Custom JWT** | FREE | Medium (1 hour) | Learning (understand auth) |
| **Auth0** | FREE tier | Easy (30 mins) | Production-ready |
| **Firebase Auth** | FREE | Easy (30 mins) | Quickest setup |
| **Passport.js** | FREE | Medium (1 hour) | Express integration |

### 4. **Storage: Firebase Storage** (FREE)

```
Free tier:
âœ… 5GB storage
âœ… 1GB/day download
âœ… Easy CDN

Perfect for:
âœ… Photos
âœ… User avatars
âœ… Media files
```

### 5. **Hosting Options** (FREE)

| Platform | Free Tier | Storage | Why |
|----------|-----------|---------|-----|
| **Vercel** | âœ… Yes | Unlimited | Best for Node.js |
| **Render** | âœ… Yes | Unlimited | Good alternative |
| **Railway** | âœ… Limited ($5 credit) | Sufficient | Easy migration |
| **Heroku** | âŒ Free tier removed | - | Use alternatives |
| **Google Cloud** | âœ… $300 credit | Large | Good long-term |

---

# Option 1A: Express.js + MongoDB + Custom JWT Auth

## Full Stack Breakdown

```
Frontend:  Flutter (Dart)
Backend:   Node.js + Express.js
Database:  MongoDB Atlas
Auth:      Custom JWT (you control)
Storage:   Firebase Storage
Hosting:   Vercel (free) or Railway
```

## Architecture Diagram

```
Mobile App (Flutter)
    â”‚
    â”œâ”€ JWT Token (stored securely)
    â”‚
    â†“
Express.js Server
    â”‚
    â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
    â”‚                     â”‚                â”‚
    â†“                     â†“                â†“
MongoDB         Firebase             Logic
(Visits,        (Photos,             (Validation,
 Trips,         Avatars)            Calculations)
 Users,         
 Places)
```

## Express.js Backend Structure

```
backend/
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ server.ts                    # Main entry
â”‚   â”œâ”€â”€ config/
â”‚   â”‚   â”œâ”€â”€ database.ts              # MongoDB connection
â”‚   â”‚   â”œâ”€â”€ firebase.ts              # Firebase config
â”‚   â”‚   â””â”€â”€ env.ts                   # Environment variables
â”‚   â”œâ”€â”€ middleware/
â”‚   â”‚   â”œâ”€â”€ auth.ts                  # JWT verification
â”‚   â”‚   â”œâ”€â”€ errorHandler.ts
â”‚   â”‚   â””â”€â”€ corsHandler.ts
â”‚   â”œâ”€â”€ routes/
â”‚   â”‚   â”œâ”€â”€ auth.routes.ts           # /auth/register, /auth/login
â”‚   â”‚   â”œâ”€â”€ users.routes.ts          # /users/profile
â”‚   â”‚   â”œâ”€â”€ places.routes.ts         # /places
â”‚   â”‚   â”œâ”€â”€ visits.routes.ts         # /visits
â”‚   â”‚   â”œâ”€â”€ trips.routes.ts          # /trips
â”‚   â”‚   â”œâ”€â”€ photos.routes.ts         # /photos
â”‚   â”‚   â””â”€â”€ achievements.routes.ts   # /achievements
â”‚   â”œâ”€â”€ controllers/
â”‚   â”‚   â”œâ”€â”€ auth.controller.ts       # Business logic
â”‚   â”‚   â”œâ”€â”€ users.controller.ts
â”‚   â”‚   â”œâ”€â”€ places.controller.ts
â”‚   â”‚   â”œâ”€â”€ visits.controller.ts
â”‚   â”‚   â”œâ”€â”€ trips.controller.ts
â”‚   â”‚   â””â”€â”€ achievements.controller.ts
â”‚   â”œâ”€â”€ models/
â”‚   â”‚   â”œâ”€â”€ User.ts                  # MongoDB schemas
â”‚   â”‚   â”œâ”€â”€ Place.ts
â”‚   â”‚   â”œâ”€â”€ Visit.ts
â”‚   â”‚   â”œâ”€â”€ Trip.ts
â”‚   â”‚   â”œâ”€â”€ Achievement.ts
â”‚   â”‚   â””â”€â”€ Photo.ts
â”‚   â”œâ”€â”€ services/
â”‚   â”‚   â”œâ”€â”€ auth.service.ts          # Auth logic
â”‚   â”‚   â”œâ”€â”€ user.service.ts
â”‚   â”‚   â”œâ”€â”€ place.service.ts
â”‚   â”‚   â”œâ”€â”€ visit.service.ts
â”‚   â”‚   â”œâ”€â”€ firebase.service.ts      # Storage uploads
â”‚   â”‚   â””â”€â”€ jwt.service.ts
â”‚   â”œâ”€â”€ utils/
â”‚   â”‚   â”œâ”€â”€ validators.ts
â”‚   â”‚   â”œâ”€â”€ helpers.ts
â”‚   â”‚   â””â”€â”€ errors.ts
â”‚   â””â”€â”€ types/
â”‚       â””â”€â”€ index.ts                 # TypeScript types
â”œâ”€â”€ package.json
â”œâ”€â”€ tsconfig.json
â”œâ”€â”€ .env.example
â””â”€â”€ README.md
```

## Example: Express Auth Endpoint (Custom JWT)

```typescript
// backend/src/routes/auth.routes.ts
import express from 'express';
import { AuthController } from '../controllers/auth.controller';

const router = express.Router();
const authController = new AuthController();

// POST /api/auth/register
router.post('/register', (req, res) => authController.register(req, res));

// POST /api/auth/login
router.post('/login', (req, res) => authController.login(req, res));

// POST /api/auth/logout
router.post('/logout', (req, res) => authController.logout(req, res));

export default router;
```

```typescript
// backend/src/controllers/auth.controller.ts
import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import { User } from '../models/User';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export class AuthController {
  private authService: AuthService;

  constructor() {
    this.authService = new AuthService();
  }

  async register(req: Request, res: Response) {
    try {
      const { email, password, name } = req.body;

      // Validation
      if (!email || !password || !name) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      // Check if user exists
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(409).json({ error: 'Email already registered' });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Create user
      const user = new User({
        email,
        password: hashedPassword,
        name,
        createdAt: new Date(),
      });

      await user.save();

      // Generate JWT token
      const token = jwt.sign(
        { userId: user._id, email: user.email },
        process.env.JWT_SECRET!,
        { expiresIn: '7d' }
      );

      return res.status(201).json({
        message: 'User registered successfully',
        token,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
        },
      });
    } catch (error) {
      return res.status(500).json({ error: 'Registration failed' });
    }
  }

  async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      // Validation
      if (!email || !password) {
        return res.status(400).json({ error: 'Missing email or password' });
      }

      // Find user
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Verify password
      const passwordMatch = await bcrypt.compare(password, user.password);
      if (!passwordMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Generate JWT token
      const token = jwt.sign(
        { userId: user._id, email: user.email },
        process.env.JWT_SECRET!,
        { expiresIn: '7d' }
      );

      return res.status(200).json({
        message: 'Login successful',
        token,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
        },
      });
    } catch (error) {
      return res.status(500).json({ error: 'Login failed' });
    }
  }
}
```

## Flutter Implementation

```dart
// lib/data/repositories/auth_repository.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final String baseUrl = 'https://your-api.vercel.app/api';
  final storage = const FlutterSecureStorage();

  // Register
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      
      // Save token securely
      await storage.write(key: 'jwt_token', value: token);
      
      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'error': 'Registration failed'};
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      
      // Save token securely
      await storage.write(key: 'jwt_token', value: token);
      
      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'error': 'Login failed'};
    }
  }

  // Get token for authenticated requests
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Logout
  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}

// Usage in API calls
class PlacesRepository {
  final String baseUrl = 'https://your-api.vercel.app/api';
  final AuthRepository authRepository = AuthRepository();

  Future<List<Place>> getPlaces() async {
    final token = await authRepository.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/places'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Place.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }
}
```

## JWT Middleware

```typescript
// backend/src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface AuthRequest extends Request {
  userId?: string;
}

export function authMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing token' });
    }

    const token = authHeader.substring(7);

    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.userId = (decoded as any).userId;

    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

## Data Isolation (Backend)

```typescript
// backend/src/controllers/visits.controller.ts
import { Request, Response } from 'express';
import { Visit } from '../models/Visit';

interface AuthRequest extends Request {
  userId?: string;
}

export class VisitsController {
  // Get user's own visits only
  async getUserVisits(req: AuthRequest, res: Response) {
    try {
      const userId = req.userId; // From JWT
      
      // Query only this user's visits
      const visits = await Visit.find({ userId }).sort({ visitedAt: -1 });
      
      return res.json(visits);
    } catch (error) {
      return res.status(500).json({ error: 'Failed to fetch visits' });
    }
  }

  // Record visit for current user
  async recordVisit(req: AuthRequest, res: Response) {
    try {
      const userId = req.userId;
      const { placeId } = req.body;

      // Verify place exists
      const place = await Place.findById(placeId);
      if (!place) {
        return res.status(404).json({ error: 'Place not found' });
      }

      // Check GPS distance
      const userGPS = req.body.gps; // {lat, lng}
      const distance = calculateDistance(
        userGPS.lat, 
        userGPS.lng, 
        place.location.lat, 
        place.location.lng
      );

      if (distance > 100) { // 100 meters
        return res.status(400).json({ error: 'Too far from place' });
      }

      // Create visit (automatically scoped to userId)
      const visit = new Visit({
        userId,        // â† User is automatically scoped
        placeId,
        visitedAt: new Date(),
      });

      await visit.save();

      return res.json({ success: true, visit });
    } catch (error) {
      return res.status(500).json({ error: 'Failed to record visit' });
    }
  }
}
```

---

# Option 1B: Express.js + MongoDB + Auth0

## Same as Option 1A but with Auth0 for authentication

```
Difference:
Instead of custom JWT â†’ Use Auth0

Benefits:
âœ… Don't maintain auth code
âœ… Social login ready
âœ… Professional security
âœ… MFA support

Free tier:
âœ… 7,000 users
âœ… 1M active users
```

## Setup

```typescript
// backend/src/middleware/auth0.ts
import { auth } from 'express-oauth2-jwt-bearer';

export const checkJwt = auth({
  audience: 'your-api-identifier',
  issuerBaseURL: `https://${process.env.AUTH0_DOMAIN}`,
});

// Use in routes
app.use('/api/protected', checkJwt);
```

## Flutter Implementation

```dart
// lib/core/services/auth0_service.dart
import 'package:flutter_appauth/flutter_appauth.dart';

class Auth0Service {
  final _appAuth = FlutterAppAuth();

  Future<void> login() async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        'YOUR_AUTH0_CLIENT_ID',
        'YOUR_AUTH0_DOMAIN/authorize',
        redirectUrl: 'com.example.maporia://login-callback',
        discoveryUrl: 'https://YOUR_AUTH0_DOMAIN/.well-known/openid-configuration',
        scopes: ['openid', 'profile', 'email'],
      ),
    );

    if (result != null) {
      // Save token
      final token = result.accessToken;
      // Use token in API calls
    }
  }
}
```

---

# Option 2: Firebase Backend + Express.js Custom API

## Hybrid Approach

```
Flutter App
    â†“
Express.js API
    â†“
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                â”‚                â”‚
â†“                â†“                â†“
Firebase         MongoDB        Custom
Auth            (if using)      Logic
```

## When to Use This

```
Use when:
âœ… Want social login (Google, Facebook)
âœ… Want push notifications
âœ… Want analytics
âœ… But also want custom backend control
```

## Setup

```typescript
// backend/src/config/firebase.ts
import admin from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
  storageBucket: 'your-project.appspot.com',
});

export const auth = admin.auth();
export const storage = admin.storage();
export const db = admin.firestore();
```

```typescript
// backend/src/middleware/firebase-auth.ts
import { Request, Response, NextFunction } from 'express';
import { auth } from '../config/firebase';

interface AuthRequest extends Request {
  user?: admin.auth.DecodedIdToken;
}

export async function firebaseAuthMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) {
      return res.status(401).json({ error: 'Missing token' });
    }

    const decodedToken = await auth.verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

---

# Option 3: Nest.js + MongoDB + Separate Services (Professional Grade)

## For Learning Enterprise Architecture

```
Why Nest.js?
âœ… Enterprise framework
âœ… TypeScript-first
âœ… Dependency injection
âœ… Modular architecture
âœ… Professional patterns
âœ… Scalable
âœ… Good for portfolio
```

## Project Structure

```
backend/
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ main.ts                      # Entry point
â”‚   â”œâ”€â”€ app.module.ts                # App module
â”‚   â”œâ”€â”€ auth/
â”‚   â”‚   â”œâ”€â”€ auth.controller.ts
â”‚   â”‚   â”œâ”€â”€ auth.service.ts
â”‚   â”‚   â”œâ”€â”€ auth.module.ts
â”‚   â”‚   â”œâ”€â”€ jwt.strategy.ts
â”‚   â”‚   â””â”€â”€ local.strategy.ts
â”‚   â”œâ”€â”€ users/
â”‚   â”‚   â”œâ”€â”€ users.controller.ts
â”‚   â”‚   â”œâ”€â”€ users.service.ts
â”‚   â”‚   â”œâ”€â”€ users.module.ts
â”‚   â”‚   â”œâ”€â”€ schemas/
â”‚   â”‚   â”‚   â””â”€â”€ user.schema.ts
â”‚   â”‚   â””â”€â”€ dto/
â”‚   â”‚       â”œâ”€â”€ create-user.dto.ts
â”‚   â”‚       â””â”€â”€ update-user.dto.ts
â”‚   â”œâ”€â”€ places/
â”‚   â”‚   â”œâ”€â”€ places.controller.ts
â”‚   â”‚   â”œâ”€â”€ places.service.ts
â”‚   â”‚   â”œâ”€â”€ places.module.ts
â”‚   â”‚   â”œâ”€â”€ schemas/
â”‚   â”‚   â”‚   â””â”€â”€ place.schema.ts
â”‚   â”‚   â””â”€â”€ dto/
â”‚   â”‚       â”œâ”€â”€ create-place.dto.ts
â”‚   â”‚       â””â”€â”€ place-query.dto.ts
â”‚   â”œâ”€â”€ visits/
â”‚   â”‚   â”œâ”€â”€ visits.controller.ts
â”‚   â”‚   â”œâ”€â”€ visits.service.ts
â”‚   â”‚   â”œâ”€â”€ visits.module.ts
â”‚   â”‚   â””â”€â”€ schemas/
â”‚   â”‚       â””â”€â”€ visit.schema.ts
â”‚   â”œâ”€â”€ trips/
â”‚   â”‚   â”œâ”€â”€ trips.controller.ts
â”‚   â”‚   â”œâ”€â”€ trips.service.ts
â”‚   â”‚   â”œâ”€â”€ trips.module.ts
â”‚   â”‚   â””â”€â”€ schemas/
â”‚   â”‚       â””â”€â”€ trip.schema.ts
â”‚   â”œâ”€â”€ common/
â”‚   â”‚   â”œâ”€â”€ guards/
â”‚   â”‚   â”‚   â””â”€â”€ jwt-auth.guard.ts
â”‚   â”‚   â”œâ”€â”€ decorators/
â”‚   â”‚   â”‚   â””â”€â”€ user.decorator.ts
â”‚   â”‚   â””â”€â”€ filters/
â”‚   â”‚       â””â”€â”€ http-exception.filter.ts
â”‚   â””â”€â”€ config/
â”‚       â”œâ”€â”€ database.config.ts
â”‚       â”œâ”€â”€ firebase.config.ts
â”‚       â””â”€â”€ env.ts
â”œâ”€â”€ test/
â”œâ”€â”€ package.json
â””â”€â”€ docker-compose.yml
```

## Nest.js Example

```typescript
// backend/src/auth/auth.service.ts
import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(email: string, password: string, name: string) {
    // Check if user exists
    const existingUser = await this.usersService.findByEmail(email);
    if (existingUser) {
      throw new Error('User already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await this.usersService.create({
      email,
      password: hashedPassword,
      name,
    });

    // Generate JWT
    const token = this.jwtService.sign({
      sub: user._id,
      email: user.email,
    });

    return { token, user };
  }

  async login(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new Error('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      throw new Error('Invalid credentials');
    }

    const token = this.jwtService.sign({
      sub: user._id,
      email: user.email,
    });

    return { token, user };
  }
}
```

```typescript
// backend/src/auth/auth.controller.ts
import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('api/auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  register(@Body() dto: { email: string; password: string; name: string }) {
    return this.authService.register(dto.email, dto.password, dto.name);
  }

  @Post('login')
  login(@Body() dto: { email: string; password: string }) {
    return this.authService.login(dto.email, dto.password);
  }
}
```

```typescript
// backend/src/visits/visits.controller.ts
import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../common/decorators/user.decorator';
import { VisitsService } from './visits.service';

@Controller('api/visits')
export class VisitsController {
  constructor(private visitsService: VisitsService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  getUserVisits(@User() user: any) {
    // Only gets current user's visits
    return this.visitsService.getUserVisits(user.sub);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  recordVisit(@User() user: any, @Body() dto: { placeId: string; gps: any }) {
    // Records visit for current user only
    return this.visitsService.recordVisit(user.sub, dto.placeId, dto.gps);
  }
}
```

---

# Comparison: All Options

| Factor | Option 1A (Express + Custom JWT) | Option 1B (Express + Auth0) | Option 2 (Firebase + Express) | Option 3 (Nest.js) |
|--------|--------------------------------|----------------------------|-------------------------------|------------------|
| **Complexity** | Easy | Easy | Medium | Hard |
| **Learning Value** | âœ…âœ…âœ… High | âœ… Good | âœ… Good | âœ…âœ…âœ… Very High |
| **Production Ready** | âœ… Good | âœ…âœ… Excellent | âœ… Good | âœ…âœ… Excellent |
| **Time to MVP** | 1 week | 3 days | 3 days | 2 weeks |
| **Free Tier** | âœ… Good | âœ…âœ… Good | âœ…âœ… Excellent | âœ… Good |
| **Maintenance** | Medium (JWT) | Low (Auth0 handles) | Low | Medium-High |
| **Portfolio Value** | âœ…âœ… Good | âœ… Good | âœ… Medium | âœ…âœ…âœ… Excellent |
| **Social Login** | âŒ Need OAuth | âœ… Easy | âœ… Easy | Need OAuth |
| **Push Notifications** | âŒ Need Firebase | âš ï¸ Can integrate | âœ… Built-in | Need Firebase |
| **Real-time** | âŒ Manual setup | âš ï¸ Manual setup | âœ… Firebase Realtime | âŒ Manual setup |

---

# My RECOMMENDATION for University Project

## **Option 1A: Express.js + MongoDB + Custom JWT Auth**

### Why?

```
âœ… Best learning experience
  - Understand authentication end-to-end
  - Learn backend fundamentals
  - Understand JWT tokens
  - Great for examiners to see

âœ… Professional architecture
  - Separate concerns
  - Scalable design
  - Portfolio-worthy

âœ… Free forever
  - No service costs
  - Can migrate later
  - MongoDB free tier sufficient

âœ… Fast implementation
  - Start in 1 week
  - Straightforward flow
  - Can focus on features

âœ… Easy to explain in presentation
  - Show JWT flow
  - Explain data isolation
  - Demonstrate separate services
```

## Why NOT Others?

```
Option 1B (Auth0):
âŒ Less learning (Auth0 handles auth)
âŒ Less to explain in university presentation

Option 2 (Firebase):
âŒ Vendor lock-in (Firebase)
âŒ Less control
âŒ Not as "professional looking"

Option 3 (Nest.js):
âš ï¸ Too complex for MVP
âš ï¸ Takes more time
âœ… Good if you have 3+ months
```

---

# Stack Recommendation: Express.js + MongoDB

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚        MAPORIA - University Project            â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                â”‚
â”‚  Frontend:                                     â”‚
â”‚  â””â”€ Flutter (Dart) - already planned          â”‚
â”‚                                                â”‚
â”‚  Backend:                                      â”‚
â”‚  â”œâ”€ Node.js + Express.js                      â”‚
â”‚  â”œâ”€ TypeScript (optional but recommended)     â”‚
â”‚  â””â”€ Custom JWT authentication                 â”‚
â”‚                                                â”‚
â”‚  Database:                                     â”‚
â”‚  â”œâ”€ MongoDB Atlas (free M0 cluster)           â”‚
â”‚  â”œâ”€ Mongoose ORM                              â”‚
â”‚  â””â”€ Indexes for performance                   â”‚
â”‚                                                â”‚
â”‚  Storage:                                      â”‚
â”‚  â”œâ”€ Firebase Storage (user photos)            â”‚
â”‚  â””â”€ Cloudinary free tier (alternative)        â”‚
â”‚                                                â”‚
â”‚  Notifications:                                â”‚
â”‚  â””â”€ Firebase Cloud Messaging                  â”‚
â”‚                                                â”‚
â”‚  Hosting:                                      â”‚
â”‚  â”œâ”€ Vercel (free)                             â”‚
â”‚  â””â”€ MongoDB Atlas (free)                      â”‚
â”‚                                                â”‚
â”‚  Cost: $0/month (for prototype)                â”‚
â”‚                                                â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

# Quick Start: Express + MongoDB

## 1. Install Node.js
```bash
# Download from https://nodejs.org
node --version  # Verify
```

## 2. Create Express Backend

```bash
mkdir backend
cd backend
npm init -y
npm install express mongoose bcrypt jsonwebtoken dotenv cors
npm install -D typescript @types/node ts-node
npx tsc --init
```

## 3. Create MongoDB Account

```bash
# https://mongodb.com/cloud/atlas
# 1. Sign up free
# 2. Create free cluster (M0)
# 3. Get connection string
```

## 4. Basic Server

```typescript
// backend/src/server.ts
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Connect MongoDB
mongoose.connect(process.env.MONGODB_URI!)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB error:', err));

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## 5. Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Login and deploy
vercel
```

---

# Setup Roadmap

```
Week 1: Backend Setup
â”œâ”€ Create Express project
â”œâ”€ Setup MongoDB
â”œâ”€ Create JWT auth
â””â”€ Test with Postman

Week 2: Flutter Integration
â”œâ”€ Update Flutter to call your API
â”œâ”€ Test login/register
â””â”€ Implement data isolation

Week 3+: Features
â”œâ”€ Places API
â”œâ”€ Visits API
â”œâ”€ Trips API
â””â”€ Photos integration
```

---

# Next Steps

1. **Choose your option** (I recommend Option 1A)
2. **Setup local environment**
   - Install Node.js
   - Create MongoDB account
3. **Create basic Express server**
4. **Test with Postman**
5. **Integrate Flutter app**

---

**Which option interests you most?** I can create a detailed setup guide for the one you choose! ðŸš€

