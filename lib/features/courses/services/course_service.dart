import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saris_cosmo_center/core/network/api_endpoints.dart';

class CourseService {
  Future<Map<String, dynamic>> getCourses(String token, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.courses}?page=$page'),
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

  Future<Map<String, dynamic>> getCourseDetail(String token, String slug) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.courseDetail(slug)),
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

  Future<Map<String, dynamic>> getMyEnrollments(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.myEnrollments),
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

  Future<Map<String, dynamic>> getEnrollmentDetail(String token, int enrollmentId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.enrollmentDetail(enrollmentId)),
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

  Future<Map<String, dynamic>> enrollInCourse(String token, int courseId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.enrollInCourse(courseId)),
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
      throw Exception('Failed to enroll in course: $e');
    }
  }

  Future<Map<String, dynamic>> createRazorpayOrder(String token, int enrollmentId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.razorpayCreateOrder),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payable_type': 'enrollment',
          'payable_id': enrollmentId,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
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
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to verify payment: $e');
    }
  }

  Future<Map<String, dynamic>> updateLessonProgress(
    String token,
    int enrollmentId,
    int lessonId,
    String status,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.updateLessonProgress(enrollmentId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lesson_id': lessonId,
          'status': status,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to update progress: $e');
    }
  }

  Future<Map<String, dynamic>> getCertificateDetail(String token, String code) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.certificateDetail(code)),
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
      throw Exception('Failed to fetch certificate: $e');
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
