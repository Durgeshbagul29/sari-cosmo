class ProductReviewUser {
  final int id;
  final String name;

  const ProductReviewUser({
    required this.id,
    required this.name,
  });

  factory ProductReviewUser.fromJson(Map<String, dynamic> json) {
    return ProductReviewUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ProductReview {
  final int id;
  final int productId;
  final int userId;
  final int rating;
  final String title;
  final String comment;
  final bool isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProductReviewUser user;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] ?? 0,
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      isApproved: json['is_approved'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      user: ProductReviewUser.fromJson(json['user'] ?? const {}),
    );
  }
}

class ProductReviewSummary {
  final int productId;
  final String productName;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<ProductReview> reviews;

  const ProductReviewSummary({
    required this.productId,
    required this.productName,
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.reviews,
  });

  factory ProductReviewSummary.fromJson(Map<String, dynamic> json) {
    final reviewsData = Map<String, dynamic>.from(json['reviews'] ?? const {});
    final distributionData =
        Map<String, dynamic>.from(json['distribution'] ?? const {});
    final reviewList = (reviewsData['data'] as List? ?? const [])
        .map((item) => ProductReview.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return ProductReviewSummary(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      distribution: {
        5: distributionData['5'] ?? 0,
        4: distributionData['4'] ?? 0,
        3: distributionData['3'] ?? 0,
        2: distributionData['2'] ?? 0,
        1: distributionData['1'] ?? 0,
      },
      currentPage: reviewsData['current_page'] ?? 1,
      lastPage: reviewsData['last_page'] ?? 1,
      perPage: reviewsData['per_page'] ?? reviewList.length,
      total: reviewsData['total'] ?? reviewList.length,
      reviews: reviewList,
    );
  }
}
