import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';
import 'package:saris_cosmo_center/features/search/search_screen.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_controller.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_category_controller.dart';

import 'package:saris_cosmo_center/features/courses/controllers/course_filter_controller.dart';
// Standalone Widgets
import 'widgets/course_list_card.dart';
import 'widgets/course_filter_bottom_sheet.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseController _courseController = Get.put(CourseController());
  final ScrollController _scrollController = ScrollController();

  final CourseFilterController _filterController =
      Get.find<CourseFilterController>();

  @override
  void initState() {
    super.initState();
    Get.put(CourseCategoryController());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _courseController.fetchCourses();
    }
  }

  List<Course> get _filtered {
    List<Course> items = _courseController.courses.toList();

    // Filter by categories (dynamic)
    if (_filterController.selectedCategories.isNotEmpty) {
      items = items
          .where((c) => _filterController.selectedCategories.contains(c.category.name))
          .toList();
    }

    // Sort by price
    if (_filterController.sortOption.value == 'Price: Low to High') {
      items.sort((a, b) => a.price.compareTo(b.price));
    } else if (_filterController.sortOption.value == 'Price: High to Low') {
      items.sort((a, b) => b.price.compareTo(a.price));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSortBottomSheet,
          ),
        ],
      ),
      body: Obx(() {
        final filtered = _filtered;
        final isLoading = _courseController.isLoading.value;

        return RefreshIndicator(
          onRefresh: () => _courseController.fetchCourses(isRefresh: true),
          color: AppTheme.primary,
          child: filtered.isEmpty
              ? (isLoading
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: 4,
                      itemBuilder: (ctx, i) => const CourseListCardShimmer(),
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(
                            child: Text('No courses found',
                                style: TextStyle(color: AppTheme.textMedium)),
                          ),
                        ),
                      ],
                    ))
              : ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length +
                      (_courseController.isPaginating.value ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == filtered.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                            child:
                                CircularProgressIndicator(color: AppTheme.primary)),
                      );
                    }
                    return CourseListCard(course: filtered[i]);
                  },
                ),
        );
      }),
    );
  }

  void _showFilterSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CourseFilterBottomSheet(
        initialSelectedCategories: _filterController.selectedCategories.toSet(),
        initialSortOption: _filterController.sortOption.value,
        onApply: (selectedCategories, sortOption) {
          _filterController.applyFilters(selectedCategories, sortOption);
        },
      ),
    );
  }
}
