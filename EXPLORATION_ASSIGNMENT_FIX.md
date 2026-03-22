# Exploration Assignment System Fix - March 21, 2026

## Problem
New user accounts were being assigned places in only **some districts**, leaving other districts completely empty with no places to visit.

## Root Cause
The `assignExplorationForUser()` function only iterated through districts that already had places in the database. Districts without any places were excluded from the assignment loop, resulting in incomplete exploration progress.

## Solution
Modified `/backend/src/controllers/explorationController.js`:

### 1. Updated Assignment Tiers (Lines 20-23)
**Before:**
```javascript
const COUNT_TIERS = {
  sameDistrict: { min: 4, max: 7 },
  sameProvince: { min: 4, max: 6 },
  otherProvince: { min: 3, max: 5 },
};
```

**After:**
```javascript
const COUNT_TIERS = {
  sameDistrict: { min: 4, max: 10 },
  sameProvince: { min: 4, max: 10 },
  otherProvince: { min: 4, max: 10 },
};
```
✅ **Change:** All tiers now assign 4-10 places (consistent & minimum of 4 for all)

### 2. Added Complete District List (Lines 25-52)
```javascript
const ALL_SRI_LANKA_DISTRICTS = [
  { district: 'Colombo', province: 'Western Province' },
  { district: 'Gampaha', province: 'Western Province' },
  // ... all 25 districts listed
];
```
✅ **Change:** Complete list of all 25 Sri Lanka districts to ensure no district is skipped

### 3. Refactored `assignExplorationForUser()` Function (Lines 295-365)
**Key Changes:**
- Iterates through **ALL_SRI_LANKA_DISTRICTS** instead of just districts with places
- For each district:
  - **If 0 places:** Skip (assignment won't be created, but future places can be added)
  - **If 1-3 places:** Assign all available places
  - **If 4+ places:** Assign random 4-10 places
- Ensures no district gets fewer than 4 places (if places exist)
- Prevents empty districts from being assigned

## Expected Behavior After Fix

### Registration Flow
1. New user logs in
2. User selects hometown district
3. Backend calls `assignExplorationForUser(userId, hometownDistrict)`
4. **NEW:** Every district gets assigned 4-10 places (or all available if fewer than 4)
5. User sees complete map with places in all districts

### Before Fix
```
User: New Account
├── Colombo: 5 places ✓
├── Gampaha: 0 places ✗
├── Kandy: 6 places ✓
├── Matara: 0 places ✗
└── ... (mixed coverage)
```

### After Fix
```
User: New Account
├── Colombo: 8 places ✓
├── Gampaha: 4 places ✓
├── Kandy: 7 places ✓
├── Matara: 5 places ✓
└── ... (complete coverage: 4-10 per district)
```

## Testing the Fix

### Test Case 1: New User Registration
```bash
# Register new account
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d {
    "email": "test@example.com",
    "password": "Test123!",
    "name": "Test User"
  }

# Check assignments (should have places for ALL districts)
curl -X GET http://localhost:5000/api/exploration/assignments \
  -H "Authorization: Bearer {token}"
```

### Expected Result
```javascript
{
  assignments: [
    { district: "Colombo", assignedCount: 7, locations: [...] },
    { district: "Gampaha", assignedCount: 5, locations: [...] },
    { district: "Kalutara", assignedCount: 6, locations: [...] },
    // ... all districts present (no gaps)
  ]
}
```

## Backward Compatibility
✅ Existing users' assignments are not affected
✅ Reroll system still works (uses same function)
✅ UnlockLocation fallback still works for older data

## Performance Impact
- Minimal: Single loop through 25 districts (constant 25 iterations)
- Database queries unchanged
- No additional collection scans

## Files Modified
- `/backend/src/controllers/explorationController.js`
  - Lines 20-52: Updated COUNT_TIERS and added ALL_SRI_LANKA_DISTRICTS
  - Lines 295-365: Refactored assignExplorationForUser() function
