import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_service.dart';
import '../models/enrollment_model.dart';

class MyCoursesController extends GetxController {
  final CourseService _courseService = CourseService();

  var enrollments = <Enrollment>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyEnrollments();
  }

  Future<void> fetchMyEnrollments() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        debugPrint('No auth token found for enrollments');
        return;
      }

      final response = await _courseService.getMyEnrollments(token);
      debugPrint('My Enrollments Response: $response');

      final List data = response['data'] ?? [];
      final list = data.map((e) => Enrollment.fromJson(e)).toList();
      enrollments.assignAll(list);
    } catch (e) {
      debugPrint('Fetch My Enrollments Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
