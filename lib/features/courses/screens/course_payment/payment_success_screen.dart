import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/shop/screens/order/order_detail_screen.dart';
import 'package:saris_cosmo_center/features/courses/screens/enrollment_detail/enrollment_detail_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String title;
  final double amount;
  final String paymentId;
  final bool isCourse;
  final int? orderId;
  final int? enrollmentId;

  const PaymentSuccessScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.paymentId,
    this.isCourse = false,
    this.orderId,
    this.enrollmentId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = Tween<double>(begin: 25.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // PhonePe Style Animation Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main Circle (Starts massive, shrinks to 1x)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Checkmark in Circle
                    ScaleTransition(
                      scale: _checkAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isCourse 
                          ? 'You are now enrolled in\n${widget.title}'
                          : 'Your order for\n${widget.title}\nhas been placed successfully!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMedium,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Amount Paid',
                                  style: TextStyle(
                                      color: AppTheme.textMedium,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  '₹${widget.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: AppTheme.textDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppTheme.divider),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Transaction ID',
                                  style: TextStyle(
                                      color: AppTheme.textMedium,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.paymentId,
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppTheme.textDark,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.isCourse && widget.enrollmentId != null) {
                        Get.off(() => EnrollmentDetailScreen(enrollmentId: widget.enrollmentId!));
                      } else if (!widget.isCourse && widget.orderId != null) {
                        Get.off(() => OrderDetailScreen(
                              orderId: widget.orderId!,
                              navigateToMyOrdersOnBack: true,
                            ));
                      } else {
                        Get.until((route) => route.isFirst);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isCourse 
                          ? 'Start Learning' 
                          : (widget.orderId != null ? 'Check Order Details' : 'Back to Home'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
