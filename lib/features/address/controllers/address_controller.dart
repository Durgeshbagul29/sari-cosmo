import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/address_model.dart';

class AddressController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var addresses = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.getAddresses(token);
        debugPrint('Get Addresses Response: $response');
        
        final data = response['data'] as List?;
        if (data != null) {
          addresses.value = data.map((e) => AddressModel.fromJson(e)).toList();
        } else {
          addresses.clear();
        }
      }
    } catch (e) {
      debugPrint('Get Addresses Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.addAddress(token, address.toJson());
        debugPrint('Add Address Response: $response');
        
        Get.snackbar('Success', response['message'] ?? 'Address added successfully',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, margin: const EdgeInsets.all(16));
        
        await fetchAddresses();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Add Address Error: $e');
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, margin: const EdgeInsets.all(16));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateAddress(String id, AddressModel address) async {
    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.updateAddress(token, id, address.toJson());
        debugPrint('Update Address Response: $response');
        
        Get.snackbar('Success', response['message'] ?? 'Address updated successfully',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, margin: const EdgeInsets.all(16));
        
        await fetchAddresses();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update Address Error: $e');
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, margin: const EdgeInsets.all(16));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.deleteAddress(token, id);
        debugPrint('Delete Address Response: $response');
        
        Get.snackbar('Success', response['message'] ?? 'Address deleted successfully',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, margin: const EdgeInsets.all(16));
        
        await fetchAddresses();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete Address Error: $e');
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, margin: const EdgeInsets.all(16));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.setDefaultAddress(token, id);
        debugPrint('Set Default Address Response: $response');
        
        Get.snackbar('Success', response['message'] ?? 'Address set as default',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, margin: const EdgeInsets.all(16));
        
        await fetchAddresses();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Set Default Address Error: $e');
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, margin: const EdgeInsets.all(16));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
