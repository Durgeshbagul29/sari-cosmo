import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:get/get.dart';
import '../../../models/product_model.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_filter_controller.dart';
import '../../products_details/product_detail_screen.dart';

class ProductListCard extends StatelessWidget {
  final Product product;
  const ProductListCard({super.key, required this.product});

  // Professional green accents (same as grid card)
  static const Color _ratingGreen = Color(0xFF388E3C);
  static const Color _discountGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.originalPrice > product.price;

    return GestureDetector(
      onTap: () {
        Get.find<ProductFilterController>().reset();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 0.8),
        ),
        child: Row(children: [
          // ── Image Section ──
          Stack(children: [
            Container(
              width: 130,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: product.imageUrl.isNotEmpty
                      ? NetworkImageWidget(
                          url: product.imageUrl,
                          height: 130,
                          width: 110,
                          fit: BoxFit.contain,
                          borderRadius: BorderRadius.zero)
                      : Center(
                          child: Icon(Icons.shopping_bag_outlined,
                              size: 44, color: Colors.grey.shade300),
                        ),
                ),
              ),
            ),

            // Discount badge - green
            if (product.discountPercent > 0)
              Positioned(
                top: 8,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: const BoxDecoration(
                    color: _discountGreen,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    '${product.discountPercent}% off',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            // Out of stock overlay
            if (!product.isInStock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Out of Stock',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
          ]),

          // Vertical divider
          Container(width: 0.5, color: Colors.grey.shade200),

          // ── Details Section ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: Colors.grey.shade800)),

                  const SizedBox(height: 4),

                  // Category
                  Text(product.category,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),

                  const SizedBox(height: 4),

                  // Rating - green pill
                  if (product.rating > 0)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: _ratingGreen,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.star_rounded,
                                  color: Colors.white, size: 10),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviews})',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),

                  const Spacer(),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price - primary
                      Text('₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary)),

                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${product.originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey.shade400),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.discountPercent}% off',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _discountGreen),
                        ),
                      ],

                      const Spacer(),

                      // Add to cart - primary button
                      GestureDetector(
                        onTap: product.isInStock
                            ? () {
                                Get.find<CartController>()
                                    .addToCart(product.id, 1);
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: product.isInStock
                                ? AppTheme.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  color: product.isInStock
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                  size: 14),
                              const SizedBox(width: 2),
                              Text('ADD',
                                  style: TextStyle(
                                      color: product.isInStock
                                          ? Colors.white
                                          : Colors.grey.shade500,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
