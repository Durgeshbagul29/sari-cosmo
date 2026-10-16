import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_category_model.dart';
import '../services/product_category_service.dart';

class ProductCategoryController extends GetxController {
  final ProductCategoryService _categoryService = ProductCategoryService();

  var categories = <ProductCategory>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _categoryService.getProductCategories(token ?? '');
      debugPrint('Product Categories Response: $response');

      final List data = response['data'] ?? [];
      final parsedCategories = data
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .where((category) => category.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      categories.assignAll(parsedCategories);
    } catch (e) {
      debugPrint('Fetch Product Categories Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
