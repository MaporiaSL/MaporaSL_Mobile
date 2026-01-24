const { body, validationResult } = require('express-validator');

// Middleware to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array().map(err => ({ field: err.param, message: err.msg }))
    });
  }
  next();
};

// Validate create destination request
const validateCreateDestination = [
  body('name')
    .trim()
    .notEmpty().withMessage('Name is required')
    .isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('latitude')
    .notEmpty().withMessage('Latitude is required')
    .isFloat({ min: -90, max: 90 }).withMessage('Latitude must be between -90 and 90'),
  body('longitude')
    .notEmpty().withMessage('Longitude is required')
    .isFloat({ min: -180, max: 180 }).withMessage('Longitude must be between -180 and 180'),
  body('notes')
    .optional()
    .trim(),
  body('visited')
    .optional()
    .isBoolean().withMessage('Visited must be a boolean'),
  handleValidationErrors
];

// Validate update destination request
const validateUpdateDestination = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('latitude')
    .optional()
    .isFloat({ min: -90, max: 90 }).withMessage('Latitude must be between -90 and 90'),
  body('longitude')
    .optional()
    .isFloat({ min: -180, max: 180 }).withMessage('Longitude must be between -180 and 180'),
  body('notes')
    .optional()
    .trim(),
  body('visited')
    .optional()
    .isBoolean().withMessage('Visited must be a boolean'),
  handleValidationErrors
];

module.exports = {
  validateCreateDestination,
  validateUpdateDestination,
  handleValidationErrors
};
