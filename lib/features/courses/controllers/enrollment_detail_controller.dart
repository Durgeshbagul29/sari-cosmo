import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_service.dart';
import '../models/enrollment_model.dart';
import '../models/course_model.dart';

class EnrollmentDetailController extends GetxController {
  final CourseService _courseService = CourseService();

  var isLoading = false.obs;
  var isUpdatingProgress = false.obs;
  var enrollment = Rxn<Enrollment>();
  var courseDetails = Rxn<Course>();
  var isFetchingCertificate = false.obs;
  var certificateDetail = Rxn<CertificateDetail>();

  Future<void> fetchEnrollmentDetail(int enrollmentId) async {
    isLoading.value = true;
    enrollment.value = null;
    courseDetails.value = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) {
        throw Exception('Not authenticated');
      }

      // 1. Fetch Enrollment Details
      final enrollmentResponse = await _courseService.getEnrollmentDetail(token, enrollmentId);
      debugPrint('Enrollment Detail Response: $enrollmentResponse');

      final enrollmentData = enrollmentResponse['data'];
      if (enrollmentData == null) {
        throw Exception('Failed to parse enrollment details');
      }

      final parsedEnrollment = Enrollment.fromJson(Map<String, dynamic>.from(enrollmentData as Map));
      enrollment.value = parsedEnrollment;

      // 2. Fetch Course Details to get the full syllabus (modules & lessons) if not present in enrollment
      if (parsedEnrollment.course.modules.isEmpty) {
        try {
          final courseResponse = await _courseService.getCourseDetail(token, parsedEnrollment.course.slug);
          debugPrint('Course Detail Response: $courseResponse');

          final courseData = courseResponse['data'];
          if (courseData != null) {
            courseDetails.value = Course.fromJson(Map<String, dynamic>.from(courseData as Map));
          }
        } catch (secondaryError) {
          debugPrint('Secondary Fetch Course Detail Error (ignored): $secondaryError');
        }
      }
    } catch (e) {
      debugPrint('Fetch Enrollment Detail Error: $e');
      Get.snackbar(
        'Error',
        'Failed to load enrollment details: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProgress(int enrollmentId, int lessonId, String newStatus) async {
    isUpdatingProgress.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) throw Exception('Not authenticated');

      final response = await _courseService.updateLessonProgress(token, enrollmentId, lessonId, newStatus);
      debugPrint('Update Progress Response: $response');

      if (response['success'] == true) {
        // Refresh the enrollment details to show updated checks and overall percentage
        final enrollmentResponse = await _courseService.getEnrollmentDetail(token, enrollmentId);
        final enrollmentData = enrollmentResponse['data'];
        if (enrollmentData != null) {
          enrollment.value = Enrollment.fromJson(Map<String, dynamic>.from(enrollmentData as Map));
        }
        
        Get.snackbar(
          'Progress Updated',
          response['message'] ?? 'Lesson progress updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Update Progress Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update lesson progress: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isUpdatingProgress.value = false;
    }
  }

  Future<void> fetchCertificateDetail(String code) async {
    isFetchingCertificate.value = true;
    certificateDetail.value = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) throw Exception('Not authenticated');

      final response = await _courseService.getCertificateDetail(token, code);
      debugPrint('Certificate Detail Response: $response');

      final data = response['data'];
      if (data == null) {
        throw Exception('Certificate details not found');
      }

      certificateDetail.value = CertificateDetail.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Fetch Certificate Detail Error: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch certificate details: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isFetchingCertificate.value = false;
    }
  }
}
