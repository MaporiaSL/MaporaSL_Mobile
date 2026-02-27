const express = require('express');
const { body } = require('express-validator');
const RealStoreItem = require('../models/RealStoreItem');
const Order = require('../models/Order');
const PaymentReceipt = require('../models/PaymentReceipt');
const CartService = require('../services/cartService');
const crypto = require('crypto');
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

// POST /api/store/payhere/notify - Webhook for PayHere payment status
router.post('/payhere/notify', express.urlencoded({ extended: true }), async (req, res) => {
  try {
    const {
      merchant_id,
      order_id,
      payhere_amount,
      payhere_currency,
      status_code,
      md5sig,
      payment_id,
    } = req.body;

    const merchantSecret = process.env.PAYHERE_MERCHANT_SECRET || 'placeholder_secret';

    // Validate signature
    const hashedSecret = crypto.createHash('md5').update(merchantSecret).digest('hex').toUpperCase();
    const hashStr = merchant_id + order_id + payhere_amount + payhere_currency + status_code + hashedSecret;
    const computedSig = crypto.createHash('md5').update(hashStr).digest('hex').toUpperCase();

    if (computedSig !== md5sig) {
      console.error('Invalid PayHere signature for order:', order_id);
      return res.status(400).send('Invalid Signature');
    }

    const order = await Order.findOne({ orderId: order_id });
    if (!order) {
      console.error('Order not found for PayHere notify:', order_id);
      return res.status(404).send('Order Not Found');
    }

    // Status map based on standard PayHere codes:
    // 2: Success, 0: Pending, -1: Canceled, -2: Failed, -3: Chargedback
    let newStatus = order.status;
    let notes = '';

    if (status_code === '2') {
      newStatus = 'PAID';
      notes = `Payment successful (Payment ID: ${payment_id})`;
      order.payherePaymentId = payment_id;
      order.paymentVerifiedAt = new Date();
    } else if (status_code === '-2') {
      newStatus = 'FAILED';
      notes = `Payment failed (Payment ID: ${payment_id})`;
    } else if (status_code === '0') {
      notes = `Payment pending (Payment ID: ${payment_id})`;
    } else if (status_code === '-1') {
      newStatus = 'FAILED';
      notes = `Payment cancelled by user.`;
    }

    if (newStatus !== order.status) {
      order.status = newStatus;
      order.statusHistory.push({
        status: newStatus,
        updatedAt: new Date(),
        notes,
      });
      await order.save();
    }

    // PayHere expects a 200 OK immediately
    res.status(200).send('OK');
  } catch (error) {
    console.error('PayHere webhook error:', error);
    res.status(500).send('Server Error');
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

// Helper to generate a simple unique orderId
const generateOrderId = async () => {
  const today = new Date();
  const dateStr = today.toISOString().slice(0, 10).replace(/-/g, '');

  // Use a random or timestamp-based suffix instead of counting 
  // to avoid race conditions and duplicate key errors (E11000)
  const uniqueSuffix = Date.now().toString().slice(-5);

  return `ORD-${dateStr}-${uniqueSuffix}`;
};

// POST /api/store/checkout - create order from cart
router.post(
  '/checkout',
  validateCheckout,
  handleValidationErrors,
  async (req, res) => {
    try {
      console.log('CHECKOUT REQUEST BODY:', req.body);
      const { shippingAddress } = req.body;

      const cart = await CartService.getCart(req.userId);
      console.log('CART CONTENTS BEFORE CHECKOUT:', JSON.stringify(cart, null, 2));
      if (!cart.items.length) {
        return res.status(400).json({ error: 'Cart is empty' });
      }

      const orderId = await generateOrderId();

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
        shippingAddress,
        status: 'pending_payment',
        statusHistory: [
          {
            status: 'pending_payment',
            updatedAt: new Date(),
            notes: 'Order created; awaiting PayHere payment',
            updatedBy: null,
          },
        ],
      });

      await CartService.clearCart(req.userId);

      // Generate PayHere Hash
      const merchantId = process.env.PAYHERE_MERCHANT_ID || '1234567';
      const merchantSecret = process.env.PAYHERE_MERCHANT_SECRET || 'placeholder_secret';
      const amount = order.pricing.total.toString();
      const currency = order.pricing.currency || 'LKR';

      const hashedSecret = crypto.createHash('md5').update(merchantSecret).digest('hex').toUpperCase();
      const amountFormatted = parseFloat(amount).toFixed(2);
      const hashStr = merchantId + orderId + amountFormatted + currency + hashedSecret;
      const hash = crypto.createHash('md5').update(hashStr).digest('hex').toUpperCase();

      res.json({
        order: {
          ...order.toJSON(),
          payhereHash: hash,
          payhereMerchantId: merchantId,
        },
        message: 'Order created safely. Please proceed to PayHere payment.',
      });
    } catch (error) {
      console.error('ERROR DURING CHECKOUT EXACT REASON:', error);
      res.status(400).json({ error: error.message });
    }
  }
);

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

