const { body, validationResult } = require('express-validator');

// Cart item validation
const validateCartItem = [
  body('itemId').notEmpty().withMessage('Item ID is required'),
  body('quantity')
    .isInt({ min: 1, max: 10 })
    .withMessage('Quantity must be between 1 and 10'),
];

// Checkout validation
const validateCheckout = [
  body('shippingAddress.fullName')
    .notEmpty()
    .withMessage('Full name is required'),
  body('shippingAddress.street')
    .notEmpty()
    .withMessage('Street is required'),
  body('shippingAddress.city').notEmpty().withMessage('City is required'),
  body('shippingAddress.phone')
    .isMobilePhone()
    .withMessage('Invalid phone'),
  body('shippingAddress.email').isEmail().withMessage('Invalid email'),
];

// Helper to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

module.exports = {
  validateCartItem,
  validateCheckout,
  handleValidationErrors,
};

