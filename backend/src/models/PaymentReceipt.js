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
      type: String,
      required: true,
      index: true,
    },
    receiptUrl: {
      type: String,
      required: true,
    },
    receiptFileName: String,
    receiptFileSize: Number,
    uploadedAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
    transferAmount: {
      type: Number,
      required: true,
    },
    transferDate: {
      type: Date,
    },
    transferFromAccount: String,
    verificationStatus: {
      type: String,
      enum: ['pending', 'verified', 'rejected', 'resubmitted'],
      default: 'pending',
      index: true,
    },
    verifiedBy: mongoose.Schema.Types.ObjectId,
    verificationDate: Date,
    verificationNotes: String,
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
    verificationAttempts: {
      type: Number,
      default: 1,
    },
    createdAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

paymentReceiptSchema.index({
  verificationStatus: 1,
  uploadedAt: -1,
});

module.exports = mongoose.model('PaymentReceipt', paymentReceiptSchema);

