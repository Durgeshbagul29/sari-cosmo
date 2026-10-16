import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

class WishlistController extends GetxController {
  final rxProducts = <Map<String, dynamic>>[].obs;
  final rxCourses = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        debugPrint('Wishlist fetch: No auth token found.');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/v1/wishlist'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Wishlist GET Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List items = body['data'] != null && body['data']['data'] != null 
              ? body['data']['data'] 
              : [];
          
          final products = <Map<String, dynamic>>[];
          final courses = <Map<String, dynamic>>[];

          for (var item in items) {
            final type = item['wishlistable_type'] ?? item['type'] ?? '';
            if (type == 'product') {
              products.add(Map<String, dynamic>.from(item));
            } else if (type == 'course') {
              courses.add(Map<String, dynamic>.from(item));
            }
          }

          rxProducts.assignAll(products);
          rxCourses.assignAll(courses);
        }
      }
    } catch (e) {
      debugPrint('Fetch Wishlist Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isProductWishlisted(String name, {int? id, String? slug}) {
    return rxProducts.any((p) {
      final pId = p['wishlistable_id'] ?? p['id'];
      final pSlug = p['slug'];
      final pName = p['name'] ?? p['title'];
      
      if (id != null && id != 0 && pId == id) return true;
      if (slug != null && slug.isNotEmpty && pSlug == slug) return true;
      return pName == name;
    });
  }

  Future<void> toggleProductWishlist(Map<String, dynamic> productMap) async {
    final name = productMap['name'] ?? productMap['title'] ?? '';
    final id = productMap['id'] ?? productMap['wishlistable_id'] ?? 0;
    final slug = productMap['slug'] ?? '';

    // Optimistic UI Toggle
    final index = rxProducts.indexWhere((p) {
      final pId = p['wishlistable_id'] ?? p['id'];
      final pSlug = p['slug'];
      final pName = p['name'] ?? p['title'];
      
      if (id != 0 && pId == id) return true;
      if (slug.isNotEmpty && pSlug == slug) return true;
      return pName == name;
    });

    if (index >= 0) {
      rxProducts.removeAt(index);
      _showWishlistSnackbar(name, isAdded: false);
    } else {
      rxProducts.add(productMap);
      _showWishlistSnackbar(name, isAdded: true);
    }

    if (id == 0) {
      debugPrint('Wishlist toggle skipped for mock/invalid product ID.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/v1/wishlist/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'wishlistable_type': 'product',
          'wishlistable_id': id,
          'type': 'product',
          'id': id,
        }),
      );

      debugPrint('Wishlist Toggle Product Response: ${response.statusCode} - ${response.body}');
      fetchWishlist(); // Sync with server
    } catch (e) {
      debugPrint('Toggle product wishlist error: $e');
    }
  }

  bool isCourseWishlisted(String title, {int? id, String? slug}) {
    return rxCourses.any((c) {
      final cId = c['wishlistable_id'] ?? c['id'];
      final cSlug = c['slug'];
      final cTitle = c['name'] ?? c['title'];
      
      if (id != null && id != 0 && cId == id) return true;
      if (slug != null && slug.isNotEmpty && cSlug == slug) return true;
      return cTitle == title;
    });
  }

  Future<void> toggleCourseWishlist(Map<String, dynamic> courseMap) async {
    final title = courseMap['name'] ?? courseMap['title'] ?? '';
    final id = courseMap['id'] ?? courseMap['wishlistable_id'] ?? 0;
    final slug = courseMap['slug'] ?? '';

    // Optimistic UI Toggle
    final index = rxCourses.indexWhere((c) {
      final cId = c['wishlistable_id'] ?? c['id'];
      final cSlug = c['slug'];
      final cTitle = c['name'] ?? c['title'];
      
      if (id != 0 && cId == id) return true;
      if (slug.isNotEmpty && cSlug == slug) return true;
      return cTitle == title;
    });

    if (index >= 0) {
      rxCourses.removeAt(index);
      _showWishlistSnackbar(title, isAdded: false);
    } else {
      rxCourses.add(courseMap);
      _showWishlistSnackbar(title, isAdded: true);
    }

    if (id == 0) {
      debugPrint('Wishlist toggle skipped for mock/invalid course ID.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/v1/wishlist/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'wishlistable_type': 'course',
          'wishlistable_id': id,
          'type': 'course',
          'id': id,
        }),
      );

      debugPrint('Wishlist Toggle Course Response: ${response.statusCode} - ${response.body}');
      fetchWishlist(); // Sync with server
    } catch (e) {
      debugPrint('Toggle course wishlist error: $e');
    }
  }

  void _showWishlistSnackbar(String itemName, {required bool isAdded}) {
    if (isAdded) {
      AppSnackbar.primary(
        'Added to Wishlist',
        '"$itemName" has been added to your wishlist.',
        icon: const Icon(Icons.favorite_rounded, color: Colors.white),
      );
    } else {
      AppSnackbar.black(
        'Removed from Wishlist',
        '"$itemName" has been removed from your wishlist.',
        icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
      );
    }
  }
}
