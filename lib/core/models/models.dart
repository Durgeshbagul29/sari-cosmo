class Product {
  final String id, name, subtitle, category, description, imageUrl, badge, directionToUse;
  final double price, originalPrice, rating;
  final int reviews, stock;
  final List<String> benefits, ingredients, availableSizes;

  const Product({
    required this.id, required this.name, this.subtitle = '', required this.category,
    required this.description, required this.imageUrl, required this.price,
    required this.originalPrice, required this.rating, required this.reviews,
    required this.stock, required this.benefits, this.badge = '',
    this.ingredients = const [], this.directionToUse = '', this.availableSizes = const [],
  });

  int get discountPercent => originalPrice > 0 ? ((originalPrice - price) / originalPrice * 100).round() : 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
      stock: json['stock'] ?? 0,
      badge: json['badge'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      directionToUse: json['directionToUse'] ?? '',
      availableSizes: List<String>.from(json['availableSizes'] ?? []),
    );
  }
}

class Expert {
  final String id, name, specialization, qualification, imageUrl, bio;
  final double rating;
  final int patients, experience;
  final List<String> services;
  final List<String> availableDays;

  const Expert({
    required this.id, required this.name, required this.specialization,
    required this.qualification, required this.imageUrl, required this.bio,
    required this.rating, required this.patients, required this.experience,
    required this.services, required this.availableDays,
  });

  factory Expert.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> expertData = json['expert'] is Map<String, dynamic> 
        ? json['expert'] 
        : json;

    List<String> parseStringList(dynamic list) {
      if (list == null) return [];
      if (list is List) {
        return list.map((e) {
          if (e is Map) {
            return (e['name'] ?? '').toString();
          }
          return e.toString();
        }).where((element) => element.isNotEmpty).toList();
      }
      return [list.toString()];
    }

    final String fallbackName = json['name'] ?? json['title'] ?? 'Expert';
    final rawPhoto = expertData['photo'] ?? expertData['image_url'] ?? expertData['imageUrl'] ?? expertData['thumbnail'] ?? json['thumbnail'] ?? '';
    final String imageUrl = rawPhoto is String ? rawPhoto : '';

    return Expert(
      id: (expertData['id'] ?? json['id'] ?? '').toString(),
      name: expertData['name'] ?? fallbackName,
      specialization: expertData['specialization'] ?? expertData['speciality'] ?? json['name'] ?? 'Specialist',
      qualification: expertData['qualification'] ?? 'Certified Specialist',
      imageUrl: imageUrl,
      bio: expertData['bio'] ?? json['description'] ?? 'No biography available.',
      rating: (expertData['rating'] ?? json['rating'] ?? 4.5).toDouble(),
      patients: expertData['patients'] ?? json['patients'] ?? 100,
      experience: expertData['experience'] ?? json['experience'] ?? 5,
      services: parseStringList(expertData['services'] ?? json['services'] ?? [json['name'] ?? '']),
      availableDays: parseStringList(expertData['availableDays'] ?? expertData['available_days'] ?? ['Mon', 'Wed', 'Fri']),
    );
  }
}

class Appointment {
  final String id, expertName, service, date, time, status, type;
  const Appointment({
    required this.id, required this.expertName, required this.service,
    required this.date, required this.time, required this.status, required this.type,
  });
}
