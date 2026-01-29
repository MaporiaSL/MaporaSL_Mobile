# MAPORIA Alternative Tech Stacks - Professional Architecture

> **For University Project Prototypes**  
> **Date**: January 1, 2026  
> **Goal**: Professional separate-services architecture with FREE tiers

---

## Why Separate Services? (Professional Approach)

```
Monolithic Backend (Supabase):
┌─────────────────┐
│   Supabase      │
├─────────────────┤
│ Auth            │
│ Database        │
│ Storage         │
│ Realtime        │
└─────────────────┘

Problems:
❌ Vendor lock-in
❌ Harder to replace components
❌ Less flexible

---

Microservices/Separated Stack:
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Auth Service │  │ Database     │  │ Storage      │
│ (Auth0/JWT)  │  │ (MongoDB)    │  │ (Firebase/S3)│
└──────────────┘  └──────────────┘  └──────────────┘

Benefits:
✅ Professional architecture
✅ Easy to replace any component
✅ Scale independently
✅ Matches real-world systems
✅ Better for learning
✅ Prepare for enterprise migration
```

---

# Option 1: RECOMMENDED - MongoDB + Custom Express API + Separate Services

## Stack Overview

```
Flutter App
    ↓
┌─────────────────────────────────────────────────┐
│         Express.js API (Node.js)                │
│         Your custom backend server              │
└───────────────┬─────────────────┬───────────────┘
                │                 │
       ┌────────┴────────┐  ┌─────┴──────────┐
       │                 │  │                │
       ↓                 ↓  ↓                ↓
    MongoDB         Firebase         Auth0/JWT
    (Database)      (Storage)        (Auth)
    Atlas           Storage
```

## Component Breakdown

### 1. **Backend API: Express.js** (FREE)

```
Why Express.js?
✅ Simple, lightweight
✅ Perfect for learning
✅ Large ecosystem
✅ Easy to deploy
✅ Great documentation
✅ Industry standard for startups
✅ Free hosting options
```

### 2. **Database: MongoDB Atlas** (FREE)

```
Free tier:
✅ 512MB storage
✅ Unlimited requests
✅ 3 replicas
✅ Auto-backup
✅ M0 cluster (always free)

Perfect for:
✅ University projects
✅ Prototypes
✅ Up to ~100k users
✅ Document-based data (flexible schema)
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
✅ 5GB storage
✅ 1GB/day download
✅ Easy CDN

Perfect for:
✅ Photos
✅ User avatars
✅ Media files
```

### 5. **Hosting Options** (FREE)

| Platform | Free Tier | Storage | Why |
|----------|-----------|---------|-----|
| **Vercel** | ✅ Yes | Unlimited | Best for Node.js |
| **Render** | ✅ Yes | Unlimited | Good alternative |
| **Railway** | ✅ Limited ($5 credit) | Sufficient | Easy migration |
| **Heroku** | ❌ Free tier removed | - | Use alternatives |
| **Google Cloud** | ✅ $300 credit | Large | Good long-term |

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
    │
    ├─ JWT Token (stored securely)
    │
    ↓
Express.js Server
    │
    ├─────────────────────┬────────────────┐
    │                     │                │
    ↓                     ↓                ↓
MongoDB         Firebase             Logic
(Visits,        (Photos,             (Validation,
 Trips,         Avatars)            Calculations)
 Users,         
 Places)
```

## Express.js Backend Structure

```
backend/
├── src/
│   ├── server.ts                    # Main entry
│   ├── config/
│   │   ├── database.ts              # MongoDB connection
│   │   ├── firebase.ts              # Firebase config
│   │   └── env.ts                   # Environment variables
│   ├── middleware/
│   │   ├── auth.ts                  # JWT verification
│   │   ├── errorHandler.ts
│   │   └── corsHandler.ts
│   ├── routes/
│   │   ├── auth.routes.ts           # /auth/register, /auth/login
│   │   ├── users.routes.ts          # /users/profile
│   │   ├── places.routes.ts         # /places
│   │   ├── visits.routes.ts         # /visits
│   │   ├── trips.routes.ts          # /trips
│   │   ├── photos.routes.ts         # /photos
│   │   └── achievements.routes.ts   # /achievements
│   ├── controllers/
│   │   ├── auth.controller.ts       # Business logic
│   │   ├── users.controller.ts
│   │   ├── places.controller.ts
│   │   ├── visits.controller.ts
│   │   ├── trips.controller.ts
│   │   └── achievements.controller.ts
│   ├── models/
│   │   ├── User.ts                  # MongoDB schemas
│   │   ├── Place.ts
│   │   ├── Visit.ts
│   │   ├── Trip.ts
│   │   ├── Achievement.ts
│   │   └── Photo.ts
│   ├── services/
│   │   ├── auth.service.ts          # Auth logic
│   │   ├── user.service.ts
│   │   ├── place.service.ts
│   │   ├── visit.service.ts
│   │   ├── firebase.service.ts      # Storage uploads
│   │   └── jwt.service.ts
│   ├── utils/
│   │   ├── validators.ts
│   │   ├── helpers.ts
│   │   └── errors.ts
│   └── types/
│       └── index.ts                 # TypeScript types
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
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
        userId,        // ← User is automatically scoped
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
Instead of custom JWT → Use Auth0

Benefits:
✅ Don't maintain auth code
✅ Social login ready
✅ Professional security
✅ MFA support

Free tier:
✅ 7,000 users
✅ 1M active users
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
    ↓
Express.js API
    ↓
┌────────────────┬────────────────┐
│                │                │
↓                ↓                ↓
Firebase         MongoDB        Custom
Auth            (if using)      Logic
```

## When to Use This

```
Use when:
✅ Want social login (Google, Facebook)
✅ Want push notifications
✅ Want analytics
✅ But also want custom backend control
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
✅ Enterprise framework
✅ TypeScript-first
✅ Dependency injection
✅ Modular architecture
✅ Professional patterns
✅ Scalable
✅ Good for portfolio
```

## Project Structure

```
backend/
├── src/
│   ├── main.ts                      # Entry point
│   ├── app.module.ts                # App module
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.module.ts
│   │   ├── jwt.strategy.ts
│   │   └── local.strategy.ts
│   ├── users/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.module.ts
│   │   ├── schemas/
│   │   │   └── user.schema.ts
│   │   └── dto/
│   │       ├── create-user.dto.ts
│   │       └── update-user.dto.ts
│   ├── places/
│   │   ├── places.controller.ts
│   │   ├── places.service.ts
│   │   ├── places.module.ts
│   │   ├── schemas/
│   │   │   └── place.schema.ts
│   │   └── dto/
│   │       ├── create-place.dto.ts
│   │       └── place-query.dto.ts
│   ├── visits/
│   │   ├── visits.controller.ts
│   │   ├── visits.service.ts
│   │   ├── visits.module.ts
│   │   └── schemas/
│   │       └── visit.schema.ts
│   ├── trips/
│   │   ├── trips.controller.ts
│   │   ├── trips.service.ts
│   │   ├── trips.module.ts
│   │   └── schemas/
│   │       └── trip.schema.ts
│   ├── common/
│   │   ├── guards/
│   │   │   └── jwt-auth.guard.ts
│   │   ├── decorators/
│   │   │   └── user.decorator.ts
│   │   └── filters/
│   │       └── http-exception.filter.ts
│   └── config/
│       ├── database.config.ts
│       ├── firebase.config.ts
│       └── env.ts
├── test/
├── package.json
└── docker-compose.yml
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
| **Learning Value** | ✅✅✅ High | ✅ Good | ✅ Good | ✅✅✅ Very High |
| **Production Ready** | ✅ Good | ✅✅ Excellent | ✅ Good | ✅✅ Excellent |
| **Time to MVP** | 1 week | 3 days | 3 days | 2 weeks |
| **Free Tier** | ✅ Good | ✅✅ Good | ✅✅ Excellent | ✅ Good |
| **Maintenance** | Medium (JWT) | Low (Auth0 handles) | Low | Medium-High |
| **Portfolio Value** | ✅✅ Good | ✅ Good | ✅ Medium | ✅✅✅ Excellent |
| **Social Login** | ❌ Need OAuth | ✅ Easy | ✅ Easy | Need OAuth |
| **Push Notifications** | ❌ Need Firebase | ⚠️ Can integrate | ✅ Built-in | Need Firebase |
| **Real-time** | ❌ Manual setup | ⚠️ Manual setup | ✅ Firebase Realtime | ❌ Manual setup |

---

# My RECOMMENDATION for University Project

## **Option 1A: Express.js + MongoDB + Custom JWT Auth**

### Why?

```
✅ Best learning experience
  - Understand authentication end-to-end
  - Learn backend fundamentals
  - Understand JWT tokens
  - Great for examiners to see

✅ Professional architecture
  - Separate concerns
  - Scalable design
  - Portfolio-worthy

✅ Free forever
  - No service costs
  - Can migrate later
  - MongoDB free tier sufficient

✅ Fast implementation
  - Start in 1 week
  - Straightforward flow
  - Can focus on features

✅ Easy to explain in presentation
  - Show JWT flow
  - Explain data isolation
  - Demonstrate separate services
```

## Why NOT Others?

```
Option 1B (Auth0):
❌ Less learning (Auth0 handles auth)
❌ Less to explain in university presentation

Option 2 (Firebase):
❌ Vendor lock-in (Firebase)
❌ Less control
❌ Not as "professional looking"

Option 3 (Nest.js):
⚠️ Too complex for MVP
⚠️ Takes more time
✅ Good if you have 3+ months
```

---

# Stack Recommendation: Express.js + MongoDB

```
┌────────────────────────────────────────────────┐
│        MAPORIA - University Project            │
├────────────────────────────────────────────────┤
│                                                │
│  Frontend:                                     │
│  └─ Flutter (Dart) - already planned          │
│                                                │
│  Backend:                                      │
│  ├─ Node.js + Express.js                      │
│  ├─ TypeScript (optional but recommended)     │
│  └─ Custom JWT authentication                 │
│                                                │
│  Database:                                     │
│  ├─ MongoDB Atlas (free M0 cluster)           │
│  ├─ Mongoose ORM                              │
│  └─ Indexes for performance                   │
│                                                │
│  Storage:                                      │
│  ├─ Firebase Storage (user photos)            │
│  └─ Cloudinary free tier (alternative)        │
│                                                │
│  Notifications:                                │
│  └─ Firebase Cloud Messaging                  │
│                                                │
│  Hosting:                                      │
│  ├─ Vercel (free)                             │
│  └─ MongoDB Atlas (free)                      │
│                                                │
│  Cost: $0/month (for prototype)                │
│                                                │
└────────────────────────────────────────────────┘
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
├─ Create Express project
├─ Setup MongoDB
├─ Create JWT auth
└─ Test with Postman

Week 2: Flutter Integration
├─ Update Flutter to call your API
├─ Test login/register
└─ Implement data isolation

Week 3+: Features
├─ Places API
├─ Visits API
├─ Trips API
└─ Photos integration
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

**Which option interests you most?** I can create a detailed setup guide for the one you choose! 🚀
