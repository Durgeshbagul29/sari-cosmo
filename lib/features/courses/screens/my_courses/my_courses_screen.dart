import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../../controllers/my_courses_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/course_payment_controller.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/enrollment_card.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myCoursesController = Get.put(MyCoursesController());
    final courseController = Get.put(CourseController());
    final paymentController = Get.put(CoursePaymentController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Courses'),
        scrolledUnderElevation: 0,
      ),
      body: Obx(() {
        if (myCoursesController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final enrollments = myCoursesController.enrollments;

        if (enrollments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: AppTheme.textLight.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You are not enrolled in any courses yet.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          );
        }

        final activeCount =
            enrollments.where((e) => e.status.toLowerCase() == 'active').length;

        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () => myCoursesController.fetchMyEnrollments(),
          child: Column(
            children: [
              ProgressSummaryCard(count: activeCount),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
                  itemCount: enrollments.length,
                  itemBuilder: (context, index) {
                    final enrollment = enrollments[index];
                    return EnrollmentCard(
                      enrollment: enrollment,
                      courseController: courseController,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
