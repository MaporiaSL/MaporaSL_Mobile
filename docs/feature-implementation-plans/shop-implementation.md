# Shop Implementation Plan

**Version**: 2.0  
**Date**: January 29, 2026  
**Duration**: 5 Weeks (Phases 1-4)

---

## Phase 1: Real Store Backend (Week 1-2)

### Database Models

**RealStoreItem.js** (MongoDB Model)
```javascript
const mongoose = require('mongoose');

const realStoreItemSchema = new mongoose.Schema({
  itemId: { type: String, unique: true, required: true, index: true },
  name: { type: String, required: true, trim: true, index: true },
  description: String,
  longDescription: String,
  category: {
    type: String,
    enum: ['souvenirs', 'apparel', 'travel-gear', 'books', 'food-spices', 'merch', 'art-prints'],
    required: true,
    index: true,
  },
  price: {
    lkr: { type: Number, required: true, min: 0 },
    originalPrice: Number,
  },
  stock: {
    available: { type: Number, required: true, min: 0 },
    reservedInCart: { type: Number, default: 0, min: 0 },
    sold: { type: Number, default: 0, min: 0 },
  },
  images: { type: [String], required: true },
  thumbnail: { type: String, required: true },
  weight: Number,
  dimensions: { length: Number, width: Number, height: Number },
  shippingEstimateDays: { type: Number, default: 3 },
  tags: { type: [String], default: [] },
  featured: { type: Boolean, default: false, index: true },
  displayOrder: { type: Number, default: 999, index: true },
  seller: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  deletedAt: Date,
}, { timestamps: true });

realStoreItemSchema.index({ category: 1, featured: -1, displayOrder: 1 });
module.exports = mongoose.model('RealStoreItem', realStoreItemSchema);
```

**ShoppingCart.js**
```javascript
const mongoose = require('mongoose');

const shoppingCartSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  items: [{
    itemId: { type: String, required: true },
    itemName: String,
    quantity: { type: Number, required: true, min: 1, max: 10 },
    unitPrice: { type: Number, required: true },
    subtotal: { type: Number, required: true },
    addedAt: { type: Date, default: Date.now },
  }],
  subtotal: { type: Number, default: 0, min: 0 },
  tax: { type: Number, default: 0, min: 0 },
  estimatedShipping: { type: Number, default: 0, min: 0 },
  total: { type: Number, default: 0, min: 0 },
  status: { type: String, enum: ['active', 'abandoned', 'converted_to_order'], default: 'active', index: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, default: () => new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) },
}, { timestamps: true });

shoppingCartSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
module.exports = mongoose.model('ShoppingCart', shoppingCartSchema);
```

**Order.js**
```javascript
const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  orderId: { type: String, unique: true, required: true, index: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  items: [{
    itemId: String,
    itemName: String,
    quantity: Number,
    unitPrice: Number,
    subtotal: Number,
  }],
  pricing: {
    subtotal: { type: Number, required: true },
    tax: Number,
    shippingEstimate: Number,
    total: { type: Number, required: true },
    currency: { type: String, default: 'LKR' },
  },
  bankDetails: {
    accountName: String,
    accountNumber: String,
    bankName: String,
    routingNumber: String,
    referenceId: String,
  },
  paymentReceipt: {
    receiptUrl: String,
    uploadedAt: Date,
    verifiedBy: mongoose.Schema.Types.ObjectId,
    verificationStatus: { type: String, enum: ['pending', 'verified', 'rejected'], default: 'pending', index: true },
    verificationNotes: String,
    rejectionReason: String,
  },
  status: {
    type: String,
    enum: ['pending_payment', 'payment_received', 'processing', 'shipped', 'delivered', 'cancelled'],
    default: 'pending_payment',
    index: true,
  },
  statusHistory: [{
    status: String,
    updatedAt: Date,
    notes: String,
    updatedBy: mongoose.Schema.Types.ObjectId,
  }],
  shippingAddress: {
    fullName: { type: String, required: true },
    street: { type: String, required: true },
    city: { type: String, required: true },
    postalCode: String,
    phone: { type: String, required: true },
    email: { type: String, required: true },
    province: String,
  },
  trackingNumber: String,
  estimatedDeliveryDate: Date,
  actualDeliveryDate: Date,
  deliveryNotes: String,
  createdAt: { type: Date, default: Date.now },
  paymentVerifiedAt: Date,
  shippedAt: Date,
  deliveredAt: Date,
}, { timestamps: true });

orderSchema.index({ userId: 1, createdAt: -1 });
orderSchema.index({ status: 1, createdAt: -1 });
module.exports = mongoose.model('Order', orderSchema);
```

**PaymentReceipt.js**
```javascript
const mongoose = require('mongoose');

const paymentReceiptSchema = new mongoose.Schema({
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true, index: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  receiptUrl: { type: String, required: true },
  receiptFileName: String,
  uploadedAt: { type: Date, default: Date.now, index: true },
  transferAmount: { type: Number, required: true },
  transferDate: Date,
  transferFromAccount: String,
  verificationStatus: { type: String, enum: ['pending', 'verified', 'rejected'], default: 'pending', index: true },
  verifiedBy: mongoose.Schema.Types.ObjectId,
  verificationDate: Date,
  verificationNotes: String,
  rejectionReason: { type: String, enum: ['amount_mismatch', 'unclear_image', 'suspicious_activity', 'duplicate', 'other'] },
  resubmissionAllowed: { type: Boolean, default: true },
  verificationAttempts: { type: Number, default: 1 },
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

paymentReceiptSchema.index({ verificationStatus: 1, uploadedAt: -1 });
module.exports = mongoose.model('PaymentReceipt', paymentReceiptSchema);
```

### Cart Service

**cartService.js**
```javascript
const ShoppingCart = require('../models/ShoppingCart');
const RealStoreItem = require('../models/RealStoreItem');

class CartService {
  static async getCart(userId) {
    let cart = await ShoppingCart.findOne({ userId });
    if (!cart) {
      cart = await ShoppingCart.create({ userId });
    }
    await this.recalculateTotals(cart);
    return cart;
  }

  static async addToCart(userId, itemId, quantity) {
    const item = await RealStoreItem.findOne({ itemId });
    if (!item) throw new Error('Item not found');
    
    const availableStock = item.stock.available - item.stock.reservedInCart;
    if (availableStock < quantity) throw new Error('Insufficient stock');

    let cart = await ShoppingCart.findOne({ userId });
    if (!cart) {
      cart = await ShoppingCart.create({ userId });
    }

    const existingItem = cart.items.find(i => i.itemId === itemId);
    if (existingItem) {
      const newQuantity = existingItem.quantity + quantity;
      if (newQuantity > 10) throw new Error('Max quantity is 10');
      existingItem.quantity = newQuantity;
      existingItem.subtotal = newQuantity * existingItem.unitPrice;
    } else {
      cart.items.push({
        itemId,
        itemName: item.name,
        quantity,
        unitPrice: item.price.lkr,
        subtotal: quantity * item.price.lkr,
      });
    }

    await RealStoreItem.updateOne({ itemId }, { $inc: { 'stock.reservedInCart': quantity } });
    await this.recalculateTotals(cart);
    return await cart.save();
  }

  static async removeFromCart(userId, itemId) {
    const cart = await ShoppingCart.findOne({ userId });
    if (!cart) throw new Error('Cart not found');

    const item = cart.items.find(i => i.itemId === itemId);
    if (!item) throw new Error('Item not in cart');

    await RealStoreItem.updateOne({ itemId }, { $inc: { 'stock.reservedInCart': -item.quantity } });
    cart.items = cart.items.filter(i => i.itemId !== itemId);
    
    await this.recalculateTotals(cart);
    return await cart.save();
  }

  static async updateQuantity(userId, itemId, newQuantity) {
    if (newQuantity < 1 || newQuantity > 10) throw new Error('Invalid quantity');
    
    const cart = await ShoppingCart.findOne({ userId });
    if (!cart) throw new Error('Cart not found');

    const item = cart.items.find(i => i.itemId === itemId);
    if (!item) throw new Error('Item not in cart');

    const quantityDifference = newQuantity - item.quantity;
    await RealStoreItem.updateOne({ itemId }, { $inc: { 'stock.reservedInCart': quantityDifference } });
    
    item.quantity = newQuantity;
    item.subtotal = newQuantity * item.unitPrice;
    
    await this.recalculateTotals(cart);
    return await cart.save();
  }

  static async recalculateTotals(cart) {
    let subtotal = 0;
    cart.items.forEach(item => subtotal += item.subtotal);
    const tax = Math.round(subtotal * 0.025);
    const shipping = subtotal > 10000 ? 0 : 500;
    
    cart.subtotal = subtotal;
    cart.tax = tax;
    cart.estimatedShipping = shipping;
    cart.total = subtotal + tax + shipping;
  }

  static async clearCart(userId) {
    const cart = await ShoppingCart.findOne({ userId });
    if (cart) {
      for (const item of cart.items) {
        await RealStoreItem.updateOne({ itemId: item.itemId }, { $inc: { 'stock.reservedInCart': -item.quantity } });
      }
    }
    return await ShoppingCart.updateOne({ userId }, {
      $set: { items: [], status: 'active', subtotal: 0, tax: 0, estimatedShipping: 0, total: 0 }
    });
  }
}

module.exports = CartService;
```

### API Endpoints (Real Store)

**routes/realStore.js**
```javascript
const express = require('express');
const router = express.Router();
const RealStoreItem = require('../models/RealStoreItem');
const Order = require('../models/Order');
const PaymentReceipt = require('../models/PaymentReceipt');
const CartService = require('../services/cartService');
const { authenticate } = require('../middleware/auth');

// GET /api/store/items
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
    res.json({ items, pagination: { skip: parseInt(skip), limit: parseInt(limit), total } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/items/:id
router.get('/items/:id', async (req, res) => {
  try {
    const item = await RealStoreItem.findOne({ itemId: req.params.id, deletedAt: null });
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/cart
router.get('/cart', authenticate, async (req, res) => {
  try {
    const cart = await CartService.getCart(req.user.id);
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/store/cart/add
router.post('/cart/add', authenticate, async (req, res) => {
  try {
    const { itemId, quantity } = req.body;
    const cart = await CartService.addToCart(req.user.id, itemId, quantity);
    res.json(cart);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/store/cart/remove
router.post('/cart/remove', authenticate, async (req, res) => {
  try {
    const { itemId } = req.body;
    const cart = await CartService.removeFromCart(req.user.id, itemId);
    res.json(cart);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/store/cart/update
router.post('/cart/update', authenticate, async (req, res) => {
  try {
    const { itemId, quantity } = req.body;
    const cart = await CartService.updateQuantity(req.user.id, itemId, quantity);
    res.json(cart);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/store/checkout
router.post('/checkout', authenticate, async (req, res) => {
  try {
    const { shippingAddress } = req.body;
    const cart = await CartService.getCart(req.user.id);
    if (cart.items.length === 0) return res.status(400).json({ error: 'Cart is empty' });

    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const count = await Order.countDocuments({ createdAt: { $gte: new Date(today) } });
    const orderId = `ORD-${today}-${String(count + 1).padStart(3, '0')}`;
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
        referenceId,
      },
      shippingAddress,
      status: 'pending_payment',
    });

    await CartService.clearCart(req.user.id);
    res.json({ order, message: 'Order created. Please transfer amount and upload receipt.' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/store/payment/upload-receipt
router.post('/payment/upload-receipt', authenticate, async (req, res) => {
  try {
    const { orderId, receiptUrl } = req.body;
    const order = await Order.findOne({ orderId, userId: req.user.id });
    if (!order) return res.status(404).json({ error: 'Order not found' });
    if (order.status !== 'pending_payment') return res.status(400).json({ error: 'Cannot upload receipt for this order' });

    order.paymentReceipt.receiptUrl = receiptUrl;
    order.paymentReceipt.uploadedAt = new Date();
    order.paymentReceipt.verificationStatus = 'pending';
    await order.save();

    await PaymentReceipt.create({
      orderId: order._id,
      userId: req.user.id,
      receiptUrl,
      transferAmount: order.pricing.total,
      verificationStatus: 'pending',
    });

    res.json({ message: 'Receipt uploaded successfully', status: 'pending_verification' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// GET /api/store/orders
router.get('/orders', authenticate, async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user.id }).sort({ createdAt: -1 }).lean();
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/orders/:orderId
router.get('/orders/:orderId', authenticate, async (req, res) => {
  try {
    const order = await Order.findOne({ orderId: req.params.orderId, userId: req.user.id });
    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

---

## Phase 2: Real Store Mobile UI (Week 2-3)

### Riverpod Providers

**lib/features/shop/providers/real_store_providers.dart**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/real_store_models.dart';
import '../services/real_store_service.dart';

final realStoreServiceProvider = Provider((ref) => RealStoreService());

final storeProductsProvider = FutureProvider.family<List<RealStoreItem>, ({String? category, int skip, int limit})>(
  (ref, params) async {
    final service = ref.watch(realStoreServiceProvider);
    return service.getProducts(category: params.category, skip: params.skip, limit: params.limit);
  },
);

final shoppingCartProvider = StateNotifierProvider<ShoppingCartNotifier, ShoppingCart?>(
  (ref) => ShoppingCartNotifier(ref.watch(realStoreServiceProvider)),
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
}
```

### Mobile UI Components

**lib/features/shop/screens/shop_screen.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('MAPORIA Shop'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Real Store'),
              Tab(text: 'In-App Shop'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RealStoreTab(),
            InAppShopTab(),
          ],
        ),
      ),
    );
  }
}

class RealStoreTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(storeProductsProvider(
      (category: null, skip: 0, limit: 20),
    ));

    return productsAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (products) => GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onAddToCart: () {
              ref.read(shoppingCartProvider.notifier).addItem(product.itemId, 1);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} added to cart')),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final RealStoreItem product;
  final VoidCallback onAddToCart;

  ProductCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(product.thumbnail, height: 120, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text('LKR ${product.price.lkr}', style: TextStyle(color: Colors.green)),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: onAddToCart,
                  icon: Icon(Icons.shopping_cart, size: 14),
                  label: Text('Add'),
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

---

## Phase 3: Admin Dashboard (Week 3-4)

**routes/adminStore.js** (Verify Receipt, Update Order Status)
```javascript
const express = require('express');
const router = express.Router();
const { authenticateAdmin } = require('../middleware/auth');
const Order = require('../models/Order');
const PaymentReceipt = require('../models/PaymentReceipt');

router.use(authenticateAdmin);

// POST /api/admin/orders/:orderId/verify-receipt
router.post('/orders/:orderId/verify-receipt', async (req, res) => {
  try {
    const { approved, rejectionReason, notes } = req.body;
    const order = await Order.findOne({ orderId: req.params.orderId });
    if (!order) return res.status(404).json({ error: 'Order not found' });

    if (approved) {
      order.paymentReceipt.verificationStatus = 'verified';
      order.paymentReceipt.verifiedBy = req.user.id;
      order.status = 'payment_received';
      order.statusHistory.push({ status: 'payment_received', updatedAt: new Date(), notes, updatedBy: req.user.id });
      order.paymentVerifiedAt = new Date();
    } else {
      order.paymentReceipt.verificationStatus = 'rejected';
      order.paymentReceipt.rejectionReason = rejectionReason;
    }

    await order.save();
    res.json({ message: 'Receipt verification updated', order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/admin/orders/:orderId/status
router.post('/orders/:orderId/status', async (req, res) => {
  try {
    const { status, trackingNumber, notes } = req.body;
    const order = await Order.findOne({ orderId: req.params.orderId });
    if (!order) return res.status(404).json({ error: 'Order not found' });

    order.status = status;
    order.statusHistory.push({ status, updatedAt: new Date(), notes, updatedBy: req.user.id });
    if (status === 'shipped' && trackingNumber) {
      order.trackingNumber = trackingNumber;
      order.shippedAt = new Date();
    }
    if (status === 'delivered') {
      order.deliveredAt = new Date();
    }

    await order.save();
    res.json({ message: 'Order status updated', order });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/admin/orders
router.get('/orders', async (req, res) => {
  try {
    const { status = 'pending_payment', skip = 0, limit = 20 } = req.query;
    const orders = await Order.find({ status }).sort({ createdAt: -1 }).skip(parseInt(skip)).limit(parseInt(limit));
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

---

## Phase 4: In-App Shop (Week 4-5)

### Models

**models/InAppShopItem.js**
```javascript
const mongoose = require('mongoose');

const inAppShopItemSchema = new mongoose.Schema({
  itemId: { type: String, unique: true, required: true },
  name: { type: String, required: true },
  category: { type: String, required: true },
  rarity: { type: String, enum: ['common', 'rare', 'epic', 'legendary'], default: 'common' },
  cost: {
    gemstones: { type: Number, required: true },
    travelCoins: Number,
  },
  availableFrom: Date,
  availableUntil: Date,
  isLimitedEdition: { type: Boolean, default: false },
  maxPurchases: Number,
  currentPurchaseCount: { type: Number, default: 0 },
  thumbnail: String,
  fullImage: String,
  icon: String,
  tags: [String],
  featured: { type: Boolean, default: false },
  displayOrder: { type: Number, default: 999 },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('InAppShopItem', inAppShopItemSchema);
```

**models/UserInAppInventory.js**
```javascript
const mongoose = require('mongoose');

const userInAppInventorySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', unique: true, required: true },
  gemstones: { type: Number, default: 0 },
  travelCoins: { type: Number, default: 0 },
  items: [{
    itemId: String,
    purchaseDate: Date,
    quantity: Number,
    equippedSlot: String,
    expiresAt: Date,
  }],
  equipped: {
    avatarSkin: String,
    avatarFrame: String,
    mapTheme: String,
  },
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('UserInAppInventory', userInAppInventorySchema);
```

### In-App Shop API Endpoints

**routes/inAppShop.js**
```javascript
const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const InAppShopItem = require('../models/InAppShopItem');
const UserInAppInventory = require('../models/UserInAppInventory');
const InAppTransaction = require('../models/InAppTransaction');

// GET /api/inapp-shop/items
router.get('/items', async (req, res) => {
  try {
    const items = await InAppShopItem.find({}).sort({ featured: -1, displayOrder: 1 });
    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/inapp-shop/inventory
router.get('/inventory', authenticate, async (req, res) => {
  try {
    let inventory = await UserInAppInventory.findOne({ userId: req.user.id });
    if (!inventory) {
      inventory = await UserInAppInventory.create({ userId: req.user.id });
    }
    res.json(inventory);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/inapp-shop/purchase
router.post('/purchase', authenticate, async (req, res) => {
  try {
    const { itemId, quantity = 1 } = req.body;
    const item = await InAppShopItem.findOne({ itemId });
    if (!item) return res.status(404).json({ error: 'Item not found' });

    let inventory = await UserInAppInventory.findOne({ userId: req.user.id });
    if (!inventory) {
      inventory = await UserInAppInventory.create({ userId: req.user.id });
    }

    const cost = item.cost.gemstones * quantity;
    if (inventory.gemstones < cost) {
      return res.status(400).json({ error: 'Insufficient gemstones' });
    }

    inventory.gemstones -= cost;
    inventory.items.push({
      itemId,
      purchaseDate: new Date(),
      quantity,
      equippedSlot: null,
    });
    await inventory.save();

    await InAppTransaction.create({
      userId: req.user.id,
      itemId,
      quantity,
      costType: 'gemstones',
      costAmount: cost,
      status: 'completed',
      purchaseDate: new Date(),
      transactionId: `${req.user.id}-${itemId}-${Date.now()}`,
    });

    res.json({ message: 'Purchase successful', inventory });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// POST /api/inapp-shop/equip
router.post('/equip', authenticate, async (req, res) => {
  try {
    const { itemId, slot } = req.body;
    const inventory = await UserInAppInventory.findOne({ userId: req.user.id });
    if (!inventory) return res.status(404).json({ error: 'Inventory not found' });

    const item = inventory.items.find(i => i.itemId === itemId);
    if (!item) return res.status(400).json({ error: 'Item not in inventory' });

    inventory.equipped[slot] = itemId;
    item.equippedSlot = slot;
    await inventory.save();

    res.json({ message: 'Item equipped', equipped: inventory.equipped });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

---

## Testing Checklist

### Phase 1 Backend
- [ ] Cart operations (add, remove, update)
- [ ] Stock reservation system
- [ ] Price calculation with tax & shipping
- [ ] Order creation workflow
- [ ] Cart expiration cleanup

### Phase 2 Mobile
- [ ] Product listing pagination
- [ ] Cart persistence across app restarts
- [ ] Checkout form validation
- [ ] Receipt image upload
- [ ] Order tracking display

### Phase 3 Admin
- [ ] Receipt verification workflow
- [ ] Order status updates
- [ ] Admin notifications
- [ ] Dashboard statistics

### Phase 4 In-App
- [ ] Cosmetics purchase flow
- [ ] Inventory management
- [ ] Equipping system
- [ ] Limited edition availability check

---

## Deployment

**Week 1-2**: Deploy Phase 1 to staging  
**Week 2-3**: Beta test Phase 2 with users  
**Week 3-4**: Admin dashboard internal testing  
**Week 4-5**: Phase 4 integration testing  
**Week 5**: Production rollout (10% → 50% → 100%)

**Status**: ✅ Ready for development | See SHOP.md for specification
