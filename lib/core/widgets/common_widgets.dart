import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.subtitle = '', this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ])),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
      ]),
    );
  }
}

class BadgeChip extends StatelessWidget {
  final String label;
  final Color? bg, fg;
  const BadgeChip({super.key, required this.label, this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? AppTheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(
        color: fg ?? Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;
  const StarRating({super.key, required this.rating, this.reviewCount, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, color: AppTheme.ratingStar, size: size + 2),
      const SizedBox(width: 3),
      Text(rating.toStringAsFixed(1),
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      if (reviewCount != null) ...[
        const SizedBox(width: 3),
        Text('($reviewCount)',
          style: TextStyle(fontSize: size - 1, color: AppTheme.textLight)),
      ],
    ]);
  }
}

class PriceTag extends StatelessWidget {
  final double price, originalPrice;
  final bool isFree;
  const PriceTag({super.key, required this.price, required this.originalPrice, this.isFree = false});

  @override
  Widget build(BuildContext context) {
    if (isFree) return const BadgeChip(label: 'FREE', bg: AppTheme.success);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('₹${price.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
      const SizedBox(width: 6),
      if (originalPrice > price)
        Text('₹${originalPrice.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight,
              decoration: TextDecoration.lineThrough)),
    ]);
  }
}

class NetworkImageWidget extends StatelessWidget {
  final String url;
  final double? height, width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  const NetworkImageWidget({super.key, required this.url, this.height, this.width,
    this.fit = BoxFit.cover, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    Widget img;
    final bool isNetwork = url.startsWith('http') || url.startsWith('https');

    if (isNetwork) {
      img = CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(
          height: height,
          width: width,
          color: AppTheme.cardBg,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorIcon(),
      );
    } else {
      img = Image.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildErrorIcon(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _buildErrorIcon() {
    return Container(
      height: height, width: width, color: AppTheme.cardBg,
      child: const Center(child: Icon(Icons.image_not_supported_outlined, color: AppTheme.textLight, size: 32)),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  const CustomSearchBar({super.key, this.hint = 'Search products, courses...', this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, color: AppTheme.textLight, size: 20),
          const SizedBox(width: 10),
          Text(hint, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
        ]),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CategoryChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : AppTheme.textMedium,
          fontSize: 13, fontWeight: FontWeight.w500,
        )),
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  final String message;
  const FullScreenLoader({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

