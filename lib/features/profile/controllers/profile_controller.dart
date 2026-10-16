import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/dashboard_model.dart';
import '../../../core/models/user_model.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var isProfileUpdating = false.obs;
  var dashboardData = DashboardModel().obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var localAvatarPath = ''.obs;
  var currentUser = Rxn<UserModel>();
  var hasLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    await Future.wait([
      fetchDashboardData(),
      fetchProfile(),
    ]);
    isLoading.value = false;
    hasLoaded.value = true;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? 'Guest User';
    userEmail.value = prefs.getString('user_email') ?? '';
    localAvatarPath.value = prefs.getString('local_avatar_path') ?? '';
  }

  Future<void> fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.getDashboardData(token);
        debugPrint('Dashboard Response: $response');
        
        final data = response['data'] ?? response;
        dashboardData.value = DashboardModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Dashboard Error: $e');
    }
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.getProfile(token);
        debugPrint('Profile Fetch Response: $response');
        
        final data = response['data'] ?? response;
        currentUser.value = UserModel.fromJson(data);
        
        // Update local names just in case
        if (currentUser.value?.name != null) {
          userName.value = currentUser.value!.name!;
          await prefs.setString('user_name', userName.value);
        }
        if (currentUser.value?.email != null) {
          userEmail.value = currentUser.value!.email!;
          await prefs.setString('user_email', userEmail.value);
        }
      }
    } catch (e) {
      debugPrint('Profile Fetch Error: $e');
    }
  }

  Future<bool> updateProfile(String name, String phone) async {
    isProfileUpdating.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await _apiService.updateProfile(token, name, phone);
        debugPrint('Profile Update Response: $response');
        
        final data = response['data'] ?? response;
        currentUser.value = UserModel.fromJson(data);
        
        // Update local names
        if (currentUser.value?.name != null) {
          userName.value = currentUser.value!.name!;
          await prefs.setString('user_name', userName.value);
        }
        if (currentUser.value?.phone != null) {
          await prefs.setString('user_phone', currentUser.value!.phone!);
        }

        AppSnackbar.success('Success', 'Profile updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Profile Update Error: $e');
      AppSnackbar.error('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isProfileUpdating.value = false;
    }
  }

  Future<bool> uploadProfileImage(String filePath) async {
    isProfileUpdating.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        await prefs.setString('local_avatar_path', filePath);
        localAvatarPath.value = filePath;

        final response = await _apiService.uploadAvatar(token, filePath);
        debugPrint('Upload Avatar Response: $response');

        final data = response['data'] ?? response;
        currentUser.value = UserModel.fromJson(data);

        AppSnackbar.success('Success', 'Profile image updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Upload Avatar Error: $e');
      AppSnackbar.error('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isProfileUpdating.value = false;
    }
  }

  Future<bool> removeProfileImage() async {
    isProfileUpdating.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        await prefs.remove('local_avatar_path');
        localAvatarPath.value = '';

        final response = await _apiService.removeAvatar(token);
        debugPrint('Remove Avatar Response: $response');

        final data = response['data'] ?? response;
        currentUser.value = UserModel.fromJson(data);

        AppSnackbar.success('Success', 'Profile image removed successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Remove Avatar Error: $e');
      AppSnackbar.error('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isProfileUpdating.value = false;
    }
  }

  var isPasswordUpdating = false.obs;

  Future<bool> changePassword(String currentPassword, String password, String passwordConfirmation) async {
    isPasswordUpdating.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await _apiService.changePassword(
          token,
          currentPassword,
          password,
          passwordConfirmation,
        );
        debugPrint('Change Password Response: $response');

        final String message = response['message'] ?? 'Password updated successfully';
        AppSnackbar.success('Success', message);
        return true;
      }
      AppSnackbar.error('Error', 'Authentication token not found. Please log in again.');
      return false;
    } catch (e) {
      debugPrint('Change Password Error: $e');
      AppSnackbar.error('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isPasswordUpdating.value = false;
    }
  }
}
