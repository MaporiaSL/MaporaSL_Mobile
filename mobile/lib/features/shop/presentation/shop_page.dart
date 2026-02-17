import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/real_store_models.dart';
import '../providers/real_store_providers.dart';
import 'checkout_page.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(realStoreItemsProvider);
    final cartAsync = ref.watch(shoppingCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          cartAsync.when(
            data: (cart) {
              final count = cart.items.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );
              return IconButton(
                icon: Badge(
                  label: Text('$count'),
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ShoppingCartPage()),
                  );
                },
              );
            },
            loading: () => IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ShoppingCartPage()),
                );
              },
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ShoppingCartPage()),
                );
              },
            ),
          ),
          // Reserve space for overlay profile icon so cart stays visible
          const SizedBox(width: 56),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No products available yet.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _RealStoreItemCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load products\n$e')),
      ),
    );
  }
}

class _RealStoreItemCard extends ConsumerWidget {
  const _RealStoreItemCard({required this.item});

  final RealStoreItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(shoppingCartProvider);
    final cartItem = cartAsync.valueOrNull?.items
        .where((i) => i.itemId == item.itemId)
        .firstOrNull;
    final quantity = cartItem?.quantity ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: item.thumbnail.isEmpty
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image, size: 32)),
                    )
                  : Image.network(
                      item.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  item.district,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'LKR ${item.priceLkr}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (quantity > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (quantity == 1) {
                            ref
                                .read(shoppingCartProvider.notifier)
                                .removeItem(item.itemId);
                          } else {
                            ref
                                .read(shoppingCartProvider.notifier)
                                .updateQuantity(item.itemId, quantity - 1);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$quantity',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: () {
                          ref
                              .read(shoppingCartProvider.notifier)
                              .updateQuantity(item.itemId, quantity + 1);
                        },
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () async {
                        await ref
                            .read(shoppingCartProvider.notifier)
                            .addItem(item.itemId, 1);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('Add'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}

class ShoppingCartPage extends ConsumerWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(shoppingCartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      title: Text(item.itemName),
                      subtitle: Text(
                        'LKR ${item.unitPrice} x ${item.quantity}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: item.quantity > 1
                                ? () => ref
                                      .read(shoppingCartProvider.notifier)
                                      .updateQuantity(
                                        item.itemId,
                                        item.quantity - 1,
                                      )
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => ref
                                .read(shoppingCartProvider.notifier)
                                .updateQuantity(item.itemId, item.quantity + 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => ref
                                .read(shoppingCartProvider.notifier)
                                .removeItem(item.itemId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Subtotal: LKR ${cart.subtotal}'),
                    Text('Tax: LKR ${cart.tax}'),
                    Text('Shipping: LKR ${cart.estimatedShipping}'),
                    const SizedBox(height: 8),
                    Text(
                      'Total: LKR ${cart.total}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CheckoutPage(),
                          ),
                        );
                      },
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load cart\n$e')),
      ),
    );
  }
}
