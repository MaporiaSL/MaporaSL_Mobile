# Local Development Setup Guide

**Last Updated**: January 24, 2026  
**Target OS**: Windows (adaptable for macOS/Linux)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Environment Configuration](#environment-configuration)
4. [Running the Backend](#running-the-backend)
5. [Testing the API](#testing-the-api)
6. [Development Workflow](#development-workflow)
7. [Common Issues](#common-issues)

---

## Prerequisites

### Required Software

Install the following before starting:

#### 1. Node.js (v18 or higher)
- **Download**: [https://nodejs.org/](https://nodejs.org/)
- **Recommended**: LTS version (Long Term Support)
- **Verify installation**:
  ```bash
  node --version  # Should show v18.x.x or higher
  npm --version   # Should show 9.x.x or higher
  ```

#### 2. Git
- **Download**: [https://git-scm.com/downloads](https://git-scm.com/downloads)
- **Verify installation**:
  ```bash
  git --version  # Should show git version 2.x.x
  ```

#### 3. Code Editor
- **Recommended**: [Visual Studio Code](https://code.visualstudio.com/)
- **Alternative**: WebStorm, Sublime Text, or any editor

#### 4. MongoDB Atlas Account (Free)
- **Sign up**: [https://www.mongodb.com/cloud/atlas/register](https://www.mongodb.com/cloud/atlas/register)
- **Note**: We use cloud MongoDB, not local installation
- See [MongoDB Atlas Setup](#mongodb-atlas-setup) section below

#### 5. Auth0 Account (Free)
- **Sign up**: [https://auth0.com/signup](https://auth0.com/signup)
- See [Auth0 Setup Guide](./AUTH0_SETUP.md) for detailed instructions

---

## Project Setup

### Step 1: Clone the Repository

```bash
# Navigate to your projects directory
cd D:\Github_projects

# Clone the repository (replace with your repo URL)
git clone https://github.com/yourusername/gemified-travel-portfolio.git

# Navigate into the project
cd gemified-travel-portfolio
```

---

### Step 2: Install Backend Dependencies

```bash
# Navigate to backend directory
cd backend

# Install all dependencies
npm install
```

**Expected output**:
```
added 85 packages, and audited 86 packages in 8s

10 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

**Installed Packages**:
- `express` - Web framework
- `mongoose` - MongoDB ODM
- `express-jwt` - JWT authentication middleware
- `jwks-rsa` - Auth0 public key fetching
- `express-validator` - Input validation
- `cors` - CORS middleware
- `helmet` - Security middleware
- `morgan` - HTTP logging
- `dotenv` - Environment variables
- `nodemon` - Development auto-reload (dev dependency)

---

## Environment Configuration

### Step 1: MongoDB Atlas Setup

#### Create Database

1. **Sign in** to [MongoDB Atlas](https://cloud.mongodb.com/)

2. **Create a Cluster** (if you haven't already):
   - Click **"Build a Database"**
   - Choose **Shared** (Free tier)
   - Select cloud provider (AWS recommended)
   - Select region (choose closest to you)
   - Cluster name: `gemified-travel-cluster` (or any name)
   - Click **"Create Cluster"** (takes 3-5 minutes)

3. **Create Database User**:
   - Click **"Database Access"** in left sidebar
   - Click **"+ Add New Database User"**
   - Authentication method: **Password**
   - Username: `gemified-admin` (or any name)
   - Password: Generate secure password (save this!)
   - Database User Privileges: **Read and write to any database**
   - Click **"Add User"**

4. **Whitelist IP Address**:
   - Click **"Network Access"** in left sidebar
   - Click **"+ Add IP Address"**
   - For development: Click **"Allow Access from Anywhere"** (0.0.0.0/0)
   - For production: Add specific IPs
   - Click **"Confirm"**

5. **Get Connection String**:
   - Click **"Database"** in left sidebar
   - Click **"Connect"** on your cluster
   - Choose **"Connect your application"**
   - Driver: **Node.js**, Version: **5.5 or later**
   - Copy the connection string:
     ```
     mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
     ```
   - Replace `<username>` with your database username
   - Replace `<password>` with your database password
   - Add database name: `mongodb+srv://...mongodb.net/gemified-travel?retryWrites...`

---

### Step 2: Auth0 Setup

Follow the detailed guide: [AUTH0_SETUP.md](./AUTH0_SETUP.md)

**Quick summary**:
1. Create Auth0 account
2. Create Machine-to-Machine Application
3. Create API with identifier (audience)
4. Note down:
   - Domain (e.g., `your-tenant.us.auth0.com`)
   - Audience (e.g., `https://api.gemified-travel.com`)
   - Client ID
   - Client Secret

---

### Step 3: Create .env File

#### Copy Template

```bash
# In backend directory
cp .env.example .env
```

#### Edit .env File

Open `.env` in your editor and fill in the values:

```env
# Server Configuration
PORT=5000
CLIENT_ORIGIN=http://localhost:3000

# MongoDB Atlas Connection
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/gemified-travel?retryWrites=true&w=majority

# Auth0 Configuration
AUTH0_DOMAIN=your-tenant.us.auth0.com
AUTH0_AUDIENCE=https://api.gemified-travel.com
AUTH0_CLIENT_ID=your_client_id_here
AUTH0_CLIENT_SECRET=your_client_secret_here
```

**Important**:
- Replace ALL placeholder values with your actual credentials
- Do NOT commit `.env` to git (it's in `.gitignore`)
- Keep `CLIENT_SECRET` confidential

---

### Step 4: Verify Configuration

Create a test script to verify MongoDB connection:

```bash
# In backend directory
node -e "require('dotenv').config(); console.log('✅ Environment loaded'); console.log('MongoDB URI:', process.env.MONGODB_URI ? '✅ Set' : '❌ Missing'); console.log('Auth0 Domain:', process.env.AUTH0_DOMAIN ? '✅ Set' : '❌ Missing');"
```

**Expected output**:
```
✅ Environment loaded
MongoDB URI: ✅ Set
Auth0 Domain: ✅ Set
```

---

## Running the Backend

### Development Mode (with auto-reload)

```bash
# In backend directory
npm run dev
```

**Expected output**:
```
[nodemon] 3.0.2
[nodemon] to restart at any time, enter `rs`
[nodemon] watching path(s): *.*
[nodemon] watching extensions: js,mjs,json
[nodemon] starting `node src/server.js`
MongoDB connected successfully
Server running on port 5000
```

**Features**:
- Auto-restarts on file changes
- Watches `.js`, `.json` files
- Type `rs` to manually restart

---

### Production Mode

```bash
# In backend directory
npm start
```

**Expected output**:
```
MongoDB connected successfully
Server running on port 5000
```

**Note**: No auto-reload in production mode.

---

### Verify Server is Running

Open another terminal:

```bash
# Test health endpoint
curl http://localhost:5000/health
```

**Expected response**:
```json
{
  "status": "ok",
  "timestamp": "2026-01-24T10:00:00.000Z"
}
```

---

## Testing the API

### Step 1: Get Auth0 Token

**Using PowerShell**:

```powershell
# Replace with your credentials
$body = @{
    client_id = "YOUR_CLIENT_ID"
    client_secret = "YOUR_CLIENT_SECRET"
    audience = "YOUR_AUTH0_AUDIENCE"
    grant_type = "client_credentials"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://YOUR_AUTH0_DOMAIN/oauth/token" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

$TOKEN = $response.access_token
Write-Host "Token obtained: $TOKEN"
```

---

### Step 2: Register User

```powershell
$headers = @{
    "Authorization" = "Bearer $TOKEN"
    "Content-Type" = "application/json"
}

$body = @{
    email = "test@example.com"
    name = "Test User"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" `
    -Method POST `
    -Headers $headers `
    -Body $body

$response | ConvertTo-Json -Depth 5
```

**Expected response** (201 Created):
```json
{
  "message": "User registered successfully",
  "user": {
    "_id": "...",
    "auth0Id": "auth0|...",
    "email": "test@example.com",
    "name": "Test User",
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

### Step 3: Create a Travel

```powershell
$travelBody = @{
    title = "Sri Lanka Adventure"
    description = "Two week trip exploring the island"
    startDate = "2024-03-01T00:00:00.000Z"
    endDate = "2024-03-15T00:00:00.000Z"
    locations = @("Colombo", "Kandy", "Galle")
} | ConvertTo-Json

$travelResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/travel" `
    -Method POST `
    -Headers $headers `
    -Body $travelBody

$travelResponse | ConvertTo-Json -Depth 5

# Save travel ID for next step
$TRAVEL_ID = $travelResponse.travel._id
```

**Expected response** (201 Created):
```json
{
  "message": "Travel created successfully",
  "travel": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "...",
    "title": "Sri Lanka Adventure",
    "description": "Two week trip exploring the island",
    "startDate": "2024-03-01T00:00:00.000Z",
    "endDate": "2024-03-15T00:00:00.000Z",
    "locations": ["Colombo", "Kandy", "Galle"],
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

### Step 4: Create a Destination

```powershell
$destBody = @{
    name = "Sigiriya Rock Fortress"
    latitude = 7.9570
    longitude = 80.7603
    notes = "Ancient rock fortress with stunning frescoes"
    visited = $true
} | ConvertTo-Json

$destResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/travel/$TRAVEL_ID/destinations" `
    -Method POST `
    -Headers $headers `
    -Body $destBody

$destResponse | ConvertTo-Json -Depth 5
```

**Expected response** (201 Created):
```json
{
  "message": "Destination created successfully",
  "destination": {
    "_id": "...",
    "userId": "...",
    "travelId": "507f1f77bcf86cd799439011",
    "name": "Sigiriya Rock Fortress",
    "latitude": 7.9570,
    "longitude": 80.7603,
    "notes": "Ancient rock fortress with stunning frescoes",
    "visited": true,
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

### Step 5: List Travels

```powershell
$travelsResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/travel" `
    -Method GET `
    -Headers $headers

$travelsResponse | ConvertTo-Json -Depth 5
```

**Expected response** (200 OK):
```json
{
  "travels": [ /* array of your travels */ ],
  "total": 1
}
```

---

### Step 6: List Destinations

```powershell
$destinationsResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/travel/$TRAVEL_ID/destinations" `
    -Method GET `
    -Headers $headers

$destinationsResponse | ConvertTo-Json -Depth 5
```

---

## Development Workflow

### Typical Development Flow

1. **Start Development Server**:
   ```bash
   cd backend
   npm run dev
   ```

2. **Make Code Changes**:
   - Edit files in `src/` directory
   - Server auto-restarts on save

3. **Test Changes**:
   - Use PowerShell/cURL to test endpoints
   - Check server logs for errors

4. **Commit Changes**:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin main
   ```

---

### Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── db.js              # MongoDB connection
│   ├── middleware/
│   │   └── auth.js            # JWT validation
│   ├── models/
│   │   ├── User.js            # User schema
│   │   ├── Travel.js          # Travel schema
│   │   └── Destination.js     # Destination schema
│   ├── controllers/
│   │   ├── authController.js      # Auth logic
│   │   ├── travelController.js    # Travel CRUD
│   │   └── destinationController.js  # Destination CRUD
│   ├── routes/
│   │   ├── authRoutes.js          # Auth endpoints
│   │   ├── travelRoutes.js        # Travel endpoints
│   │   └── destinationRoutes.js   # Destination endpoints
│   ├── validators/
│   │   ├── travelValidator.js     # Travel input validation
│   │   └── destinationValidator.js  # Destination input validation
│   └── server.js              # Express app entry point
├── .env                       # Environment variables (not in git)
├── .env.example               # Template for .env
├── .gitignore                 # Git ignore rules
├── package.json               # Dependencies and scripts
└── package-lock.json          # Dependency lock file
```

---

### Useful npm Scripts

```bash
# Development mode (auto-reload)
npm run dev

# Production mode
npm start

# Install new package
npm install package-name

# Install dev dependency
npm install --save-dev package-name

# Check for outdated packages
npm outdated

# Update packages
npm update
```

---

## Common Issues

### Issue: Port 5000 Already in Use

**Error**:
```
Error: listen EADDRINUSE: address already in use :::5000
```

**Solution 1**: Kill existing process
```powershell
# Find process using port 5000
netstat -ano | findstr :5000

# Kill process by PID
taskkill /PID <PID> /F
```

**Solution 2**: Change port
```env
# In .env file
PORT=5001
```

---

### Issue: MongoDB Connection Failed

**Error**:
```
MongooseServerSelectionError: Could not connect to any servers in your MongoDB Atlas cluster
```

**Solutions**:
1. **Check IP Whitelist**:
   - MongoDB Atlas → Network Access
   - Ensure 0.0.0.0/0 is whitelisted (development)

2. **Verify Connection String**:
   - Ensure username and password are correct
   - Ensure database name is included
   - Check for special characters (URL encode if needed)

3. **Test Connection**:
   ```bash
   node -e "const mongoose = require('mongoose'); require('dotenv').config(); mongoose.connect(process.env.MONGODB_URI).then(() => console.log('✅ Connected')).catch(e => console.log('❌ Error:', e.message));"
   ```

---

### Issue: 401 Unauthorized on All Requests

**Possible Causes**:

1. **Missing Authorization Header**:
   ```powershell
   # ❌ Wrong
   Invoke-RestMethod -Uri "http://localhost:5000/api/travel"
   
   # ✅ Correct
   Invoke-RestMethod -Uri "http://localhost:5000/api/travel" -Headers @{ "Authorization" = "Bearer $TOKEN" }
   ```

2. **Wrong Auth0 Configuration**:
   - Verify `AUTH0_DOMAIN` in `.env`
   - Verify `AUTH0_AUDIENCE` matches API identifier
   - Check application is authorized for API in Auth0 Dashboard

3. **Expired Token**:
   - Tokens expire after 24 hours (default)
   - Get a new token

---

### Issue: npm install Fails

**Error**:
```
npm ERR! code ENOENT
npm ERR! syscall open
npm ERR! path package.json
```

**Solution**:
```bash
# Ensure you're in backend directory
cd backend
pwd  # Should show .../gemified-travel-portfolio/backend

# Then run
npm install
```

---

### Issue: nodemon Not Found

**Error**:
```
'nodemon' is not recognized as an internal or external command
```

**Solution**:
```bash
# Reinstall dev dependencies
npm install

# Or install nodemon globally
npm install -g nodemon
```

---

### Issue: Environment Variables Not Loading

**Symptoms**:
- `process.env.MONGODB_URI` is undefined
- Server can't connect to database

**Solutions**:
1. **Ensure .env file exists**:
   ```bash
   ls -la backend/.env  # Should exist
   ```

2. **Check .env syntax**:
   - No spaces around `=`
   - No quotes around values (unless value has spaces)
   ```env
   # ❌ Wrong
   PORT = 5000
   MONGODB_URI = "mongodb+srv://..."
   
   # ✅ Correct
   PORT=5000
   MONGODB_URI=mongodb+srv://...
   ```

3. **Restart server** after changing `.env`

---

## Next Steps

After successful setup:

1. ✅ **Review API Documentation**: [API_REFERENCE.md](../04_api/API_REFERENCE.md)
2. ✅ **Understand Database Schema**: [DATABASE_SCHEMA.md](../03_architecture/DATABASE_SCHEMA.md)
3. 📱 **Set up Flutter Mobile App** (future phase)
4. 🗺️ **Integrate Map Features** (Phase 3)
5. 🧪 **Write Tests** (future phase)

---

## Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [Mongoose Documentation](https://mongoosejs.com/)
- [MongoDB Atlas Documentation](https://www.mongodb.com/docs/atlas/)
- [Auth0 Documentation](https://auth0.com/docs)
- [Node.js Documentation](https://nodejs.org/docs/)

---

## Getting Help

If you encounter issues:

1. Check this guide's [Common Issues](#common-issues) section
2. Review server logs in terminal
3. Check MongoDB Atlas connection in dashboard
4. Verify Auth0 configuration in dashboard
5. Consult project documentation in `docs/`
6. Search existing issues in project repository

---

## Development Tips

### Use VS Code Extensions

Recommended extensions:
- **REST Client** - Test APIs directly in VS Code
- **MongoDB for VS Code** - View database collections
- **Thunder Client** - Alternative to Postman
- **ESLint** - Code linting
- **Prettier** - Code formatting

### Enable Auto-Save

VS Code → File → Auto Save (or `Ctrl+,` → search "auto save")

### Use Git Branches

```bash
# Create feature branch
git checkout -b feature/new-feature

# Work on feature
git add .
git commit -m "feat: implement new feature"

# Merge to main
git checkout main
git merge feature/new-feature
```

### Keep Dependencies Updated

```bash
# Check outdated packages
npm outdated

# Update all (carefully)
npm update

# Or update specific package
npm update express
```

---

**Happy coding! 🚀**
