import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/real_store_models.dart';

class RealStoreApi {
  RealStoreApi(this._client);

  final ApiClient _client;

  Future<List<RealStoreItem>> getItems({
    String? district,
    String? category,
    int skip = 0,
    int limit = 20,
  }) async {
    final Response response = await _client.get(
      '/api/store/items',
      queryParameters: {
        if (district != null) 'district': district,
        if (category != null) 'category': category,
        'skip': skip,
        'limit': limit,
      },
    );

    final List items = (response.data['items'] as List? ?? <dynamic>[]);
    return items
        .map((json) => RealStoreItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ShoppingCart> getCart() async {
    final Response response = await _client.get('/api/store/cart');
    return ShoppingCart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ShoppingCart> addToCart(String itemId, int quantity) async {
    final Response response = await _client.post(
      '/api/store/cart/add',
      data: {'itemId': itemId, 'quantity': quantity},
    );
    return ShoppingCart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ShoppingCart> updateQuantity(String itemId, int quantity) async {
    final Response response = await _client.post(
      '/api/store/cart/update',
      data: {'itemId': itemId, 'quantity': quantity},
    );
    return ShoppingCart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ShoppingCart> removeFromCart(String itemId) async {
    final Response response = await _client.post(
      '/api/store/cart/remove',
      data: {'itemId': itemId},
    );
    return ShoppingCart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> checkout(ShippingAddress shippingAddress) async {
    final Response response = await _client.post(
      '/api/store/checkout',
      data: {
        'shippingAddress': shippingAddress.toJson(),
      },
    );

    return Order.fromJson(
      (response.data as Map<String, dynamic>)['order']
          as Map<String, dynamic>,
    );
  }

  Future<List<Order>> getOrders() async {
    final Response response = await _client.get('/api/store/orders');
    final List data = response.data as List? ?? <dynamic>[];
    return data
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final realStoreApiProvider = Provider<RealStoreApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return RealStoreApi(client);
});

