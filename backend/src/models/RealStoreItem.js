const mongoose = require('mongoose');

const realStoreItemSchema = new mongoose.Schema(
  {
    itemId: {
      type: String,
      unique: true,
      required: true,
      index: true,
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
    },
    district: {
      type: String,
      enum: [
        'Colombo',
        'Gampaha',
        'Kalutara',
        'Kandy',
        'Matale',
        'Nuwara Eliya',
        'Galle',
        'Matara',
        'Hambantota',
        'Jaffna',
        'Kilinochchi',
        'Mannar',
        'Vavuniya',
        'Mullaitivu',
        'Batticaloa',
        'Ampara',
        'Trincomalee',
        'Kurunegala',
        'Puttalam',
        'Anuradhapura',
        'Polonnaruwa',
        'Badulla',
        'Monaragala',
        'Ratnapura',
        'Kegalle',
      ],
      required: true,
      index: true,
    },
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
        'handicraft',
      ],
      required: true,
      index: true,
    },
    price: {
      lkr: {
        type: Number,
        required: true,
        min: 0,
      },
      originalPrice: {
        type: Number,
      },
    },
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
    images: {
      type: [String],
      required: true,
      validate: {
        validator: (v) => Array.isArray(v) && v.length > 0,
        message: 'At least one image URL is required',
      },
    },
    thumbnail: {
      type: String,
      required: true,
    },
    weight: {
      type: Number,
      required: true,
    },
    dimensions: {
      length: Number,
      width: Number,
      height: Number,
    },
    shippingEstimateDays: {
      type: Number,
      default: 3,
    },
    isFragile: {
      type: Boolean,
      default: false,
    },
    tags: {
      type: [String],
      default: [],
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
    seller: String,
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
    deletedAt: Date,
  },
  { timestamps: true }
);

realStoreItemSchema.index({ category: 1, featured: -1, displayOrder: 1 });
realStoreItemSchema.index({ featured: -1, displayOrder: 1 });

module.exports = mongoose.model('RealStoreItem', realStoreItemSchema);

