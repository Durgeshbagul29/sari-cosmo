import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

class CartService {
  /// GET /v1/cart — Fetch all cart items
  Future<Map<String, dynamic>> getCart(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.cart),
        headers: _headers(token),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// POST /v1/cart/add — Add item to cart
  Future<Map<String, dynamic>> addToCart(String token, int productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.cartAdd),
        headers: _headers(token),
        body: jsonEncode({
          'product_id': productId.toString(),
          'quantity': quantity,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// PUT /v1/cart/items/:cartItemId — Update cart item quantity
  Future<Map<String, dynamic>> updateCartItem(String token, int cartItemId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.cartItem(cartItemId)),
        headers: _headers(token),
        body: jsonEncode({
          'quantity': quantity,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// DELETE /v1/cart/items/:cartItemId — Remove item from cart
  Future<Map<String, dynamic>> deleteCartItem(String token, int cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiEndpoints.cartItem(cartItemId)),
        headers: _headers(token),
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
      String errorMessage = 'An error occurred';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
