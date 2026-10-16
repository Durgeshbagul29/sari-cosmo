class CartResponse {
  final bool success;
  final CartData data;

  CartResponse({required this.success, required this.data});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] ?? false,
      data: CartData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class CartData {
  final int id;
  final double subtotal;
  final int totalItems;
  final List<CartItem> items;

  CartData({
    required this.id,
    required this.subtotal,
    required this.totalItems,
    required this.items,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      id: json['id'],
      subtotal: (json['subtotal'] as num).toDouble(),
      totalItems: json['total_items'],
      items: (json['items'] as List).map((e) => CartItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subtotal': subtotal,
      'total_items': totalItems,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CartItem {
  final int id;
  final int quantity;
  final double price;
  final double total;
  final CartProduct product;

  CartItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.total,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      product: CartProduct.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price,
      'total': total,
      'product': product.toJson(),
    };
  }
}

class CartProduct {
  final int id;
  final String name;
  final String slug;
  final String thumbnail;
  final int stockQuantity;

  CartProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.thumbnail,
    required this.stockQuantity,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      stockQuantity: json['stock_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'thumbnail': thumbnail,
      'stock_quantity': stockQuantity,
    };
  }
}
