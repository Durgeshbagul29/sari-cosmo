import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';
import '../../../models/product_model.dart';

class ProductShareSheet extends StatelessWidget {
  final Product product;
  const ProductShareSheet({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductShareSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String productUrl = 'https://saricosmo.abraca-dabra.com/products/${product.slug}';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share Product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          
          // Product Preview
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: AppTheme.surface,
                    width: 60,
                    height: 60,
                    child: product.imageUrl.isNotEmpty
                        ? NetworkImageWidget(url: product.imageUrl, fit: BoxFit.contain)
                        : const Icon(Icons.shopping_bag_outlined, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          
          // Sharing options grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareItem(
                  icon: Icons.link_rounded,
                  label: 'Copy Link',
                  color: Colors.blue.shade600,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: productUrl));
                    Navigator.pop(context);
                    AppSnackbar.success(
                      'Copied!',
                      'Product link copied to clipboard.',
                    );
                  },
                ),
                _shareItem(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: Colors.green.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    AppSnackbar.primary(
                      'Share initiated',
                      'Opening WhatsApp to share: ${product.name}',
                    );
                  },
                ),
                _shareItem(
                  icon: Icons.alternate_email_rounded,
                  label: 'Email',
                  color: Colors.red.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    AppSnackbar.primary(
                      'Share initiated',
                      'Opening Email application...',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _shareItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMedium, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
