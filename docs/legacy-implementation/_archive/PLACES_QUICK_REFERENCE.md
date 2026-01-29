# Places Feature - Quick Reference

**Status**: 📋 Planning Complete | 🛠️ Ready for Implementation  
**Criticality**: 🔴 CRITICAL - Foundational system

---

## Why Places Matter

**Every trip creation starts with selecting Places.**

Without this system:
- ❌ Users can't discover attractions
- ❌ Trip planning lacks structure
- ❌ Community contributions ignored
- ❌ No verified, curated location data

---

## The Three Documents

| Document | Pages | Purpose |
|----------|-------|---------|
| [PLACES_FEATURE_SPEC.md](PLACES_FEATURE_SPEC.md) | 8 | **WHAT**: Feature design, data models, workflows |
| [PLACES_IMPLEMENTATION_PLAN.md](PLACES_IMPLEMENTATION_PLAN.md) | 50+ | **HOW**: Step-by-step implementation guide |
| [PLACES_PLANNING_SUMMARY.md](PLACES_PLANNING_SUMMARY.md) | 6 | **SUMMARY**: Overview & quick reference |

---

## Key Numbers

| Metric | Value |
|--------|-------|
| Initial seed places | 42 curated attractions |
| Target capacity | 1000+ places (Sri Lanka) |
| Admin review time | 24 hours |
| User badges | 4 tiers |
| Data fields per place | 15+ |
| Implementation phases | 6 phases |
| Estimated duration | 6-8 weeks |

---

## Place Data Structure

```
Place = {
  name, description,
  category (waterfall/mountain/beach/temple/historical/forest/garden/city),
  province, district,
  coordinates (lat/lng),
  googleMapsUrl (direct pin link),
  photos (2+ required),
  accessibility (season/difficulty/duration/fee),
  rating, reviewCount,
  tags, source (system|user),
  contributor, verified
}
```

---

## Implementation Phases at a Glance

| Phase | Duration | Owner | Deliverable |
|-------|----------|-------|-------------|
| 1 | 2-3 days | Developer | `places_seed_data.json` (42 places) |
| 2 | 1 week | Backend | API endpoints + photo upload |
| 3 | 1 week | Frontend | Discovery UI + trip integration |
| 4 | 1 week | Frontend | Submission form + validation |
| 5 | 1 week | Admin | Review dashboard + workflow |
| 6 | 3-4 days | All | Badges, leaderboard, stats |

---

## Critical API Endpoints (Phase 2)

### Public
```
GET  /api/places                 # List all (paginated, filterable)
GET  /api/places/:id            # Get single place
GET  /api/places/search?q=name  # Search
```

### User
```
POST /api/places/request        # Submit new place
GET  /api/places/requests/:id   # View submissions
```

### Admin
```
GET  /api/admin/places/requests       # Pending list
PATCH /api/admin/places/requests/:id/approve   # Approve
PATCH /api/admin/places/requests/:id/reject    # Reject
POST /api/admin/places                # Bulk import
```

---

## Frontend Components (Phase 3-4)

### Discovery (Phase 3)
- `PlaceCard` - Single place preview
- `PlaceListPage` - Browse all places (search, filter, infinite scroll)
- `PlaceDetailPage` - Full place info + "Add to Trip" button

### Contribution (Phase 4)
- `SubmitPlacePage` - Submission form
- `PhotoUploadSection` - Multi-photo picker
- `ProvinceDistrictSelector` - Cascading location picker
- `LocationPicker` - Map-based coordinate selection

### Profile (Phase 6)
- `ContributionsSection` - Stats, badges, list
- `LeaderboardPage` - Top contributors ranking

---

## Admin Dashboard (Phase 5)

### Views
- Pending submissions list (with counts)
- Submission detail + photo gallery
- Verification checklist UI
- Approve/reject interface
- Bulk actions

### Features
- Status filtering (pending/approved/rejected)
- Date range filtering
- Photo gallery lightbox
- Approval reasons (preset)
- Contributor reputation tracking

---

## User Badges (Gamification)

| Badge | Icon | Requirement |
|-------|------|-------------|
| Explorer | 🏅 | 1 approved |
| Local Guide | 🎖️ | 5 approved |
| Place Curator | 👑 | 10 approved |
| Community Legend | 🌟 | 20+ approved |

---

## Seed Data Status

✅ **42 curated Sri Lankan attractions** in JSON ready for import:
- Sigiriya, Kandy Temple, Anuradhapura, Polonnaruwa
- Yala, Sinharaja, Horton Plains
- Mirissa, Unawatuna, Galle Fort
- Adams Peak, Knuckles Range
- Dambulla, Peradeniya Gardens
- Ella, Ravana Falls, St. Clair Falls, Dunbar Falls
- Colombo, Nuwara Eliya
- + more...

**File**: `project_resorces/places_seed_data.json`

---

## Integration with Trips

**Current (without Places)**:
```
Trip Creation → Manual text input of destinations
```

**After Places (Phase 3)**:
```
Trip Creation → Search/Browse Places → Select from curated list → System routes
```

---

## Security & Verification

✅ Photo validation (clear, unblurred)  
✅ Location validation (within Sri Lanka)  
✅ Duplicate detection (name + location match)  
✅ Legitimacy check (not private/restricted)  
✅ Spam prevention (rate limiting)  
✅ Admin review before listing  

---

## Success Metrics (Go-Live)

- ✅ 50-100 verified places in database
- ✅ System handles 1000+ places (performance tested)
- ✅ Place discovery UI integrated with trips
- ✅ User submission form working
- ✅ Admin approval workflow functional
- ✅ 90%+ submission approval rate
- ✅ 100+ community contributions in first 3 months

---

## Document Links

- **Full Spec**: [PLACES_FEATURE_SPEC.md](./PLACES_FEATURE_SPEC.md)
- **Implementation**: [PLACES_IMPLEMENTATION_PLAN.md](./PLACES_IMPLEMENTATION_PLAN.md)
- **Planning Summary**: [PLACES_PLANNING_SUMMARY.md](./PLACES_PLANNING_SUMMARY.md)
- **Seed Data**: [places_seed_data.json](../../project_resorces/places_seed_data.json)
- **Project Truth**: [PROJECT_SOURCE_OF_TRUTH.md](../01_planning/PROJECT_SOURCE_OF_TRUTH.md)

---

## Questions?

Refer to the full spec documents or reach out to development team.

**Next Step**: Backend team → Start Phase 2 implementation

