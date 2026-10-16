import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../../../models/enrollment_model.dart';
import '../../../controllers/course_controller.dart';
import '../../../controllers/course_payment_controller.dart';
import '../../enrollment_detail/enrollment_detail_screen.dart';

class EnrollmentCard extends StatelessWidget {
  final Enrollment enrollment;
  final CourseController courseController;

  const EnrollmentCard({
    super.key,
    required this.enrollment,
    required this.courseController,
  });

  @override
  Widget build(BuildContext context) {
    final double progressFraction = enrollment.progressPercent / 100.0;
    final isPaid = enrollment.paymentStatus.toLowerCase() == 'paid';
    final isPending = enrollment.paymentStatus.toLowerCase() == 'pending';

    // Format enrollment date nicely
    String formattedDate = '';
    try {
      final dt = DateTime.parse(enrollment.enrolledAt);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      formattedDate =
          'Enrolled on ${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      formattedDate = enrollment.enrolledAt.split('T').first;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnrollmentDetailScreen(enrollmentId: enrollment.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Header (Image + Title + Status Badges)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail / Placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: enrollment.course.thumbnail != null &&
                            enrollment.course.thumbnail!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: enrollment.course.thumbnail!,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 70,
                              width: 70,
                              color: AppTheme.primary.withValues(alpha: 0.05),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 70,
                              width: 70,
                              color: AppTheme.primary.withValues(alpha: 0.05),
                              child: const Center(
                                child: Icon(Icons.school_rounded,
                                    color: AppTheme.primary, size: 28),
                              ),
                            ),
                          )
                        : Container(
                            height: 70,
                            width: 70,
                            color: AppTheme.primary.withValues(alpha: 0.05),
                            child: const Center(
                              child: Icon(Icons.school_rounded,
                                  color: AppTheme.primary, size: 28),
                              ),
                            ),
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment Badge + Date Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Payment Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? AppTheme.success.withValues(alpha: 0.1)
                                    : isPending
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPaid
                                    ? 'PAID'
                                    : isPending
                                        ? 'PENDING'
                                        : enrollment.paymentStatus.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isPaid
                                      ? AppTheme.success
                                      : isPending
                                          ? Colors.orange.shade800
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            // Enrolled Date
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          enrollment.course.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Course Progress',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${enrollment.progressPercent.toInt()}% Complete',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 6,
                      backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressFraction >= 0.8
                            ? AppTheme.success
                            : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (isPaid) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnrollmentDetailScreen(
                              enrollmentId: enrollment.id),
                        ),
                      );
                    } else {
                      Get.find<CoursePaymentController>()
                          .resumePayment(enrollment);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        isPaid ? AppTheme.primary : AppTheme.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isPaid ? 'Start Learning' : 'Pay Now',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
