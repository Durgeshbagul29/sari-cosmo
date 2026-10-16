import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/firebase_notification_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/models/user_model.dart';
import '../../../main.dart';
import '../login_screen.dart';
import '../../shop/controllers/cart_controller.dart';
import '../../shop/controllers/product_controller.dart';
import '../../shop/controllers/order_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../address/controllers/address_controller.dart';
import '../../courses/controllers/course_controller.dart';
import '../../courses/controllers/my_courses_controller.dart';
import '../../courses/controllers/course_payment_controller.dart';
import '../../shop/controllers/wishlist_controller.dart';
import '../../appointments/controllers/appointment_controller.dart';
import '../../shop/controllers/checkout_controller.dart';
import '../../profile/controllers/notification_controller.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();
  var loginError = ''.obs;
  var registerError = ''.obs;

  Future<void> login(String email, String password, BuildContext context) async {
    isLoading.value = true;
    try {
      final response = await _apiService.login(email.trim(), password);
      debugPrint('Login Response: $response');
      
      // Parse response
      final userData = response['data']?['user'] ?? response['data'] ?? response['user'] ?? response;
      final tempUser = UserModel.fromJson(userData);

      // Verify that the role is 'customer'
      final role = tempUser.role;
      if (role == null || role.toLowerCase() != 'customer') {
        AppSnackbar.error(
          'Access Denied',
          'Only customer accounts are authorized to use this application. Please register a customer account to log in.',
          icon: const Icon(Icons.gpp_bad_rounded, color: Colors.white),
        );
        return;
      }

      currentUser.value = tempUser;
      
      // Save token
      final token = response['data']?['token'] ?? response['token'] ?? currentUser.value?.token;
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString('auth_token', token);
      }

      // Save user details locally
      if (currentUser.value != null) {
        if (currentUser.value!.name != null) await prefs.setString('user_name', currentUser.value!.name!);
        if (currentUser.value!.email != null) await prefs.setString('user_email', currentUser.value!.email!);
        if (currentUser.value!.phone != null) await prefs.setString('user_phone', currentUser.value!.phone!);
        if (currentUser.value!.role != null) await prefs.setString('user_role', currentUser.value!.role!);
      }

      AppSnackbar.success('Success', 'Login Successful');

      // Register device FCM token upon login
      try {
        if (token != null) {
          final fcmService = FirebaseNotificationService.instance;
          await fcmService.handlePendingTokenRegistration(token);
        }
      } catch (e) {
        debugPrint('Login FCM token registration error: $e');
      }
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '').trim();
      AppSnackbar.error(
        'Login Failed',
        errorMsg,
        icon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String phone, String password, String passwordConfirmation, BuildContext context) async {
    isLoading.value = true;
    try {
      final response = await _apiService.register(name.trim(), email.trim(), phone.trim(), password, passwordConfirmation);
      debugPrint('Register Response: $response');
      
      final userData = response['data']?['user'] ?? response['data'] ?? response['user'] ?? response;
      currentUser.value = UserModel.fromJson(userData);

      // Save user details locally
      final prefs = await SharedPreferences.getInstance();
      if (currentUser.value != null) {
        if (currentUser.value!.name != null) await prefs.setString('user_name', currentUser.value!.name!);
        if (currentUser.value!.email != null) await prefs.setString('user_email', currentUser.value!.email!);
        if (currentUser.value!.phone != null) await prefs.setString('user_phone', currentUser.value!.phone!);
        if (currentUser.value!.role != null) await prefs.setString('user_role', currentUser.value!.role!);
      }

      AppSnackbar.success('Success', response['message'] ?? 'Account created successfully');
      
      if (context.mounted) {
        // Navigate to login page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('Register Error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '').trim();
      AppSnackbar.error('Registration Failed', errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestPasswordReset(String email, BuildContext context) async {
    isLoading.value = true;
    try {
      final response = await _apiService.forgotPassword(email.trim());
      debugPrint('Forgot Password Response: $response');
      
      final bool success = response['success'] ?? false;
      final String message = response['message'] ?? 'We have emailed your password reset link.';
      
      if (success) {
        AppSnackbar.success('Success', message);
        if (context.mounted) {
          Navigator.of(context).pop(); // Go back to login screen
        }
      } else {
        AppSnackbar.error('Failed', message);
      }
    } catch (e) {
      debugPrint('Forgot Password Error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '').trim();
      AppSnackbar.error('Password Reset Failed', errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final fcmToken = prefs.getString('fcm_token');
      
      if (token != null) {
        // Attempt to deregister FCM token on backend prior to logout
        try {
          await FirebaseNotificationService.instance.deleteDeviceToken(token);
        } catch (e) {
          debugPrint('Deregister FCM token on logout error: $e');
        }
        
        final response = await _apiService.logout(token, fcmToken: fcmToken);
        debugPrint('Logout Response: $response');
      }
      
      // Preserve onboardingComplete flag
      final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
      
      // Clear all user data from preferences
      await prefs.clear();
      
      // Restore onboardingComplete so user doesn't see onboarding again
      if (onboardingComplete) {
        await prefs.setBool('onboardingComplete', true);
      }
      
      currentUser.value = null;

      // Clear all active Get controllers to remove any cached state
      Get.delete<CartController>(force: true);
      Get.delete<ProductController>(force: true);
      Get.delete<OrderController>(force: true);
      Get.delete<ProfileController>(force: true);
      Get.delete<AddressController>(force: true);
      Get.delete<CourseController>(force: true);
      Get.delete<MyCoursesController>(force: true);
      Get.delete<CoursePaymentController>(force: true);
      Get.delete<WishlistController>(force: true);
      Get.delete<AppointmentController>(force: true);
      Get.delete<CheckoutController>(force: true);
      Get.delete<NotificationController>(force: true);
      Get.delete<NavigationController>(force: true);

      AppSnackbar.success('Success', 'Logged out successfully');
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout Error: $e');
      AppSnackbar.error('Logout Failed', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
