class CreateOrderRequest {
  final int addressId;
  final Address shippingAddress;
  final Address? billingAddress;
  final String paymentMethod;
  final String notes;
  final String? couponCode;
  final bool saveAddress;

  CreateOrderRequest({
    required this.addressId,
    required this.shippingAddress,
    this.billingAddress,
    required this.paymentMethod,
    required this.notes,
    this.couponCode,
    required this.saveAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress?.toJson() ?? [],
      'payment_method': paymentMethod,
      'notes': notes,
      'coupon_code': couponCode,
      'save_address': saveAddress,
    };
  }
}

class Address {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;

  Address({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
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
