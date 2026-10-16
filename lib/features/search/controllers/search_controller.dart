import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/search_service.dart';
import 'package:saris_cosmo_center/features/shop/models/product_model.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';
import 'package:saris_cosmo_center/features/appointments/models/service_model.dart';

class AppSearchController extends GetxController {
  final SearchService _searchService = SearchService();

  var products = <Product>[].obs;
  var courses = <Course>[].obs;
  var services = <ServiceModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> performSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      products.clear();
      courses.clear();
      services.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      // Perform parallel requests for products, courses, and services
      final results = await Future.wait([
        _searchService.search(token, cleanQuery, 'products'),
        _searchService.search(token, cleanQuery, 'courses'),
        _searchService.search(token, cleanQuery, 'services'),
      ]);

      final productsResponse = results[0];
      final coursesResponse = results[1];
      final servicesResponse = results[2];

      // Parse products
      if (productsResponse['success'] == true && productsResponse['data'] != null) {
        final List list = productsResponse['data']['products'] ?? [];
        products.assignAll(list.map((e) => Product.fromJson(e)).toList());
      } else {
        products.clear();
      }

      // Parse courses
      if (coursesResponse['success'] == true && coursesResponse['data'] != null) {
        final List list = coursesResponse['data']['courses'] ?? [];
        courses.assignAll(list.map((e) => Course.fromJson(e)).toList());
      } else {
        courses.clear();
      }

      // Parse services
      if (servicesResponse['success'] == true && servicesResponse['data'] != null) {
        final List list = servicesResponse['data']['services'] ?? [];
        services.assignAll(list.map((e) => ServiceModel.fromJson(e)).toList());
      } else {
        services.clear();
      }
    } catch (e) {
      debugPrint('Search Error: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    products.clear();
    courses.clear();
    services.clear();
    errorMessage.value = '';
    isLoading.value = false;
  }
}
