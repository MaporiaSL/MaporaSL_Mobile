# Auth0 Setup Guide

**Last Updated**: January 24, 2026  
**Auth0 Version**: Latest (2026)

---

## Table of Contents

1. [Overview](#overview)
2. [Creating an Auth0 Account](#creating-an-auth0-account)
3. [Setting Up Your Application](#setting-up-your-application)
4. [Configuring the API](#configuring-the-api)
5. [Getting Your Credentials](#getting-your-credentials)
6. [Obtaining JWT Tokens](#obtaining-jwt-tokens)
7. [Testing Authentication](#testing-authentication)
8. [Understanding Token Flow](#understanding-token-flow)
9. [Troubleshooting](#troubleshooting)

---

## Overview

This guide walks you through setting up Auth0 for the Gemified Travel Portfolio backend. Auth0 provides:
- JWT-based authentication with RS256 signing
- Secure token validation via JWKS (JSON Web Key Set)
- User management and identity provider integration
- No custom JWT implementation needed

---

## Creating an Auth0 Account

### Step 1: Sign Up

1. Go to [https://auth0.com/](https://auth0.com/)
2. Click **"Sign Up"** or **"Get Started"**
3. Choose your signup method:
   - Email/Password
   - Google
   - GitHub
   - Microsoft
4. Verify your email address
5. Choose your tenant name (e.g., `gemified-travel`)
   - This becomes your domain: `gemified-travel.us.auth0.com`
   - Cannot be changed later, choose carefully

### Step 2: Complete Account Setup

1. Select your **region** (choose closest to your users):
   - US
   - EU
   - AU
   - Asia
2. Select your **account type**:
   - Personal/Development (recommended for this project)
3. Skip onboarding tutorials if you prefer

---

## Setting Up Your Application

### Step 1: Create an Application

1. In Auth0 Dashboard, go to **Applications** → **Applications**
2. Click **"+ Create Application"**
3. Enter application name: `Gemified Travel Backend`
4. Select application type: **Machine to Machine Applications**
5. Click **"Create"**

### Step 2: Configure Application Settings

1. In your application settings, note these values:
   - **Domain**: `your-tenant.us.auth0.com` or `your-tenant.eu.auth0.com`
   - **Client ID**: Auto-generated (e.g., `abc123def456...`)
   - **Client Secret**: Auto-generated (click "Show" to reveal)

2. Scroll down to **Application URIs**:
   - **Allowed Callback URLs**: `http://localhost:3000/callback` (for mobile app later)
   - **Allowed Logout URLs**: `http://localhost:3000`
   - **Allowed Web Origins**: `http://localhost:3000`

3. Scroll down to **Advanced Settings** → **Grant Types**:
   - Ensure **Client Credentials** is enabled ✅
   - This allows server-to-server authentication

4. Click **"Save Changes"**

---

## Configuring the API

### Step 1: Create an API

1. In Auth0 Dashboard, go to **Applications** → **APIs**
2. Click **"+ Create API"**
3. Fill in the form:
   - **Name**: `Gemified Travel API`
   - **Identifier**: `https://api.gemified-travel.com` (this is your audience)
     - Can be any unique URL format
     - Doesn't need to be a real domain
     - Used in JWT audience (`aud`) claim
   - **Signing Algorithm**: **RS256** (default, keep this)
4. Click **"Create"**

### Step 2: Configure API Settings

1. In your API settings, go to **Settings** tab
2. Note the **Identifier** - this is your `AUTH0_AUDIENCE`
3. Scroll to **RBAC Settings** (optional for now):
   - Enable RBAC if you want role-based access control
   - Enable "Add Permissions in the Access Token" for API permissions
4. Click **"Save"**

### Step 3: Authorize Application

1. Still in your API page, go to **Machine to Machine Applications** tab
2. Find your `Gemified Travel Backend` application
3. Toggle it to **Authorized** ✅
4. Optionally select specific permissions (scopes) if you defined any
5. Click **"Update"**

---

## Getting Your Credentials

You need four values for your backend `.env` file:

### 1. AUTH0_DOMAIN
- Found in: **Applications** → Your App → **Settings** → **Domain**
- Format: `your-tenant.us.auth0.com` or `your-tenant.eu.auth0.com`
- Example: `gemified-travel.us.auth0.com`
- **Do NOT include** `https://` prefix

### 2. AUTH0_AUDIENCE
- Found in: **Applications** → **APIs** → Your API → **Settings** → **Identifier**
- Format: Usually a URL-like string
- Example: `https://api.gemified-travel.com`

### 3. AUTH0_CLIENT_ID (for testing)
- Found in: **Applications** → Your App → **Settings** → **Client ID**
- Format: Random alphanumeric string
- Example: `abc123def456xyz789`

### 4. AUTH0_CLIENT_SECRET (for testing)
- Found in: **Applications** → Your App → **Settings** → **Client Secret**
- Click **"Show"** to reveal
- Format: Long random string
- Example: `aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890`
- ⚠️ **Keep this SECRET** - never commit to git

### Add to .env File

```env
# Auth0 Configuration
AUTH0_DOMAIN=your-tenant.us.auth0.com
AUTH0_AUDIENCE=https://api.gemified-travel.com
AUTH0_CLIENT_ID=your_client_id_here
AUTH0_CLIENT_SECRET=your_client_secret_here

# MongoDB (already configured)
MONGODB_URI=mongodb+srv://...

# Server
PORT=5000
CLIENT_ORIGIN=http://localhost:3000
```

---

## Obtaining JWT Tokens

### Method 1: Using cURL (Recommended for Testing)

```bash
curl --request POST \
  --url https://YOUR_AUTH0_DOMAIN/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "audience": "YOUR_AUTH0_AUDIENCE",
    "grant_type": "client_credentials"
  }'
```

**Response**:
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEyMzQ1In0...",
  "token_type": "Bearer",
  "expires_in": 86400
}
```

Copy the `access_token` value to use in API requests.

---

### Method 2: Using PowerShell (Windows)

```powershell
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

$token = $response.access_token
Write-Host "Token: $token"

# Save token to variable for later use
$env:AUTH_TOKEN = $token
```

---

### Method 3: Using Postman

1. Create a new request in Postman
2. Set method to **POST**
3. URL: `https://YOUR_AUTH0_DOMAIN/oauth/token`
4. Go to **Headers** tab:
   - Add `Content-Type: application/json`
5. Go to **Body** tab:
   - Select **raw** and **JSON**
   - Paste:
     ```json
     {
       "client_id": "YOUR_CLIENT_ID",
       "client_secret": "YOUR_CLIENT_SECRET",
       "audience": "YOUR_AUTH0_AUDIENCE",
       "grant_type": "client_credentials"
     }
     ```
6. Click **Send**
7. Copy the `access_token` from response

---

### Method 4: Using Auth0 Test Tab (Quick Test)

1. In Auth0 Dashboard, go to **Applications** → **APIs**
2. Click on your API
3. Go to **Test** tab
4. Click **"Copy Token"** button
5. This generates a token instantly for testing

---

## Testing Authentication

### Step 1: Get a Token

Use any method above to obtain a JWT token. For example:

```bash
# Replace with your actual credentials
TOKEN=$(curl -s --request POST \
  --url https://your-tenant.us.auth0.com/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "audience": "https://api.gemified-travel.com",
    "grant_type": "client_credentials"
  }' | jq -r '.access_token')

echo $TOKEN
```

### Step 2: Test Protected Endpoint

```bash
# Test health endpoint (unprotected)
curl http://localhost:5000/health

# Test protected endpoint (requires token)
curl -X GET http://localhost:5000/api/travel \
  -H "Authorization: Bearer $TOKEN"
```

**Expected Results**:
- Health endpoint: Returns `{ "status": "ok", "timestamp": "..." }`
- Without token: Returns `401 Unauthorized`
- With valid token: Returns travel data or empty array

### Step 3: Register Your User

```bash
# Using PowerShell
$TOKEN = "YOUR_JWT_TOKEN_HERE"
$headers = @{
    "Authorization" = "Bearer $TOKEN"
    "Content-Type" = "application/json"
}

$body = @{
    email = "your.email@example.com"
    name = "Your Name"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" `
    -Method POST `
    -Headers $headers `
    -Body $body
```

---

## Understanding Token Flow

### Token Structure

A JWT token has three parts (separated by `.`):

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

1. **Header**: Algorithm and token type
2. **Payload**: User data and claims
3. **Signature**: Verification signature

### Important Claims

Your backend uses these JWT claims:

| Claim | Description | Used For |
|-------|-------------|----------|
| `sub` | Subject (user ID) | Extracted as `req.userId` for data isolation |
| `aud` | Audience | Validates token is for your API |
| `iss` | Issuer | Validates token is from your Auth0 tenant |
| `exp` | Expiration | Auto-checked by express-jwt |
| `iat` | Issued At | Token creation timestamp |

### Token Validation Flow

```
1. User sends request with JWT in Authorization header
   → Authorization: Bearer <token>

2. checkJwt middleware intercepts request
   → Extracts token from header
   → Fetches Auth0 public key from JWKS endpoint
   → Verifies signature using RS256 algorithm
   → Validates aud, iss, exp claims

3. If valid:
   → Token payload attached to req.auth
   → extractUserId middleware runs
   → req.userId = req.auth.sub

4. Controller receives request
   → Uses req.userId to filter database queries
   → Returns only user's own data
```

---

## Troubleshooting

### Issue: "No authorization token was found"

**Cause**: Missing Authorization header

**Solution**:
```bash
# ❌ Wrong
curl http://localhost:5000/api/travel

# ✅ Correct
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:5000/api/travel
```

---

### Issue: "jwt malformed"

**Cause**: Token is incomplete or corrupted

**Solutions**:
1. Ensure you copied the entire token (no spaces, no line breaks)
2. Token should have exactly 2 dots (`.`) separating 3 parts
3. Re-generate token and copy again

---

### Issue: "Invalid token"

**Cause**: Token validation failed

**Possible Reasons**:
1. **Wrong audience**: Check `AUTH0_AUDIENCE` matches API identifier
2. **Wrong domain**: Check `AUTH0_DOMAIN` matches Auth0 tenant
3. **Expired token**: Tokens expire after 24 hours (default), get new one
4. **Wrong algorithm**: Ensure API uses RS256 (not HS256)

**Debug Steps**:
```bash
# Check token contents (decode Base64)
echo "TOKEN_PAYLOAD" | base64 -d | jq

# Verify audience and issuer claims
```

---

### Issue: "Request failed with status code 401"

**Cause**: Application not authorized for API

**Solution**:
1. Go to Auth0 Dashboard → APIs → Your API
2. Click **Machine to Machine Applications** tab
3. Ensure your application is toggled **ON** (Authorized)
4. Click **Update**
5. Re-generate token

---

### Issue: Token works in Postman but not in code

**Cause**: Token variable not properly passed

**Solution**:
```javascript
// ❌ Wrong
headers: { Authorization: token }

// ✅ Correct
headers: { Authorization: `Bearer ${token}` }
```

---

## Security Best Practices

### ✅ DO

- Store `CLIENT_SECRET` in `.env` (never in code)
- Add `.env` to `.gitignore`
- Use HTTPS in production
- Regenerate tokens regularly
- Set token expiration (default 24h is good)
- Use separate Auth0 tenants for dev/staging/production

### ❌ DON'T

- Commit credentials to git
- Share `CLIENT_SECRET` publicly
- Use the same credentials for all environments
- Store tokens in localStorage (mobile: use secure storage)
- Log tokens in console/files

---

## Production Considerations

### Environment Variables

For production, update these values:

```env
AUTH0_DOMAIN=your-tenant.us.auth0.com  # Same for all environments
AUTH0_AUDIENCE=https://api.gemified-travel.com  # Same for all
CLIENT_ORIGIN=https://yourdomain.com  # Update to production URL
```

### Application URLs

In Auth0 Dashboard → Applications → Your App:
- **Allowed Callback URLs**: Add production URL
- **Allowed Logout URLs**: Add production URL
- **Allowed Web Origins**: Add production URL

### Token Expiration

- Default: 24 hours (86400 seconds)
- To change: Auth0 Dashboard → APIs → Your API → Settings → Token Expiration
- Recommended: 24 hours for development, 1 hour for production

---

## Next Steps

After completing Auth0 setup:

1. ✅ Verify you can obtain JWT tokens
2. ✅ Test protected endpoints with tokens
3. ✅ Register your user account
4. 📱 Integrate Auth0 SDK in Flutter mobile app (Phase 3)
5. 🔐 Add role-based permissions (optional)
6. 📊 Monitor authentication logs in Auth0 Dashboard

---

## Useful Links

- [Auth0 Dashboard](https://manage.auth0.com/)
- [Auth0 Documentation](https://auth0.com/docs)
- [JWT Debugger](https://jwt.io/) - Decode and inspect tokens
- [Auth0 Community](https://community.auth0.com/) - Get help

---

## Support

For Auth0-specific issues:
- Check [Auth0 Documentation](https://auth0.com/docs)
- Visit [Auth0 Community Forum](https://community.auth0.com/)
- Contact Auth0 Support (paid plans)

For project-specific issues:
- Check project documentation in `docs/`
- Review [API_REFERENCE.md](../04_api/API_REFERENCE.md)
- Check [TROUBLESHOOTING.md](../05_setup_guides/TROUBLESHOOTING.md) (if exists)
