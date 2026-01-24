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

// Validate create travel request
const validateCreateTravel = [
  body('title')
    .trim()
    .notEmpty().withMessage('Title is required')
    .isLength({ min: 3 }).withMessage('Title must be at least 3 characters'),
  body('description')
    .optional()
    .trim(),
  body('startDate')
    .notEmpty().withMessage('Start date is required')
    .isISO8601().withMessage('Start date must be a valid ISO 8601 date'),
  body('endDate')
    .notEmpty().withMessage('End date is required')
    .isISO8601().withMessage('End date must be a valid ISO 8601 date')
    .custom((value, { req }) => {
      const startDate = new Date(req.body.startDate);
      const endDate = new Date(value);
      if (endDate <= startDate) {
        throw new Error('End date must be after start date');
      }
      return true;
    }),
  body('locations')
    .optional()
    .isArray().withMessage('Locations must be an array')
    .custom(arr => {
      if (arr && arr.some(loc => typeof loc !== 'string')) {
        throw new Error('All locations must be strings');
      }
      return true;
    }),
  handleValidationErrors
];

// Validate update travel request
const validateUpdateTravel = [
  body('title')
    .optional()
    .trim()
    .isLength({ min: 3 }).withMessage('Title must be at least 3 characters'),
  body('description')
    .optional()
    .trim(),
  body('startDate')
    .optional()
    .isISO8601().withMessage('Start date must be a valid ISO 8601 date'),
  body('endDate')
    .optional()
    .isISO8601().withMessage('End date must be a valid ISO 8601 date')
    .custom((value, { req }) => {
      if (value) {
        const startDate = new Date(req.body.startDate || req.travel.startDate);
        const endDate = new Date(value);
        if (endDate <= startDate) {
          throw new Error('End date must be after start date');
        }
      }
      return true;
    }),
  body('locations')
    .optional()
    .isArray().withMessage('Locations must be an array'),
  handleValidationErrors
];

module.exports = {
  validateCreateTravel,
  validateUpdateTravel,
  handleValidationErrors
};
