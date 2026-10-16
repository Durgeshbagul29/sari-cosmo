import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/checkout_service.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';
import '../models/cart_model.dart';
import '../../shop/controllers/cart_controller.dart';
import 'package:saris_cosmo_center/core/models/address_model.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/courses/screens/course_payment/payment_success_screen.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

class CheckoutController extends GetxController {
  final CheckoutService _checkoutService = CheckoutService();
  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();
  late Razorpay _razorpay;

  // Rx Price summaries
  var subtotal = 0.0.obs;
  var discount = 0.0.obs;
  var tax = 0.0.obs;
  var shippingCharge = 0.0.obs;
  var total = 0.0.obs;
  var selectedCouponCode = ''.obs;

  // Address listing & selection
  var addresses = <AddressModel>[].obs;
  var selectedAddress = Rxn<AddressModel>();

  // Payment configuration
  var selectedPaymentMethod = 'cod'.obs; // 'cod' or 'razorpay'
  var notes = ''.obs;
  var isLoading = false.obs;
  var isOrderCreated = false.obs;

  // Storing temporary Razorpay order id & local payment id & order id for payment verification
  String? _currentRazorpayOrderId;
  int? _currentPaymentId;
  int? _currentOrderId;
  Map<String, dynamic>? _lastRazorpayOptions;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Reset checkout reactive state before loading
  void resetCheckoutState() {
    subtotal.value = 0.0;
    discount.value = 0.0;
    tax.value = 0.0;
    shippingCharge.value = 0.0;
    total.value = 0.0;
    selectedCouponCode.value = '';
    selectedAddress.value = null;
    addresses.clear();
    isOrderCreated.value = false;
    _currentRazorpayOrderId = null;
    _currentPaymentId = null;
    _currentOrderId = null;
    _lastRazorpayOptions = null;
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// GET /v1/orders/checkout summary
  Future<void> fetchCheckoutSummary({String? couponCode}) async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final response = await _checkoutService.getCheckoutSummary(token, couponCode: couponCode);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        subtotal.value = (data['subtotal'] ?? 0).toDouble();
        discount.value = (data['discount'] ?? 0).toDouble();
        tax.value = (data['tax'] ?? 0).toDouble();
        shippingCharge.value = (data['shipping_charge'] ?? 0).toDouble();
        total.value = (data['total'] ?? 0).toDouble();
        selectedCouponCode.value = data['coupon_code'] ?? '';

        // Parse addresses returned by summary
        final List addrList = data['addresses'] ?? [];
        final parsedAddresses = addrList.map((e) => AddressModel.fromJson(e)).toList();
        addresses.assignAll(parsedAddresses);

        // Auto-select default address
        if (selectedAddress.value == null && parsedAddresses.isNotEmpty) {
          final def = parsedAddresses.firstWhere((a) => a.isDefault == true, orElse: () => parsedAddresses.first);
          selectedAddress.value = def;
        }
      }
    } catch (e) {
      debugPrint('Checkout Summary Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// POST /v1/cart/coupon
  Future<void> applyCoupon(String couponCode) async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _checkoutService.applyCouponToCart(token, couponCode);
      if (result['success'] == true) {
        await fetchCheckoutSummary(couponCode: couponCode);
        AppSnackbar.success(
          'Coupon Applied',
          result['message'] ?? 'Coupon applied successfully!',
        );
      }
    } catch (e) {
      AppSnackbar.error(
        'Failed to Apply Coupon',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove coupon from cart (refresh checkout summary with null code)
  Future<void> removeCoupon() async {
    await fetchCheckoutSummary(couponCode: '');
  }

  /// Finalize transaction & trigger order placing
  Future<void> placeOrder(BuildContext context) async {
    if (selectedAddress.value == null) {
      AppSnackbar.warning('Select Address', 'Please select a delivery address.');
      return;
    }

    if (selectedPaymentMethod.value == 'razorpay' && isOrderCreated.value && _lastRazorpayOptions != null) {
      debugPrint('Retrying Razorpay payment for order $_currentOrderId with options: $_lastRazorpayOptions');
      try {
        isLoading.value = true;
        _razorpay.open(_lastRazorpayOptions!);
      } catch (e) {
        debugPrint('Error starting Razorpay checkout: $e');
        _handlePaymentError(PaymentFailureResponse(2, 'Could not open payment gateway. Please try again.', null));
      } finally {
        isLoading.value = false;
      }
      return;
    }

    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final checkoutData = {
        'address_id': selectedAddress.value!.id,
        'payment_method': selectedPaymentMethod.value,
        'coupon_code': selectedCouponCode.value,
        'notes': notes.value,
      };

      debugPrint('Placing order via POST /v1/orders/checkout: $checkoutData');
      final response = await _checkoutService.placeOrder(token, checkoutData);

      if (response['success'] == true && response['data'] != null) {
        final orderInfo = response['data'];
        _currentOrderId = orderInfo['id'] != null ? (orderInfo['id'] as num).toInt() : null;

        if (selectedPaymentMethod.value == 'razorpay' && response['payment'] != null) {
          // ONLINE payment flow via Razorpay
          final paymentDetails = response['payment'];
          _currentRazorpayOrderId = paymentDetails['razorpay_order_id'];
          _currentPaymentId = paymentDetails['payment_id'] != null 
              ? (paymentDetails['payment_id'] as num).toInt() 
              : null;

          final options = {
            'key': paymentDetails['key_id'] ?? 'rzp_test_B099ZSH414zUNy',
            'amount': paymentDetails['amount'],
            'name': 'IICTN / Saris Cosmo',
            'description': 'Payment for Order ${orderInfo['order_number']}',
            'order_id': _currentRazorpayOrderId,
            'prefill': {
              'contact': selectedAddress.value!.phone ?? '9876543210',
              'email': 'customer@example.com'
            }
          };

          _lastRazorpayOptions = options;
          isOrderCreated.value = true;

          debugPrint('Launching Razorpay SDK options: $options');
          _razorpay.open(options);
        } else {
          // COD payment flow (successful immediately)
          _handleOrderCompletion(
            orderInfo['total'].toDouble(),
            'COD_${orderInfo['order_number']}_${DateTime.now().millisecondsSinceEpoch}',
            _currentOrderId ?? 0,
          );
        }
      }
    } catch (e) {
      AppSnackbar.error(
        'Order Placement Failed',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verification callback on payment completion
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final verifyData = {
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId ?? _currentRazorpayOrderId,
        'razorpay_signature': response.signature,
        'payment_id': _currentPaymentId,
      };

      debugPrint('Verifying payment via POST /v1/razorpay/verify: $verifyData');
      final result = await _checkoutService.verifyPaymentSignature(token, verifyData);
      
      if (result['success'] == true) {
        _handleOrderCompletion(total.value, response.paymentId ?? 'pay_success', _currentOrderId ?? 0);
      } else {
        throw Exception('Payment verification rejected by server.');
      }
    } catch (e) {
      AppSnackbar.error(
        'Payment Verification Error',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelAndRestoreCart() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return false;

      if (_currentOrderId == null) {
        debugPrint('cancelAndRestoreCart: _currentOrderId is null, skipping cancel.');
        return false;
      }

      // 1. Cancel the pending order on the server
      debugPrint('Cancelling pending order $_currentOrderId due to payment failure/cancellation...');
      final cancelResponse = await _orderService.cancelOrder(token, _currentOrderId!);
      debugPrint('Cancel Order Response: $cancelResponse');

      // 2. Add items back to the server cart
      final cartController = Get.find<CartController>();
      final items = List<CartItem>.from(cartController.cartItems);
      
      debugPrint('Restoring ${items.length} items to server cart...');
      for (final item in items) {
        await _cartService.addToCart(token, item.product.id, item.quantity);
      }

      // 3. Fetch fresh cart data to sync CartController state
      await cartController.fetchCart();

      // 4. Reset order creation flags so user can edit checkout options again
      isOrderCreated.value = false;
      _currentRazorpayOrderId = null;
      _currentPaymentId = null;
      _currentOrderId = null;
      _lastRazorpayOptions = null;

      return true;
    } catch (e) {
      debugPrint('Error cancelling/restoring order: $e');
      AppSnackbar.error(
        'Error',
        'Could not restore cart: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showPaymentFailedDialog(String reason) {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppTheme.surface,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Payment Incomplete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reason,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your order has been registered. What would you like to do next?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    if (_lastRazorpayOptions != null) {
                      try {
                        isLoading.value = true;
                        _razorpay.open(_lastRazorpayOptions!);
                      } catch (e) {
                        debugPrint('Error starting Razorpay checkout: $e');
                      } finally {
                        isLoading.value = false;
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Retry Online Payment',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () async {
                    Get.back(); // close dialog
                    final success = await cancelAndRestoreCart();
                    if (success) {
                      Get.back(); // navigate back (return to Cart/previous screen)
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary),
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order & Go Back',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String errorMessage = 'Payment failed. Please try again.';
    if (response.code == 2) {
      errorMessage = 'Payment was cancelled. You can retry the payment or change payment method.';
    } else if (response.code == 1) {
      errorMessage = 'Network error occurred. Please check your connection and try again.';
    } else if (response.message != null && response.message!.isNotEmpty) {
      errorMessage = response.message!;
    }

    AppSnackbar.error(
      'Payment Status',
      errorMessage,
    );

    // Show professional options dialog if the order was created
    if (isOrderCreated.value && _currentOrderId != null) {
      _showPaymentFailedDialog(errorMessage);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Selected external wallet: ${response.walletName}');
  }

  void _handleOrderCompletion(double amount, String paymentId, int orderId) {
    // Clear local cart database/store locally since server already cleared it
    Get.find<CartController>().clearCartLocally();
 
    // Close any open dialogs first to ensure active route is CheckoutScreen
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    // Pop the CheckoutScreen route so it is removed from history
    Get.back();

    // Redirect to success screen by pushing it on top of previous route (CartScreen)
    Get.to(() => PaymentSuccessScreen(
      title: 'Store Products',
      amount: amount,
      paymentId: paymentId,
      isCourse: false,
      orderId: orderId,
    ));
  }
}
