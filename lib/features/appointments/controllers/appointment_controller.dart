import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../services/appointment_service.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';
import '../screens/appointment_success_screen.dart';
import 'package:saris_cosmo_center/core/models/models.dart';

class AppointmentController extends GetxController {
  final AppointmentService _appointmentService = AppointmentService();

  var services = <ServiceModel>[].obs;
  var categories = <ServiceCategory>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  
  // Experts list
  var expertsList = <Expert>[].obs;
  var isLoadingExperts = false.obs;
  var hasLoadedExperts = false.obs;

  var isLoadingServices = false.obs;
  var isLoadingCategories = false.obs;
  var isDetailLoading = false.obs;
  var hasLoadedServices = false.obs;

  var selectedCategoryIds = <int>[].obs;
  var searchQuery = ''.obs;
  var serviceDetail = Rxn<ServiceModel>();

  // Reviews state variables
  var reviewsSummary = Rxn<Map<String, dynamic>>();
  var isLoadingReviews = false.obs;
  var isSubmittingReview = false.obs;

  // User Appointments variables
  var userAppointments = <AppointmentModel>[].obs;
  var isLoadingAppointments = false.obs;
  var isRescheduling = false.obs;
  int currentPage = 1;
  int lastPage = 1;
  var isLoadingMoreAppointments = false.obs;

  // Slot variables
  var availableSlots = <Map<String, dynamic>>[].obs;
  var isLoadingSlots = false.obs;
  var isBooking = false.obs;

  // Razorpay session parameters
  late Razorpay _razorpay;
  int? _bookingAppointmentId;
  int? _bookingPaymentId;
  String? _bookingRazorpayOrderId;
  double? _bookingAmount;
  String? _bookingServiceName;
  String? _bookingStaffName;
  String? _bookingDate;
  String? _bookingTime;
  String? _bookingPaymentMethod;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchServices();
    fetchCategories();
    fetchExperts();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> fetchServices() async {
    isLoadingServices.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await _appointmentService.getServices(token);
      debugPrint('Fetch Services Response: $response');

      final List data = response['data'] ?? [];
      final parsed = data.map((e) => ServiceModel.fromJson(e)).toList();
      services.assignAll(parsed);
      applyFilters();
    } catch (e) {
      debugPrint('Fetch Services Error: $e');
    } finally {
      isLoadingServices.value = false;
      hasLoadedServices.value = true;
    }
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await _appointmentService.getServiceCategories(token);
      debugPrint('Fetch Service Categories Response: $response');

      final List data = response['data'] ?? [];
      final parsed = data.map((e) => ServiceCategory.fromJson(e)).toList();
      categories.assignAll(parsed);
    } catch (e) {
      debugPrint('Fetch Service Categories Error: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchExperts({bool isRefresh = false}) async {
    if (!isRefresh && hasLoadedExperts.value) return;
    isLoadingExperts.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final response = await _appointmentService.getExperts(token);
      debugPrint('Fetch Experts Response: $response');
      final List data = response['data'] ?? [];
      final parsed = data.map((e) => Expert.fromJson(e)).toList();
      expertsList.assignAll(parsed);
      hasLoadedExperts.value = true;
    } catch (e) {
      debugPrint('Fetch Experts Error: $e');
    } finally {
      isLoadingExperts.value = false;
    }
  }

  Future<void> fetchServiceDetail(String slug) async {
    isDetailLoading.value = true;
    serviceDetail.value = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await _appointmentService.getServiceDetail(token, slug);
      debugPrint('Fetch Service Detail Response: $response');

      if (response['data'] != null) {
        serviceDetail.value = ServiceModel.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Fetch Service Detail Error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  void toggleCategorySelection(int categoryId) {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
    }
    applyFilters();
  }

  void clearCategorySelection() {
    selectedCategoryIds.clear();
    applyFilters();
  }

  void resetFilters() {
    selectedCategoryIds.clear();
    searchQuery.value = '';
    applyFilters();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    var list = services.toList();

    // Apply category filter
    if (selectedCategoryIds.isNotEmpty) {
      list = list.where((s) => s.category != null && selectedCategoryIds.contains(s.category!.id)).toList();
    }

    // Apply search query filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((s) {
        final nameMatch = s.name.toLowerCase().contains(q);
        final catMatch = s.category?.name.toLowerCase().contains(q) ?? false;
        final descMatch = s.description?.toLowerCase().contains(q) ?? false;
        return nameMatch || catMatch || descMatch;
      }).toList();
    }

    filteredServices.assignAll(list);
  }

  Future<void> fetchAvailableSlots({
    required int serviceId,
    required String date,
    int? staffMemberId,
  }) async {
    isLoadingSlots.value = true;
    availableSlots.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) return;

      final response = await _appointmentService.getAvailableSlots(
        token,
        serviceId,
        date,
        staffMemberId: staffMemberId,
      );
      debugPrint('Available Slots Response: $response');

      final List data = response['data'] ?? response['slots'] ?? [];
      final List<Map<String, dynamic>> flattenedSlots = [];

      for (var item in data) {
        if (item is Map) {
          if (item.containsKey('slots') && item['slots'] is List) {
            final staff = item['staff'] ?? item['staff_member'];
            final slotsList = item['slots'];
            for (var slot in slotsList) {
              if (slot is Map) {
                flattenedSlots.add({
                  'start_time': slot['start_time']?.toString() ?? '',
                  'end_time': slot['end_time']?.toString() ?? '',
                  'staff_member_id': staff != null ? (staff['id'] as int?) : null,
                  'staff_member': {
                    'name': staff != null ? staff['name']?.toString() : null,
                    'user': {
                      'name': staff != null ? staff['name']?.toString() : null,
                    }
                  }
                });
              }
            }
          } else {
            flattenedSlots.add(item.cast<String, dynamic>());
          }
        }
      }
      availableSlots.assignAll(flattenedSlots);
    } catch (e) {
      debugPrint('Fetch Available Slots Error: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<void> bookServiceAppointment({
    required int serviceId,
    required int? staffMemberId,
    required String appointmentDate,
    required String startTime,
    required String paymentMethod,
    String? notes,
    required String serviceName,
    required String staffName,
    required double price,
  }) async {
    isBooking.value = true;
    _showLoadingDialog();

    _bookingServiceName = serviceName;
    _bookingStaffName = staffName;
    _bookingDate = appointmentDate;
    _bookingTime = startTime;
    _bookingAmount = price;
    _bookingPaymentMethod = paymentMethod;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) {
        throw Exception('Please log in to book appointments.');
      }

      // Step 1: Create appointment
      final bookResponse = await _appointmentService.createAppointment(
        token,
        serviceId: serviceId,
        staffMemberId: staffMemberId,
        appointmentDate: appointmentDate,
        startTime: startTime,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      debugPrint('Create Appointment Response: $bookResponse');

      final apptData = bookResponse['data'] ?? bookResponse['appointment'];
      if (apptData == null) {
        throw Exception('Failed to create appointment.');
      }

      final apptId = apptData['id'] as int;
      _bookingAppointmentId = apptId;

      if (paymentMethod == 'pay_later') {
        _hideLoadingDialog();
        // Delay navigation to let the loading dialog pop animation finish completely
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.off(() => AppointmentSuccessScreen(
                serviceName: serviceName,
                staffName: staffName,
                date: appointmentDate,
                time: startTime,
                amount: price,
                paymentMethod: 'Pay Later',
                paymentId: 'PAY_LATER_$apptId',
              ));
        });
        return;
      }

      // Step 2: Online payment flow (create Razorpay Order)
      final orderResponse = await _appointmentService.createRazorpayOrder(token, apptId);
      debugPrint('Appointment Razorpay Order Response: $orderResponse');

      final razorpayOrderId = orderResponse['razorpay_order_id']?.toString() ?? '';
      final keyId = orderResponse['key_id']?.toString() ?? 'rzp_test_B099ZSH414zUNy';
      final int amountPaise = orderResponse['amount'] as int? ?? (price * 100).toInt();
      final paymentId = orderResponse['payment_id'] as int? ?? 0;

      _bookingPaymentId = paymentId;
      _bookingRazorpayOrderId = razorpayOrderId;

      _hideLoadingDialog();

      // Step 3: Open Razorpay SDK
      var options = {
        'key': keyId,
        'amount': amountPaise,
        'name': 'Archana\'s Herbal & Cosmetology',
        'description': 'Booking: $serviceName',
        'order_id': razorpayOrderId,
        'prefill': {
          'contact': '+917741833859',
          'email': 'archana.herbals@gmail.com'
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        throw Exception('Could not open Razorpay checkout: $e');
      }

    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Book Service Appointment Error: $e');
      Get.snackbar(
        'Booking Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isBooking.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final apptId = _bookingAppointmentId;
    final paymentId = _bookingPaymentId;
    final rzpOrderId = response.orderId ?? _bookingRazorpayOrderId;
    final rzpPaymentId = response.paymentId;
    final rzpSignature = response.signature;

    final serviceName = _bookingServiceName ?? 'Service';
    final staffName = _bookingStaffName ?? 'Specialist';
    final apptDate = _bookingDate ?? '';
    final apptTime = _bookingTime ?? '';
    final amount = _bookingAmount ?? 0.0;

    if (apptId == null || paymentId == null || rzpPaymentId == null || rzpSignature == null) {
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
      final verifyResponse = await _appointmentService.verifyRazorpayPayment(
        token,
        razorpayOrderId: rzpOrderId ?? '',
        razorpayPaymentId: rzpPaymentId,
        razorpaySignature: rzpSignature,
        paymentId: paymentId,
      );
      debugPrint('Verify Payment Response: $verifyResponse');

      _hideLoadingDialog();

      if (verifyResponse['success'] == true) {
        // Delay navigation to let the loading dialog pop animation finish completely
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.off(() => AppointmentSuccessScreen(
                serviceName: serviceName,
                staffName: staffName,
                date: apptDate,
                time: apptTime,
                amount: amount,
                paymentMethod: 'Online Payment',
                paymentId: rzpPaymentId,
              ));
        });
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
        'You cancelled the payment. Please try again to complete booking.',
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

  Future<void> fetchUserAppointments({bool loadMore = false}) async {
    if (loadMore) {
      if (currentPage >= lastPage) return;
      isLoadingMoreAppointments.value = true;
    } else {
      currentPage = 1;
      isLoadingAppointments.value = true;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) return;

      final nextPage = loadMore ? currentPage + 1 : 1;
      final response = await _appointmentService.getAppointments(token, page: nextPage);
      debugPrint('Fetch Appointments Response: $response');

      final List data = response['data'] ?? response['appointments'] ?? [];
      final parsed = data.map((e) => AppointmentModel.fromJson(e)).toList();

      final meta = response['meta'];
      if (meta != null) {
        currentPage = meta['current_page'] ?? nextPage;
        lastPage = meta['last_page'] ?? 1;
      } else {
        currentPage = nextPage;
        lastPage = 1;
      }

      if (loadMore) {
        userAppointments.addAll(parsed);
      } else {
        userAppointments.assignAll(parsed);
      }
    } catch (e) {
      debugPrint('Fetch User Appointments Error: $e');
    } finally {
      if (loadMore) {
        isLoadingMoreAppointments.value = false;
      } else {
        isLoadingAppointments.value = false;
      }
    }
  }

  Future<AppointmentModel?> fetchAppointmentDetail(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) return null;

      final response = await _appointmentService.getAppointmentDetail(token, id);
      debugPrint('Fetch Appointment Detail Response: $response');

      if (response['success'] == true && response['data'] != null) {
        return AppointmentModel.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Fetch Appointment Detail Error: $e');
    }
    return null;
  }

  Future<bool> cancelServiceAppointment(int appointmentId) async {
    _showLoadingDialog();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) throw Exception('Not authenticated');

      final response = await _appointmentService.cancelAppointment(token, appointmentId);
      debugPrint('Cancel Appointment Response: $response');

      _hideLoadingDialog();
      fetchUserAppointments(); // Refresh the list
      return true;
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Cancel Appointment Error: $e');
      Get.snackbar(
        'Cancellation Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  Future<bool> rescheduleServiceAppointment({
    required int appointmentId,
    required int? staffMemberId,
    required String appointmentDate,
    required String startTime,
  }) async {
    isRescheduling.value = true;
    _showLoadingDialog();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) throw Exception('Not authenticated');

      final response = await _appointmentService.rescheduleAppointment(
        token,
        appointmentId,
        staffMemberId: staffMemberId,
        appointmentDate: appointmentDate,
        startTime: startTime,
      );
      debugPrint('Reschedule Response: $response');

      _hideLoadingDialog();
      fetchUserAppointments(); // Refresh the list
      return true;
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Reschedule Error: $e');
      Get.snackbar(
        'Reschedule Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isRescheduling.value = false;
    }
  }

  Future<void> fetchServiceReviews(String slug) async {
    isLoadingReviews.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final response = await _appointmentService.getServiceReviews(token, slug);
      debugPrint('Fetch Service Reviews Response: $response');
      if (response['success'] == true) {
        reviewsSummary.value = response['data'] ?? response;
      }
    } catch (e) {
      debugPrint('Fetch Service Reviews Error: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<bool> submitServiceReview(
      String slug, int rating, String title, String comment) async {
    isSubmittingReview.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final reviewData = {
        'rating': rating,
        'title': title,
        'comment': comment,
      };
      final response = await _appointmentService.submitServiceReview(token, slug, reviewData);
      debugPrint('Submit Service Review Response: $response');
      if (response['success'] == true || response.isNotEmpty) {
        await fetchServiceReviews(slug);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Submit Service Review Error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Review Verification',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1B15),
        colorText: Colors.white,
        icon: const Icon(
          Icons.verified_user_outlined,
          color: AppTheme.primary,
          size: 26,
        ),
        titleText: const Text(
          'Verification Required',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
        messageText: Text(
          errorMsg,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        borderColor: AppTheme.primary.withValues(alpha: 0.6),
        borderWidth: 1.5,
        borderRadius: 16,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 5),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        snackStyle: SnackStyle.FLOATING,
      );
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
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
}
