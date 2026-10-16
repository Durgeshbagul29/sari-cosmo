import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import '../services/course_service.dart';
import '../screens/course_payment/payment_success_screen.dart';
import '../screens/enrollment_detail/enrollment_detail_screen.dart';
import '../screens/my_courses/my_courses_screen.dart';
import 'my_courses_controller.dart';

class CoursePaymentController extends GetxController {
  late Razorpay _razorpay;
  final CourseService _courseService = CourseService();
  
  Course? _activeCourse;
  String? _activeCourseTitle;
  double? _activeCoursePrice;

  int? _currentEnrollmentId;
  int? _currentPaymentId;
  String? _currentRazorpayOrderId;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void _showLoadingDialog() {
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> startCheckout(Course course) async {
    _activeCourse = course;
    _activeCourseTitle = course.title;
    _activeCoursePrice = course.price;
    _showLoadingDialog();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) {
        throw Exception('Please log in to enroll in this course.');
      }

      // Step 1: Enroll in Course
      final enrollResponse = await _courseService.enrollInCourse(token, course.id);
      debugPrint('Enroll Course Response: $enrollResponse');

      final enrollmentData = enrollResponse['data'];
      if (enrollmentData == null) {
        throw Exception('Failed to create enrollment.');
      }

      final enrollmentId = enrollmentData['id'] as int;
      _currentEnrollmentId = enrollmentId;
      final status = enrollmentData['status']?.toString() ?? 'pending';
      final paymentStatus = enrollmentData['payment_status']?.toString() ?? 'pending';

      // If the course is free or already active & paid, go straight to success
      if (course.isFree || (status == 'active' && paymentStatus == 'paid')) {
        _hideLoadingDialog();
        Get.to(() => PaymentSuccessScreen(
              title: course.title,
              amount: 0.0,
              paymentId: 'FREE_ENROLLMENT_${enrollmentId}_${DateTime.now().millisecondsSinceEpoch}',
              isCourse: true,
              enrollmentId: enrollmentId,
            ));
        return;
      }

      // For paid courses, navigate to My Courses screen to make payment
      _hideLoadingDialog();
      Get.snackbar(
        'Enrolled Successfully',
        'Please complete the payment on the My Courses screen to start learning.',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      try {
        final myCoursesController = Get.find<MyCoursesController>();
        myCoursesController.fetchMyEnrollments();
      } catch (_) {}

      // Open My Courses Screen
      Get.off(() => const MyCoursesScreen());
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Start Checkout Error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.toLowerCase().contains('already enrolled')) {
        _handleAlreadyEnrolled(course);
      } else {
        Get.snackbar(
          'Checkout Error',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  Future<void> resumePayment(Enrollment enrollmentObj) async {
    _activeCourse = null;
    _activeCourseTitle = enrollmentObj.course.title;
    _currentEnrollmentId = enrollmentObj.id;
    _showLoadingDialog();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) {
        throw Exception('Please log in to complete your payment.');
      }

      // Step 2: Initiate Payment (create Razorpay Order on server)
      final orderResponse = await _courseService.createRazorpayOrder(token, enrollmentObj.id);
      debugPrint('Resume Razorpay Order Response: $orderResponse');

      final razorpayOrderId = orderResponse['razorpay_order_id']?.toString() ?? '';
      final keyId = orderResponse['key_id']?.toString() ?? 'rzp_test_B099ZSH414zUNy';
      final int amountPaise = orderResponse['amount'] as int? ?? 0;
      final paymentId = orderResponse['payment_id'] as int? ?? 0;
      
      _currentPaymentId = paymentId;
      _currentRazorpayOrderId = razorpayOrderId;
      _activeCoursePrice = amountPaise / 100.0;

      _hideLoadingDialog();

      // Step 3: Open Razorpay Gateway
      var options = {
        'key': keyId,
        'amount': amountPaise,
        'name': 'Archana\'s Herbal & Cosmetology',
        'description': enrollmentObj.course.title,
        'order_id': razorpayOrderId,
        'prefill': {
          'contact': '+917741833859',
          'email': 'archana.herbals@gmail.com'
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        throw Exception('Could not open payment sheet: $e');
      }
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Resume Payment Error: $e');
      Get.snackbar(
        'Payment Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _handleAlreadyEnrolled(Course course) async {
    _showLoadingDialog();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final response = await _courseService.getMyEnrollments(token);
      final list = response['data'] as List? ?? [];
      
      _hideLoadingDialog();
      
      int? matchedEnrollmentId;
      for (var item in list) {
        if (item is Map && item['course'] is Map) {
          final courseMap = item['course'] as Map;
          if (courseMap['id'] == course.id || courseMap['slug'] == course.slug) {
            matchedEnrollmentId = item['id'] as int?;
            break;
          }
        }
      }

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Already Enrolled', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'You are already enrolled in "${course.title}". Would you like to view your course details and progress?',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMedium)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close Dialog
                if (matchedEnrollmentId != null) {
                  Get.to(() => EnrollmentDetailScreen(enrollmentId: matchedEnrollmentId!));
                } else {
                  Get.snackbar(
                    'Error',
                    'Could not find active enrollment details.',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Go to Course'),
            ),
          ],
        ),
      );
    } catch (e) {
      _hideLoadingDialog();
      Get.snackbar(
        'Already Enrolled',
        'You are already enrolled in this course. You can access it from My Courses.',
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final enrollmentId = _currentEnrollmentId;
    final paymentId = _currentPaymentId;
    final rzpOrderId = response.orderId ?? _currentRazorpayOrderId;
    final rzpPaymentId = response.paymentId;
    final rzpSignature = response.signature;

    final title = _activeCourseTitle ?? 'Course';
    final price = _activeCoursePrice ?? 0.0;

    if (enrollmentId == null || paymentId == null || rzpPaymentId == null || rzpSignature == null) {
      Get.snackbar(
        'Error',
        'Invalid payment session. Please contact support.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    _showLoadingDialog();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) throw Exception('Not authenticated');

      // Step 4: Verify Payment
      final verifyResponse = await _courseService.verifyRazorpayPayment(
        token,
        razorpayOrderId: rzpOrderId ?? '',
        razorpayPaymentId: rzpPaymentId,
        razorpaySignature: rzpSignature,
        paymentId: paymentId,
      );
      debugPrint('Verify Payment Response: $verifyResponse');

      _hideLoadingDialog();

      if (verifyResponse['success'] == true) {
        try {
          if (Get.isRegistered<MyCoursesController>()) {
            Get.find<MyCoursesController>().fetchMyEnrollments();
          }
        } catch (_) {}

        Get.to(() => PaymentSuccessScreen(
              title: title,
              amount: price,
              paymentId: rzpPaymentId,
              isCourse: true,
              enrollmentId: enrollmentId,
            ));
      } else {
        throw Exception(verifyResponse['message'] ?? 'Verification failed.');
      }
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Payment Verification Error: $e');
      Get.snackbar(
        'Payment Verification Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final String message = response.message ?? '';
    final bool isUserCancelled = message.toLowerCase().contains('cancel') || response.code == 2;

    if (isUserCancelled) {
      Get.snackbar(
        'Payment Cancelled',
        'You cancelled the payment. You can resume it anytime by tapping "Pay Now" on the course card.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'Payment Failed',
        message.isNotEmpty ? message : 'Payment processing failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet Selected',
      'Please complete the payment using ${response.walletName}',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
