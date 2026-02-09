import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/real_store_api.dart';
import '../models/real_store_models.dart';

final realStoreItemsProvider = FutureProvider.autoDispose<
    List<RealStoreItem>>((ref) async {
  final api = ref.watch(realStoreApiProvider);
  return api.getItems();
});

class ShoppingCartNotifier extends StateNotifier<AsyncValue<ShoppingCart>> {
  ShoppingCartNotifier(this._api) : super(const AsyncValue.loading()) {
    _load();
  }

  final RealStoreApi _api;

  Future<void> _load() async {
    try {
      final cart = await _api.getCart();
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(String itemId, int quantity) async {
    try {
      final updated = await _api.addToCart(itemId, quantity);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final updated = await _api.updateQuantity(itemId, quantity);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final updated = await _api.removeFromCart(itemId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final shoppingCartProvider = StateNotifierProvider.autoDispose<
    ShoppingCartNotifier, AsyncValue<ShoppingCart>>((ref) {
  final api = ref.watch(realStoreApiProvider);
  return ShoppingCartNotifier(api);
});

