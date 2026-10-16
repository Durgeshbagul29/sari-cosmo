class ProductCategory {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final int? parent;
  final int sortOrder;
  final bool isActive;
  final int productsCount;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.image,
    this.parent,
    this.sortOrder = 0,
    this.isActive = true,
    this.productsCount = 0,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final parentValue = json['parent'] ?? json['parent_id'];
    return ProductCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      image: json['image']?.toString(),
      parent: parentValue == null ? null : int.tryParse(parentValue.toString()),
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      productsCount: json['products_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'parent': parent,
      'sort_order': sortOrder,
      'is_active': isActive,
      'products_count': productsCount,
    };
  }
}
