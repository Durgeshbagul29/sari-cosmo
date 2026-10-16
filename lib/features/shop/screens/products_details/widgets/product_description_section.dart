import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../../../models/product_model.dart';

class ProductDescriptionSection extends StatelessWidget {
  final Product product;
  const ProductDescriptionSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final text = product.description.isNotEmpty 
        ? product.description 
        : product.shortDescription;
        
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(height: 1.6, color: AppTheme.textMedium, fontSize: 14),
        ),
      ],
    );
  }
}
