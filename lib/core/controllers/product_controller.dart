import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/models/models.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading(true);
      final String response = await rootBundle.loadString('assets/data/products.json');
      final data = await json.decode(response) as List<dynamic>;
      products.value = data.map((x) => Product.fromJson(x)).toList();
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      isLoading(false);
    }
  }
}
