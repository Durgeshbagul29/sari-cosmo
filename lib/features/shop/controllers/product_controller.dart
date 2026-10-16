import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  var products = <Product>[].obs;
  var isLoading = false.obs;
  var isPaginating = false.obs;
  var hasLoaded = false.obs;

  var currentPage = 1.obs;
  var lastPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts(isRefresh: true);
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      isLoading.value = true;
    } else {
      if (currentPage.value >= lastPage.value || isPaginating.value) {
        return;
      }
      currentPage.value++;
      isPaginating.value = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _productService.getProducts(token ?? '', page: currentPage.value);
      debugPrint('Products Response Page ${currentPage.value}: $response');

      final List data = response['data'] ?? [];
      final newProducts = data.map((e) => Product.fromJson(e)).toList();

      if (isRefresh) {
        products.assignAll(newProducts);
      } else {
        products.addAll(newProducts);
      }

      if (response['meta'] != null) {
        lastPage.value = response['meta']['last_page'] ?? 1;
      }
    } catch (e) {
      debugPrint('Fetch Products Error: $e');
      if (!isRefresh) {
        currentPage.value--;
      }
    } finally {
      if (isRefresh) {
        isLoading.value = false;
      } else {
        isPaginating.value = false;
      }
      hasLoaded.value = true;
    }
  }

  Future<bool> submitProductReview(String slug, int rating, String title, String comment) async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final reviewData = {
        'rating': rating,
        'title': title,
        'comment': comment,
      };

      debugPrint('Submitting review for slug $slug: $reviewData');
      final response = await _productService.submitReview(token, slug, reviewData);
      return response['success'] == true;
    } catch (e) {
      debugPrint('Submit Review Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
