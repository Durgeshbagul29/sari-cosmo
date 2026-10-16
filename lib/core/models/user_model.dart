class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? avatar;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? status;
  final String? createdAt;
  final String? token;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.avatar,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.status,
    this.createdAt,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      avatar: json['avatar']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'status': status,
      'created_at': createdAt,
      'token': token,
    };
  }
}
