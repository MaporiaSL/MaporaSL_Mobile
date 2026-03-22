import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/real_store_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('You have no past orders.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Order: ${order.orderId}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatStatus(order.status),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (order.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy - h:mm a').format(order.createdAt!.toLocal()),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                      const Divider(height: 24),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('${item.quantity}x ${item.itemName}')),
                                Text(CurrencyFormatter.formatLkr(item.subtotal)),
                              ],
                            ),
                          )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            CurrencyFormatter.formatLkr(order.total),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading orders: $e')),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending_payment':
      case 'payment_received':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'PAID':
        return 'Paid';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'FAILED':
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'FAILED':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
