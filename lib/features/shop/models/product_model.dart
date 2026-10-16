import 'product_category_model.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String shortDescription;
  final String sku;
  final double basePrice; // API price
  final double? salePrice;
  final double effectivePrice; // API effective_price
  final int stockQuantity;
  final bool isInStock;
  final bool isFeatured;
  final bool isActive;
  final String? thumbnail;
  final ProductCategory categoryData;
  final String createdAt;

  // Additional detail fields with default fallbacks if not in list
  final String description;
  final double rating;
  final int reviews;
  final List<String> benefits;
  final List<String> ingredients;
  final String directionToUse;
  final List<String> availableSizes;
  final String? weight;
  final int? lowStockThreshold;
  final bool? isLowStock;
  final List<String> images;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.shortDescription,
    required this.sku,
    required this.basePrice,
    this.salePrice,
    required this.effectivePrice,
    required this.stockQuantity,
    required this.isInStock,
    required this.isFeatured,
    required this.isActive,
    this.thumbnail,
    required this.categoryData,
    required this.createdAt,
    this.description = '',
    this.rating = 4.5,
    this.reviews = 10,
    this.benefits = const [],
    this.ingredients = const [],
    this.directionToUse = '',
    this.availableSizes = const [],
    this.weight,
    this.lowStockThreshold,
    this.isLowStock,
    this.images = const [],
  });

  // Getters for legacy properties
  String get category => categoryData.name;
  String get categorySlug => categoryData.slug;
  int get stock => stockQuantity;
  int get discountPercent => basePrice > 0 ? (((basePrice - effectivePrice) / basePrice) * 100).round() : 0;
  String get imageUrl => thumbnail ?? '';
  String get badge => isFeatured ? 'Featured' : '';
  String get subtitle => shortDescription;
  double get originalPrice => basePrice;
  double get price => effectivePrice;

  factory Product.fromJson(Map<String, dynamic> json) {
    final double rawPrice = (json['price'] ?? 0).toDouble();
    final double rawEffective = (json['effective_price'] ?? rawPrice).toDouble();
    final String? thumb = json['thumbnail'];

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['short_description'] ?? '',
      sku: json['sku'] ?? '',
      basePrice: rawPrice,
      salePrice: json['sale_price'] != null ? (json['sale_price'] as num).toDouble() : null,
      effectivePrice: rawEffective,
      stockQuantity: json['stock_quantity'] ?? 0,
      isInStock: json['is_in_stock'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? false,
      thumbnail: thumb,
      categoryData: ProductCategory.fromJson(json['category'] ?? {}),
      createdAt: json['created_at'] ?? '',
      description: json['description'] ?? json['short_description'] ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 4.5,
      reviews: json['reviews'] ?? 10,
      benefits: json['benefits'] != null 
          ? List<String>.from(json['benefits']) 
          : const [
              'Premium quality ayurvedic preparation',
              'Safe and effective for daily use',
              '100% natural ingredients only'
            ],
      ingredients: json['ingredients'] != null 
          ? List<String>.from(json['ingredients']) 
          : const [
              'Herbal extracts',
              'Natural essential oils',
              'Purified base'
            ],
      directionToUse: json['direction_to_use'] ?? json['directionToUse'] ?? 'Apply standard quantity on desired areas. Rinse thoroughly or massage gently.',
      availableSizes: json['available_sizes'] != null 
          ? List<String>.from(json['available_sizes']) 
          : const ['100g', '200g'],
      weight: json['weight']?.toString(),
      lowStockThreshold: json['low_stock_threshold'],
      isLowStock: json['is_low_stock'],
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : (thumb != null ? [thumb] : const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'short_description': shortDescription,
      'sku': sku,
      'price': basePrice,
      'sale_price': salePrice,
      'effective_price': effectivePrice,
      'stock_quantity': stockQuantity,
      'is_in_stock': isInStock,
      'is_featured': isFeatured,
      'is_active': isActive,
      'thumbnail': thumbnail,
      'category': categoryData.toJson(),
      'created_at': createdAt,
      'description': description,
      'rating': rating,
      'reviews': reviews,
      'benefits': benefits,
      'ingredients': ingredients,
      'direction_to_use': directionToUse,
      'available_sizes': availableSizes,
      'weight': weight,
      'low_stock_threshold': lowStockThreshold,
      'is_low_stock': isLowStock,
      'images': images,
    };
  }
}
