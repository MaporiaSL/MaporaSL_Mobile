const ShoppingCart = require('../models/ShoppingCart');
const RealStoreItem = require('../models/RealStoreItem');

// Basic pricing rules for the cart.
// You can fine-tune these numbers or make them configurable via environment variables.
const TAX_RATE = Number(process.env.SHOP_TAX_RATE || 0.0); // e.g. 0.08 for 8%
const SHIPPING_BASE = Number(process.env.SHOP_SHIPPING_BASE || 0);
const SHIPPING_PER_ITEM = Number(process.env.SHOP_SHIPPING_PER_ITEM || 0);

/**
 * Recalculate subtotal, tax, shipping and total for a cart.
 */
function calculateTotals(cart) {
  const subtotal = cart.items.reduce((sum, item) => sum + item.subtotal, 0);
  const tax = Math.round(subtotal * TAX_RATE);
  const itemCount = cart.items.reduce((sum, item) => sum + item.quantity, 0);
  const estimatedShipping = SHIPPING_BASE + SHIPPING_PER_ITEM * itemCount;
  const total = subtotal + tax + estimatedShipping;

  cart.subtotal = subtotal;
  cart.tax = tax;
  cart.estimatedShipping = estimatedShipping;
  cart.total = total;

  return cart;
}

async function getOrCreateActiveCart(userId) {
  let cart = await ShoppingCart.findOne({ userId, status: 'active' });
  if (!cart) {
    cart = await ShoppingCart.create({
      userId,
      items: [],
      subtotal: 0,
      tax: 0,
      estimatedShipping: 0,
      total: 0,
      status: 'active',
    });
  }
  return cart;
}

async function getCart(userId) {
  const cart = await getOrCreateActiveCart(userId);
  return calculateTotals(cart);
}

async function addToCart(userId, itemId, quantity) {
  if (quantity <= 0) {
    throw new Error('Quantity must be at least 1');
  }

  const item = await RealStoreItem.findOne({ itemId, deletedAt: null });
  if (!item) {
    throw new Error('Item not found');
  }

  if (item.stock.available < quantity) {
    throw new Error('Not enough stock available');
  }

  const unitPrice = item.price.lkr;
  let cart = await getOrCreateActiveCart(userId);

  const existing = cart.items.find((i) => i.itemId === itemId);
  if (existing) {
    const newQuantity = existing.quantity + quantity;
    if (newQuantity > 10) {
      throw new Error('Cannot have more than 10 units of a single item in the cart');
    }
    existing.quantity = newQuantity;
    existing.subtotal = existing.quantity * unitPrice;
  } else {
    cart.items.push({
      itemId: item.itemId,
      itemName: item.name,
      quantity,
      unitPrice,
      subtotal: unitPrice * quantity,
    });
  }

  cart.updatedAt = new Date();
  cart = calculateTotals(cart);
  await cart.save();

  return cart;
}

async function updateQuantity(userId, itemId, quantity) {
  if (quantity <= 0) {
    // Delegate to remove if quantity becomes zero / negative
    return removeFromCart(userId, itemId);
  }

  const item = await RealStoreItem.findOne({ itemId, deletedAt: null });
  if (!item) {
    throw new Error('Item not found');
  }

  if (quantity > 10) {
    throw new Error('Cannot have more than 10 units of a single item in the cart');
  }

  if (item.stock.available < quantity) {
    throw new Error('Not enough stock available');
  }

  let cart = await getOrCreateActiveCart(userId);
  const existing = cart.items.find((i) => i.itemId === itemId);

  if (!existing) {
    throw new Error('Item not found in cart');
  }

  existing.quantity = quantity;
  existing.subtotal = quantity * existing.unitPrice;
  cart.updatedAt = new Date();

  cart = calculateTotals(cart);
  await cart.save();

  return cart;
}

async function removeFromCart(userId, itemId) {
  let cart = await getOrCreateActiveCart(userId);
  cart.items = cart.items.filter((i) => i.itemId !== itemId);
  cart.updatedAt = new Date();

  cart = calculateTotals(cart);
  await cart.save();

  return cart;
}

async function clearCart(userId) {
  let cart = await getOrCreateActiveCart(userId);
  cart.items = [];
  cart.updatedAt = new Date();

  cart = calculateTotals(cart);
  await cart.save();

  return cart;
}

module.exports = {
  getCart,
  addToCart,
  updateQuantity,
  removeFromCart,
  clearCart,
};

