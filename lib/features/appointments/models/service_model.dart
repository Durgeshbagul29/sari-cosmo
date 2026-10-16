class ServiceCategory {
  final int id;
  final String name;
  final String slug;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

class ServiceStaff {
  final int id;
  final String name;
  final String? email;
  final String? role;
  final String? image;
  final String? specialization;

  const ServiceStaff({
    required this.id,
    required this.name,
    this.email,
    this.role,
    this.image,
    this.specialization,
  });

  factory ServiceStaff.fromJson(Map<String, dynamic> json) {
    return ServiceStaff(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      role: json['role'],
      image: json['image'] ?? json['profile_photo_url'],
      specialization: json['specialization'] ?? json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'image': image,
      'specialization': specialization,
    };
  }
}

class ServiceModel {
  final int id;
  final String name;
  final String slug;
  final int durationMinutes;
  final double price;
  final String? image;
  final bool isActive;
  final ServiceCategory? category;
  final String? description;
  final List<ServiceStaff>? staff;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.durationMinutes,
    required this.price,
    this.image,
    required this.isActive,
    this.category,
    this.description,
    this.staff,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final staffList = json['staff'] as List?;
    List<ServiceStaff>? parsedStaff =
        staffList?.map((s) => ServiceStaff.fromJson(s)).toList();

    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
      isActive: json['is_active'] ?? true,
      category: json['category'] != null
          ? ServiceCategory.fromJson(json['category'])
          : null,
      description: json['description'],
      staff: parsedStaff,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'duration_minutes': durationMinutes,
      'price': price,
      'image': image,
      'is_active': isActive,
      'category': category?.toJson(),
      'description': description,
      'staff': staff?.map((s) => s.toJson()).toList(),
    };
  }
}
