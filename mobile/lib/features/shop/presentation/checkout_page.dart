import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/real_store_models.dart';
import '../providers/real_store_providers.dart';
import '../data/real_store_api.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:dio/dio.dart';
import 'order_success_page.dart';
import '../../../core/utils/currency_formatter.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedDistrict;
  final List<String> _sriLankanDistricts = [
    'Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa', 'Colombo', 'Galle',
    'Gampaha', 'Hambantota', 'Jaffna', 'Kalutara', 'Kandy', 'Kegalle',
    'Kilinochchi', 'Kurunegala', 'Mannar', 'Matale', 'Matara', 'Monaragala',
    'Mullaitivu', 'Nuwara Eliya', 'Polonnaruwa', 'Puttalam', 'Ratnapura',
    'Trincomalee', 'Vavuniya'
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final address = ShippingAddress(
        fullName: _nameController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        district: _selectedDistrict ?? '',
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      final api = ref.read(realStoreApiProvider);
      final order = await api.checkout(address);

      if (order.payhereHash == null || order.payhereMerchantId == null) {
        throw Exception('Payment configuration missing from server');
      }

      // Initialize PayHere Payment Object
      Map paymentObject = {
        "sandbox": true,
        "merchant_id": order.payhereMerchantId,
        "merchant_secret": "", // Not needed for mobile SDK, hash is enough
        "notify_url": order.payhereNotifyUrl ??
            "https://ent13zglezxqd.x.pipedream.net/", // Fallback to Pipedream if server fails
        "order_id": order.orderId,
        "items": "Maporia Order ${order.orderId}",
        "amount": double.parse(order.total.toStringAsFixed(2)),
        "currency": order.currency,
        "hash": order.payhereHash,
        "first_name": _nameController.text.split(' ').first,
        "last_name": _nameController.text.split(' ').length > 1
            ? _nameController.text.split(' ').last
            : '',
        "email": _emailController.text,
        "phone": _phoneController.text,
        "address": _streetController.text,
        "city": _cityController.text,
        "country": "Sri Lanka",
        "delivery_address": _streetController.text,
        "delivery_city": _cityController.text,
        "delivery_country": "Sri Lanka",
      };

      if (mounted) {
        setState(() => _isSubmitting = false);
      }

      // Start PayHere Payment
      PayHere.startPayment(
        paymentObject,
        (paymentId) async {
          debugPrint(
            "PayHere One-Time Payment Success. Payment Id: $paymentId",
          );
          try {
            await ref.read(realStoreApiProvider).verifyPayment(order.orderId);
          } catch (e) {
            debugPrint("Failed to assert local payment verification: $e");
          }
          final _ = ref.refresh(shoppingCartProvider);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
            );
          }
        },
        (error) {
          debugPrint("PayHere One-Time Payment Error. Error: $error");
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Payment Failed: $error')));
          }
        },
        () {
          debugPrint("PayHere One-Time Payment Dismissed");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled by user')),
            );
          }
        },
      );
    } on DioException catch (dioErr) {
      if (mounted) {
        final errorMsg = dioErr.response?.data != null 
            ? dioErr.response!.data.toString() 
            : dioErr.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $errorMsg')),
        );
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(shoppingCartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Shipping Information'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedDistrict,
                    items: _sriLankanDistricts.map((district) {
                      return DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDistrict = val;
                      });
                    },
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Order Summary'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${item.quantity}x ${item.itemName}', style: const TextStyle(color: Colors.black87))),
                              Text(CurrencyFormatter.formatLkr(item.subtotal), style: const TextStyle(color: Colors.black87)),
                            ],
                          ),
                        )),
                        const Divider(),
                        _buildSummaryRow(
                          'Subtotal',
                          CurrencyFormatter.formatLkr(cart.subtotal),
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Shipping',
                          // Will calculate shipping dynamically based on district in the future or via backend
                          CurrencyFormatter.formatLkr(
                            _selectedDistrict == 'Colombo' ? 300 :
                            (_selectedDistrict == 'Gampaha' || _selectedDistrict == 'Kalutara' ? 400 : 
                            (_selectedDistrict != null ? 500 : cart.estimatedShipping))
                          ),
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Total',
                          CurrencyFormatter.formatLkr(
                            cart.subtotal + cart.tax + 
                            (_selectedDistrict == 'Colombo' ? 300 :
                            (_selectedDistrict == 'Gampaha' || _selectedDistrict == 'Kalutara' ? 400 : 
                            (_selectedDistrict != null ? 500 : cart.estimatedShipping)))
                          ),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Payment Method'),
                  const SizedBox(height: 8),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.payment),
                      title: Text('PayHere'),
                      subtitle: Text(
                        'Secure payment via Credit/Debit card, eZ Cash, etc.',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 16 : 14,
      color: Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
