# MAPORIA Shop Feature - Documentation Summary

**Date**: January 29, 2026  
**Status**: Documentation Complete - Ready for Development  
**Prepared for**: Development Team

---

## Executive Summary

The MAPORIA Shop is a **hybrid e-commerce platform** combining two distinct sections:

1. **Real Store** - Physical products with manual bank transfer payments
2. **In-App Shop** - Digital cosmetics purchased with gameplay currency

All documentation has been completed with comprehensive code examples, API specifications, and implementation timelines.

---

## Documentation Files

### 1. SHOP_FEATURE_SPEC.md (24.9 KB)
**Purpose**: Complete feature specification and design document

**Contents**:
- Executive summary with hybrid architecture explanation
- Feature overview for both Real Store and In-App Shop
- Currency & pricing system (LKR vs Gemstones)
- Complete database schema (7 MongoDB collections)
- User flows (4 detailed processes)
- Technical requirements (21 API endpoints)
- Success metrics (separate KPIs for each shop)
- Phase roadmap (7 phases through future)
- Security & fraud prevention measures
- Gamification psychology for in-app shop
- Future features roadmap (Phases 5-8)

**Target Audience**: Product managers, architects, team leads

### 2. SHOP_IMPLEMENTATION_PLAN.md (56 KB)
**Purpose**: Step-by-step implementation guide with code examples

**Contents**:
- Phase-by-phase breakdown (Phases 1-5)
- Complete MongoDB model definitions (4 new collections)
- Cart management service with full implementation
- Backend API endpoints with code (all 11 real store endpoints)
- Riverpod providers for mobile state management
- Flutter UI components (shopping cart, checkout, bank details)
- Admin dashboard API endpoints
- Testing checklist
- Deployment strategy

**Target Audience**: Backend developers, mobile developers, QA

### 3. SHOP_QUICK_REFERENCE.md (15.5 KB)
**Purpose**: Developer quick reference and cheat sheet

**Contents**:
- One-page architecture overview
- Database collections quick reference
- API endpoint cheat sheet
- Key implementation details (stock management, pricing, payment flow)
- Configuration & environment variables
- Success metrics summary
- File structure diagram
- Development checklist
- Troubleshooting guide
- Useful commands

**Target Audience**: All developers (reference during development)

### 4. CHANGELOG.md (Updated)
**Purpose**: Project changelog with feature tracking

**Changes**: Updated with comprehensive Shop feature entry documenting:
- Hybrid model clarification
- Real Store vs In-App Shop distinction
- Implementation timeline
- Key features and technical scope
- Next steps for team

---

## Key Technical Specifications

### Database Schema (7 Collections)

**Real Store Collections**:
1. `RealStoreItem` - Product catalog (7 categories)
2. `ShoppingCart` - Persistent user carts (30-day expiry)
3. `Order` - Complete order records with status tracking
4. `PaymentReceipt` - Separate audit collection for verification

**In-App Shop Collections**:
5. `InAppShopItem` - Cosmetics inventory
6. `UserInAppInventory` - Player cosmetics ownership & equipping
7. `InAppTransaction` - Purchase transaction audit trail

### API Endpoints (21 Total)

**Real Store**: 11 endpoints
```
GET  /api/store/items                       - Browse products
GET  /api/store/items/:id                   - Product details
GET  /api/store/items/category/:category    - Filter by category
GET  /api/store/cart                        - View cart
POST /api/store/cart/add                    - Add to cart
POST /api/store/cart/remove                 - Remove from cart
POST /api/store/cart/update                 - Update quantity
POST /api/store/checkout                    - Create order
POST /api/store/payment/upload-receipt      - Upload receipt
GET  /api/store/orders                      - User's orders
GET  /api/store/orders/:orderId             - Order details
```

**In-App Shop**: 4 endpoints
```
GET  /api/inapp-shop/items                  - Browse cosmetics
GET  /api/inapp-shop/inventory              - User inventory
POST /api/inapp-shop/purchase               - Buy item
POST /api/inapp-shop/equip                  - Equip cosmetic
```

**Admin**: 6 endpoints
```
GET  /api/admin/orders                      - Pending orders
POST /api/admin/orders/:orderId/verify-receipt
POST /api/admin/orders/:orderId/status
POST /api/admin/store/items                 - Create product
PUT  /api/admin/store/items/:id             - Update product
DELETE /api/admin/store/items/:id           - Delete product
```

### Real Store Features

**Purchase Flow**:
1. User browses products by category
2. Adds items to persistent cart
3. Proceeds to checkout
4. Enters shipping address
5. System displays bank account details with unique reference ID
6. User transfers money offline to bank account
7. User uploads bank transfer receipt as proof
8. Order created with `status: pending_payment`
9. Admin reviews receipt and verifies payment
10. Order status updates to `payment_received`
11. Admin processes shipment and updates status
12. User tracks order status in real-time

**Key Details**:
- Currency: LKR (Sri Lankan Rupees only)
- Categories: Souvenirs, apparel, books, food, merch, art prints, travel gear
- Stock Management: Real-time availability with cart reservations
- Pricing: Subtotal + 2.5% tax + shipping (free over 10K LKR)
- Cart Expiration: 30 days with automatic cleanup
- Payment Verification: Manual admin review of receipts
- Order ID Format: ORD-YYYYMMDD-001 (daily sequence)

### In-App Shop Features

**Purchase Flow**:
1. User browses cosmetics by category
2. Selects item with gem cost
3. Confirmation dialog
4. Purchase completes instantly
5. Item added to inventory
6. User can equip item to profile
7. Changes visible immediately to other users

**Key Details**:
- Currency: Gemstones earned through gameplay
- Item Types: Avatar skins, frames, emotes, map themes, effects
- Rarity: Common, Rare, Epic, Legendary
- Instant Purchase: No manual processing
- Equipping: Unequips previous item in same slot
- Limited Editions: Time-based availability with count-down timers

---

## Implementation Timeline

### Phase 1: Real Store MVP Backend (Week 1-2)
- MongoDB models (4 collections)
- Cart service with stock management
- 11 API endpoints
- Receipt upload infrastructure
- Admin verification endpoints

### Phase 2: Real Store Mobile UI (Week 2-3)
- Shop screen with Real Store tab
- Product browsing & filtering
- Shopping cart implementation
- Checkout screen with bank details
- Receipt image upload interface

### Phase 3: Admin Dashboard (Week 3-4)
- Receipt verification interface
- Order status management
- Product CRUD operations
- Dashboard statistics

### Phase 4: In-App Shop (Week 4-5)
- InAppShopItem & UserInAppInventory models
- 4 cosmetics API endpoints
- Mobile cosmetics browsing UI
- Purchase & equipping system

### Phase 5+: Future Enhancements (Q2 2026+)
- Payment gateway integration (Phase 5)
- Delivery tracking automation (Phase 6)
- Travel Coins marketplace (Phase 7)
- Revenue analytics (Phase 8)

---

## Success Metrics

### Real Store (Month 1-3)
| Metric | Target |
|--------|--------|
| Store Browse Rate | 40% of monthly active users |
| Add-to-Cart Conversion | 20% of browsers |
| Checkout Completion | 70% of carts |
| Avg Order Value | LKR 3,000-5,000 |
| Receipt Upload Rate | 95% of orders |
| Payment Verification Time | <24 hours |
| Monthly Revenue | LKR 500,000+ (Month 2) |

### In-App Shop (Month 1-3)
| Metric | Target |
|--------|--------|
| Browse Rate | 60% of weekly active users |
| Purchase Conversion | 15% of browsers |
| Avg Gems Earned/Day | 50-100 per user |
| Equipped Cosmetics | 50% of users |
| Repeat Purchasers | 30% buy 2+ items |

---

## File Structure

```
docs/06_implementation/
├── SHOP_FEATURE_SPEC.md           ✅ Complete feature spec
├── SHOP_IMPLEMENTATION_PLAN.md    ✅ Step-by-step implementation
└── SHOP_QUICK_REFERENCE.md        ✅ Developer quick reference

backend/src/
├── models/
│   ├── RealStoreItem.js           (To be created)
│   ├── ShoppingCart.js            (To be created)
│   ├── Order.js                   (To be created)
│   └── PaymentReceipt.js          (To be created)
├── routes/
│   ├── realStore.js               (To be created - 11 endpoints)
│   ├── inAppShop.js               (To be created - 4 endpoints)
│   └── adminStore.js              (To be created - 6 endpoints)
├── services/
│   ├── cartService.js             (To be created)
│   ├── orderService.js            (To be created)
│   └── paymentService.js          (To be created)
└── middleware/
    ├── auth.js                    (Exists, extend for admin)
    └── upload.js                  (To be created - multer)

mobile/lib/features/shop/
├── models/
│   └── real_store_models.dart     (To be created)
├── services/
│   └── real_store_service.dart    (To be created)
├── providers/
│   └── real_store_providers.dart  (To be created)
├── screens/
│   ├── shop_screen.dart           (To be created)
│   ├── shopping_cart_screen.dart  (To be created)
│   └── checkout_screen.dart       (To be created)
└── widgets/
    ├── store_item_card.dart       (To be created)
    ├── cart_item_tile.dart        (To be created)
    └── bank_details_card.dart     (To be created)
```

---

## Documentation Quality Checklist

✅ **SHOP_FEATURE_SPEC.md**
- [x] Executive summary with hybrid model clarity
- [x] Complete feature overview for both shops
- [x] Currency system documented
- [x] All 7 database collections specified
- [x] 4 detailed user flows provided
- [x] 21 API endpoints listed
- [x] Success metrics defined
- [x] Phase roadmap (7 phases) included
- [x] Future features documented (Phases 5-8)
- [x] Security & fraud prevention measures

✅ **SHOP_IMPLEMENTATION_PLAN.md**
- [x] Phase-by-phase breakdown
- [x] Complete code examples for models
- [x] Cart service implementation
- [x] All 11 real store endpoint code
- [x] Riverpod providers code
- [x] Flutter UI component examples
- [x] Admin API endpoints
- [x] Testing & deployment strategy
- [x] 56 KB comprehensive guide

✅ **SHOP_QUICK_REFERENCE.md**
- [x] One-page architecture overview
- [x] Database schema quick reference
- [x] API endpoint cheat sheet
- [x] Key implementation details
- [x] Configuration examples
- [x] Success metrics summary
- [x] File structure diagram
- [x] Troubleshooting guide
- [x] Developer-friendly format

---

## How to Use These Documents

### For Project Managers
1. Read **SHOP_FEATURE_SPEC.md** executive summary
2. Review success metrics and phase timeline
3. Share with stakeholders for approval

### For Architects
1. Study **SHOP_FEATURE_SPEC.md** technical requirements section
2. Review database schemas and API architecture
3. Use as foundation for system design

### For Backend Developers
1. Reference **SHOP_IMPLEMENTATION_PLAN.md** Phase 1
2. Copy MongoDB model definitions
3. Implement cart service using provided code
4. Use **SHOP_QUICK_REFERENCE.md** for quick lookups

### For Mobile Developers
1. Reference **SHOP_IMPLEMENTATION_PLAN.md** Phase 2-3
2. Copy Riverpod provider patterns
3. Implement Flutter UI using provided components
4. Follow user flows from specification

### For QA/Testing
1. Review **SHOP_IMPLEMENTATION_PLAN.md** testing section
2. Create test cases for each user flow
3. Use troubleshooting guide for common issues

### For DevOps/Deployment
1. Review Phase 5 deployment strategy
2. Prepare staging environment
3. Plan rollout phases (10% → 50% → 100%)

---

## Key Decisions Made

### Real Store Payment Strategy
**Decision**: Manual bank transfer + receipt upload for Phase 1  
**Rationale**: Fastest to implement, works with Sri Lankan banking practices  
**Future**: Payment gateway integration (Phase 5) for automation  

### Cart Expiration
**Decision**: 30 days automatic expiration  
**Rationale**: Balances user convenience with inventory management  
**Implementation**: MongoDB TTL index for automatic cleanup  

### Currency Separation
**Decision**: LKR for real store only, Gemstones for in-app only  
**Rationale**: Clear business model separation, prevents confusion  
**Future**: Travel Coins adds third currency for in-app marketplace  

### Soft Delete Strategy
**Decision**: Use `deletedAt` field instead of hard delete  
**Rationale**: Preserves audit trail, allows recovery, maintains historical data  

### Stock Reservation
**Decision**: Reserve stock when added to cart, release on expiration  
**Rationale**: Prevents overselling while maintaining user experience  

---

## Critical Implementation Notes

### Security
- All receipt uploads go through Firebase Storage
- Server-side validation of all cart operations
- Rate limiting: Max 10 purchases/minute per user
- Admin audit log for all receipt verifications
- No direct gem trading between players

### Performance
- Database indexes on: itemId, userId, status, featured
- Cart calculated on-demand to avoid stale data
- Pagination: 20 items per page default
- Image optimization: Thumbnails + full images cached

### Accessibility
- All prices displayed in LKR with clear formatting
- Receipt upload with file type validation
- Mobile-first responsive design
- Clear error messages for failed operations

---

## Next Steps for Development Team

1. **Week 1-2 (Backend)**
   - Create MongoDB models using provided schemas
   - Implement cart service from provided code
   - Create 11 real store API endpoints
   - Set up receipt upload infrastructure

2. **Week 2-3 (Mobile)**
   - Create Riverpod providers
   - Build shop screen and product listing
   - Implement shopping cart UI
   - Create checkout flow with bank details

3. **Week 3-4 (Admin)**
   - Build admin verification interface
   - Create order management dashboard
   - Implement product CRUD operations

4. **Week 4-5 (In-App)**
   - Create in-app shop models and APIs
   - Build cosmetics browsing and purchase UI
   - Implement equipping system

5. **Week 5+ (Testing & Deployment)**
   - Run comprehensive test suite
   - Deploy to staging environment
   - Conduct alpha testing with team
   - Plan production rollout phases

---

## Support & Questions

### Documentation References
- **Architecture Questions** → SHOP_FEATURE_SPEC.md sections 1-4
- **Implementation Questions** → SHOP_IMPLEMENTATION_PLAN.md Phase details
- **Quick Lookup** → SHOP_QUICK_REFERENCE.md
- **API Specifications** → API_REFERENCE.md (to be updated)

### Common Questions Answered
- *Q: How is payment verified?* → Admin manually reviews receipt
- *Q: Can users get refunds?* → Manual refund process via admin (future automation)
- *Q: What happens to carts after 30 days?* → Automatic expiration with user notification
- *Q: How do we prevent stock overselling?* → Cart reservation system
- *Q: What about international customers?* → Future: PayPal support in Phase 5

---

## Document Versioning

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 29, 2026 | Initial in-game cosmetics shop spec |
| 2.0 | Jan 29, 2026 | Complete rewrite for hybrid model (Real Store + In-App) |

---

## Acknowledgments

**Documentation created**: January 29, 2026  
**Based on user feedback**: Clarification that Shop is a real e-commerce store with manual bank transfer payments, not an in-game currency marketplace  
**Ready for**: Backend & Mobile development teams

---

**Status**: ✅ DOCUMENTATION COMPLETE - READY FOR DEVELOPMENT KICKOFF

For questions or clarifications, refer to the detailed documentation files or reach out to the product team.
