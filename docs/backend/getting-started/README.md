# Backend - Getting Started

**New to the backend? Start here!**

---

## 📚 Quick Links

- [Quick Setup](#quick-setup-5-minutes) - Get server running
- [Project Structure](project-structure.md) - Understand the codebase
- [Back to Backend Overview](../README.md) - Full backend documentation

---

## Quick Setup (5 minutes)

### 1. Prerequisites

- **Node.js** v18+ installed (`node --version`)
- **npm** v9+ installed (`npm --version`)
- **MongoDB** access (Atlas or local)
- **Text Editor** (VS Code recommended)

### 2. Install Dependencies

```bash
cd backend
npm install
```

### 3. Configure Environment

Create `backend/.env` file (copy from `.env.example`):

```bash
# Copy template
cp .env.example .env

# Edit .env with your values:
```

**Required variables**:
```
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/dbname
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account@your-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
JWT_SECRET=your_jwt_secret
PORT=5000
NODE_ENV=development
```

See [Environment Variables](../../common/setup-guides/environment-variables.md) for details.

### 4. Start Development Server

```bash
npm run dev
```

**Expected output**:
```
Server running on port 5000
```

**Test it**:
```bash
curl http://localhost:5000/health
# Should return: {"status":"ok","timestamp":"..."}
```

### 5. Verify Setup

Create a simple test:

```bash
# Test health endpoint
curl http://localhost:5000/health

# Should see: {"status": "ok", "timestamp": "2026-02-01T..."}
```

✅ **Done!** Backend is running.

---

## 🎯 Next Steps

### Run Your First Test
```bash
npm test
```

### Read Project Structure
→ [Project Structure](project-structure.md)

### Start Implementing a Feature
1. Go to [Feature Implementation](../feature-implementation/)
2. Pick a feature
3. Follow the step-by-step guide

### Understand the Database
→ [Database Documentation](../database/)

### See What APIs Exist
→ [API Endpoints](../api-endpoints/)

---

## 🚀 Development Workflow

### Starting a work session
```bash
cd backend
npm run dev    # Starts with hot reload
```

### Making changes
1. Edit files in `backend/src/`
2. Server auto-reloads (via nodemon)
3. Test your changes with curl or Postman

### Stopping the server
```bash
Ctrl+C
```

### Running tests
```bash
npm test
```

---

## ✅ Checklist

- [ ] Node.js installed
- [ ] Cloned the repo
- [ ] `.env` file created with correct values
- [ ] `npm install` completed
- [ ] `npm run dev` works
- [ ] Health endpoint responds
- [ ] Read [Project Structure](project-structure.md)

---

## ❓ Troubleshooting

### "Port 5000 already in use"
```bash
# Change PORT in .env to 5001
PORT=5001
```

### "Cannot find module"
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### "MongoDB connection failed"
```bash
# Check MONGODB_URI in .env
# Make sure MongoDB is running
# Check credentials are correct
```

### "Firebase auth error"
```bash
# Verify FIREBASE_PROJECT_ID and FIREBASE_CLIENT_EMAIL in .env
# Check Firebase service account JSON is valid
```

---

## 📖 Full Documentation

For more details, see:
- [Project Structure](project-structure.md) - File organization
- [Backend Overview](../README.md) - All backend docs
- [Feature Implementation](../feature-implementation/) - Start implementing
- [Common Setup Guides](../../common/setup-guides/) - Environment setup

---

**Ready to code? → [Project Structure](project-structure.md)**
