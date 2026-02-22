const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema(
  {
    orderId: {
      type: String,
      unique: true,
      required: true,
      index: true,
    },
    userId: {
      type: String,
      required: true,
      index: true,
    },
    items: [
      {
        itemId: String,
        itemName: String,
        quantity: Number,
        unitPrice: Number,
        subtotal: Number,
      },
    ],
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
      verificationStatus: {
        type: String,
        enum: ['pending', 'verified', 'rejected'],
        default: 'pending',
        index: true,
      },
      verificationNotes: String,
      rejectionReason: String,
    },
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
    statusHistory: [
      {
        status: String,
        updatedAt: Date,
        notes: String,
        updatedBy: mongoose.Schema.Types.ObjectId,
      },
    ],
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
  },
  { timestamps: true }
);

orderSchema.index({ userId: 1, createdAt: -1 });
orderSchema.index({ status: 1, createdAt: -1 });
// Note: orderId and paymentReceipt.verificationStatus already have index: true in schema definition

module.exports = mongoose.model('Order', orderSchema);

