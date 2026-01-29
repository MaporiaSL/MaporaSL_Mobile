# MAPORIA Shop Feature Specification

**Version**: 2.0  
**Date**: January 29, 2026 (Updated)  
**Status**: Planning Phase  
**Owner**: Product Team

---

## 📋 Executive Summary

The MAPORIA Shop is a **hybrid e-commerce platform** with two integrated sections:

1. **Real Store** (Primary) - Physical souvenirs and travel merchandise
   - Users purchase real Sri Lankan souvenirs, travel gear, books, apparel in **LKR (Sri Lankan Rupees)**
   - Cart system → Manual bank transfer checkout → Receipt upload → Order fulfillment by admins
   - Orders tracked with metadata: item list, price, receipt reference, delivery status
   - Future: Payment gateway integration, online payment methods, automated delivery tracking

2. **In-App Shop** (Secondary) - Digital cosmetics and sharing items
   - Users spend in-app currency (**Gemstones** or future **Travel Coins**) earned through gameplay
   - Items: Avatar skins, frames, emotes, map themes, sharing frames, effects
   - Instant purchase and equip system
   - Future: In-app currency marketplace, trading systems

---

## 🎯 Feature Overview

### Real Store (E-Commerce Section)

**What Users Can Buy**:
- 🎁 Sri Lankan souvenirs (crafts, textiles, masks, jewelry)
- 🎒 Travel gear (backpacks, water bottles, hats, sun protection)
- 📚 Travel guides and books about Sri Lanka
- 👕 MAPORIA branded merchandise (t-shirts, hoodies, caps)
- 🍜 Local specialty foods and spices (packaged)
- 📷 Prints of Sri Lankan landmarks (available as framed art)

**Purchase Process**:
```
Browse Items → Add to Cart → Review Cart → Proceed to Checkout
   ↓
Display Bank Account Details (for manual transfer)
   ↓
User transfers money to bank account
   ↓
User uploads transfer receipt as proof
   ↓
Order confirmed & moved to "My Purchases"
   ↓
Admin reviews receipt & processes order
   ↓
Item shipped & delivery tracked manually
```

**Currency**: LKR (Sri Lankan Rupees) only
**Payment Method**: Bank transfer (manual) for Phase 1
**Future Methods**: Credit card, PayPal, Dialog Axiata eZ Cash, etc.

### In-App Shop (Cosmetics Section)

**What Users Can Buy**:
- 🧑 Avatar skins (themed costumes)
- 🖼️ Avatar frames (decorative borders)
- 😊 Avatar emotes (animations)
- 🗺️ Map themes (visual customizations)
- 🎯 Marker styles (custom place pins)
- 🌌 Reveal effects (fog-of-war animations)
- 📸 Sharing frames (for photo exports)
- ✨ Chat effects and animations

**Currency**: Gemstones (earned through gameplay) or Travel Coins (future)
**Pricing**: 5-100 gems/coins per item
**Instant**: Purchase and equip immediately (no manual processing)

---

## 💰 Currency & Pricing System

### Real Store Currency: LKR (Sri Lankan Rupees)

**Item Pricing Examples**:
- Souvenir items: LKR 500 - 5,000
- T-shirts: LKR 1,500 - 3,500
- Travel guides: LKR 2,000 - 4,500
- Framed prints: LKR 3,000 - 8,000
- Travel gear: LKR 5,000 - 20,000

**Payment Flow**:
1. Bank account details displayed at checkout
2. User transfers money offline
3. User uploads receipt as proof
4. Order confirmed after receipt verification
5. Admin processes payment and ships item

### In-App Shop Currency: Gemstones (Phase 1) / Travel Coins (Future)

**Earned Through**:
- ✅ Completing achievement tiers (10-100 gems)
- ✅ District completion (50 gems per district)
- ✅ Province completion (200 gems per province)
- ✅ First place visit of day (10 gems)
- ✅ Memory lane entries (5 gems each)
- ✅ Seasonal challenges (100+ gems)

**Spending**: One-way conversion (non-refundable for in-app items)

**Future Currency (Travel Coins)**:
- Separate currency designed later
- Possible uses: VIP status, special experiences, premium features
- Could be earned through different activities

---

## 🏪 Shop Categories

### Real Store Categories

**1. Souvenirs & Crafts**
- Wooden masks & carvings
- Batik fabrics and wall hangings
- Pottery and ceramics
- Metal lacework (Jaladhari)
- Beaded jewelry and accessories

**2. Travel Apparel**
- T-shirts with Sri Lankan landmarks
- Hoodies and sweaters
- Hats (baseball caps, sun hats)
- Scarves and shawls
- Water-resistant jackets

**3. Travel Essentials**
- Backpacks (20L-40L)
- Water bottles (insulated)
- Travel pillows
- Packing cubes
- Portable chargers

**4. Books & Guides**
- Lonely Planet Sri Lanka
- Trekking guides
- Cultural history books
- Photography guides
- Local food guides

**5. Food & Spices**
- Curry powder blends
- Tea from Nuwara Eliya
- Spice sets
- Dried fruits
- Local sweets (packaged)

**6. MAPORIA Branded Merchandise**
- Official t-shirts
- Caps with MAPORIA logo
- Stickers and badges
- Pins for backpacks
- Shoulder bags

**7. Local Art & Prints**
- Framed prints of landmarks
- Canvas paintings
- Photography prints
- Limited edition artist collaborations

### In-App Shop Categories

**1. Avatar Customization**
- Avatar skins (regional themes)
- Avatar frames (decorative borders)
- Avatar emotes (animations)
- Status icons

**2. Map Customization**
- Map themes (vintage, festival, night mode)
- Marker styles
- Trail markers
- Reveal effect animations

**3. Sharing Features**
- Photo export frames
- Social share watermarks
- Profile card backgrounds
- Achievement display frames

**4. Visual Effects**
- Chat message effects
- Achievement unlock animations
- Notification styles
- UI theme variations

**5. Limited & Seasonal**
- Event-specific items
- Holiday-themed cosmetics
- Festival items (Vesak, New Year, etc.)

---

## 📊 Shop Database Schema

### Real Store Models

#### RealStoreItem (MongoDB)

```javascript
{
  _id: ObjectId,
  itemId: String, // "souvenir-001", "apparel-tshirt-001"
  name: String, // "Sri Lankan Tea Set"
  description: String,
  category: String, // "souvenirs", "apparel", "food", "books", "merch", "art"
  
  // Pricing in LKR
  price: {
    lkr: Number, // required (e.g., 2500)
    originalPrice: Number, // before discount (optional)
  },
  
  // Stock management
  stock: {
    available: Number,
    reservedInCart: Number,
    sold: Number,
  },
  
  // Product details
  description: String,
  longDescription: String, // detailed specs
  images: [String], // URLs to product images
  thumbnail: String, // preview image
  
  // Shipping & delivery
  weight: Number, // grams
  dimensions: {
    length: Number,
    width: Number,
    height: Number,
  },
  shippingEstimateDays: Number, // e.g., 3-5 days
  
  // Tags and categorization
  tags: [String], // ['popular', 'new', 'bestseller', 'limited']
  featured: Boolean,
  
  // Metadata
  createdAt: Date,
  updatedAt: Date,
  seller: String, // admin or vendor name
}
```

#### ShoppingCart (MongoDB)

```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  
  // Cart items
  items: [
    {
      itemId: String, // reference to RealStoreItem
      itemName: String,
      quantity: Number,
      unitPrice: Number, // LKR at time of adding
      subtotal: Number, // quantity * unitPrice
      addedAt: Date,
    }
  ],
  
  // Totals
  subtotal: Number,
  tax: Number, // if applicable
  estimatedShipping: Number, // if applicable
  total: Number,
  
  // Status
  status: String, // "active", "abandoned", "converted_to_order"
  
  // Metadata
  createdAt: Date,
  updatedAt: Date,
  expiresAt: Date, // cart expires after 30 days
}
```

#### Order (MongoDB)

```javascript
{
  _id: ObjectId,
  orderId: String, // unique order number "ORD-20260129-001"
  userId: ObjectId,
  
  // Order items
  items: [
    {
      itemId: String,
      itemName: String,
      quantity: Number,
      unitPrice: Number, // LKR at purchase time
      subtotal: Number,
    }
  ],
  
  // Pricing
  pricing: {
    subtotal: Number,
    tax: Number,
    shippingEstimate: Number,
    total: Number,
    currency: "LKR",
  },
  
  // Bank transfer details shown to user
  bankDetails: {
    accountName: String,
    accountNumber: String,
    bankName: String,
    routingNumber: String, // if applicable
    referenceId: String, // for user to include in transfer
  },
  
  // Payment proof
  paymentReceipt: {
    receiptUrl: String, // uploaded by user
    uploadedAt: Date,
    verifiedBy: ObjectId, // admin who verified
    verificationStatus: String, // "pending", "verified", "rejected"
    verificationNotes: String, // admin comments if rejected
  },
  
  // Order status
  status: String, // "pending_payment", "payment_received", "processing", "shipped", "delivered", "cancelled"
  statusHistory: [
    {
      status: String,
      updatedAt: Date,
      notes: String,
      updatedBy: ObjectId, // admin
    }
  ],
  
  // Shipping info
  shippingAddress: {
    fullName: String,
    street: String,
    city: String,
    postalCode: String,
    phone: String,
    email: String,
  },
  
  // Tracking
  trackingNumber: String, // assigned by admin
  estimatedDeliveryDate: Date,
  actualDeliveryDate: Date,
  deliveryNotes: String, // admin notes about delivery
  
  // Metadata
  createdAt: Date,
  paymentVerifiedAt: Date,
  shippedAt: Date,
  deliveredAt: Date,
}
```

#### PaymentReceipt (MongoDB) - Separate collection for audit

```javascript
{
  _id: ObjectId,
  orderId: ObjectId, // reference to Order
  userId: ObjectId,
  
  // Receipt information
  receiptUrl: String,
  receiptFileName: String,
  uploadedAt: Date,
  
  // Transfer proof
  transferAmount: Number, // LKR
  transferDate: Date, // user claims they transferred on this date
  transferFromAccount: String, // optional, from receipt
  
  // Verification
  verificationStatus: String, // "pending", "verified", "rejected"
  verifiedBy: ObjectId, // admin who verified
  verificationDate: Date,
  verificationNotes: String, // admin notes
  
  // For rejected receipts
  rejectionReason: String, // "amount_mismatch", "unclear_image", "suspicious", etc.
  resubmissionAllowed: Boolean,
}
```

### In-App Shop Models

#### InAppShopItem (MongoDB)

```javascript
{
  _id: ObjectId,
  itemId: String, // "avatar-skin-001"
  name: String,
  description: String,
  category: String, // "avatar-skin", "map-theme", "effect", "frame"
  type: String, // "cosmetic" or "functional"
  rarity: String, // "common", "rare", "epic", "legendary"
  
  // Pricing in game currency
  cost: {
    gemstones: Number, // required
    travelCoins: Number, // future currency (optional)
  },
  
  // Availability
  availableFrom: Date,
  availableUntil: Date, // null for permanent
  isLimitedEdition: Boolean,
  maxPurchases: Number, // null for unlimited
  currentPurchaseCount: Number,
  
  // Display
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

#### UserInAppInventory (MongoDB)

```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  
  // Currency
  gemstones: Number,
  travelCoins: Number, // future
  
  // Owned items
  items: [
    {
      itemId: String,
      purchaseDate: Date,
      quantity: Number,
      equippedSlot: String, // null if not equipped
      expiresAt: Date, // for time-limited items
    }
  ],
  
  // Equipped loadout
  equipped: {
    avatarSkin: String,
    avatarFrame: String,
    mapTheme: String,
    // ... other slots
  },
  
  updatedAt: Date,
}
```

#### InAppTransaction (MongoDB)

```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  itemId: String,
  quantity: Number,
  
  costType: String, // "gemstones" or "travelCoins"
  costAmount: Number,
  
  status: String, // "completed", "refunded"
  purchaseDate: Date,
  
  transactionId: String, // UUID
}
```

---

## 👥 User Flows

### Real Store Flow: Browse → Cart → Checkout → Payment → Order

```
User opens Shop → Taps "Real Store" tab
  ↓
Browse items by category, search, filters
  ↓
Tap item → View details, images, price, reviews
  ↓
"Add to Cart" → item added with quantity
  ↓
Continue shopping OR go to Cart
  ↓
CHECKOUT:
  - Review items & quantities
  - Enter shipping address (name, phone, email, location)
  - View order total in LKR
  - "Proceed to Payment"
  ↓
PAYMENT SCREEN:
  - Display bank account details (account name, number, bank)
  - Show reference ID user should include in transfer memo
  - Display total amount to transfer: "Please transfer LKR 5,500"
  - Clear instructions: "Transfer to account, then upload receipt"
  ↓
User transfers money offline (via bank app, ATM, branch)
  ↓
User uploads receipt/screenshot as proof
  ↓
Receipt uploaded successfully → Order created
  - Status: "Pending Payment Verification"
  - Moved to "My Orders" tab
  ↓
ADMIN REVIEW (manual):
  - Admin receives notification of new order
  - Admin checks receipt against order total
  - If valid: Mark as "Payment Verified" → Status: "Processing"
  - If invalid: Reject with reason → User can resubmit
  ↓
ORDER PROCESSING & DELIVERY (manual):
  - Admin prepares package
  - Admin updates status: "Shipped" with tracking info
  - User receives notification with tracking details
  - Package delivered → Admin marks as "Delivered"
  - User confirms delivery in app
```

### Real Store: Cart Management

```
User view Cart
  ↓
See all items with:
  - Product image
  - Name
  - Quantity controls (- / +)
  - Unit price (LKR)
  - Subtotal
  ↓
Actions:
  - Increase/decrease quantity
  - Remove item
  - Continue shopping
  - Checkout
  ↓
Cart shows:
  - Subtotal (LKR)
  - Estimated shipping (LKR)
  - Total (LKR)
  ↓
Note: Cart persists for 30 days if not checked out
```

### Real Store: Order Status Tracking

```
User opens "My Orders"
  ↓
See all past and current orders with:
  - Order number (e.g., ORD-20260129-001)
  - Order date
  - Total (LKR)
  - Current status (badge color: yellow=pending, green=shipped, blue=delivered)
  ↓
Tap order → View details:
  - Full item list with prices
  - Shipping address
  - Payment receipt reference
  - Status timeline (when status changed)
  - Tracking number (if shipped)
  - Estimated delivery date
  ↓
If delivery is late:
  - "Contact Support" button
  - Pre-filled message with order details
```

### In-App Shop: Browse & Purchase

```
User opens Shop → Taps "In-App Shop" tab
  ↓
View featured items & browse by category
  ↓
Tap item → See full preview
  - Image
  - Name & description
  - Cost in Gemstones or Travel Coins
  - Rarity/tags
  ↓
If user has enough currency:
  - "Buy for [50 Gems]" button enabled
  ↓
If insufficient currency:
  - Button disabled with message: "Need 50 Gems, you have 30"
  ↓
Tap "Buy" → Confirmation dialog
  - "Purchase for 50 Gems?"
  - "Confirm" or "Cancel"
  ↓
Confirm → Item added to inventory
  ↓
Automatically equip? (for cosmetics)
  - "Yes, equip now" or "Keep in inventory"
  ↓
Purchase complete & instant
  - Item visible in inventory
  - If equipped, see effect immediately on profile/map
```

### In-App Shop: Inventory & Equipping

```
User opens Profile → "Inventory"
  ↓
See all owned in-app items organized by:
  - Avatar customizations
  - Map themes
  - Effects
  - Frames
  ↓
Tap item to:
  - View full preview
  - See if equipped
  - Equip if not equipped
  - Unequip if equipped
  ↓
When equip item:
  - Unequips previous item in same slot
  - Item visually appears on profile immediately
  - Changes visible to other users on leaderboard
```

---

## 🎮 Gamification & Psychology

### FOMO Mechanics

- **Count-down timers** on limited items
- **Price increase signals**: "Price increases in 3 days"
- **Availability indicators**: "Only 50 left!" (for limited-quantity items)
- **"Last chance" banner** for expiring seasonal items

### Progression Hooks

- **Rarity progression**: Common → Rare → Epic → Legendary
- **Collection sets**: Buy 3 skins from "Sri Lanka Heritage" get 5% discount on the 4th
- **Level-based unlocks**: Unlock premium boosters after reaching level 10
- **Achievement unlocks**: Beat 100 places → unlock "Explorer" avatar

### Social Sharing

- **Equipped items visible** on user profile & leaderboard
- **Achievement badges** show equipped designs
- **Share loadout**: "Check out my custom avatar!" → link to profile
- **Limited edition signals**: Badge on profile shows "Founder's Item"

---

## 🔒 Security & Fraud Prevention

### Transaction Safety

- ✅ Server-side validation of all purchases
- ✅ Duplicate purchase prevention (idempotent keys)
- ✅ Rate limiting: max 10 purchases/minute per user
- ✅ Anomaly detection: flag purchases 3x normal spend
- ✅ Admin audit log: all transactions logged with user ID

### Gem Currency (Hard Currency)

- ✅ Server-side balance validation
- ✅ Receipt validation for IAP (in-app purchases)
- ✅ Refund handling via app store policies
- ✅ Chargeback protection via payment processor
- ✅ No direct gem trading between players

### Item Access Control

- ✅ Items only purchasable with sufficient balance
- ✅ Refunds only within 7-day window
- ✅ Time-limited items verified server-side
- ✅ Equipped items validated on sync

---

## 📈 Monetization Strategy (Optional)

### Phase 1 (MVP): Gemstones Only
- 100% cosmetic items earned through gameplay
- No hard currency purchases required
- All items attainable through play

### Phase 2 (Post-Launch): Optional Gem Sales
- Tier 1: $0.99 (50 gems)
- Tier 2: $4.99 (300 gems) → +20% bonus
- Tier 3: $9.99 (700 gems) → +30% bonus
- Tier 4: $24.99 (2000 gems) → +50% bonus

**Non-predatory approach**:
- No P2W mechanics (gems can't buy gameplay advantage)
- No battle pass or seasonal forced-pay systems
- No ads or ad-watching requirements
- Cosmetics-only for hard currency
- Free alternative path for all items (via gemstones)

---

## 🛠️ Technical Requirements

### Backend Dependencies
- Node.js / Express.js (existing)
- MongoDB (existing) - 5 new collections
- Firebase Storage for product images (existing)
- Email service for order notifications (SendGrid or similar)

### Mobile Dependencies
- Flutter & Dart (existing)
- Riverpod for state management (existing)
- Image picker for receipt upload (image_picker package)
- File picker for receipt selection (file_picker package)

### API Endpoints (Phase 1 Real Store + Phase 2 In-App)

**Real Store Endpoints**:
- `GET /api/store/items` - Browse all products
- `GET /api/store/items/:id` - Product details
- `GET /api/store/items/category/:category` - Filter by category
- `GET /api/store/cart` - View user's cart
- `POST /api/store/cart/add` - Add item to cart
- `POST /api/store/cart/remove` - Remove from cart
- `POST /api/store/cart/update` - Update quantity
- `POST /api/store/checkout` - Create order
- `POST /api/store/payment/upload-receipt` - Upload payment proof
- `GET /api/store/orders` - User's orders
- `GET /api/store/orders/:orderId` - Order details

**In-App Shop Endpoints** (existing from previous plan):
- `GET /api/inapp-shop/items` - Browse cosmetics
- `GET /api/inapp-shop/inventory` - User's items
- `POST /api/inapp-shop/purchase` - Buy item
- `POST /api/inapp-shop/equip` - Equip cosmetic

**Admin Endpoints** (Phase 3):
- `POST /api/admin/orders/:orderId/verify-receipt` - Approve/reject payment
- `POST /api/admin/orders/:orderId/status` - Update order status
- `POST /api/admin/store/items` - Create product
- `PUT /api/admin/store/items/:id` - Update product
- `DELETE /api/admin/store/items/:id` - Remove product
- `GET /api/admin/dashboard/orders` - Pending orders

### New Database Collections
1. RealStoreItem
2. ShoppingCart
3. Order
4. PaymentReceipt
5. InAppShopItem (renamed from ShopItem)
6. UserInAppInventory (renamed from UserInventory)

---

## 📋 Success Metrics

### Real Store Metrics
| Metric | Target | Timeline |
|--------|--------|----------|
| **Store Browse Rate** | 40% of active users visit real store monthly | 2 months |
| **Add-to-Cart Rate** | 20% of browsers add items | 2 months |
| **Checkout Completion** | 70% of carts completed as orders | Ongoing |
| **Avg Order Value** | LKR 3,000-5,000 | Ongoing |
| **Repeat Customer Rate** | 30% make 2+ purchases | 3 months |
| **Receipt Upload Rate** | 95% of orders have receipt proof | Ongoing |
| **Payment Verification Time** | Admin verifies within 24 hours | Ongoing |

### In-App Shop Metrics
| Metric | Target | Timeline |
|--------|--------|----------|
| **In-App Browse Rate** | 60% of active users visit in-app shop weekly | 3 months |
| **Purchase Conversion** | 15% of browsers make purchase | 3 months |
| **Avg Gems Earned/Day** | 50-100 per active user | Ongoing |
| **Equipped Items** | 50% of users equip cosmetics | 2 months |

---

## 🚀 Phase Roadmap

| Phase | Focus | Duration | Owner | Details |
|-------|-------|----------|-------|---------|
| **Phase 1** | Real Store MVP | 2-3 weeks | Backend + Mobile | Products, cart, manual checkout, receipt upload, order management |
| **Phase 2** | In-App Shop | 2 weeks | Backend + Mobile | Cosmetics, gemstones, purchase, equipping |
| **Phase 3** | Admin Dashboard | 1 week | Backend | Order management, receipt verification, status updates |
| **Phase 4** | Testing & Content | 1 week | QA + Design | Product seeding, edge cases, UI polish |
| **Phase 5 (Future)** | Payment Gateways | 2-3 weeks | Backend | Credit card, online banking, automated verification |
| **Phase 6 (Future)** | Delivery Tracking | 2-3 weeks | Backend | Courier integration, real-time tracking, automation |
| **Phase 7 (Future)** | Travel Coins & Marketplace | 3+ weeks | All | New currency, user cosmetics marketplace, monetization |

---

## 🔮 Future Features Roadmap

### Phase 5: Payment Gateway Integration (Post-Launch)
**Objective**: Eliminate manual receipt uploads with automated payment processing

**Features**:
- Credit/debit card payments (Visa, Mastercard)
- Sri Lankan payment methods:
  - Dialog Axiata eZ Cash
  - Mobitel eZ Cash  
  - Sampath Bank Online
  - DFCC Bank Online
  - HNB Assure
- PayPal for international customers
- 3D Secure authentication
- Automatic order confirmation on successful payment
- Refund management system
- Payment failure recovery flows

**Timeline**: Q2-Q3 2026 (after real store stabilizes)

### Phase 6: Automated Delivery Tracking (Post-Launch)
**Objective**: Provide customers with real-time visibility into shipment status

**Features**:
- Integration with Sri Lankan couriers:
  - QuickShaw
  - DHL Sri Lanka
  - Royal Mail
  - Aramex
- GPS tracking for shipments
- Automated status notifications:
  - Order dispatched
  - In transit
  - Out for delivery
  - Delivered
- Proof of delivery (POD) with signature/photo
- Return shipping management
- Estimated delivery date calculation
- Customer pickup location options

**Timeline**: Q3-Q4 2026 (dependent on Phase 5)

### Phase 7: Travel Coins & Marketplace (Post-Launch)
**Objective**: Create vibrant in-app cosmetics marketplace and player-to-player economy

**Features**:
- **Travel Coins**: New in-app currency with different earning mechanics
  - Earned through: daily logins, challenges, level-ups, contributions
  - Separate economy from Gemstones
  - Used for: cosmetics, cosmetics marketplace listings, VIP features

- **Cosmetics Marketplace**:
  - Players create and design cosmetics (avatar skins, frames, effects)
  - Player cosmetics go to community vote/review
  - Approved cosmetics added to shop
  - Creator receives 60% revenue share in coins
  - Limited edition releases from community creators

- **VIP/Premium Features** (Travel Coins):
  - Early access to seasonal cosmetics
  - Exclusive cosmetics for VIP members
  - Premium in-app currency bundle purchases
  - Ad-free experience

**Timeline**: Q4 2026 - Q1 2027

### Phase 8: Revenue Analytics & Optimization
**Objective**: Understand customer behavior and optimize shop performance

**Features**:
- Product popularity dashboards
- Revenue tracking (real store sales in LKR)
- Customer lifetime value analysis
- Conversion funnel analysis
- Discount/promotion effectiveness
- Seasonal trends and forecasting
- A/B testing for product placement
- Inventory management recommendations

**Timeline**: Ongoing, starting Phase 2

---

## 📚 Related Documentation

- [PROJECT_SOURCE_OF_TRUTH.md](./PROJECT_SOURCE_OF_TRUTH.md) - Feature roadmap
- [SHOP_IMPLEMENTATION_PLAN.md](./SHOP_IMPLEMENTATION_PLAN.md) - Step-by-step implementation guide
- [SHOP_QUICK_REFERENCE.md](./SHOP_QUICK_REFERENCE.md) - Developer quick reference
- [API_REFERENCE.md](../04_api/API_REFERENCE.md) - Endpoint documentation

---

**Document Owner**: Product Team  
**Last Updated**: January 29, 2026  
**Next Review**: February 12, 2026 (post-Phase 1)
