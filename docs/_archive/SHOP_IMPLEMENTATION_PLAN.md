# MAPORIA Shop Feature Implementation Plan (Hybrid Model)

**Version**: 2.0  
**Date**: January 29, 2026  
**Status**: Planning & Specification Phase  
**Team Lead**: Backend Team + Mobile Team

> **Note**: This is a complete rewrite reflecting the hybrid shop model with Real Store (e-commerce) + In-App Shop (cosmetics)

---

## 📖 Table of Contents

1. [Overview](#overview)
2. [Phase 1: Real Store MVP Backend](#phase-1-real-store-mvp-backend)
3. [Phase 2: Real Store Mobile UI](#phase-2-real-store-mobile-ui)
4. [Phase 3: Admin Dashboard & Order Management](#phase-3-admin-dashboard--order-management)
5. [Phase 4: In-App Shop Implementation](#phase-4-in-app-shop-implementation)
6. [Phase 5: Payment Gateway Integration](#phase-5-payment-gateway-integration-future)
7. [Delivery & Deployment](#delivery--deployment)

---

## Overview

### Hybrid Shop Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MAPORIA SHOP (Hybrid)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐        │
│  │    REAL STORE        │      │  IN-APP SHOP         │        │
│  ├──────────────────────┤      ├──────────────────────┤        │
│  │ Currency: LKR        │      │ Currency: Gemstones  │        │
│  │ Items: Souvenirs     │      │ Items: Cosmetics     │        │
│  │ Payment: Bank Xfer   │      │ Payment: Instant     │        │
│  │ Verification: Manual │      │ Verification: Auto   │        │
│  │ Fulfillment: Manual  │      │ Fulfillment: Auto    │        │
│  │                      │      │                      │        │
│  │ 5 Collections:       │      │ 3 Collections:       │        │
│  │ • RealStoreItem      │      │ • InAppShopItem      │        │
│  │ • ShoppingCart       │      │ • UserInAppInventory │        │
│  │ • Order              │      │ • InAppTransaction   │        │
│  │ • PaymentReceipt     │      │                      │        │
│  │                      │      │                      │        │
│  │ 11 Endpoints         │      │ 4 Endpoints          │        │
│  │ 6 Admin Endpoints    │      │                      │        │
│  └──────────────────────┘      └──────────────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Implementation Timeline

```
Phase 1: Real Store Backend         │ Week 1-2   │ Backend Team
Phase 2: Real Store Mobile UI       │ Week 2-3   │ Mobile Team
Phase 3: Admin Dashboard            │ Week 3-4   │ Full Stack
Phase 4: In-App Shop                │ Week 4-5   │ Full Stack
Phase 5: Payment Integration (Fut.) │ Q2 2026    │ Backend
Phase 6: Delivery Tracking (Fut.)   │ Q3 2026    │ Backend
```

---

## Phase 1: Real Store MVP Backend

**Duration**: Week 1-2 (10 days)  
**Owner**: Backend Team  
**Deliverables**: 
- MongoDB models (4 new collections)
- Database validation
- 11 API endpoints for real store
- Cart persistence logic
- Payment verification workflow

### 1.1 Create Real Store MongoDB Models

#### 1.1.1 RealStoreItem Model

Create `backend/src/models/RealStoreItem.js`:

```javascript
const mongoose = require('mongoose');

const realStoreItemSchema = new mongoose.Schema(
  {
    // Unique identification
    itemId: {
      type: String,
      unique: true,
      required: true,
      index: true,
      // Format: "souvenir-001", "apparel-tshirt-001", "food-tea-set-001"
    },
    
    name: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    
    description: {
      type: String,
      required: true,
    },
    
    longDescription: {
      type: String,
      // Detailed product specifications, materials, care instructions
    },
    
    // Categorization
    category: {
      type: String,
      enum: [
        'souvenirs',
        'apparel',
        'travel-gear',
        'books',
        'food-spices',
        'merch',
        'art-prints',
      ],
      required: true,
      index: true,
    },
    
    // Pricing in LKR (Sri Lankan Rupees)
    price: {
      lkr: {
        type: Number,
        required: true,
        min: 0,
      },
      originalPrice: {
        type: Number,
        // For discounted items, track original price
      },
    },
    
    // Stock management
    stock: {
      available: {
        type: Number,
        required: true,
        min: 0,
      },
      reservedInCart: {
        type: Number,
        default: 0,
        min: 0,
      },
      sold: {
        type: Number,
        default: 0,
        min: 0,
      },
    },
    
    // Product images
    images: {
      type: [String], // URLs from Firebase Storage
      required: true,
      validate: {
        validator: (v) => Array.isArray(v) && v.length > 0,
        message: 'At least one image URL is required',
      },
    },
    
    thumbnail: {
      type: String,
      required: true,
      // Main image for listing view
    },
    
    // Shipping & logistics
    weight: {
      type: Number, // in grams
      required: true,
    },
    
    dimensions: {
      length: Number, // cm
      width: Number,
      height: Number,
    },
    
    shippingEstimateDays: {
      type: Number,
      default: 3, // 3-5 days typical
    },
    
    isFragile: {
      type: Boolean,
      default: false,
    },
    
    // Tags and categorization
    tags: {
      type: [String],
      default: [],
      // e.g., ['popular', 'new', 'bestseller', 'limited', 'eco-friendly']
    },
    
    featured: {
      type: Boolean,
      default: false,
      index: true,
    },
    
    displayOrder: {
      type: Number,
      default: 999,
      index: true,
    },
    
    // Admin fields
    seller: String,
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
    deletedAt: Date, // soft delete
  },
  { timestamps: true }
);

// Indexes for performance
realStoreItemSchema.index({ category: 1, featured: -1, displayOrder: 1 });
realStoreItemSchema.index({ itemId: 1 });
realStoreItemSchema.index({ featured: -1, displayOrder: 1 });

module.exports = mongoose.model('RealStoreItem', realStoreItemSchema);
```

#### 1.1.2 ShoppingCart Model

Create `backend/src/models/ShoppingCart.js`:

```javascript
const mongoose = require('mongoose');

const shoppingCartSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true, // One active cart per user
    },
    
    items: [
      {
        itemId: {
          type: String, // Reference to RealStoreItem.itemId
          required: true,
        },
        itemName: String,
        quantity: {
          type: Number,
          required: true,
          min: 1,
          max: 10, // Prevent bulk buying
        },
        unitPrice: {
          type: Number, // LKR, captured at add time
          required: true,
        },
        subtotal: {
          type: Number, // quantity * unitPrice
          required: true,
        },
        addedAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
    
    // Totals
    subtotal: {
      type: Number,
      default: 0,
      min: 0,
    },
    
    tax: {
      type: Number,
      default: 0,
      min: 0,
    },
    
    estimatedShipping: {
      type: Number,
      default: 0,
      min: 0,
    },
    
    total: {
      type: Number,
      default: 0,
      min: 0,
    },
    
    // Status tracking
    status: {
      type: String,
      enum: ['active', 'abandoned', 'converted_to_order'],
      default: 'active',
      index: true,
    },
    
    // Expiration
    createdAt: {
      type: Date,
      default: Date.now,
    },
    
    updatedAt: {
      type: Date,
      default: Date.now,
    },
    
    expiresAt: {
      type: Date,
      // Cart expires after 30 days
      default: () => new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    },
  },
  { timestamps: true }
);

// Auto cleanup expired carts
shoppingCartSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('ShoppingCart', shoppingCartSchema);
```

#### 1.1.3 Order Model

Create `backend/src/models/Order.js`:

```javascript
const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema(
  {
    // Unique identification
    orderId: {
      type: String,
      unique: true,
      required: true,
      index: true,
      // Format: "ORD-20260129-001", generated as ORD-YYYYMMDD-SEQUENCE
    },
    
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    
    // Items ordered
    items: [
      {
        itemId: String,
        itemName: String,
        quantity: Number,
        unitPrice: Number, // LKR
        subtotal: Number,
      },
    ],
    
    // Pricing breakdown
    pricing: {
      subtotal: { type: Number, required: true },
      tax: Number,
      shippingEstimate: Number,
      total: { type: Number, required: true },
      currency: { type: String, default: 'LKR' },
    },
    
    // Bank transfer details shown to customer
    bankDetails: {
      accountName: String,
      accountNumber: String,
      bankName: String,
      routingNumber: String,
      referenceId: String, // Unique per order for transfer memo
    },
    
    // Payment receipt & verification
    paymentReceipt: {
      receiptUrl: String,
      uploadedAt: Date,
      verifiedBy: mongoose.Schema.Types.ObjectId, // Admin user ID
      verificationStatus: {
        type: String,
        enum: ['pending', 'verified', 'rejected'],
        default: 'pending',
        index: true,
      },
      verificationNotes: String,
      rejectionReason: String,
    },
    
    // Order status
    status: {
      type: String,
      enum: [
        'pending_payment',
        'payment_received',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
      ],
      default: 'pending_payment',
      index: true,
    },
    
    // Status timeline for customer
    statusHistory: [
      {
        status: String,
        updatedAt: Date,
        notes: String,
        updatedBy: mongoose.Schema.Types.ObjectId, // Admin
      },
    ],
    
    // Shipping address
    shippingAddress: {
      fullName: { type: String, required: true },
      street: { type: String, required: true },
      city: { type: String, required: true },
      postalCode: String,
      phone: { type: String, required: true },
      email: { type: String, required: true },
      province: String,
    },
    
    // Tracking information
    trackingNumber: String,
    estimatedDeliveryDate: Date,
    actualDeliveryDate: Date,
    deliveryNotes: String,
    
    // Timestamps
    createdAt: { type: Date, default: Date.now },
    paymentVerifiedAt: Date,
    shippedAt: Date,
    deliveredAt: Date,
  },
  { timestamps: true }
);

// Indexes for efficient queries
orderSchema.index({ userId: 1, createdAt: -1 });
orderSchema.index({ status: 1, createdAt: -1 });
orderSchema.index({ orderId: 1 });
orderSchema.index({ 'paymentReceipt.verificationStatus': 1 });

module.exports = mongoose.model('Order', orderSchema);
```

#### 1.1.4 PaymentReceipt Model (Audit Collection)

Create `backend/src/models/PaymentReceipt.js`:

```javascript
const mongoose = require('mongoose');

const paymentReceiptSchema = new mongoose.Schema(
  {
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Order',
      required: true,
      index: true,
    },
    
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    
    // Receipt file details
    receiptUrl: {
      type: String,
      required: true,
    },
    
    receiptFileName: String,
    receiptFileSize: Number, // bytes
    
    uploadedAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
    
    // Transfer information (from receipt)
    transferAmount: {
      type: Number, // LKR
      required: true,
    },
    
    transferDate: {
      type: Date,
      // Date user claims to have transferred
    },
    
    transferFromAccount: String, // Account shown in receipt
    
    // Verification
    verificationStatus: {
      type: String,
      enum: ['pending', 'verified', 'rejected', 'resubmitted'],
      default: 'pending',
      index: true,
    },
    
    verifiedBy: mongoose.Schema.Types.ObjectId,
    verificationDate: Date,
    verificationNotes: String,
    
    // Rejection details
    rejectionReason: {
      type: String,
      enum: [
        'amount_mismatch',
        'unclear_image',
        'suspicious_activity',
        'duplicate',
        'other',
      ],
    },
    
    resubmissionAllowed: {
      type: Boolean,
      default: true,
    },
    
    // Audit trail
    verificationAttempts: {
      type: Number,
      default: 1,
    },
    
    createdAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

// Index for pending verifications
paymentReceiptSchema.index({
  verificationStatus: 1,
  uploadedAt: -1,
});

module.exports = mongoose.model('PaymentReceipt', paymentReceiptSchema);
```

### 1.2 Database Validation & Utilities

Create `backend/src/utils/shopValidation.js`:

```javascript
const { body, validationResult } = require('express-validator');

// Cart item validation
exports.validateCartItem = [
  body('itemId').notEmpty().withMessage('Item ID is required'),
  body('quantity')
    .isInt({ min: 1, max: 10 })
    .withMessage('Quantity must be between 1 and 10'),
];

// Checkout validation
exports.validateCheckout = [
  body('shippingAddress.fullName')
    .notEmpty()
    .withMessage('Full name is required'),
  body('shippingAddress.street').notEmpty().withMessage('Street is required'),
  body('shippingAddress.city').notEmpty().withMessage('City is required'),
  body('shippingAddress.phone').isMobilePhone().withMessage('Invalid phone'),
  body('shippingAddress.email').isEmail().withMessage('Invalid email'),
];

// Receipt upload validation
exports.validateReceiptUpload = [
  body('orderId').isMongoId().withMessage('Invalid order ID'),
  // File validation handled by multer middleware
];

// Helper to handle validation errors
exports.handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

// Price validation
exports.validatePrice = (price) => {
  return price > 0 && price < 1000000; // Max 1M LKR per item
};

// Stock availability check
exports.checkStockAvailability = async (RealStoreItem, itemId, quantity) => {
  const item = await RealStoreItem.findOne({ itemId });
  if (!item) return { available: false, reason: 'Item not found' };
  
  const availableStock = item.stock.available - item.stock.reservedInCart;
  if (availableStock < quantity) {
    return { available: false, reason: 'Insufficient stock' };
  }
  
  return { available: true, price: item.price.lkr };
};
```

### 1.3 MongoDB Initialization Script

Create `backend/scripts/init-real-store.js`:

```javascript
const mongoose = require('mongoose');
const RealStoreItem = require('../src/models/RealStoreItem');
require('dotenv').config();

const sampleProducts = [
  {
    itemId: 'souvenir-mask-001',
    name: 'Traditional Wooden Mask',
    description: 'Hand-carved wooden mask',
    category: 'souvenirs',
    price: { lkr: 2500 },
    stock: { available: 50, reservedInCart: 0, sold: 0 },
    images: ['https://storage.googleapis.com/maporia/mask-001.jpg'],
    thumbnail: 'https://storage.googleapis.com/maporia/mask-001-thumb.jpg',
    weight: 300,
    dimensions: { length: 20, width: 15, height: 25 },
    tags: ['popular', 'authentic'],
    featured: true,
    displayOrder: 1,
  },
  // ... more products
];

async function initDatabase() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    // Clear existing items
    await RealStoreItem.deleteMany({});
    console.log('Cleared existing items');

    // Insert sample products
    await RealStoreItem.insertMany(sampleProducts);
    console.log('Inserted sample products');

    await mongoose.connection.close();
    console.log('Database initialization complete');
  } catch (error) {
    console.error('Initialization failed:', error);
    process.exit(1);
  }
}

initDatabase();
```

---

## Phase 1.4: Cart Management Service

Create `backend/src/services/cartService.js`:

```javascript
const ShoppingCart = require('../models/ShoppingCart');
const RealStoreItem = require('../models/RealStoreItem');

class CartService {
  // Get user's cart
  static async getCart(userId) {
    let cart = await ShoppingCart.findOne({ userId });
    
    if (!cart) {
      // Create new cart if doesn't exist
      cart = await ShoppingCart.create({ userId });
    }
    
    // Recalculate totals
    await this.recalculateTotals(cart);
    return cart;
  }

  // Add item to cart
  static async addToCart(userId, itemId, quantity) {
    // Validate stock
    const item = await RealStoreItem.findOne({ itemId });
    if (!item) throw new Error('Item not found');
    
    const availableStock = 
      item.stock.available - item.stock.reservedInCart;
    if (availableStock < quantity) {
      throw new Error('Insufficient stock');
    }

    let cart = await ShoppingCart.findOne({ userId });
    if (!cart) {
      cart = await ShoppingCart.create({ userId });
    }

    // Check if item already in cart
    const existingItem = cart.items.find(i => i.itemId === itemId);
    
    if (existingItem) {
      // Update quantity
      const newQuantity = existingItem.quantity + quantity;
      if (newQuantity > 10) throw new Error('Max quantity is 10');
      
      existingItem.quantity = newQuantity;
      existingItem.subtotal = newQuantity * existingItem.unitPrice;
    } else {
      // Add new item
      cart.items.push({
        itemId,
        itemName: item.name,
        quantity,
        unitPrice: item.price.lkr,
        subtotal: quantity * item.price.lkr,
        addedAt: new Date(),
      });
    }

    // Update reserved stock
    await RealStoreItem.updateOne(
      { itemId },
      { $inc: { 'stock.reservedInCart': quantity } }
    );

    await this.recalculateTotals(cart);
    return await cart.save();
  }

  // Remove item from cart
  static async removeFromCart(userId, itemId) {
    const cart = await ShoppingCart.findOne({ userId });
    if (!cart) throw new Error('Cart not found');

    const item = cart.items.find(i => i.itemId === itemId);
    if (!item) throw new Error('Item not in cart');

    // Release reserved stock
    await RealStoreItem.updateOne(
      { itemId },
      { $inc: { 'stock.reservedInCart': -item.quantity } }
    );

    cart.items = cart.items.filter(i => i.itemId !== itemId);
    
    await this.recalculateTotals(cart);
    return await cart.save();
  }

  // Update item quantity
  static async updateQuantity(userId, itemId, newQuantity) {
    if (newQuantity < 1 || newQuantity > 10) {
      throw new Error('Invalid quantity');
    }

    const cart = await ShoppingCart.findOne({ userId });
    if (!cart) throw new Error('Cart not found');

    const item = cart.items.find(i => i.itemId === itemId);
    if (!item) throw new Error('Item not in cart');

    const quantityDifference = newQuantity - item.quantity;

    // Update reserved stock
    await RealStoreItem.updateOne(
      { itemId },
      { $inc: { 'stock.reservedInCart': quantityDifference } }
    );

    item.quantity = newQuantity;
    item.subtotal = newQuantity * item.unitPrice;

    await this.recalculateTotals(cart);
    return await cart.save();
  }

  // Recalculate cart totals
  static async recalculateTotals(cart) {
    let subtotal = 0;
    cart.items.forEach(item => {
      subtotal += item.subtotal;
    });

    const tax = Math.round(subtotal * 0.025); // 2.5% tax
    const shipping = subtotal > 10000 ? 0 : 500; // Free shipping over 10K

    cart.subtotal = subtotal;
    cart.tax = tax;
    cart.estimatedShipping = shipping;
    cart.total = subtotal + tax + shipping;
  }

  // Clear cart (after successful order)
  static async clearCart(userId) {
    // Release all reserved stock
    const cart = await ShoppingCart.findOne({ userId });
    if (cart) {
      for (const item of cart.items) {
        await RealStoreItem.updateOne(
          { itemId: item.itemId },
          { $inc: { 'stock.reservedInCart': -item.quantity } }
        );
      }
    }

    return await ShoppingCart.updateOne(
      { userId },
      {
        $set: {
          items: [],
          status: 'active',
          subtotal: 0,
          tax: 0,
          estimatedShipping: 0,
          total: 0,
        },
      }
    );
  }
}

module.exports = CartService;
```

---

## Phase 1.5: API Endpoints - Real Store

### 1.5.1 Products Endpoints

Create `backend/src/routes/realStore.js`:

```javascript
const express = require('express');
const router = express.Router();
const RealStoreItem = require('../models/RealStoreItem');
const { authenticate } = require('../middleware/auth');

// GET /api/store/items - Browse all products
router.get('/items', async (req, res) => {
  try {
    const { skip = 0, limit = 20, category, sortBy = 'featured' } = req.query;

    const query = { deletedAt: null };
    if (category) query.category = category;

    const items = await RealStoreItem.find(query)
      .sort(sortBy === 'featured' ? { featured: -1, displayOrder: 1 } : { [sortBy]: 1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit))
      .lean();

    const total = await RealStoreItem.countDocuments(query);

    res.json({
      items,
      pagination: {
        skip: parseInt(skip),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/items/:id - Product details
router.get('/items/:id', async (req, res) => {
  try {
    const item = await RealStoreItem.findOne({
      itemId: req.params.id,
      deletedAt: null,
    });

    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/items/category/:category - Filter by category
router.get('/category/:category', async (req, res) => {
  try {
    const items = await RealStoreItem.find({
      category: req.params.category,
      deletedAt: null,
    })
      .sort({ featured: -1, displayOrder: 1 })
      .lean();

    res.json({ items, count: items.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### 1.5.2 Cart Endpoints

Create endpoints in same file:

```javascript
const CartService = require('../services/cartService');

// GET /api/store/cart - View user's cart
router.get('/cart', authenticate, async (req, res) => {
  try {
    const cart = await CartService.getCart(req.user.id);
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/store/cart/add - Add item to cart
router.post('/cart/add', authenticate, async (req, res) => {
  try {
    const { itemId, quantity } = req.body;
    const cart = await CartService.addToCart(req.user.id, itemId, quantity);
    res.json(cart);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/store/cart/remove - Remove from cart
router.post('/cart/remove', authenticate, async (req, res) => {
  try {
    const { itemId } = req.body;
    const cart = await CartService.removeFromCart(req.user.id, itemId);
    res.json(cart);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/store/cart/update - Update quantity
router.post('/cart/update', authenticate, async (req, res) => {
  try {
    const { itemId, quantity } = req.body;
    const cart = await CartService.updateQuantity(
      req.user.id,
      itemId,
      quantity
    );
    res.json(cart);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

### 1.5.3 Checkout Endpoints

```javascript
const Order = require('../models/Order');
const PaymentReceipt = require('../models/PaymentReceipt');

// Generate unique order ID
const generateOrderId = async () => {
  const today = new Date();
  const dateStr = today
    .toISOString()
    .slice(0, 10)
    .replace(/-/g, '');
  
  const count = await Order.countDocuments({
    createdAt: {
      $gte: new Date(today.setHours(0, 0, 0, 0)),
    },
  });
  
  return `ORD-${dateStr}-${String(count + 1).padStart(3, '0')}`;
};

// POST /api/store/checkout - Create order from cart
router.post('/checkout', authenticate, async (req, res) => {
  try {
    const { shippingAddress } = req.body;

    // Get cart
    const cart = await CartService.getCart(req.user.id);
    if (cart.items.length === 0) {
      return res.status(400).json({ error: 'Cart is empty' });
    }

    // Create order
    const orderId = await generateOrderId();
    const referenceId = `${orderId}-${Date.now()}`.slice(0, 20);

    const order = await Order.create({
      orderId,
      userId: req.user.id,
      items: cart.items,
      pricing: {
        subtotal: cart.subtotal,
        tax: cart.tax,
        shippingEstimate: cart.estimatedShipping,
        total: cart.total,
      },
      bankDetails: {
        accountName: process.env.BANK_ACCOUNT_NAME,
        accountNumber: process.env.BANK_ACCOUNT_NUMBER,
        bankName: process.env.BANK_NAME,
        routingNumber: process.env.BANK_ROUTING_NUMBER,
        referenceId,
      },
      shippingAddress,
      status: 'pending_payment',
    });

    // Clear cart
    await CartService.clearCart(req.user.id);

    res.json({
      order,
      message: 'Order created. Please transfer amount and upload receipt.',
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/store/payment/upload-receipt - Upload payment proof
router.post(
  '/payment/upload-receipt',
  authenticate,
  uploadMiddleware.single('receipt'), // multer middleware
  async (req, res) => {
    try {
      const { orderId } = req.body;
      const receiptUrl = req.file.path; // Firebase Storage URL

      const order = await Order.findOne({ orderId, userId: req.user.id });
      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }

      if (order.status !== 'pending_payment') {
        return res.status(400).json({
          error: 'Can only upload receipt for pending orders',
        });
      }

      // Update order with receipt
      order.paymentReceipt.receiptUrl = receiptUrl;
      order.paymentReceipt.uploadedAt = new Date();
      order.paymentReceipt.verificationStatus = 'pending';
      await order.save();

      // Create payment receipt record for admin audit
      await PaymentReceipt.create({
        orderId: order._id,
        userId: req.user.id,
        receiptUrl,
        receiptFileName: req.file.originalname,
        transferAmount: order.pricing.total,
        verificationStatus: 'pending',
      });

      res.json({
        message: 'Receipt uploaded successfully',
        status: 'pending_verification',
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
);

// GET /api/store/orders - User's orders
router.get('/orders', authenticate, async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .lean();

    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/orders/:orderId - Order details
router.get('/orders/:orderId', authenticate, async (req, res) => {
  try {
    const order = await Order.findOne({
      orderId: req.params.orderId,
      userId: req.user.id,
    });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

---

## Phase 2: Real Store Mobile UI

**Duration**: Week 2-3 (10 days)  
**Owner**: Mobile Team (Flutter)  
**Deliverables**: 
- Shop screen with tabs (Real Store, In-App Shop)
- Product browsing and filtering
- Shopping cart UI
- Checkout flow with bank details display
- Receipt upload interface
- Order tracking screen

### 2.1 Riverpod Providers Setup

Create `mobile/lib/features/shop/providers/real_store_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/real_store_models.dart';
import '../services/real_store_service.dart';

// Service provider
final realStoreServiceProvider = Provider((ref) => RealStoreService());

// Product listing provider
final storeProductsProvider = FutureProvider.family<
    List<RealStoreItem>,
    ({String? category, int skip, int limit})
>((ref, params) async {
  final service = ref.watch(realStoreServiceProvider);
  return service.getProducts(
    category: params.category,
    skip: params.skip,
    limit: params.limit,
  );
});

// Shopping cart provider (StateNotifier)
final shoppingCartProvider =
    StateNotifierProvider<ShoppingCartNotifier, ShoppingCart?>(
  (ref) {
    final service = ref.watch(realStoreServiceProvider);
    return ShoppingCartNotifier(service);
  },
);

class ShoppingCartNotifier extends StateNotifier<ShoppingCart?> {
  final RealStoreService _service;

  ShoppingCartNotifier(this._service) : super(null) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cart = await _service.getCart();
      state = cart;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addItem(String itemId, int quantity) async {
    try {
      final updated = await _service.addToCart(itemId, quantity);
      state = updated;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final updated = await _service.removeFromCart(itemId);
      state = updated;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final updated = await _service.updateQuantity(itemId, quantity);
      state = updated;
    } catch (e) {
      // Handle error
    }
  }
}

// Checkout provider
final checkoutProvider = FutureProvider.family<
    OrderResponse,
    CheckoutRequest
>((ref, request) async {
  final service = ref.watch(realStoreServiceProvider);
  return service.checkout(request);
});
```

### 2.2 Real Store Item Display

Create `mobile/lib/features/shop/widgets/store_item_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/real_store_models.dart';

class StoreItemCard extends StatelessWidget {
  final RealStoreItem item;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const StoreItemCard({
    required this.item,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: Image.network(
                item.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Product details
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 4),
                // Category tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
                SizedBox(height: 8),
                // Price and button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      'LKR ${item.price.lkr}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    // Add to cart button
                    ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: Icon(Icons.shopping_cart, size: 14),
                      label: Text('Add'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.3 Shopping Cart Screen

Create `mobile/lib/features/shop/screens/shopping_cart_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/real_store_providers.dart';

class ShoppingCartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsyncValue = ref.watch(shoppingCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: cartAsyncValue.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return Center(child: Text('Cart is empty'));
          }

          return Column(
            children: [
              // Cart items
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemTile(
                      item: item,
                      onQuantityChanged: (quantity) {
                        ref
                            .read(shoppingCartProvider.notifier)
                            .updateQuantity(item.itemId, quantity);
                      },
                      onRemove: () {
                        ref
                            .read(shoppingCartProvider.notifier)
                            .removeItem(item.itemId);
                      },
                    );
                  },
                ),
              ),
              // Cart summary
              CartSummary(cart: cart),
              // Checkout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/checkout', arguments: cart);
                  },
                  child: Text('Proceed to Checkout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final ShoppingCart cart;

  CartSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _SummaryRow('Subtotal', 'LKR ${cart.subtotal}'),
          _SummaryRow('Tax', 'LKR ${cart.tax}'),
          _SummaryRow('Shipping', 'LKR ${cart.estimatedShipping}'),
          Divider(height: 16),
          _SummaryRow(
            'Total',
            'LKR ${cart.total}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
```

### 2.4 Checkout & Payment Screen

Create `mobile/lib/features/shop/screens/checkout_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/real_store_providers.dart';
import '../models/real_store_models.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final ShoppingCart cart;

  CheckoutScreen({required this.cart});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  XFile? _receiptImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Section
            Text('Shipping Address', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            _AddressForm(
              nameController: _nameController,
              streetController: _streetController,
              cityController: _cityController,
              phoneController: _phoneController,
              emailController: _emailController,
            ),
            SizedBox(height: 24),

            // Order Summary
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            OrderSummaryCard(cart: widget.cart),
            SizedBox(height: 24),

            // Bank Transfer Details
            Text('Payment Instructions', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            BankDetailsCard(),
            SizedBox(height: 24),

            // Receipt Upload
            Text('Upload Transfer Receipt', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            ReceiptUploadWidget(
              onImageSelected: (file) => setState(() => _receiptImage = file),
              selectedImage: _receiptImage,
            ),
            SizedBox(height: 24),

            // Complete Purchase Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _receiptImage != null ? _completePurchase : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  'Complete Purchase',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completePurchase() async {
    // TODO: Complete the purchase flow
    // 1. Validate form
    // 2. Create order
    // 3. Upload receipt
    // 4. Show confirmation
  }
}

class _AddressForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  _AddressForm({
    required this.nameController,
    required this.streetController,
    required this.cityController,
    required this.phoneController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: streetController,
          decoration: InputDecoration(
            labelText: 'Street Address',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: cityController,
          decoration: InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class BankDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Account Name:', 'MAPORIA pvt ltd'),
            _DetailRow('Account Number:', '1234567890'),
            _DetailRow('Bank Name:', 'Commercial Bank of Ceylon'),
            _DetailRow('Reference ID:', 'ORD-20260129-001-1234567'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Include the Reference ID in your transfer memo so we can match your payment',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(value),
        ],
      ),
    );
  }
}

class ReceiptUploadWidget extends StatelessWidget {
  final Function(XFile) onImageSelected;
  final XFile? selectedImage;

  ReceiptUploadWidget({
    required this.onImageSelected,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: selectedImage == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Tap to upload receipt screenshot'),
                  ],
                ),
              )
            : Image.file(File(selectedImage!.path)),
      ),
    );
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImageSelected(image);
    }
  }
}
```

---

## Phase 3: Admin Dashboard & Order Management

**Duration**: Week 3-4 (10 days)  
**Owner**: Full Stack Team  
**Deliverables**:
- Admin receipt verification interface
- Order status management
- Pending order notifications
- Product management (CRUD)
- Order tracking updates

### 3.1 Admin API Endpoints

Create `backend/src/routes/adminStore.js`:

```javascript
const express = require('express');
const router = express.Router();
const { authenticateAdmin } = require('../middleware/auth');
const Order = require('../models/Order');
const PaymentReceipt = require('../models/PaymentReceipt');
const RealStoreItem = require('../models/RealStoreItem');

// Middleware
router.use(authenticateAdmin);

// GET /api/admin/orders - Pending orders for verification
router.get('/orders', async (req, res) => {
  try {
    const { status = 'pending_payment', skip = 0, limit = 20 } = req.query;

    const orders = await Order.find({ status })
      .sort({ createdAt: -1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit))
      .populate('userId', 'name email');

    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/admin/orders/:orderId/verify-receipt - Approve/reject payment
router.post('/orders/:orderId/verify-receipt', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { approved, rejectionReason, notes } = req.body;

    const order = await Order.findOne({ orderId });
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (approved) {
      // Mark as verified
      order.paymentReceipt.verificationStatus = 'verified';
      order.paymentReceipt.verifiedBy = req.user.id;
      order.paymentReceipt.verificationNotes = notes;
      order.status = 'payment_received';
      order.statusHistory.push({
        status: 'payment_received',
        updatedAt: new Date(),
        notes: 'Payment verified by admin',
        updatedBy: req.user.id,
      });
      order.paymentVerifiedAt = new Date();
    } else {
      // Reject with reason
      order.paymentReceipt.verificationStatus = 'rejected';
      order.paymentReceipt.rejectionReason = rejectionReason;
      order.paymentReceipt.verificationNotes = notes;
      order.paymentReceipt.resubmissionAllowed = true;
      order.status = 'pending_payment'; // Allow resubmission
    }

    await order.save();

    // Update PaymentReceipt collection
    await PaymentReceipt.updateOne(
      { orderId: order._id },
      {
        verificationStatus: approved ? 'verified' : 'rejected',
        verifiedBy: req.user.id,
        verificationDate: new Date(),
        verificationNotes: notes,
        rejectionReason: approved ? null : rejectionReason,
      }
    );

    res.json({ message: 'Receipt verification updated', order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/admin/orders/:orderId/status - Update order status
router.post('/orders/:orderId/status', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status, trackingNumber, notes } = req.body;

    const validStatuses = [
      'pending_payment',
      'payment_received',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const order = await Order.findOne({ orderId });
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    order.status = status;
    order.statusHistory.push({
      status,
      updatedAt: new Date(),
      notes,
      updatedBy: req.user.id,
    });

    if (status === 'shipped' && trackingNumber) {
      order.trackingNumber = trackingNumber;
      order.shippedAt = new Date();
      order.estimatedDeliveryDate = new Date(
        Date.now() + 3 * 24 * 60 * 60 * 1000
      ); // +3 days
    }

    if (status === 'delivered') {
      order.actualDeliveryDate = new Date();
      order.deliveredAt = new Date();
    }

    await order.save();

    // Send notification to user (optional)
    // await notificationService.sendOrderStatusUpdate(order);

    res.json({ message: 'Order status updated', order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Product Management

// POST /api/admin/store/items - Create product
router.post('/store/items', async (req, res) => {
  try {
    const item = await RealStoreItem.create(req.body);
    res.status(201).json(item);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// PUT /api/admin/store/items/:id - Update product
router.put('/store/items/:id', async (req, res) => {
  try {
    const item = await RealStoreItem.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json(item);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE /api/admin/store/items/:id - Soft delete product
router.delete('/store/items/:id', async (req, res) => {
  try {
    const item = await RealStoreItem.findByIdAndUpdate(
      req.params.id,
      { deletedAt: new Date() },
      { new: true }
    );

    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json({ message: 'Item deleted', item });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/admin/dashboard/orders - Dashboard statistics
router.get('/dashboard/orders', async (req, res) => {
  try {
    const stats = {
      pending_payment: await Order.countDocuments({ status: 'pending_payment' }),
      payment_received: await Order.countDocuments({ status: 'payment_received' }),
      processing: await Order.countDocuments({ status: 'processing' }),
      shipped: await Order.countDocuments({ status: 'shipped' }),
      delivered: await Order.countDocuments({ status: 'delivered' }),
      total_revenue: await Order.aggregate([
        { $match: { status: { $in: ['payment_received', 'shipped', 'delivered'] } } },
        { $group: { _id: null, total: { $sum: '$pricing.total' } } },
      ]),
    };

    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

---

## Phase 4: In-App Shop Implementation

**Duration**: Week 4-5 (10 days)  
**Owner**: Backend + Mobile  
**Deliverables**:
- InAppShopItem & UserInAppInventory models
- In-app cosmetics purchase endpoints
- Mobile cosmetics browsing & purchase UI
- Inventory & equipping system

> **Note**: Phase 4 implementation is similar to previous spec (cosmetics with Gemstones) but integrated with Real Store architecture

---

## Phase 5: Payment Gateway Integration (Future)

**Timeline**: Q2 2026 (after Phase 4 stabilizes)  
**Features**:
- Credit/debit card integration (Stripe/Adyen)
- Sri Lankan payment methods (Dialog eZ Cash, Sampath Bank Online)
- Automated payment verification
- Refund management
- Payment failure recovery

---

## Delivery & Deployment

### Testing Checklist
- [ ] Unit tests for cart service
- [ ] Integration tests for checkout flow
- [ ] Receipt upload validation
- [ ] Admin verification workflow
- [ ] Mobile UI responsiveness
- [ ] Payment receipt image handling

### Deployment Steps
1. **Week 1 (Phase 1)**: Deploy backend models & APIs to staging
2. **Week 2**: Deploy Mobile UI (real store) to beta testers
3. **Week 3**: Admin dashboard to internal team
4. **Week 4**: In-app shop integration testing
5. **Week 5**: Full production rollout

---

## References

- [SHOP_FEATURE_SPEC.md](./SHOP_FEATURE_SPEC.md) - Feature specification
- [SHOP_QUICK_REFERENCE.md](./SHOP_QUICK_REFERENCE.md) - Developer quick reference
- [API_REFERENCE.md](../04_api/API_REFERENCE.md) - Endpoint documentation

**Document Owner**: Backend & Mobile Teams  
**Last Updated**: January 29, 2026  
**Status**: Planning Phase - Ready for Phase 1 Development
