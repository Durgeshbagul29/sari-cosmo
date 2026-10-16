import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

class CheckoutService {
  /// POST /v1/cart/coupon — Apply coupon to cart
  Future<Map<String, dynamic>> applyCouponToCart(String token, String couponCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.cartCoupon),
        headers: _headers(token),
        body: jsonEncode({'coupon_code': couponCode}),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// GET /v1/orders/checkout — Get checkout price details & address listing
  Future<Map<String, dynamic>> getCheckoutSummary(String token, {String? couponCode}) async {
    try {
      String url = ApiEndpoints.ordersCheckout;
      if (couponCode != null && couponCode.isNotEmpty) {
        url += '?coupon_code=$couponCode';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(token),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// POST /v1/orders/checkout — Place order
  Future<Map<String, dynamic>> placeOrder(String token, Map<String, dynamic> checkoutData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.ordersCheckout),
        headers: _headers(token),
        body: jsonEncode(checkoutData),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// POST /v1/razorpay/verify — Verify online transaction signature
  Future<Map<String, dynamic>> verifyPaymentSignature(String token, Map<String, dynamic> verificationData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.razorpayVerify),
        headers: _headers(token),
        body: jsonEncode(verificationData),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'An error occurred during checkout operation';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
