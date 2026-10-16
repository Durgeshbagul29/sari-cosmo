import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_category_service.dart';
import '../models/course_category_model.dart';

class CourseCategoryController extends GetxController {
  final CourseCategoryService _categoryService = CourseCategoryService();

  var categories = <CourseCategory>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _categoryService.getCourseCategories(token ?? '');
      debugPrint('Course Categories Response: $response');

      final List data = response['data'] ?? [];
      final parsedCategories = data.map((e) => CourseCategory.fromJson(e)).toList();

      categories.assignAll(parsedCategories);
    } catch (e) {
      debugPrint('Fetch Course Categories Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
