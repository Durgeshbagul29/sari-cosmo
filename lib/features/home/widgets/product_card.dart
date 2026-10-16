import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:saris_cosmo_center/features/shop/models/product_model.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/features/shop/controllers/cart_controller.dart';

import '../../shop/screens/products_details/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final EdgeInsetsGeometry? margin;
  const ProductCard({super.key, required this.product, this.margin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        width: 150,
        margin: margin ?? const EdgeInsets.only(right: 12, bottom: 8, top: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider, width: 0.8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image Section
          Stack(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: NetworkImageWidget(
                    url: product.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.zero),
              ),
            ),
            if (product.discountPercent > 0)
              Positioned(
                  top: 8,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                        color: AppTheme.warning,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4))),
                    child: Text('-${product.discountPercent}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  )),
          ]),
          // Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2)),
                    const Spacer(),
                    Text('₹${product.originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary)),
                        // Add Button
                        GestureDetector(
                          onTap: () {
                            Get.find<CartController>().addToCart(product.id, 1);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: const Text('ADD',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  final double? width;
  final EdgeInsetsGeometry? margin;
  const ProductCardShimmer({super.key, this.width = 150, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: ShimmerWidget(
              width: double.infinity,
              height: 130,
              borderRadius: BorderRadius.zero,
            ),
          ),
          // Details skeleton
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(height: 4),
                  // Title skeleton line 1
                   ShimmerWidget(
                    width: 110,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                   SizedBox(height: 6),
                  // Title skeleton line 2
                   ShimmerWidget(
                    width: 70,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                   Spacer(),
                  // Price line skeleton
                   ShimmerWidget(
                    width: 40,
                    height: 10,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                   SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       ShimmerWidget(
                        width: 60,
                        height: 16,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                       ShimmerWidget(
                        width: 44,
                        height: 24,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
