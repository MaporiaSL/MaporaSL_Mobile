# Shop Feature Specification

**Version**: 2.0  
**Last Updated**: January 29, 2026  
**Status**: Ready for Development  

---

## Overview

The MAPORIA Shop is a **hybrid e-commerce platform** with two integrated sections:

1. **Real Store** - Physical souvenirs and travel merchandise (LKR currency, manual bank transfer)
2. **In-App Shop** - Digital cosmetics (Gemstones currency, instant purchase)

---

## Real Store

### Features
- Browse Sri Lankan souvenirs, apparel, books, food, art, travel gear
- Shopping cart with persistent storage (30-day expiration)
- Bank transfer checkout with receipt verification
- Manual admin order processing and fulfillment
- Order tracking with status timeline

### Purchase Flow
```
Browse Items → Add to Cart → Checkout → Bank Transfer Details
→ User Transfers Offline → Upload Receipt → Order Confirmation
→ Admin Verification → Order Processing → Shipping & Delivery
```

### Pricing
- Currency: LKR (Sri Lankan Rupees)
- Calculation: Subtotal + 2.5% tax + Shipping (free over 10K LKR)
- Order IDs: ORD-YYYYMMDD-001 format (daily counter)

### Stock Management
- Real-time availability checking
- Cart reservations (released on expiry or purchase)
- Max quantity per item: 10
- Soft deletes for products

### Order Status Flow
```
pending_payment → payment_received → processing → shipped → delivered
```

---

## In-App Shop

### Features
- Browse cosmetics: avatar skins, frames, effects, map themes
- Instant purchase with Gemstones (earned through gameplay)
- Inventory with equipping system
- Rarity tiers: Common, Rare, Epic, Legendary
- Limited edition items with availability windows

### Purchase Flow
```
Browse Items → Select Item → Confirm Purchase → Add to Inventory → Equip
```

### Pricing
- Currency: Gemstones (5-100 per item)
- Future currency: Travel Coins
- No refunds (instant purchase)

### Categories
- Avatar Skins
- Avatar Frames & Emotes
- Map Themes & Markers
- Reveal Effects
- Sharing Frames
- Limited & Seasonal

---

## Database Schema

### Real Store Collections

**RealStoreItem**
- `itemId` (unique), `name`, `description`, `category`
- `price.lkr`, `price.originalPrice`
- `stock.available`, `stock.reservedInCart`, `stock.sold`
- `images[]`, `thumbnail`, `weight`, `dimensions`
- `shippingEstimateDays`, `tags[]`, `featured`, `displayOrder`
- `createdAt`, `updatedAt`, `deletedAt` (soft delete)

**ShoppingCart**
- `userId` (unique), `items[]` with quantity/price/subtotal
- `subtotal`, `tax`, `estimatedShipping`, `total`
- `status` (active/abandoned/converted), `expiresAt` (30 days)

**Order**
- `orderId` (unique), `userId`
- `items[]`, `pricing{}`, `bankDetails{}`
- `paymentReceipt{}` with verification status
- `status`, `statusHistory[]` with timeline
- `shippingAddress{}`, `trackingNumber`, delivery dates

**PaymentReceipt** (Audit Collection)
- `orderId`, `userId`
- `receiptUrl`, `transferAmount`, `transferDate`
- `verificationStatus`, `verifiedBy`, `verificationNotes`
- `rejectionReason`, `resubmissionAllowed`

### In-App Shop Collections

**InAppShopItem**
- `itemId`, `name`, `category`, `rarity`
- `cost.gemstones`, `cost.travelCoins`
- `availableFrom`, `availableUntil`
- `isLimitedEdition`, `maxPurchases`, `currentPurchaseCount`
- `thumbnail`, `fullImage`, `icon`, `tags[]`, `featured`, `displayOrder`

**UserInAppInventory**
- `userId` (unique)
- `gemstones`, `travelCoins` (balance)
- `items[]` with purchase date & equipped slot
- `equipped{}` (current equipped cosmetics per slot)

**InAppTransaction**
- `userId`, `itemId`, `quantity`
- `costType`, `costAmount`
- `status` (completed/refunded)
- `purchaseDate`, `transactionId` (UUID)

---

## API Endpoints (21 Total)

### Real Store (11)
```
GET    /api/store/items              - Browse products
GET    /api/store/items/:id          - Product details
GET    /api/store/items/category/:category
GET    /api/store/cart               - View cart
POST   /api/store/cart/add           - Add item
POST   /api/store/cart/remove        - Remove item
POST   /api/store/cart/update        - Update quantity
POST   /api/store/checkout           - Create order
POST   /api/store/payment/upload-receipt
GET    /api/store/orders             - User's orders
GET    /api/store/orders/:orderId    - Order details
```

### In-App Shop (4)
```
GET    /api/inapp-shop/items         - Browse cosmetics
GET    /api/inapp-shop/inventory     - User's inventory
POST   /api/inapp-shop/purchase      - Buy item
POST   /api/inapp-shop/equip         - Equip cosmetic
```

### Admin (6)
```
GET    /api/admin/orders             - Pending orders
POST   /api/admin/orders/:orderId/verify-receipt
POST   /api/admin/orders/:orderId/status
POST   /api/admin/store/items        - Create product
PUT    /api/admin/store/items/:id    - Update product
DELETE /api/admin/store/items/:id    - Delete product
```

---

## Payment Verification Workflow

1. User uploads receipt → Status: `pending`
2. Admin reviews receipt image
3. Admin verifies amount matches order total
4. **If valid**: Status: `verified`, order moves to `payment_received`
5. **If invalid**: Status: `rejected`, user can resubmit with reason
6. Admin then processes shipment

---

## Security

- Server-side validation of all purchases
- Rate limiting: 10 purchases/minute per user
- Duplicate purchase prevention (idempotent keys)
- Anomaly detection (flag 3x normal spend)
- Admin audit logging for all actions
- Firebase Storage for image upload
- Firebase ID token authentication required
- No P2W mechanics in in-app shop
- Stock verification before checkout
- Cart expiration cleanup

---

## Success Metrics

### Real Store
- Browse rate: 40% of monthly active users
- Add-to-cart: 20% of browsers
- Checkout completion: 70% of carts
- Avg order value: LKR 3,000-5,000
- Receipt upload rate: 95%
- Payment verification: <24 hours
- Monthly revenue: LKR 500K+ (Month 2)

### In-App Shop
- Browse rate: 60% weekly active users
- Purchase conversion: 15% of browsers
- Gems earned/day: 50-100 per user
- Equipped cosmetics: 50% of users
- Repeat purchasers: 30% buy 2+ items

---

## Phase Roadmap

| Phase | Focus | Duration | Details |
|-------|-------|----------|---------|
| 1 | Real Store Backend | Week 1-2 | Models, cart, APIs |
| 2 | Real Store Mobile | Week 2-3 | Shop UI, checkout, receipt upload |
| 3 | Admin Dashboard | Week 3-4 | Verification, order management |
| 4 | In-App Shop | Week 4-5 | Cosmetics, purchase, equipping |
| 5 (Future) | Payment Gateways | Q2 2026 | Credit card, eZ Cash, automation |
| 6 (Future) | Delivery Tracking | Q3 2026 | Courier integration, real-time tracking |
| 7 (Future) | Travel Coins & Marketplace | Q4 2026 | New currency, user cosmetics marketplace |

---

## Technology Stack

**Backend**: Node.js, Express, MongoDB  
**Mobile**: Flutter, Riverpod  
**Storage**: Firebase Storage  
**Currency**: LKR (Sri Lankan Rupees)  
**Payment**: Manual bank transfer (Phase 1), gateways (Phase 5)  
**Authentication**: Firebase Auth + dev bypass  

---

## Future Enhancements

### Phase 5: Payment Gateway Integration
- Credit/debit card (Visa, Mastercard)
- Sri Lankan methods: Dialog eZ Cash, Sampath Bank Online
- PayPal for international
- 3D Secure authentication
- Automated order confirmation

### Phase 6: Delivery Tracking
- Courier integration (QuickShaw, DHL, Royal Mail, Aramex)
- GPS tracking
- Automated status notifications
- Proof of delivery with signature/photo
- Return shipping management

### Phase 7: Travel Coins & Marketplace
- New in-app currency with different earning mechanics
- Player cosmetics marketplace (creators earn 60% revenue share)
- VIP exclusive items
- Limited edition releases from community

---

## Configuration

**Environment Variables**:
```
MONGO_URI=mongodb://...
BANK_ACCOUNT_NAME=MAPORIA pvt ltd
BANK_ACCOUNT_NUMBER=1234567890
BANK_NAME=Commercial Bank of Ceylon
FIREBASE_PROJECT_ID=maporia-project
FIREBASE_STORAGE_BUCKET=maporia-bucket
```

**Mobile Constants**:
```dart
class ShopConfig {
  static const int maxCartQuantity = 10;
  static const double taxRate = 0.025;
  static const double freeShippingThreshold = 10000;
  static const double baseShippingCost = 500;
}
```

---

## File References
- [Implementation Plan](./SHOP_IMPLEMENTATION.md)
- [Project Roadmap](../01_planning/PROJECT_SOURCE_OF_TRUTH.md)
- [API Reference](../04_api/API_REFERENCE.md)

**Status**: ✅ Complete | **Next**: Development Kickoff
