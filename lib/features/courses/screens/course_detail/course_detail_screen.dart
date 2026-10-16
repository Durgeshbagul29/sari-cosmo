import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_detail_controller.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_payment_controller.dart';

// Modular Widgets
import 'widgets/course_app_bar.dart';
import 'widgets/course_header.dart';
import 'widgets/course_stats.dart';
import 'widgets/course_instructor.dart';
import 'widgets/course_syllabus.dart';
import 'widgets/course_bottom_bar.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Course get initialCourse => widget.course;
  final CourseDetailController _detailController =
      Get.put(CourseDetailController());
  final CoursePaymentController _paymentController =
      Get.put(CoursePaymentController());

  @override
  void initState() {
    super.initState();
    _detailController.fetchCourseDetail(initialCourse.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = _detailController.isLoading.value;
      final currentCourse = _detailController.courseDetails.value ?? initialCourse;

      if (isLoading && _detailController.courseDetails.value == null) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textDark),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppTheme.background,
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            CourseAppBar(course: currentCourse),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CourseHeader(course: currentCourse),
                    const SizedBox(height: 24),
                    CourseStats(course: currentCourse),
                    const SizedBox(height: 32),
                    CourseInstructorCard(course: currentCourse),
                    const SizedBox(height: 32),

                    // About Section
                    Text(
                      'About This Course',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentCourse.longDescription.isNotEmpty
                          ? currentCourse.longDescription
                          : currentCourse.description,
                      style: const TextStyle(
                        color: AppTheme.textMedium,
                        height: 1.6,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Syllabus Section
                    CourseSyllabus(course: currentCourse),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CourseBottomBar(
          course: currentCourse,
          onEnrollPressed: () =>
              _paymentController.startCheckout(currentCourse),
        ),
      );
    });
  }
}
