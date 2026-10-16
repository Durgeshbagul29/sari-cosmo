import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/product_review_model.dart';
import '../services/product_service.dart';

import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

class ProductDetailController extends GetxController {
  final ProductService _productService = ProductService();

  var isLoading = false.obs;
  var productDetails = Rxn<Product>();
  var reviewsLoading = false.obs;
  var reviewSummary = Rxn<ProductReviewSummary>();

  Future<void> fetchProductDetail(String slug) async {
    productDetails.value = null;
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _productService.getProductDetail(token ?? '', slug);
      debugPrint('Product Detail Response: $response');

      final data = response['data'];
      if (data != null) {
        productDetails.value = Product.fromJson(data);
      }
    } catch (e) {
      debugPrint('Fetch Product Detail Error: $e');
      AppSnackbar.error(
        'Error',
        'Failed to load product details',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductReviews(String slug) async {
    reviewsLoading.value = true;
    reviewSummary.value = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _productService.getProductReviews(token ?? '', slug);
      debugPrint('Product Reviews Response: $response');

      final data = response['data'];
      if (data != null) {
        reviewSummary.value = ProductReviewSummary.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      }
    } catch (e) {
      debugPrint('Fetch Product Reviews Error: $e');
    } finally {
      reviewsLoading.value = false;
    }
  }
}
