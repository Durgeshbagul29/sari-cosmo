import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_detail_controller.dart';
import '../cart/cart_screen.dart';
import '../../controllers/wishlist_controller.dart';

import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

// Modular Widgets
import 'widgets/product_images_carousel.dart';
import 'widgets/product_info_header.dart';
import 'widgets/product_description_section.dart';
import 'widgets/product_reviews_section.dart';
import 'widgets/product_share_sheet.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailController _detailController =
      Get.put(ProductDetailController());

  int _qty = 1;
  bool _wishlisted = false;

  @override
  void initState() {
    super.initState();
    final wishlistController = Get.put(WishlistController());
    _wishlisted = wishlistController.isProductWishlisted(
      widget.product.name,
      id: widget.product.id,
      slug: widget.product.slug,
    );
    _detailController.fetchProductDetail(widget.product.slug);
    _detailController.fetchProductReviews(widget.product.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = _detailController.isLoading.value;
      final p = _detailController.productDetails.value ?? widget.product;

      if (isLoading && _detailController.productDetails.value == null) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textDark),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        );
      }
      final images = p.images.isNotEmpty
          ? p.images
          : (p.imageUrl.isNotEmpty ? [p.imageUrl] : <String>[]);

      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: AppTheme.surface,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _wishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _wishlisted ? AppTheme.primary : AppTheme.textDark,
                        ),
                        onPressed: () {
                          setState(() {
                            _wishlisted = !_wishlisted;
                            final wishlistController = Get.find<WishlistController>();
                            wishlistController.toggleProductWishlist({
                              'id': widget.product.id,
                              'slug': widget.product.slug,
                              'name': widget.product.name,
                              'price': widget.product.effectivePrice,
                              'originalPrice': widget.product.basePrice,
                              'image': widget.product.imageUrl,
                              'category': widget.product.category,
                              'rating': widget.product.rating,
                            });
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: AppTheme.textDark),
                        onPressed: () => ProductShareSheet.show(context, p),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined,
                                color: AppTheme.textDark),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CartScreen())),
                          ),
                          Obx(() {
                            final cartController = Get.find<CartController>();
                            if (cartController.itemCount == 0) {
                              return const SizedBox.shrink();
                            }
                            return Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: AppTheme.accent, shape: BoxShape.circle),
                                child: Text(
                                  '${cartController.itemCount}',
                                  style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProductImagesCarousel(images: images),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductInfoHeader(product: p),
                          const SizedBox(height: 24),
                          ProductDescriptionSection(product: p),
                          const SizedBox(height: 24),
                          ProductReviewsSection(),
                          const SizedBox(height: 24),
                          const Divider(color: AppTheme.divider),
                          const SizedBox(height: 16),
                          // Quantity Row
                          Row(
                            children: [
                              const Text('Quantity',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark)),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.divider),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () {
                                        if (_qty > 1) setState(() => _qty--);
                                      },
                                    ),
                                    Text('$_qty',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () => setState(() => _qty++),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3))
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final p = _detailController.productDetails.value ??
                            widget.product;
                        if (p.stockQuantity <= 0) {
                          AppSnackbar.error('Out of Stock',
                              'This product is currently out of stock.');
                          return;
                        }
                        final cart = Get.find<CartController>();
                        cart.addToCart(p.id, _qty);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final p = _detailController.productDetails.value ??
                            widget.product;
                        if (p.stockQuantity <= 0) {
                          AppSnackbar.error('Out of Stock',
                              'This product is currently out of stock.');
                          return;
                        }
                        final cart = Get.find<CartController>();
                        await cart.addToCart(p.id, _qty);
                        if (context.mounted) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CartScreen()));
                        }
                      },
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
