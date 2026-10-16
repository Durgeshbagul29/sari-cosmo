import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/shop/controllers/wishlist_controller.dart';
import 'package:saris_cosmo_center/features/shop/models/product_model.dart';
import 'package:saris_cosmo_center/features/shop/models/product_category_model.dart';
import 'package:saris_cosmo_center/features/shop/screens/products_details/product_detail_screen.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';
import 'package:saris_cosmo_center/features/courses/models/course_category_model.dart';
import 'package:saris_cosmo_center/features/courses/screens/course_detail/course_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.put(WishlistController());
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Wishlist'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() {
            return TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textLight,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('Products (${wishlistController.rxProducts.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('Courses (${wishlistController.rxCourses.length})'),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsList(wishlistController),
          _buildCoursesList(wishlistController),
        ],
      ),
    );
  }

  Widget _buildProductsList(WishlistController wishlistController) {
    return Obx(() {
      final list = wishlistController.rxProducts;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  size: 40,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No products in wishlist',
                style: TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final product = Product(
                        id: item['wishlistable_id'] ?? item['id'] ?? 0,
                        name: item['name'] ?? item['title'] ?? '',
                        slug: item['slug'] ?? item['name'].toString().toLowerCase().replaceAll(' ', '-'),
                        shortDescription: item['short_description'] ?? '',
                        sku: '',
                        basePrice: (item['price'] ?? 0.0).toDouble(),
                        effectivePrice: (item['effective_price'] ?? item['sale_price'] ?? item['price'] ?? 0.0).toDouble(),
                        stockQuantity: 10,
                        isInStock: true,
                        isFeatured: false,
                        isActive: true,
                        thumbnail: item['image_url'] ?? item['image'] ?? '',
                        categoryData: ProductCategory(id: 0, name: item['category'] ?? 'Hair Care', slug: ''),
                        createdAt: '',
                        rating: (item['rating'] ?? 4.5).toDouble(),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                          child: Container(
                            width: 100,
                            height: 110,
                            color: AppTheme.primary.withValues(alpha: 0.03),
                            padding: const EdgeInsets.all(8),
                            child: CachedNetworkImage(
                              imageUrl: item['image_url'] ?? item['image'] ?? '',
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: AppTheme.textLight,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 14, color: AppTheme.ratingStar),
                                    const SizedBox(width: 2),
                                    Text('${item['rating'] ?? 4.5}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['category'] ?? 'Hair Care',
                                        style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '₹${((item['effective_price'] ?? item['sale_price'] ?? item['price'] ?? 0.0) as num).toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
                                    ),
                                    if (item['effective_price'] != null && item['price'] != null && item['price'] != item['effective_price']) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹${(item['price'] as num).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textLight,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ] else if (item['originalPrice'] != null && item['price'] != null && item['originalPrice'] != item['price']) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹${(item['originalPrice'] as num).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textLight,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_rounded, color: Color(0xFFE74C3C), size: 22),
                  onPressed: () => wishlistController.toggleProductWishlist(item),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildCoursesList(WishlistController wishlistController) {
    return Obx(() {
      final list = wishlistController.rxCourses;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  size: 40,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No courses in wishlist',
                style: TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final course = Course(
                        id: item['wishlistable_id'] ?? item['id'] ?? 0,
                        title: item['name'] ?? item['title'] ?? '',
                        slug: item['slug'] ?? item['name'].toString().toLowerCase().replaceAll(' ', '-'),
                        shortDescription: item['short_description'] ?? '',
                        thumbnail: item['image_url'] ?? item['image'] ?? '',
                        durationWeeks: 8,
                        price: (item['price'] ?? 0.0).toDouble(),
                        effectivePrice: (item['effective_price'] ?? item['sale_price'] ?? item['price'] ?? 0.0).toDouble(),
                        isPublished: true,
                        status: 'published',
                        category: CourseCategory(
                          id: 0,
                          name: item['category'] ?? 'Trichology',
                          slug: '',
                          description: '',
                          color: '#3b82f6',
                          icon: '',
                          isActive: true,
                          coursesCount: 0,
                        ),
                        instructor: CourseInstructor(id: 0, name: item['instructor'] ?? 'Instructor'),
                        createdAt: '',
                        description: '',
                        modules: const [],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailScreen(course: course),
                        ),
                      );
                    },
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                          child: Container(
                            width: 100,
                            height: 110,
                            color: AppTheme.primary.withValues(alpha: 0.03),
                            padding: const EdgeInsets.all(8),
                            child: CachedNetworkImage(
                              imageUrl: item['image_url'] ?? item['image'] ?? '',
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(
                                  Icons.school_outlined,
                                  color: AppTheme.textLight,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 13, color: AppTheme.textLight),
                                    const SizedBox(width: 4),
                                    Text(item['instructor'] ?? 'Instructor', style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '₹${((item['effective_price'] ?? item['sale_price'] ?? item['price'] ?? 0.0) as num).toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
                                    ),
                                    if (item['effective_price'] != null && item['price'] != null && item['price'] != item['effective_price']) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹${(item['price'] as num).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textLight,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_rounded, color: Color(0xFFE74C3C), size: 22),
                  onPressed: () => wishlistController.toggleCourseWishlist(item),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
