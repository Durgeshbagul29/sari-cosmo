class OrderUser {
  final int id;
  final String name;
  final String email;

  OrderUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class OrderAddress {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;

  OrderAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String productSku;
  final String productImage;
  final int quantity;
  final double price;
  final double total;
  final bool isReviewed;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
    required this.isReviewed,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      productImage: json['product_image'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      isReviewed: json['is_reviewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
      'total': total,
      'is_reviewed': isReviewed,
    };
  }
}

class OrderPayment {
  final int id;
  final double amount;
  final String status;
  final String method;

  OrderPayment({
    required this.id,
    required this.amount,
    required this.status,
    required this.method,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: json['id'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      method: json['method'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'status': status,
      'method': method,
    };
  }
}

class Order {
  final int id;
  final String orderNumber;
  final OrderUser user;
  final double subtotal;
  final double discount;
  final double tax;
  final double shippingCharge;
  final double total;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final int itemsCount;
  final String createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.user,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shippingCharge,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.itemsCount,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      user: OrderUser.fromJson(json['user'] ?? {}),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shippingCharge: (json['shipping_charge'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'COD',
      paymentStatus: json['payment_status'] ?? 'pending',
      itemsCount: json['items_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user': user.toJson(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'shipping_charge': shippingCharge,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'items_count': itemsCount,
      'created_at': createdAt,
    };
  }
}

class OrderDetail {
  final int id;
  final String orderNumber;
  final OrderUser user;
  final double subtotal;
  final double discount;
  final double tax;
  final double shippingCharge;
  final double total;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final int itemsCount;
  final String createdAt;
  final OrderAddress? shippingAddress;
  final OrderAddress? billingAddress;
  final String couponCode;
  final String notes;
  final List<OrderItem> items;
  final List<OrderPayment> payments;

  OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.user,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shippingCharge,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.itemsCount,
    required this.createdAt,
    this.shippingAddress,
    this.billingAddress,
    required this.couponCode,
    required this.notes,
    required this.items,
    required this.payments,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      user: OrderUser.fromJson(json['user'] ?? {}),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shippingCharge: (json['shipping_charge'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'COD',
      paymentStatus: json['payment_status'] ?? 'pending',
      itemsCount: json['items_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      shippingAddress: (json['shipping_address'] != null && json['shipping_address'] is Map)
          ? OrderAddress.fromJson(json['shipping_address'])
          : null,
      billingAddress: (json['billing_address'] != null && json['billing_address'] is Map)
          ? OrderAddress.fromJson(json['billing_address'])
          : null,
      couponCode: json['coupon_code'] ?? '',
      notes: json['notes'] ?? '',
      items: (json['items'] as List?)?.map((e) => OrderItem.fromJson(e)).toList() ?? [],
      payments: (json['payments'] as List?)
              ?.map((e) => OrderPayment.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user': user.toJson(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'shipping_charge': shippingCharge,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'items_count': itemsCount,
      'created_at': createdAt,
      'shipping_address': shippingAddress?.toJson(),
      'billing_address': billingAddress?.toJson(),
      'coupon_code': couponCode,
      'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}
