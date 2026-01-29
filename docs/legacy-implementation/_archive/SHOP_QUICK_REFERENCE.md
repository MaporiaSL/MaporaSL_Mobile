# MAPORIA Shop - Quick Reference Guide

**Version**: 2.0  
**Last Updated**: January 29, 2026  
**For**: Developers implementing the hybrid Shop feature

---

## One-Page Architecture Overview

```
MAPORIA SHOP (Hybrid Model)
├─ REAL STORE (E-Commerce)
│  ├─ Currency: LKR (Sri Lankan Rupees)
│  ├─ Products: Physical souvenirs, apparel, food, books, art
│  ├─ Payment: Manual bank transfer + receipt upload
│  ├─ Order Flow: Browse → Cart → Checkout → Bank Transfer → Receipt Upload → Order Tracking
│  ├─ Collections: RealStoreItem, ShoppingCart, Order, PaymentReceipt (4)
│  └─ API: 11 endpoints for browsing, cart, checkout, orders
│
└─ IN-APP SHOP (Cosmetics)
   ├─ Currency: Gemstones (earned through gameplay)
   ├─ Products: Avatar skins, frames, effects, map themes
   ├─ Payment: Instant purchase with game currency
   ├─ Order Flow: Browse → Purchase → Equip → Done
   ├─ Collections: InAppShopItem, UserInAppInventory, InAppTransaction (3)
   └─ API: 4 endpoints for browsing, inventory, purchase
```

---

## Database Collections Reference

### Real Store Collections

#### 1. RealStoreItem
```javascript
{
  itemId: String,              // unique, indexed
  name: String,
  category: String,            // enum: souvenirs, apparel, food, books, merch, art, travel-gear
  price: {
    lkr: Number,              // required
    originalPrice: Number,    // optional (for discounts)
  },
  stock: {
    available: Number,
    reservedInCart: Number,
    sold: Number,
  },
  images: [String],           // Firebase Storage URLs
  thumbnail: String,
  weight: Number,             // grams
  dimensions: { length, width, height },
  shippingEstimateDays: Number,
  tags: [String],             // ['popular', 'new', 'bestseller']
  featured: Boolean,          // indexed
  displayOrder: Number,       // indexed for sorting
  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date,            // soft delete
}
```

#### 2. ShoppingCart
```javascript
{
  userId: ObjectId,           // unique, indexed
  items: [{
    itemId: String,
    itemName: String,
    quantity: Number,         // 1-10
    unitPrice: Number,        // LKR
    subtotal: Number,
    addedAt: Date,
  }],
  subtotal: Number,
  tax: Number,
  estimatedShipping: Number,
  total: Number,
  status: String,             // 'active', 'abandoned', 'converted_to_order'
  expiresAt: Date,            // auto-deleted after 30 days
  createdAt: Date,
  updatedAt: Date,
}
```

#### 3. Order
```javascript
{
  orderId: String,            // unique, format: ORD-YYYYMMDD-001
  userId: ObjectId,           // indexed
  items: [{
    itemId: String,
    quantity: Number,
    unitPrice: Number,
    subtotal: Number,
  }],
  pricing: {
    subtotal: Number,
    tax: Number,
    shippingEstimate: Number,
    total: Number,
    currency: 'LKR',
  },
  bankDetails: {
    accountName: String,
    accountNumber: String,
    bankName: String,
    routingNumber: String,
    referenceId: String,      // for user to include in transfer
  },
  paymentReceipt: {
    receiptUrl: String,
    uploadedAt: Date,
    verifiedBy: ObjectId,     // admin
    verificationStatus: String, // 'pending', 'verified', 'rejected'
    verificationNotes: String,
    rejectionReason: String,
  },
  status: String,             // 'pending_payment', 'payment_received', 'processing', 'shipped', 'delivered'
  statusHistory: [{
    status: String,
    updatedAt: Date,
    notes: String,
    updatedBy: ObjectId,
  }],
  shippingAddress: {
    fullName: String,
    street: String,
    city: String,
    postalCode: String,
    phone: String,
    email: String,
    province: String,
  },
  trackingNumber: String,
  estimatedDeliveryDate: Date,
  actualDeliveryDate: Date,
  createdAt: Date,
  paymentVerifiedAt: Date,
  shippedAt: Date,
  deliveredAt: Date,
}
```

#### 4. PaymentReceipt (Audit Collection)
```javascript
{
  orderId: ObjectId,          // indexed
  userId: ObjectId,           // indexed
  receiptUrl: String,
  receiptFileName: String,
  uploadedAt: Date,           // indexed
  transferAmount: Number,     // LKR
  transferDate: Date,
  transferFromAccount: String,
  verificationStatus: String, // 'pending', 'verified', 'rejected'
  verifiedBy: ObjectId,
  verificationDate: Date,
  verificationNotes: String,
  rejectionReason: String,    // 'amount_mismatch', 'unclear_image', 'suspicious'
  resubmissionAllowed: Boolean,
  verificationAttempts: Number,
  createdAt: Date,
}
```

### In-App Shop Collections

#### 5. InAppShopItem
```javascript
{
  itemId: String,             // unique
  name: String,
  category: String,           // 'avatar-skin', 'map-theme', 'effect', 'frame'
  rarity: String,             // 'common', 'rare', 'epic', 'legendary'
  cost: {
    gemstones: Number,        // required
    travelCoins: Number,      // future
  },
  availableFrom: Date,
  availableUntil: Date,       // null for permanent
  isLimitedEdition: Boolean,
  maxPurchases: Number,       // null for unlimited
  currentPurchaseCount: Number,
  thumbnail: String,
  fullImage: String,
  icon: String,
  tags: [String],
  featured: Boolean,
  displayOrder: Number,
  createdAt: Date,
  updatedAt: Date,
}
```

#### 6. UserInAppInventory
```javascript
{
  userId: ObjectId,           // unique, indexed
  gemstones: Number,          // player's current gem balance
  travelCoins: Number,        // future
  items: [{
    itemId: String,
    purchaseDate: Date,
    quantity: Number,
    equippedSlot: String,     // null if not equipped
    expiresAt: Date,          // for time-limited items
  }],
  equipped: {
    avatarSkin: String,       // currently equipped
    avatarFrame: String,
    mapTheme: String,
    // ... other cosmetic slots
  },
  updatedAt: Date,
}
```

#### 7. InAppTransaction
```javascript
{
  userId: ObjectId,
  itemId: String,
  quantity: Number,
  costType: String,           // 'gemstones' or 'travelCoins'
  costAmount: Number,
  status: String,             // 'completed', 'refunded'
  purchaseDate: Date,
  transactionId: String,      // UUID for idempotency
}
```

---

## API Endpoints Cheat Sheet

### Real Store Endpoints (11 total)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/store/items` | Browse all products | Public |
| GET | `/api/store/items/:id` | Product details | Public |
| GET | `/api/store/items/category/:category` | Filter by category | Public |
| GET | `/api/store/cart` | View user's cart | Required |
| POST | `/api/store/cart/add` | Add item to cart | Required |
| POST | `/api/store/cart/remove` | Remove from cart | Required |
| POST | `/api/store/cart/update` | Update quantity | Required |
| POST | `/api/store/checkout` | Create order | Required |
| POST | `/api/store/payment/upload-receipt` | Upload payment proof | Required |
| GET | `/api/store/orders` | User's orders | Required |
| GET | `/api/store/orders/:orderId` | Order details | Required |

### In-App Shop Endpoints (4 total)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/inapp-shop/items` | Browse cosmetics | Public |
| GET | `/api/inapp-shop/inventory` | User's items | Required |
| POST | `/api/inapp-shop/purchase` | Buy item | Required |
| POST | `/api/inapp-shop/equip` | Equip cosmetic | Required |

### Admin Endpoints (6 total)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/admin/orders` | Pending orders | Admin |
| POST | `/api/admin/orders/:orderId/verify-receipt` | Approve/reject payment | Admin |
| POST | `/api/admin/orders/:orderId/status` | Update order status | Admin |
| POST | `/api/admin/store/items` | Create product | Admin |
| PUT | `/api/admin/store/items/:id` | Update product | Admin |
| DELETE | `/api/admin/store/items/:id` | Delete product | Admin |

---

## Key Implementation Details

### Cart Expiration
- Carts automatically expire after **30 days** of inactivity
- Stock reserved in cart is released when cart expires
- Use MongoDB TTL index: `expiresAt: 1` with `expireAfterSeconds: 0`

### Order IDs
- Format: `ORD-YYYYMMDD-001` (e.g., `ORD-20260129-001`)
- Sequence resets daily
- Reference ID: append timestamp to order ID for bank transfer memo

### Stock Management
```
availableStock = item.stock.available - item.stock.reservedInCart
// When user adds to cart: reservedInCart += quantity
// When user removes from cart: reservedInCart -= quantity
// When user completes order: available -= quantity, reservedInCart -= quantity
// When cart expires: reservedInCart -= quantity (no change to available)
```

### Price Calculation
```
subtotal = sum(item.quantity * item.unitPrice)
tax = subtotal * 0.025 // 2.5% tax
shipping = subtotal > 10000 ? 0 : 500 // Free shipping over 10K LKR
total = subtotal + tax + shipping
```

### Payment Verification Workflow
```
1. User uploads receipt → verificationStatus: 'pending'
2. Admin reviews receipt → checks amount matches order total
3. If valid → verificationStatus: 'verified', status: 'payment_received'
4. If invalid → verificationStatus: 'rejected', reason provided, allow resubmit
5. After verified → admin processes shipment
```

---

## Configuration & Environment Variables

### Backend .env
```
# Database
MONGO_URI=mongodb://localhost/maporia-shop

# Bank Account Details (shown to users at checkout)
BANK_ACCOUNT_NAME=MAPORIA pvt ltd
BANK_ACCOUNT_NUMBER=1234567890
BANK_NAME=Commercial Bank of Ceylon
BANK_ROUTING_NUMBER=CBSL1234

# Firebase Storage (for product images & receipts)
FIREBASE_PROJECT_ID=maporia-project
FIREBASE_STORAGE_BUCKET=maporia-bucket

# Auth
JWT_SECRET=your-secret-key
ADMIN_AUTH_KEY=admin-key

# Email (for notifications)
SENDGRID_API_KEY=your-sendgrid-key
```

### Mobile Constants
```dart
class ShopConfig {
  static const String baseUrl = 'https://api.maporia.app';
  
  // Real Store
  static const int maxCartQuantity = 10;
  static const List<String> realStoreCategories = [
    'souvenirs', 'apparel', 'travel-gear', 'books', 
    'food-spices', 'merch', 'art-prints'
  ];
  
  // In-App Shop
  static const List<String> inAppCategories = [
    'avatar-skin', 'avatar-frame', 'avatar-emote', 
    'map-theme', 'marker-style', 'reveal-effect'
  ];
  
  // Pricing
  static const double taxRate = 0.025;
  static const double freeShippingThreshold = 10000;
  static const double baseShippingCost = 500;
}
```

---

## Success Metrics

### Real Store KPIs
| Metric | Target | Timeline |
|--------|--------|----------|
| Store Browse Rate | 40% monthly active users | Month 1 |
| Add-to-Cart Rate | 20% of browsers | Month 1 |
| Checkout Completion | 70% of carts → orders | Ongoing |
| Avg Order Value | LKR 3,000-5,000 | Ongoing |
| Receipt Upload Rate | 95% of orders | Ongoing |
| Payment Verification Time | <24 hours admin | Ongoing |
| Monthly Revenue | LKR 500,000+ | Month 2 |

### In-App Shop KPIs
| Metric | Target | Timeline |
|--------|--------|----------|
| Browse Rate | 60% weekly active users | Month 1 |
| Purchase Conversion | 15% of browsers | Month 2 |
| Avg Gems Earned/Day | 50-100 per user | Ongoing |
| Equipped Items | 50% of users | Month 1 |
| Repeat Purchasers | 30% buy 2+ items | Month 2 |

---

## File Structure

```
backend/
├── src/
│   ├── models/
│   │   ├── RealStoreItem.js
│   │   ├── ShoppingCart.js
│   │   ├── Order.js
│   │   └── PaymentReceipt.js
│   ├── routes/
│   │   ├── realStore.js       (11 endpoints)
│   │   ├── inAppShop.js       (4 endpoints)
│   │   └── adminStore.js      (6 endpoints)
│   ├── services/
│   │   ├── cartService.js
│   │   ├── orderService.js
│   │   └── paymentService.js
│   └── middleware/
│       ├── auth.js
│       └── upload.js          (multer for receipt upload)
│
mobile/lib/
├── features/shop/
│   ├── models/
│   │   └── real_store_models.dart
│   ├── services/
│   │   └── real_store_service.dart
│   ├── providers/
│   │   └── real_store_providers.dart
│   ├── screens/
│   │   ├── shop_screen.dart
│   │   ├── shopping_cart_screen.dart
│   │   └── checkout_screen.dart
│   └── widgets/
│       ├── store_item_card.dart
│       ├── cart_item_tile.dart
│       └── bank_details_card.dart
```

---

## Development Checklist

### Phase 1: Backend
- [ ] MongoDB models created & tested
- [ ] Cart service with stock management
- [ ] Real store API endpoints (11 total)
- [ ] Admin endpoints for verification
- [ ] Receipt upload middleware
- [ ] Order creation & status tracking
- [ ] Database indexes for performance
- [ ] Environment variables configured

### Phase 2: Mobile UI
- [ ] Shop screen with Real Store tab
- [ ] Product browsing & filtering
- [ ] Shopping cart implementation
- [ ] Checkout screen with bank details
- [ ] Receipt image upload
- [ ] Order tracking screen
- [ ] Cart expiration notification
- [ ] Error handling & validation

### Phase 3: Testing
- [ ] Unit tests for cart service
- [ ] Integration tests for checkout
- [ ] Admin verification workflow test
- [ ] Receipt upload validation test
- [ ] Stock management test
- [ ] Mobile UI responsiveness test
- [ ] End-to-end order flow test

### Phase 4: Deployment
- [ ] Staging environment testing
- [ ] Admin dashboard for order management
- [ ] In-app shop integration
- [ ] Production rollout plan
- [ ] Performance monitoring
- [ ] User support documentation

---

## Common Issues & Troubleshooting

### Stock Management Issues
**Problem**: Multiple users can add same item beyond available stock  
**Solution**: Use MongoDB `$inc` operator and check before-and-after values

### Cart Expiration
**Problem**: Users lose carts after 30 days  
**Solution**: Notify users before expiration, allow cart saving in profile

### Receipt Upload Failures
**Problem**: Large receipt images fail to upload  
**Solution**: Compress images client-side before upload, set max file size

### Payment Verification Delays
**Problem**: Orders stuck in "pending_payment" status  
**Solution**: Send daily reminder emails to admins about pending verifications

---

## Useful Commands

### Initialize Product Database
```bash
node backend/scripts/init-real-store.js
```

### Create Test Order
```bash
curl -X POST http://localhost:3000/api/store/checkout \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "shippingAddress": {
      "fullName": "John Doe",
      "street": "123 Main St",
      "city": "Colombo",
      "phone": "0712345678",
      "email": "john@example.com"
    }
  }'
```

### Admin: Get Pending Orders
```bash
curl http://localhost:3000/api/admin/orders?status=pending_payment \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

## Future Enhancements

- **Phase 5**: Payment gateway integration (credit card, eZ Cash)
- **Phase 6**: Delivery tracking with courier APIs
- **Phase 7**: Travel Coins marketplace for user cosmetics
- **Phase 8**: Revenue analytics & A/B testing

---

**Questions?** Refer to `SHOP_FEATURE_SPEC.md` for detailed documentation.
