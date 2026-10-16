import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_service.dart';
import '../models/course_model.dart';

class CourseDetailController extends GetxController {
  final CourseService _courseService = CourseService();

  var isLoading = false.obs;
  var courseDetails = Rxn<Course>();

  Future<void> fetchCourseDetail(String slug) async {
    courseDetails.value = null;
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _courseService.getCourseDetail(token ?? '', slug);
      debugPrint('Course Detail Response: $response');

      final data = response['data'];
      if (data != null) {
        courseDetails.value = Course.fromJson(data);
      }
    } catch (e) {
      debugPrint('Fetch Course Detail Error: $e');
      Get.snackbar('Error', 'Failed to load course details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
    } finally {
      isLoading.value = false;
    }
  }
}
