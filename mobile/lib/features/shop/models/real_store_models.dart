import 'package:meta/meta.dart';

@immutable
class RealStoreItem {
  const RealStoreItem({
    required this.itemId,
    required this.name,
    required this.description,
    this.longDescription,
    required this.district,
    required this.category,
    required this.priceLkr,
    required this.thumbnail,
  });

  final String itemId;
  final String name;
  final String description;
  final String? longDescription;
  final String district;
  final String category;
  final int priceLkr;
  final String thumbnail;

  factory RealStoreItem.fromJson(Map<String, dynamic> json) {
    final price = json['price'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return RealStoreItem(
      itemId: json['itemId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      longDescription: json['longDescription'] as String?,
      district: json['district'] as String? ?? '',
      category: json['category'] as String? ?? '',
      priceLkr: (price['lkr'] as num? ?? 0).toInt(),
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }
}

@immutable
class CartItem {
  const CartItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final String itemId;
  final String itemName;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      unitPrice: (json['unitPrice'] as num? ?? 0).toInt(),
      subtotal: (json['subtotal'] as num? ?? 0).toInt(),
    );
  }
}

@immutable
class ShoppingCart {
  const ShoppingCart({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.estimatedShipping,
    required this.total,
  });

  final List<CartItem> items;
  final int subtotal;
  final int tax;
  final int estimatedShipping;
  final int total;

  factory ShoppingCart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? <dynamic>[];
    return ShoppingCart(
      items: itemsJson
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num? ?? 0).toInt(),
      tax: (json['tax'] as num? ?? 0).toInt(),
      estimatedShipping:
          (json['estimatedShipping'] as num? ?? 0).toInt(),
      total: (json['total'] as num? ?? 0).toInt(),
    );
  }
}

@immutable
class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.street,
    required this.city,
    required this.phone,
    required this.email,
    this.postalCode,
    this.province,
  });

  final String fullName;
  final String street;
  final String city;
  final String phone;
  final String email;
  final String? postalCode;
  final String? province;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'street': street,
      'city': city,
      'phone': phone,
      'email': email,
      if (postalCode != null) 'postalCode': postalCode,
      if (province != null) 'province': province,
    };
  }
}

@immutable
class Order {
  const Order({
    required this.orderId,
    required this.userId,
    required this.total,
    required this.currency,
    required this.status,
  });

  final String orderId;
  final String userId;
  final int total;
  final String currency;
  final String status;

  factory Order.fromJson(Map<String, dynamic> json) {
    final pricing =
        json['pricing'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return Order(
      orderId: json['orderId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      total: (pricing['total'] as num? ?? 0).toInt(),
      currency: pricing['currency'] as String? ?? 'LKR',
      status: json['status'] as String? ?? '',
    );
  }
}

