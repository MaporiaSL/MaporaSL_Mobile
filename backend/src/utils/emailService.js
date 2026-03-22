const nodemailer = require('nodemailer');

// Set up a simple reusable transporter
// In production, configure environment variables for SMTP
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    // IMPORTANT: Replace these with your actual Gmail and App Password
    // Or set EMAIL_USER and EMAIL_PASS in your backend/.env file
    user: process.env.EMAIL_USER || 'your.business@gmail.com', 
    pass: process.env.EMAIL_PASS || 'your-16-digit-app-password',
  },
});

async function sendOrderConfirmationEmail(order) {
  try {
    const toEmail = order.shippingAddress.email;
    if (!toEmail) return;

    const itemsHtml = order.items.map(i => `<li>${i.quantity}x ${i.itemName} - LKR ${i.subtotal.toFixed(2)}</li>`).join('');

    const mailOptions = {
      from: '"Maporia E-Commerce" <no-reply@maporia.lk>',
      to: toEmail,
      subject: `Order Confirmation - ${order.orderId}`,
      html: `
        <h2>Thank you for your order!</h2>
        <p>Your payment has been successfully processed.</p>
        <h3>Order Summary: ${order.orderId}</h3>
        <ul>
          ${itemsHtml}
        </ul>
        <br/>
        <p><strong>Subtotal:</strong> LKR ${order.pricing.subtotal.toFixed(2)}</p>
        <p><strong>Shipping:</strong> LKR ${order.pricing.shippingEstimate.toFixed(2)}</p>
        <p><strong>Total Paid:</strong> LKR ${order.pricing.total.toFixed(2)}</p>
        <br/>
        <h3>Delivery Information</h3>
        <p>
          ${order.shippingAddress.fullName}<br/>
          ${order.shippingAddress.street}<br/>
          ${order.shippingAddress.city}<br/>
          ${order.shippingAddress.district}
        </p>
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Order confirmation email sent:', info.messageId);
    return info;
  } catch (error) {
    console.error('Error sending confirmation email:', error);
  }
}

module.exports = {
  sendOrderConfirmationEmail,
};
