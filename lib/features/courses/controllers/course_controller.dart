import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_service.dart';
import '../models/course_model.dart';

class CourseController extends GetxController {
  final CourseService _courseService = CourseService();
  
  var courses = <Course>[].obs;
  var isLoading = false.obs;
  var isPaginating = false.obs;
  var hasLoaded = false.obs;
  
  var currentPage = 1.obs;
  var lastPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses(isRefresh: true);
  }

  Future<void> fetchCourses({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      isLoading.value = true;
    } else {
      if (currentPage.value >= lastPage.value || isPaginating.value) {
        return;
      }
      currentPage.value++;
      isPaginating.value = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await _courseService.getCourses(token ?? '', page: currentPage.value);
      debugPrint('Courses Response Page ${currentPage.value}: $response');
      
      final List data = response['data'] ?? [];
      final newCourses = data.map((e) => Course.fromJson(e)).toList();

      if (isRefresh) {
        courses.assignAll(newCourses);
      } else {
        courses.addAll(newCourses);
      }

      if (response['meta'] != null) {
        lastPage.value = response['meta']['last_page'] ?? 1;
      }
    } catch (e) {
      debugPrint('Fetch Courses Error: $e');
      if (!isRefresh) {
        currentPage.value--;
      }
    } finally {
      if (isRefresh) {
        isLoading.value = false;
      } else {
        isPaginating.value = false;
      }
      hasLoaded.value = true;
    }
  }
}
