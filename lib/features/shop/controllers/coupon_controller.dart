import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponController extends GetxController {
  final CouponService _couponService = CouponService();

  var coupons = <Coupon>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Fetch all available coupons
  Future<void> fetchCoupons() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final token = await _getToken();
      if (token == null) {
        debugPrint('Fetch Coupons: auth_token is null, skipping fetch.');
        errorMessage.value = 'Not authenticated. Please log in.';
        return;
      }

      debugPrint('Fetching coupons from GET /v1/coupons/available...');
      final response = await _couponService.getAvailableCoupons(token);
      debugPrint('GET /v1/coupons/available Response: $response');
      if (response['success'] == true && response['data'] != null) {
        final List dataList = response['data'] ?? [];
        final parsedCoupons = dataList.map((e) => Coupon.fromJson(e)).toList();
        coupons.assignAll(parsedCoupons);
        debugPrint('Parsed ${parsedCoupons.length} coupons successfully.');
      } else {
        errorMessage.value = 'Failed to load coupons.';
      }
    } catch (e) {
      debugPrint('Fetch Coupons Error: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void clearCoupons() {
    coupons.clear();
    errorMessage.value = '';
    isLoading.value = false;
  }
}
