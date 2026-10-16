import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/address/add_address_screen.dart';
import 'package:saris_cosmo_center/features/shop/controllers/checkout_controller.dart';
import 'package:saris_cosmo_center/features/shop/controllers/coupon_controller.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());

    // Reset and fetch fresh checkout data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetCheckoutState();
      controller.fetchCheckoutSummary();
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (controller.isOrderCreated.value) {
          final shouldLeave = await _showExitConfirmationDialog(context, controller);
          if (shouldLeave) {
            await controller.cancelAndRestoreCart();
            Get.back();
          }
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Place Order'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              if (controller.isOrderCreated.value) {
                final shouldLeave = await _showExitConfirmationDialog(context, controller);
                if (shouldLeave) {
                  await controller.cancelAndRestoreCart();
                  Get.back();
                }
              } else {
                Get.back();
              }
            },
          ),
        ),
      body: Obx(() {
        if (controller.isLoading.value && controller.subtotal.value == 0) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Delivery Address Selection
                  _buildAddressSection(context, controller),

                  const SizedBox(height: 12),

                  // 2. Coupon Selection
                  _buildCouponSection(context, controller),

                  const SizedBox(height: 12),

                  // 3. Payment Method Selection
                  _buildPaymentSection(controller),

                  const SizedBox(height: 12),

                  // 4. Order Summary Card
                  _buildSummarySection(controller),
                ],
              ),
            ),

            // Updating overlay loader
            if (controller.isLoading.value)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomBar(context, controller),
    ),
  );
}

  // Horizontal Address Selection List
  Widget _buildAddressSection(BuildContext context, CheckoutController controller) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                TextButton.icon(
                  onPressed: controller.isOrderCreated.value
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                          ).then((value) {
                            controller.fetchCheckoutSummary();
                          });
                        },
                  icon: const Icon(Icons.add_rounded, size: 16, color: AppTheme.primary),
                  label: const Text(
                    'Add New',
                    style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.addresses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined, size: 48, color: AppTheme.textLight.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      const Text(
                        'No address found. Please add a shipping address.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.isOrderCreated.value
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                                ).then((value) {
                                  controller.fetchCheckoutSummary();
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Add Address', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final address = controller.addresses[index];
                  return Obx(() {
                    final isSelected = controller.selectedAddress.value?.id == address.id;

                    return Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.divider,
                          width: isSelected ? 1.8 : 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: controller.isOrderCreated.value
                              ? () {
                                  AppSnackbar.warning(
                                    'Selection Locked',
                                    'Delivery address cannot be changed after the order is created.',
                                  );
                                }
                              : () {
                                  controller.selectedAddress.value = address;
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      address.isDefault == true ? Icons.home_rounded : Icons.location_on_rounded,
                                      size: 16,
                                      color: isSelected ? AppTheme.primary : AppTheme.textLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      address.name ?? 'Receiver Name',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    '${address.address}, ${address.city}, ${address.state} - ${address.pincode}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMedium, height: 1.4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.phone ?? '',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // Coupon application block
  Widget _buildCouponSection(BuildContext context, CheckoutController controller) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coupons',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final hasCoupon = controller.selectedCouponCode.value.isNotEmpty;

            if (hasCoupon) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coupon "${controller.selectedCouponCode.value}" Applied',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.success),
                          ),
                          if (controller.discount.value > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Saved ₹${controller.discount.value.toStringAsFixed(0)} on this order!',
                                style: TextStyle(fontSize: 11, color: AppTheme.success.withValues(alpha: 0.9)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!controller.isOrderCreated.value)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textMedium),
                        onPressed: () => controller.removeCoupon(),
                      ),
                  ],
                ),
              );
            }

            return GestureDetector(
              onTap: controller.isOrderCreated.value
                  ? () {
                      AppSnackbar.warning(
                        'Selection Locked',
                        'Coupons cannot be changed after the order is created.',
                      );
                    }
                  : () => _showCouponSelectionBottomSheet(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: AppTheme.primary, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Apply Coupon Code',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textLight),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Payment Options Radio Cards
  Widget _buildPaymentSection(CheckoutController controller) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          // COD option
          _buildPaymentMethodTile(
            controller: controller,
            methodId: 'cod',
            title: 'Cash on Delivery',
            subtitle: 'Pay with cash upon delivery of items',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 10),
          // Razorpay option
          _buildPaymentMethodTile(
            controller: controller,
            methodId: 'razorpay',
            title: 'Pay Online',
            subtitle: 'Pay securely using Card, NetBanking, or UPI',
            icon: Icons.payment_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required CheckoutController controller,
    required String methodId,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == methodId;

      return GestureDetector(
        onTap: controller.isOrderCreated.value
            ? () {
                AppSnackbar.warning(
                  'Selection Locked',
                  'Payment method cannot be changed after the order is created.',
                );
              }
            : () => controller.selectedPaymentMethod.value = methodId,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.divider,
              width: isSelected ? 1.8 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textMedium, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMedium),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: methodId,
                groupValue: controller.selectedPaymentMethod.value,
                onChanged: controller.isOrderCreated.value
                    ? null
                    : (val) => controller.selectedPaymentMethod.value = val!,
                activeColor: AppTheme.primary,
              ),
            ],
          ),
        ),
      );
    });
  }

  // Price Breakdown Summary Section
  Widget _buildSummarySection(CheckoutController controller) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          _summaryRow('Subtotal', controller.subtotal.value),
          if (controller.discount.value > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _summaryRow('Discount', -controller.discount.value, isHighlight: true),
            ),
          const SizedBox(height: 8),
          _summaryRow('GST Tax (18%)', controller.tax.value),
          const SizedBox(height: 8),
          _summaryRow('Shipping Charge', controller.shippingCharge.value, isFreeString: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              Text(
                '₹${controller.total.value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isHighlight = false, bool isFreeString = false}) {
    String valueStr = '₹${value.toStringAsFixed(2)}';
    if (value < 0) {
      valueStr = '-₹${value.abs().toStringAsFixed(2)}';
    } else if (isFreeString && value == 0) {
      valueStr = 'Free';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
        Text(
          valueStr,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHighlight ? AppTheme.success : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  // Sticky bottom action bar
  Widget _buildBottomBar(BuildContext context, CheckoutController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total to Pay', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    Obx(() => Text(
                          '₹${controller.total.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary),
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () => controller.placeOrder(context),
                        child: Text(
                          controller.selectedPaymentMethod.value == 'razorpay' ? 'Pay & Place Order' : 'Place Order',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom sheet modal for promo coupons
  void _showCouponSelectionBottomSheet(BuildContext context, CheckoutController checkoutController) {
    final couponController = Get.put(CouponController());

    // Fetch fresh coupons
    couponController.fetchCoupons();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Coupons',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0, color: AppTheme.divider),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Obx(() {
                        if (couponController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                        }

                        // Active coupons only
                        final activeCoupons = couponController.coupons.where((c) => c.isActive).toList();

                        if (activeCoupons.isEmpty) {
                          return Center(
                            child: Text(
                              couponController.errorMessage.value.isNotEmpty
                                  ? couponController.errorMessage.value
                                  : 'No coupons available.',
                              style: const TextStyle(color: AppTheme.textMedium),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: activeCoupons.length,
                          itemBuilder: (context, index) {
                            final coupon = activeCoupons[index];
                            final String discountText = coupon.type == 'percent'
                                ? '${coupon.value.toStringAsFixed(0)}% OFF'
                                : '₹${coupon.value.toStringAsFixed(0)} OFF';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.divider),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                                        ),
                                        child: Text(
                                          coupon.code,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary, letterSpacing: 0.5),
                                        ),
                                      ),
                                      Text(
                                        discountText,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.success),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    coupon.description,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textDark, height: 1.3),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1, color: AppTheme.divider),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Min Order: ₹${coupon.minOrderAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textMedium),
                                          ),
                                          if (coupon.maxDiscount != null && coupon.maxDiscount! > 0)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                'Max Discount: ₹${coupon.maxDiscount!.toStringAsFixed(0)}',
                                                style: const TextStyle(fontSize: 11, color: AppTheme.textMedium),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        'Valid Till: ${coupon.validTillFormatted}',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMedium),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        checkoutController.applyCoupon(coupon.code);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Apply Coupon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context, CheckoutController controller) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Checkout?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        content: const Text(
          'Your payment is incomplete. If you leave now, this pending order will be cancelled and your cart items will be restored.',
          style: TextStyle(color: AppTheme.textMedium, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Leave & Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ) ?? false;
  }
}
