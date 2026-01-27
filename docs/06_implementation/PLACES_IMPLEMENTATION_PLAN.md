# Places Feature Implementation Plan

**Date**: January 27, 2026  
**Phase**: 📋 Planning  
**Estimated Duration**: 6-8 weeks total

---

## Overview

This document provides step-by-step implementation guidance for the Places system across all tiers: backend, frontend, and admin dashboard.

---

## Phase 1: Seed Curated Places List (Offline Research)

**Duration**: 2-3 days  
**Owner**: Developer (manual research)  
**Deliverable**: `places_seed_data.json`

### Goals
- Research and compile 50-100 major tourist attractions in Sri Lanka
- Gather comprehensive metadata for each place
- Create structured JSON with verified information
- Prepare for bulk database import

### Step-by-Step Process

#### Step 1: Research Sources
Gather information from multiple reliable sources:
- Google Maps (for location, ratings, photos)
- TripAdvisor (tourist feedback, opening hours)
- Sri Lanka Tourism Board (official attractions)
- Wikipedia (historical/geographical data)
- Local travel blogs & guides
- Instagram location tags (for popular spots)

#### Step 2: Define Place Categories
Organize places by type:
- ⛰️ **Mountain**: Adams Peak, Pidurutalagala, Knuckles Range
- 🌊 **Beach**: Mirissa, Unawatuna, Arugambe
- 💧 **Waterfall**: Dambulla, Ravana, St. Clair
- 🏛️ **Historical**: Sigiriya, Anuradhapura, Polonnaruwa
- 🏰 **Temple**: Temple of the Tooth, Kelaniya, Thuparama
- 🌲 **Forest/Nature**: Sinharaja, Yala NP, Horton Plains
- 🏙️ **City**: Colombo, Kandy, Galle
- 🌺 **Garden/Park**: Peradeniya Gardens, Hakgala Gardens

#### Step 3: Data Collection Template

For each place, gather:

```json
{
  "name": "Sigiriya Rock Fortress",
  "description": "Ancient fortress and UNESCO World Heritage Site on top of a 200m tall rock formation...",
  "category": "historical",
  "province": "Central Province",
  "district": "Matara",
  "address": "Sigiriya, Dambulla 21100",
  "coordinates": {
    "latitude": 7.9432,
    "longitude": 80.7608
  },
  "googleMapsUrl": "https://www.google.com/maps?q=7.9432,80.7608",
  "accessibility": {
    "season": "year-round",
    "bestTime": "October-March",
    "difficulty": "moderate",
    "estimatedDuration": "3-4 hours",
    "entryFee": "4,550 LKR (~$15 USD)"
  },
  "rating": 4.8,
  "reviewCount": 5234,
  "tags": ["UNESCO", "hiking", "photography", "ancient", "scenic"],
  "notes": "Bring water, early morning visits recommended to avoid crowds"
}
```

#### Step 4: Validation Checklist
Before adding to JSON:
- ✅ Name matches multiple sources
- ✅ Coordinates verified (use Google Maps)
- ✅ Location within Sri Lanka bounds
- ✅ Description is factually accurate
- ✅ Category is appropriate
- ✅ No duplicate entries
- ✅ At least 1 high-quality photo URL found
- ✅ Accessibility info is realistic

#### Step 5: Create Starter List
Target: **30-50 core attractions** as initial seed

**Distribution**:
- 15-20 historical/cultural
- 8-10 nature/outdoor
- 5-7 beaches
- 3-5 cities/urban
- Rest: mixed categories

#### Step 6: Generate JSON File

Create `project_resorces/places_seed_data.json`:

```json
{
  "version": "1.0.0",
  "generatedAt": "2026-01-27",
  "totalPlaces": 42,
  "source": "system",
  "places": [
    {
      "name": "Sigiriya Rock Fortress",
      "category": "historical",
      ...
    },
    ...
  ]
}
```

**Target file size**: < 500KB (with embedded photo URLs)

---

## Phase 2: Backend Infrastructure

**Duration**: 1 week  
**Owner**: Backend developer

### Step 1: Create Place Model

**File**: `backend/src/models/place.js`

```javascript
const placeSchema = new mongoose.Schema({
  // Basic Info
  name: {
    type: String,
    required: true,
    index: true,
    trim: true
  },
  description: {
    type: String,
    required: true,
    minlength: 50
  },
  
  // Classification
  category: {
    type: String,
    enum: ['waterfall', 'mountain', 'beach', 'historical', 'temple', 'forest', 'city', 'garden', 'other'],
    required: true,
    index: true
  },
  
  // Location
  location: {
    province: String,
    district: String,
    address: String,
    coordinates: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        index: '2dsphere'
      }
    }
  },
  googleMapsUrl: String, // direct Google Maps pin for navigation
  
  // Media
  photos: [{
    url: String,
    uploadedAt: Date,
    uploadedBy: String // "system" or userId
  }],
  mainPhotoUrl: String,
  
  // Metadata
  metadata: {
    source: {
      type: String,
      enum: ['system', 'user'],
      default: 'system'
    },
    verified: {
      type: Boolean,
      default: false
    },
    rating: {
      type: Number,
      min: 0,
      max: 5,
      default: 0
    },
    reviewCount: {
      type: Number,
      default: 0
    },
    visitCount: { // How many trips include this place
      type: Number,
      default: 0
    }
  },
  
  // Accessibility Info
  accessibility: {
    season: String, // "year-round", "Oct-Mar", etc
    difficulty: String, // "easy", "moderate", "hard"
    estimatedDuration: String, // "1-2 hours"
    entryFee: String, // "Free", "$5", etc
    wheelchairAccessible: Boolean
  },
  
  // Contributor Info (if user-submitted)
  contributor: {
    userId: mongoose.Schema.Types.ObjectId,
    username: String,
    submittedAt: Date
  },
  
  // Tags for Search
  tags: [String],
  
  // Timestamps
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Indexes
placeSchema.index({ 'location.coordinates': '2dsphere' }); // Geospatial
placeSchema.index({ category: 1 });
placeSchema.index({ 'location.province': 1, 'location.district': 1 });
placeSchema.index({ name: 'text', description: 'text', tags: 'text' }); // Full text search
```

### Step 2: Create PlaceRequest Model (User Submissions)

**File**: `backend/src/models/placeRequest.js`

```javascript
const placeRequestSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  username: String,
  
  // Submitted Data
  place: {
    name: String,
    description: String,
    category: String,
    location: {
      province: String,
      district: String,
      address: String,
      coordinates: {
        type: {
          type: String,
          enum: ['Point'],
          default: 'Point'
        },
        coordinates: [Number]
      }
    },
    googleMapsUrl: String,
    photos: [String], // URLs to uploaded photos
    accessibility: {
      season: String,
      difficulty: String,
      estimatedDuration: String,
      entryFee: String
    },
    tags: [String]
  },
  
  // Status & Review
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending',
    index: true
  },
  
  adminReview: {
    reviewedBy: mongoose.Schema.Types.ObjectId,
    reviewedAt: Date,
    decision: String,
    reason: String, // For rejections
    notes: String
  },
  
  createdAt: { type: Date, default: Date.now, index: true },
  updatedAt: { type: Date, default: Date.now }
});
```

### Step 3: Create API Endpoints

**File**: `backend/src/routes/places.js`

```javascript
// Public Routes (no auth required)
router.get('/places', listPlaces); // Paginated, filterable
router.get('/places/:id', getPlace); // Single place details
router.get('/places/search', searchPlaces); // Text search

// User Routes (auth required)
router.post('/places/request', submitPlaceRequest); // User submission
router.get('/places/requests/user/:userId', getUserSubmissions);

// Admin Routes (auth + admin check)
router.get('/admin/places/requests', listPlaceRequests); // Pending
router.patch('/admin/places/requests/:id/approve', approvePlace);
router.patch('/admin/places/requests/:id/reject', rejectPlace);
router.post('/admin/places', bulkImportPlaces); // Seed data import
router.patch('/admin/places/:id', editPlace);
```

### Step 4: Implement Handlers

**Key Handlers**:

#### `listPlaces()`
- Return paginated list of verified places
- Support filters: category, province, difficulty, rating
- Geospatial search: places near coordinates
- Sort: rating, popularity (visitCount), newly added

#### `submitPlaceRequest()`
- Validate form data
- Check for duplicates (name + location)
- Upload photos to cloud storage (Firebase/AWS S3)
- Create PlaceRequest document
- Send admin notification

#### `approvePlace()`
- Retrieve PlaceRequest
- Create Place document from submission
- Update contributor stats in User model
- Award achievement badge
- Send notification to contributor
- Delete PlaceRequest

#### `bulkImportPlaces()`
- Admin-only endpoint
- Accept JSON array of places
- Validate each place
- Insert into Places collection
- Return import summary

### Step 5: Photo Upload Integration

**Options**:
- Firebase Storage (easiest, free tier)
- AWS S3 (more scalable)
- Local storage (dev only)

**Implementation**:
```javascript
const uploadPlacePhoto = async (file) => {
  const bucket = admin.storage().bucket();
  const filePath = `places/${Date.now()}_${file.originalname}`;
  
  await bucket.upload(file.path, {
    destination: filePath
  });
  
  const url = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
  return url;
};
```

### Step 6: Bulk Import Script

**File**: `backend/scripts/importPlaces.js`

```javascript
const placeData = require('../project_resorces/places_seed_data.json');

async function importPlaces() {
  try {
    const result = await Place.insertMany(placeData.places);
    console.log(`✅ Imported ${result.length} places`);
  } catch (error) {
    console.error('❌ Import failed:', error);
  }
}

// Run: node backend/scripts/importPlaces.js
```

**Run once**: `npm run import-places`

---

## Phase 3: Frontend - Place Discovery

**Duration**: 1 week  
**Owner**: Flutter developer

### Step 1: Create Place Model (Flutter)

**File**: `mobile/lib/features/places/data/models/place_model.dart`

```dart
class Place {
  final String id;
  final String name;
  final String description;
  final String category;
  final Location location;
  final String googleMapsUrl;
  final List<String> photos;
  final double rating;
  final int reviewCount;
  final Accessibility accessibility;
  final List<String> tags;
  
  Place({
    required this.id,
    required this.name,
    // ... etc
  });
  
  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceToJson(this);
}
```

### Step 2: Create Places Repository & API Client

**File**: `mobile/lib/features/places/data/datasources/places_api.dart`

```dart
class PlacesApi {
  Future<List<Place>> listPlaces({
    required int skip,
    required int limit,
    String? category,
    String? province,
  }) async {
    final response = await dio.get(
      '/places',
      queryParameters: {
        'skip': skip,
        'limit': limit,
        if (category != null) 'category': category,
        if (province != null) 'province': province,
      },
    );
    
    return (response.data['places'] as List)
        .map((p) => Place.fromJson(p))
        .toList();
  }
  
  Future<Place> getPlace(String id) async {
    final response = await dio.get('/places/$id');
    return Place.fromJson(response.data['place']);
  }
  
  Future<List<Place>> searchPlaces(String query) async {
    final response = await dio.get(
      '/places/search',
      queryParameters: {'q': query},
    );
    return (response.data['places'] as List)
        .map((p) => Place.fromJson(p))
        .toList();
  }
}
```

### Step 3: Create Places UI

**Components**:

1. **PlaceCard** - Display single place
```dart
class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Photo
          Image.network(place.photos.first),
          // Name, category badge
          Text(place.name),
          // Rating, tags
          Row(children: [rating, ...tags]),
          // Map icon opens Google Maps pin
          IconButton(
            icon: Icon(Icons.map_outlined),
            onPressed: () => launchUrl(Uri.parse(place.googleMapsUrl)),
          ),
          // "View" or "Add to Trip" button
        ],
      ),
    );
  }
}
```

2. **PlacesListPage** - Browse all places with filters
```dart
class PlacesListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Explore Places')),
      body: Column(
        children: [
          // Search bar
          SearchBar(),
          // Filter chips
          FilterChips(),
          // Places grid/list
          PlacesList(),
        ],
      ),
    );
  }
}
```

3. **PlaceDetailPage** - Full place info
```dart
class PlaceDetailPage extends ConsumerWidget {
  final String placeId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final place = ref.watch(placeProvider(placeId));
    
    return Scaffold(
      body: ListView(
        children: [
          // Photo gallery
          PhotoGallery(place.photos),
          // Name, category
          PlaceHeader(place),
          // Rating & reviews
          RatingSection(place),
          // Description
          DescriptionSection(place),
          // Accessibility info
          AccessibilitySection(place),
          // "Add to Trip" button
          Button(
            label: 'Add to Trip',
            onPressed: () => _showTripSelector(),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Integrate with Trip Creation

Modify `create_trip_page.dart` to select places from Places list instead of free-text input:

```dart
// Instead of:
// _addPlace() { textField.add(...) }

// New approach:
_showPlaceSelector() {
  showModalBottomSheet(
    context: context,
    builder: (context) => PlacesListPage(
      onPlaceSelected: (place) {
        setState(() {
          trip.destinations.add(place);
        });
        Navigator.pop(context);
      },
    ),
  );
}
```

---

## Phase 4: Frontend - User Place Contribution

**Duration**: 1 week

### Step 1: Create PlaceSubmission Form

**File**: `mobile/lib/features/places/presentation/pages/submit_place_page.dart`

```dart
class SubmitPlacePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SubmitPlacePage> createState() => _SubmitPlacePageState();
}

class _SubmitPlacePageState extends ConsumerState<SubmitPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _photos = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suggest a Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              label: 'Place Name',
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 5,
              validator: (v) => (v?.length ?? 0) < 50 
                ? 'Min 50 characters' : null,
            ),
            
            // Category dropdown
            DropdownFormField<String>(
              label: 'Category',
              items: ['waterfall', 'mountain', 'beach', ...],
            ),
            
            // Province/District
            ProvinceDistrictSelector(),
            
            // Location picker (map)
            LocationPicker(),
            
            // Photo upload
            PhotoUploadSection(
              onPhotosSelected: (photos) {
                setState(() => _photos = photos);
              },
            ),
            
            // Accessibility info
            AccessibilityForm(),
            
            // Submit button
            ElevatedButton(
              onPressed: _submitPlace,
              child: Text('Submit for Review'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _submitPlace() async {
    if (!_formKey.currentState!.validate()) return;
    
    final request = PlaceRequest(
      name: _nameController.text,
      description: _descriptionController.text,
      photos: _photos,
      // ... other fields
    );
    
    await ref.read(placesProvider.notifier).submitPlace(request);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Submitted for review!'))
    );
    Navigator.pop(context);
  }
}
```

### Step 2: Photo Upload Handler

```dart
class PhotoUploadSection extends StatefulWidget {
  final Function(List<String>) onPhotosSelected;
  
  @override
  State<PhotoUploadSection> createState() => _PhotoUploadSectionState();
}

class _PhotoUploadSectionState extends State<PhotoUploadSection> {
  List<XFile> _selectedPhotos = [];
  
  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    
    if (images.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Please select at least 2 photos'))
      );
      return;
    }
    
    setState(() => _selectedPhotos = images);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Photos (min 2 required)'),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedPhotos.length,
            itemBuilder: (context, i) => Image.file(
              File(_selectedPhotos[i].path),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _pickPhotos,
          child: Text('📸 Add Photos'),
        ),
      ],
    );
  }
}
```

### Step 3: Submission Tracking

Add to user profile:

```dart
class UserProfilePage {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    return ListView(
      children: [
        // ... existing profile info
        
        // NEW: Contributions Section
        SectionHeader('My Contributions'),
        ContributionStats(
          totalSubmitted: user.placeSubmissions.total,
          totalApproved: user.placeSubmissions.approved,
          badges: user.badges,
        ),
        
        // List of contributed places
        if (user.placeSubmissions.approved > 0)
          ContributedPlacesList(user.placeSubmissions.places),
      ],
    );
  }
}
```

---

## Phase 5: Admin Dashboard

**Duration**: 1 week  
**Note**: Can be web-based or Flutter app (recommend web for admin tools)

### Option A: Web Admin Dashboard (React/Vue)

**Routes**:
- `/admin/places/requests` - Pending submissions
- `/admin/places/requests/:id` - Review single submission
- `/admin/places` - Manage all places

**Components**:

1. **PendingSubmissions**
```jsx
function PendingSubmissions() {
  const [requests, setRequests] = useState([]);
  
  return (
    <div>
      <h1>Pending Place Submissions ({requests.length})</h1>
      <Table>
        {requests.map(req => (
          <Row
            key={req.id}
            name={req.place.name}
            submittedBy={req.username}
            date={req.createdAt}
            onReview={() => navigate(`/requests/${req.id}`)}
          />
        ))}
      </Table>
    </div>
  );
}
```

2. **SubmissionReview**
```jsx
function SubmissionReview({ requestId }) {
  const request = useAsync(() => api.getRequest(requestId));
  
  return (
    <div>
      <PhotoGallery photos={request.place.photos} />
      <PlaceDetails place={request.place} />
      
      <VerificationChecklist>
        <CheckItem label="Place exists (verify on Google Maps)" />
        <CheckItem label="Coordinates are accurate" />
        <CheckItem label="No duplicate" />
        <CheckItem label="Legitimate/public location" />
        <CheckItem label="Photos show actual place" />
      </VerificationChecklist>
      
      <div>
        <Button
          variant="success"
          onClick={() => approveRequest(requestId)}
        >
          ✅ Approve
        </Button>
        <Button
          variant="danger"
          onClick={() => rejectRequest(requestId)}
        >
          ❌ Reject
        </Button>
      </div>
    </div>
  );
}
```

### Option B: Flutter Admin App

Create dedicated `admin_places_dashboard.dart` page in Flutter app with role-based access.

---

## Phase 6: Gamification

**Duration**: 3-4 days

### Step 1: Update User Model

Add to backend User model:

```javascript
contributedPlaces: {
  total: 0,
  approved: 0,
  places: [], // ObjectId references
  badges: [] // ["Explorer", "Local Guide", ...]
}
```

### Step 2: Badge Logic

```javascript
function awardBadges(user) {
  const approved = user.contributedPlaces.approved;
  const badges = [];
  
  if (approved >= 1) badges.push('Explorer');
  if (approved >= 5) badges.push('Local Guide');
  if (approved >= 10) badges.push('Place Curator');
  if (approved >= 20) badges.push('Community Legend');
  
  user.contributedPlaces.badges = badges;
  return user.save();
}
```

### Step 3: Leaderboard Endpoint

```javascript
router.get('/places/leaderboard', async (req, res) => {
  const leaders = await User.find()
    .select('username contributedPlaces.approved contributedPlaces.badges')
    .sort({ 'contributedPlaces.approved': -1 })
    .limit(10);
  
  res.json({ leaderboard: leaders });
});
```

### Step 4: Frontend Display

```dart
class ContributionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    return Column(
      children: [
        // Badges
        Row(
          children: user.badges.map((badge) => BadgeWidget(badge)).toList(),
        ),
        
        // Stats
        Text('Places Contributed: ${user.contributedPlaces.approved}'),
        
        // Leaderboard link
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LeaderboardPage()),
          ),
          child: Text('View Leaderboard'),
        ),
      ],
    );
  }
}
```

---

## Integration Checklist

### Phase 1 ✅
- [ ] Research complete
- [ ] places_seed_data.json created (50-100 places)
- [ ] Data validated

### Phase 2 ✅
- [ ] Place model + schema created
- [ ] PlaceRequest model created
- [ ] All API endpoints implemented
- [ ] Photo upload configured
- [ ] Bulk import script working

### Phase 3 ✅
- [ ] Place model in Flutter
- [ ] PlacesApi client working
- [ ] PlacesListPage complete
- [ ] PlaceDetailPage complete
- [ ] Integration with trip creation done

### Phase 4 ✅
- [ ] SubmitPlacePage form working
- [ ] Photo upload functional
- [ ] Form validation complete
- [ ] Submission tracking in profile

### Phase 5 ✅
- [ ] Admin dashboard deployed
- [ ] Approval workflow tested
- [ ] Rejection reasons working

### Phase 6 ✅
- [ ] Badge system functional
- [ ] Leaderboard displaying
- [ ] Profile stats showing

---

## Testing Strategy

### Backend Testing
```javascript
// Test place listing
GET /api/places?category=waterfall → 200 with places

// Test filtering
GET /api/places?province=Central%20Province → 200 filtered

// Test search
GET /api/places/search?q=sigiriya → 200 with results

// Test submission
POST /api/places/request → 201 with PlaceRequest created

// Test approval
PATCH /api/admin/places/requests/:id/approve → 200 with Place created
```

### Frontend Testing
- [ ] Places load and display correctly
- [ ] Filters work as expected
- [ ] Search returns results
- [ ] Submit form validates
- [ ] Photos upload successfully
- [ ] Profile shows contributions

### Admin Testing
- [ ] Pending list displays
- [ ] Can review submissions
- [ ] Approve creates place
- [ ] Reject deletes request
- [ ] User badge updates

---

## Deployment Order

1. ✅ Backend Places API + seed data import
2. ✅ Frontend Places discovery UI
3. ✅ Frontend submission form
4. ✅ Admin dashboard
5. ✅ Gamification layer

**Go-live readiness**: All 5 phases complete + testing passed

---

## Success Metrics

- Seed database with 50-100 places within 3 days
- Backend ready for 1000+ places (performance tested)
- 90%+ form submission to approval within 24 hours
- 50%+ of new trips use system places
- 100+ user contributions in first 3 months
- Leaderboard shows diverse contributors

