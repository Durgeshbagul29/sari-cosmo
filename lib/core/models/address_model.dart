class AddressModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final bool? isDefault;

  AddressModel({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      isDefault: json['is_default'] == true || json['is_default'] == 'true' || json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }
}
