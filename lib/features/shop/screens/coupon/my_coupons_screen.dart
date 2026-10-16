import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../../controllers/coupon_controller.dart';
import '../../models/coupon_model.dart';

class MyCouponsScreen extends StatelessWidget {
  const MyCouponsScreen({super.key});

  // Dynamic colors for the coupon cards based on their index
  static const List<Color> _couponColors = [
    AppTheme.primary,
    Color(0xFF8E44AD), // Purple
    Color(0xFF2E86C1), // Blue
    Color(0xFF16A085), // Teal
  ];

  Color _getCouponColor(int index) {
    return _couponColors[index % _couponColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Coupons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchCoupons(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.coupons.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.coupons.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textMedium, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchCoupons(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.coupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 64, color: AppTheme.textLight.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text(
                  'No coupons available at the moment.',
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        final active = controller.coupons.where((c) => c.isActive).toList();
        final expired = controller.coupons.where((c) => !c.isActive).toList();

        return RefreshIndicator(
          onRefresh: () => controller.fetchCoupons(),
          color: AppTheme.primary,
          child: ListView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              if (active.isNotEmpty) ...[
                const Text(
                  'Active Coupons',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  active.length,
                  (index) => _buildCouponCard(context, active[index], _getCouponColor(index), true),
                ),
              ],
              if (expired.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Expired / Used',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textLight),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  expired.length,
                  (index) => _buildCouponCard(context, expired[index], AppTheme.textLight, false),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCouponCard(BuildContext context, Coupon coupon, Color color, bool isActive) {
    // Determine title text, e.g. "20% OFF" or "₹500 OFF"
    final String discountTitle = coupon.type == 'percent'
        ? '${coupon.value.toStringAsFixed(0)}% OFF'
        : '₹${coupon.value.toStringAsFixed(0)} OFF';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.05 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Row(
          children: [
            // Left colored strip / ticket stub
            Container(
              width: 90,
              height: 125,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_offer_rounded, color: Colors.white, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      coupon.code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discountTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coupon.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 12, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(
                          'Min Order: ₹${coupon.minOrderAmount.toStringAsFixed(0)}${coupon.maxDiscount != null ? '  •  Max Off: ₹${coupon.maxDiscount!.toStringAsFixed(0)}' : ''}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.timer_outlined : Icons.timer_off_outlined,
                          size: 12,
                          color: isActive ? AppTheme.success : AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Valid till ${coupon.validTillFormatted}' : 'Expired on ${coupon.validTillFormatted}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive ? AppTheme.success : AppTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (isActive)
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Coupon "${coupon.code}" copied! 🎉'),
                                  backgroundColor: AppTheme.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'COPY',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
