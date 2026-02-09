const express = require('express');
const { body } = require('express-validator');
const RealStoreItem = require('../models/RealStoreItem');
const Order = require('../models/Order');
const PaymentReceipt = require('../models/PaymentReceipt');
const CartService = require('../services/cartService');
const { checkJwt, extractUserId } = require('../middleware/auth');
const {
  validateCartItem,
  validateCheckout,
  handleValidationErrors,
} = require('../utils/shopValidation');

const router = express.Router();

// GET /api/store/items - list products
router.get('/items', async (req, res) => {
  try {
    const {
      skip = 0,
      limit = 20,
      district,
      category,
      sortBy = 'featured',
    } = req.query;

    const query = { deletedAt: null };
    if (district) query.district = district;
    if (category) query.category = category;

    const items = await RealStoreItem.find(query)
      .sort(
        sortBy === 'featured'
          ? { featured: -1, displayOrder: 1 }
          : { [sortBy]: 1 }
      )
      .skip(parseInt(skip, 10))
      .limit(parseInt(limit, 10))
      .lean();

    const total = await RealStoreItem.countDocuments(query);

    res.json({
      items,
      pagination: {
        skip: parseInt(skip, 10),
        limit: parseInt(limit, 10),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/items/:id - single product
router.get('/items/:id', async (req, res) => {
  try {
    const item = await RealStoreItem.findOne({
      itemId: req.params.id,
      deletedAt: null,
    }).lean();

    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Protected routes: cart & orders
router.use(checkJwt, extractUserId);

// GET /api/store/cart - current user's cart
router.get('/cart', async (req, res) => {
  try {
    const cart = await CartService.getCart(req.userId);
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/store/cart/add - add item
router.post(
  '/cart/add',
  validateCartItem,
  handleValidationErrors,
  async (req, res) => {
    try {
      const { itemId, quantity } = req.body;
      const cart = await CartService.addToCart(
        req.userId,
        itemId,
        Number(quantity)
      );
      res.json(cart);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
);

// POST /api/store/cart/update - update quantity
router.post(
  '/cart/update',
  validateCartItem,
  handleValidationErrors,
  async (req, res) => {
    try {
      const { itemId, quantity } = req.body;
      const cart = await CartService.updateQuantity(
        req.userId,
        itemId,
        Number(quantity)
      );
      res.json(cart);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
);

// POST /api/store/cart/remove - remove line item
router.post(
  '/cart/remove',
  [body('itemId').notEmpty().withMessage('Item ID is required')],
  handleValidationErrors,
  async (req, res) => {
    try {
      const { itemId } = req.body;
      const cart = await CartService.removeFromCart(req.userId, itemId);
      res.json(cart);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
);

// Helper to generate a simple orderId
const generateOrderId = async () => {
  const today = new Date();
  const dateStr = today.toISOString().slice(0, 10).replace(/-/g, '');

  const count = await Order.countDocuments({
    createdAt: {
      $gte: new Date(today.setHours(0, 0, 0, 0)),
    },
  });

  return `ORD-${dateStr}-${String(count + 1).padStart(3, '0')}`;
};

// POST /api/store/checkout - create order from cart (manual payment for now)
router.post(
  '/checkout',
  validateCheckout,
  handleValidationErrors,
  async (req, res) => {
    try {
      const { shippingAddress } = req.body;

      const cart = await CartService.getCart(req.userId);
      if (!cart.items.length) {
        return res.status(400).json({ error: 'Cart is empty' });
      }

      const orderId = await generateOrderId();
      const referenceId = `${orderId}-${Date.now()}`.slice(0, 20);

      const order = await Order.create({
        orderId,
        userId: req.userId,
        items: cart.items,
        pricing: {
          subtotal: cart.subtotal,
          tax: cart.tax,
          shippingEstimate: cart.estimatedShipping,
          total: cart.total,
          currency: 'LKR',
        },
        bankDetails: {
          accountName: process.env.BANK_ACCOUNT_NAME || 'MAPORIA Pvt Ltd',
          accountNumber: process.env.BANK_ACCOUNT_NUMBER || '0000000000',
          bankName: process.env.BANK_NAME || 'Sample Bank',
          routingNumber: process.env.BANK_ROUTING_NUMBER || '',
          referenceId,
        },
        shippingAddress,
        status: 'pending_payment',
        statusHistory: [
          {
            status: 'pending_payment',
            updatedAt: new Date(),
            notes: 'Order created; awaiting payment',
            updatedBy: null,
          },
        ],
      });

      await CartService.clearCart(req.userId);

      res.json({
        order,
        message:
          'Order created. Please transfer the total amount and upload the payment receipt.',
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
);

// POST /api/store/payment/upload-receipt - simplified stub for now
router.post('/payment/upload-receipt', async (req, res) => {
  try {
    const { orderId, receiptUrl } = req.body;

    if (!orderId || !receiptUrl) {
      return res
        .status(400)
        .json({ error: 'orderId and receiptUrl are required' });
    }

    const order = await Order.findOne({ orderId, userId: req.userId });
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    order.paymentReceipt = {
      ...(order.paymentReceipt || {}),
      receiptUrl,
      uploadedAt: new Date(),
      verificationStatus: 'pending',
    };
    await order.save();

    await PaymentReceipt.create({
      orderId: order._id,
      userId: req.userId,
      receiptUrl,
      transferAmount: order.pricing.total,
      verificationStatus: 'pending',
    });

    res.json({
      message: 'Receipt recorded. Admin will verify the payment.',
      status: 'pending_verification',
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// GET /api/store/orders - list current user's orders
router.get('/orders', async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .lean();
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/store/orders/:orderId - single order
router.get('/orders/:orderId', async (req, res) => {
  try {
    const order = await Order.findOne({
      orderId: req.params.orderId,
      userId: req.userId,
    }).lean();

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

