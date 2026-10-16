import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();

  var cartData = Rxn<CartData>();
  var isLoading = false.obs;
  var isUpdating = false.obs; // For individual item operations

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  /// Convenience getters
  List<CartItem> get cartItems => cartData.value?.items ?? [];
  double get subtotal => cartData.value?.subtotal.toDouble() ?? 0;
  int get totalItems => cartData.value?.totalItems ?? 0;
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get tax => 0.0;
  double get deliveryFee => 0.0;
  double get total => subtotal;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// GET /v1/cart
  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) {
        debugPrint('Fetch Cart: auth_token is null, skipping fetch.');
        return;
      }

      debugPrint('Fetching cart from GET /v1/cart...');
      final response = await _cartService.getCart(token);
      debugPrint('GET /v1/cart Response: $response');
      if (response['success'] == true && response['data'] != null) {
        cartData.value = CartData.fromJson(response['data']);
        debugPrint('Parsed CartData successfully. Items count: ${cartData.value?.items.length}, Subtotal: ${cartData.value?.subtotal}');
      }
    } catch (e) {
      debugPrint('Fetch Cart Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// POST /v1/cart/add
  Future<void> addToCart(int productId, int quantity) async {
    try {
      isUpdating.value = true;
      final token = await _getToken();
      if (token == null) {
        debugPrint('Add to Cart: auth_token is null, skipping add.');
        return;
      }

      debugPrint('Adding to cart (Product ID: $productId, Qty: $quantity) via POST /v1/cart/add...');
      final response = await _cartService.addToCart(token, productId, quantity);
      debugPrint('POST /v1/cart/add Response: $response');
      if (response['success'] == true && response['data'] != null) {
        cartData.value = CartData.fromJson(response['data']);
        debugPrint('Parsed CartData after adding successfully. Items count: ${cartData.value?.items.length}');
        AppSnackbar.success(
          'Added to Cart',
          response['message'] ?? 'Item added to cart.',
        );
      }
    } catch (e) {
      debugPrint('Add to Cart Error: $e');
      AppSnackbar.error(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// PUT /v1/cart/items/:cartItemId — increase quantity
  Future<void> increaseQuantity(CartItem item) async {
    try {
      isUpdating.value = true;
      final token = await _getToken();
      if (token == null) return;

      final newQty = item.quantity + 1;
      debugPrint('Increasing quantity for item (ID: ${item.id}, Product: ${item.product.name}) to $newQty via PUT /v1/cart/items/${item.id}...');
      final response = await _cartService.updateCartItem(token, item.id, newQty);
      debugPrint('PUT /v1/cart/items/${item.id} (Increase) Response: $response');
      if (response['success'] == true && response['data'] != null) {
        cartData.value = CartData.fromJson(response['data']);
        debugPrint('Parsed CartData after increasing successfully.');
      } else {
        // Fallback: re-fetch to stay in sync
        await fetchCart();
      }
    } catch (e) {
      debugPrint('Increase Quantity Error: $e');
      _showErrorSnackbar(e);
    } finally {
      isUpdating.value = false;
    }
  }

  /// PUT /v1/cart/items/:cartItemId — decrease quantity (or remove if qty becomes 0)
  Future<void> decreaseQuantity(CartItem item) async {
    try {
      isUpdating.value = true;
      final token = await _getToken();
      if (token == null) return;

      if (item.quantity <= 1) {
        debugPrint('Quantity is <= 1, deleting item (ID: ${item.id})...');
        await _deleteItem(token, item.id);
      } else {
        final newQty = item.quantity - 1;
        debugPrint('Decreasing quantity for item (ID: ${item.id}, Product: ${item.product.name}) to $newQty via PUT /v1/cart/items/${item.id}...');
        final response = await _cartService.updateCartItem(token, item.id, newQty);
        debugPrint('PUT /v1/cart/items/${item.id} (Decrease) Response: $response');
        if (response['success'] == true && response['data'] != null) {
          cartData.value = CartData.fromJson(response['data']);
          debugPrint('Parsed CartData after decreasing successfully.');
        } else {
          await fetchCart();
        }
      }
    } catch (e) {
      debugPrint('Decrease Quantity Error: $e');
      _showErrorSnackbar(e);
    } finally {
      isUpdating.value = false;
    }
  }

  /// DELETE /v1/cart/items/:cartItemId
  Future<void> removeFromCart(CartItem item) async {
    try {
      isUpdating.value = true;
      final token = await _getToken();
      if (token == null) return;

      debugPrint('Removing item (ID: ${item.id}, Product: ${item.product.name}) from cart...');
      await _deleteItem(token, item.id);
    } catch (e) {
      debugPrint('Remove from Cart Error: $e');
      _showErrorSnackbar(e);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> _deleteItem(String token, int cartItemId) async {
    final response = await _cartService.deleteCartItem(token, cartItemId);
    debugPrint('DELETE /v1/cart/items/$cartItemId Response: $response');
    if (response['success'] == true && response['data'] != null) {
      cartData.value = CartData.fromJson(response['data']);
      debugPrint('Parsed CartData after item deletion successfully.');
    } else {
      // Re-fetch to sync state
      await fetchCart();
    }
  }

  /// Clear entire cart by deleting each item
  Future<void> clearCart() async {
    try {
      isUpdating.value = true;
      final token = await _getToken();
      if (token == null) return;

      final items = List<CartItem>.from(cartItems);
      debugPrint('Clearing cart - deleting all ${items.length} items...');
      for (final item in items) {
        debugPrint('Deleting item: ${item.product.name} (ID: ${item.id})');
        await _cartService.deleteCartItem(token, item.id);
      }
      cartData.value = null;
      debugPrint('Cart cleared successfully.');
    } catch (e) {
      debugPrint('Clear Cart Error: $e');
      _showErrorSnackbar(e);
      await fetchCart(); // Re-sync
    } finally {
      isUpdating.value = false;
    }
  }

  /// Clear the cart local state directly without calling the server APIs
  void clearCartLocally() {
    cartData.value = null;
  }

  void _showErrorSnackbar(Object e) {
    AppSnackbar.error(
      'Error',
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}
