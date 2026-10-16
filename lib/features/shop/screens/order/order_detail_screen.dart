import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import 'my_orders_screen.dart';
import '../../controllers/product_controller.dart';
import '../../../../core/utils/app_snackbar.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final bool navigateToMyOrdersOnBack;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.navigateToMyOrdersOnBack = false,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderController _orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderController.fetchOrderDetail(widget.orderId);
    });
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      if (dateStr.contains('T')) {
        return dateStr.split('T').first;
      }
      return dateStr;
    }
  }

  bool _isDeliveredStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized.contains('deliver') || normalized.contains('complete');
  }

  Color _getStatusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (_isDeliveredStatus(status)) {
      return AppTheme.success;
    }
    if (normalized == 'cancelled' || normalized == 'failed') {
      return AppColors.error;
    }
    return AppTheme.warning;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.navigateToMyOrdersOnBack,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.off(() => const MyOrdersScreen());
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Order Details'),
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (widget.navigateToMyOrdersOnBack) {
                Get.off(() => const MyOrdersScreen());
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: Obx(() {
          if (_orderController.isDetailLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
  
          final detail = _orderController.orderDetail.value;
          if (detail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 60, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load order details.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _orderController.fetchOrderDetail(widget.orderId),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }
  
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildOrderInfo(detail),
                const SizedBox(height: 12),
                _buildTrackingTimeline(detail.status),
                const SizedBox(height: 12),
                _buildItemsList(detail.items, _isDeliveredStatus(detail.status)),
                const SizedBox(height: 12),
                if (detail.shippingAddress != null) ...[
                  _buildShippingAddress(detail.shippingAddress!),
                  const SizedBox(height: 12),
                ],
                if (detail.billingAddress != null) ...[
                  _buildBillingAddress(detail.billingAddress!),
                  const SizedBox(height: 12),
                ],
                _buildPaymentDetails(detail),
                const SizedBox(height: 12),
                _buildPriceDetails(detail),
                const SizedBox(height: 12),
                _buildActionButtons(context, detail),
                SizedBox(height: 32 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderInfo(OrderDetail detail) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID - ${detail.orderNumber}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              if (_isDeliveredStatus(detail.status))
                Obx(() => _orderController.isDownloadingInvoice.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                      )
                    : GestureDetector(
                        onTap: () => _orderController.downloadInvoice(detail.id, detail.orderNumber),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            border: Border.all(color: AppTheme.primary),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.download_rounded, size: 14, color: AppTheme.primary),
                              SizedBox(width: 4),
                              Text('Invoice', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                            ],
                          ),
                        ),
                      ))
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Placed on ${_formatDate(detail.createdAt)}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textMedium),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              BadgeChip(
                label: detail.status.toUpperCase(),
                bg: _getStatusColor(detail.status).withOpacity(0.12),
                fg: _getStatusColor(detail.status),
              ),
              const SizedBox(width: 8),
              BadgeChip(
                label: detail.paymentStatus.toUpperCase(),
                bg: detail.paymentStatus.toLowerCase() == 'paid'
                    ? AppTheme.success.withOpacity(0.12)
                    : AppTheme.primary.withOpacity(0.12),
                fg: detail.paymentStatus.toLowerCase() == 'paid'
                    ? AppTheme.success
                    : AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(String status) {
    int currentStep = 0;
    final normalized = status.trim().toLowerCase();
    if (normalized == 'pending') currentStep = 0;
    else if (normalized == 'confirmed') currentStep = 1;
    else if (normalized == 'processing' || normalized == 'packed') currentStep = 2;
    else if (normalized == 'shipped') currentStep = 3;
    else if (normalized == 'completed' || normalized == 'delivered') currentStep = 4;
    else currentStep = 0;

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 24),
          _buildStep('Pending', 'Order has been placed', true, currentStep >= 0, isFirst: true),
          _buildStep('Confirmed', 'Seller has confirmed your order', currentStep > 0, currentStep >= 1),
          _buildStep('Processing', 'Your order is being processed', currentStep > 1, currentStep >= 2),
          _buildStep('Shipped', 'Your item has been shipped', currentStep > 2, currentStep >= 3),
          _buildStep('Delivered', 'Your item has been delivered', currentStep > 3, currentStep >= 4, isLast: true),
        ],
      ),
    );
  }

  Widget _buildStep(String title, String subtitle, bool isLineActive, bool isNodeActive, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isLineActive ? AppTheme.success : AppTheme.divider,
              ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isNodeActive ? AppTheme.success : AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: isNodeActive ? AppTheme.success : AppTheme.textLight, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isNodeActive ? AppTheme.success : AppTheme.divider,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 0 : 20, bottom: isLast ? 0 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isNodeActive ? FontWeight.w700 : FontWeight.w500,
                    color: isNodeActive ? AppTheme.textDark : AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<OrderItem> items, bool isDelivered) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Items in this Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          ),
          if (isDelivered) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, size: 16, color: AppTheme.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivered orders can be reviewed below.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: item.productImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: NetworkImageWidget(
                            url: item.productImage,
                            fit: BoxFit.contain,
                            width: 74,
                            height: 74,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.primary,
                            size: 28,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                      if (isDelivered) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 32,
                          child: TextButton.icon(
                            onPressed: item.isReviewed
                                ? null
                                : () => _showReviewDialog(context, item),
                            icon: const Icon(Icons.rate_review_outlined, size: 14, color: AppTheme.primary),
                            label: Text(
                              item.isReviewed ? 'Reviewed' : 'Add Review',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.isReviewed
                                    ? AppTheme.textLight
                                    : AppTheme.primary,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              backgroundColor: item.isReviewed
                                  ? AppTheme.divider.withOpacity(0.25)
                                  : AppTheme.primary.withOpacity(0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, OrderItem item) {
    int selectedRating = 5;
    final titleController = TextEditingController();
    final commentController = TextEditingController();
    final productController = Get.put(ProductController());
    final isSubmitting = false.obs;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Review ${item.productName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starRating = index + 1;
                        final isSelected = starRating <= selectedRating;
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              selectedRating = starRating;
                            });
                          },
                          icon: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Excellent product!',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Comment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write your detailed experience here...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textMedium)),
                ),
                Obx(() => ElevatedButton(
                  onPressed: isSubmitting.value
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            AppSnackbar.warning('Required Field', 'Please enter a review title.');
                            return;
                          }
                          if (commentController.text.trim().isEmpty) {
                            AppSnackbar.warning('Required Field', 'Please enter a comment.');
                            return;
                          }

                          try {
                            isSubmitting.value = true;
                            // Find product slug
                            final matchedProduct = productController.products.firstWhereOrNull((p) => p.id == item.productId);
                            String slug = matchedProduct?.slug ?? '';
                            if (slug.isEmpty) {
                              // Fallback slug generation
                              slug = item.productName
                                  .toLowerCase()
                                  .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
                                  .trim()
                                  .replaceAll(RegExp(r'\s+'), '-');
                            }

                            final success = await productController.submitProductReview(
                              slug,
                              selectedRating,
                              titleController.text.trim(),
                              commentController.text.trim(),
                            );

                            if (success) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              AppSnackbar.success('Success', 'Review submitted successfully.');
                            } else {
                              AppSnackbar.error('Failed', 'Failed to submit review.');
                            }
                          } catch (e) {
                            AppSnackbar.error('Error', e.toString());
                          } finally {
                            isSubmitting.value = false;
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit'),
                )),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildShippingAddress(OrderAddress addr) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shipping Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          Text(addr.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 6),
          Text(
            '${addr.address}\n${addr.city}, ${addr.state} ${addr.pincode}\nPhone: ${addr.phone}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddress(OrderAddress addr) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billing Details',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 16),
          Text(addr.name,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 6),
          Text(
            '${addr.address}\n${addr.city}, ${addr.state} ${addr.pincode}\nPhone: ${addr.phone}',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textMedium, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(OrderDetail detail) {
    final payment = detail.payments.isNotEmpty ? detail.payments.first : null;

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _paymentRow('Method', detail.paymentMethod),
          const SizedBox(height: 12),
          _paymentRow('Status', detail.paymentStatus),
          const SizedBox(height: 12),
          _paymentRow('Amount', '₹${detail.total.toStringAsFixed(2)}'),
          if (payment != null) ...[
            const SizedBox(height: 12),
            _paymentRow('Gateway Method', payment.method),
            const SizedBox(height: 12),
            _paymentRow('Gateway Status', payment.status),
            const SizedBox(height: 12),
            _paymentRow('Captured Amount', '₹${payment.amount.toStringAsFixed(2)}'),
          ],
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textMedium,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetails(OrderDetail detail) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
              Text('₹${detail.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            ],
          ),
          if (detail.discount > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                Text('-₹${detail.discount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: AppTheme.success, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          if (detail.tax > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                Text('₹${detail.tax.toStringAsFixed(1)}', style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Charges', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
              Text(
                detail.shippingCharge == 0 ? 'FREE' : '₹${detail.shippingCharge.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  color: detail.shippingCharge == 0 ? AppTheme.success : AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              Text('₹${detail.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderDetail detail) {
    final isDelivered = _isDeliveredStatus(detail.status);
    final statusLower = detail.status.trim().toLowerCase();
    final isCancelled = statusLower == 'cancelled';

    if (isCancelled) {
      return const SizedBox.shrink();
    }

    if (isDelivered) {
      return Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Obx(() => ElevatedButton.icon(
                onPressed: _orderController.isDownloadingInvoice.value
                    ? null
                    : () => _orderController.downloadInvoice(detail.id, detail.orderNumber),
                icon: _orderController.isDownloadingInvoice.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 20),
                label: Text(
                  _orderController.isDownloadingInvoice.value
                      ? 'Downloading...'
                      : 'Download Invoice',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  content: const Text('Are you sure you want to cancel this order?', style: TextStyle(color: AppTheme.textMedium, height: 1.5)),
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No, Keep It', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textMedium)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final success = await _orderController.cancelOrder(detail.id);
                        if (success) {
                          AppSnackbar.error(
                            'Order Cancelled',
                            'Your order has been cancelled successfully.',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Yes, Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.cancel_outlined, size: 20),
            label: const Text('Cancel Order', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }
  }
}
