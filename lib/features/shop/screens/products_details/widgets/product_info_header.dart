import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import '../../../models/product_model.dart';

class ProductInfoHeader extends StatelessWidget {
  final Product product;
  const ProductInfoHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badges Row
        Row(
          children: [
            BadgeChip(
              label: product.category,
              bg: AppTheme.primary.withOpacity(0.1),
              fg: AppTheme.primary,
            ),
            if (product.badge.isNotEmpty) ...[
              const SizedBox(width: 8),
              BadgeChip(
                label: product.badge,
                bg: product.badge == 'New' ? AppTheme.success : AppTheme.primary,
              ),
            ],
            if (product.weight != null && product.weight!.isNotEmpty) ...[
              const SizedBox(width: 8),
              BadgeChip(
                label: '${product.weight} g',
                bg: Colors.blue.withOpacity(0.1),
                fg: Colors.blue.shade700,
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          product.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        // SKU Metadata
        Text(
          'SKU: ${product.sku}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        // Rating & Stock Details
        Row(
          children: [
            StarRating(rating: product.rating, reviewCount: product.reviews, size: 14),
            const Spacer(),
            // Stock Indicator
            if (product.isLowStock == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Low Stock: Only ${product.stockQuantity} left!',
                  style: const TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            else if (product.stockQuantity > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'In Stock (${product.stockQuantity})',
                  style: const TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Out of Stock',
                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Price Row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMedium, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 8),
                      if (product.originalPrice > product.price) ...[
                        Text(
                          '₹${product.originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        BadgeChip(
                          label: '${product.discountPercent}% OFF',
                          bg: AppTheme.warning,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
