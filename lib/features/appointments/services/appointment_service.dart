import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

class AppointmentService {
  Future<Map<String, dynamic>> getServices(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.services),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> getServiceDetail(String token, String slug) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.serviceDetail(slug)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> getServiceCategories(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.serviceCategories),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> getAvailableSlots(
    String token,
    int serviceId,
    String date, {
    int? staffMemberId,
  }) async {
    try {
      String urlString = '${ApiEndpoints.availableSlots}?service_id=$serviceId&date=$date';
      if (staffMemberId != null) {
        urlString += '&staff_member_id=$staffMemberId';
      }
      print('DEBUG [getAvailableSlots] Request URL: $urlString');
      print('DEBUG [getAvailableSlots] Auth Token: $token');
      
      final response = await http.get(
        Uri.parse(urlString),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('DEBUG [getAvailableSlots] Response Code: ${response.statusCode}');
      print('DEBUG [getAvailableSlots] Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG [getAvailableSlots] Error caught: $e');
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to fetch available slots: $e');
    }
  }

  Future<Map<String, dynamic>> createAppointment(
    String token, {
    required int serviceId,
    required int? staffMemberId,
    required String appointmentDate,
    required String startTime,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final body = {
        'service_id': serviceId,
        'appointment_date': appointmentDate,
        'start_time': startTime,
        'payment_method': paymentMethod,
      };
      if (staffMemberId != null) {
        body['staff_member_id'] = staffMemberId;
      }
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.appointments),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<Map<String, dynamic>> rescheduleAppointment(
    String token,
    int appointmentId, {
    required int? staffMemberId,
    required String appointmentDate,
    required String startTime,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'appointment_date': appointmentDate,
        'start_time': startTime,
      };
      if (staffMemberId != null) {
        body['staff_member_id'] = staffMemberId;
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.rescheduleAppointment(appointmentId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to reschedule appointment: $e');
    }
  }

  Future<Map<String, dynamic>> createRazorpayOrder(String token, int appointmentId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.razorpayCreateOrder),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payable_type': 'appointment',
          'payable_id': appointmentId,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to create payment order: $e');
    }
  }

  Future<Map<String, dynamic>> verifyRazorpayPayment(
    String token, {
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int paymentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.razorpayVerify),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'payment_id': paymentId,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to verify payment: $e');
    }
  }

  Future<Map<String, dynamic>> getExperts(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.experts),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to fetch experts: $e');
    }
  }

  Future<Map<String, dynamic>> getAppointments(String token, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.appointments}?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  Future<Map<String, dynamic>> getAppointmentDetail(String token, int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.appointmentDetail(id)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to fetch appointment details: $e');
    }
  }

  Future<Map<String, dynamic>> cancelAppointment(String token, int appointmentId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.cancelAppointment(appointmentId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  Future<Map<String, dynamic>> getServiceReviews(String token, String slug) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.serviceReviews(slug)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to fetch service reviews: $e');
    }
  }

  Future<Map<String, dynamic>> submitServiceReview(
    String token,
    String slug,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.serviceReviews(slug)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(reviewData),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('Failed to submit service review: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'An error occurred';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
