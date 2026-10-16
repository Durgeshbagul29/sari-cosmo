import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/enrollment_model.dart';
import '../../controllers/enrollment_detail_controller.dart';
import '../../controllers/my_courses_controller.dart';
import '../lesson/lesson_detail_screen.dart';

class EnrollmentDetailScreen extends StatefulWidget {
  final int enrollmentId;

  const EnrollmentDetailScreen({
    super.key,
    required this.enrollmentId,
  });

  @override
  State<EnrollmentDetailScreen> createState() => _EnrollmentDetailScreenState();
}

class _EnrollmentDetailScreenState extends State<EnrollmentDetailScreen> {
  final EnrollmentDetailController _detailController =
      Get.put(EnrollmentDetailController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detailController.fetchEnrollmentDetail(widget.enrollmentId);
    });
  }

  @override
  void dispose() {
    try {
      if (Get.isRegistered<MyCoursesController>()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<MyCoursesController>()) {
            Get.find<MyCoursesController>().fetchMyEnrollments();
          }
        });
      }
    } catch (_) {}
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      if (dateStr.contains('T')) {
        return dateStr.split('T').first;
      }
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Course Progress'),
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (_detailController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final enrollment = _detailController.enrollment.value;
        final course = _detailController.courseDetails.value;

        if (enrollment == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load progress details.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      _detailController.fetchEnrollmentDetail(widget.enrollmentId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () =>
              _detailController.fetchEnrollmentDetail(widget.enrollmentId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCourseHeader(enrollment),
                const SizedBox(height: 12),
                _buildStudentInfoCard(enrollment),
                const SizedBox(height: 12),
                _buildPaymentInfoCard(enrollment),
                const SizedBox(height: 12),
                _buildProgressCard(enrollment),
                const SizedBox(height: 12),
                () {
                  final List<dynamic> modules = enrollment.course.modules.isNotEmpty
                      ? enrollment.course.modules
                      : (course?.modules ?? []);
                  if (modules.isNotEmpty) {
                    return _buildSyllabusList(modules, enrollment);
                  } else {
                    return _buildRawLessonProgressList(enrollment);
                  }
                }(),
                const SizedBox(height: 12),
                _buildCertificateCard(enrollment),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCourseHeader(Enrollment enrollment) {
    final isPaid = enrollment.paymentStatus.toLowerCase() == 'paid';
    final isPending = enrollment.paymentStatus.toLowerCase() == 'pending';

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: enrollment.course.thumbnail != null &&
                    enrollment.course.thumbnail!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: enrollment.course.thumbnail!,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 80,
                      width: 80,
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
                      height: 80,
                      width: 80,
                      color: AppTheme.primary.withValues(alpha: 0.05),
                      child: const Center(
                        child: Icon(Icons.school_rounded,
                            color: AppTheme.primary, size: 32),
                      ),
                    ),
                  )
                : Container(
                    height: 80,
                    width: 80,
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    child: const Center(
                      child: Icon(Icons.school_rounded,
                          color: AppTheme.primary, size: 32),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // Course details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Payment Status
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
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isPaid
                              ? AppTheme.success
                              : isPending
                                  ? Colors.orange.shade800
                                  : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Enrollment Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: enrollment.status.toLowerCase() == 'active'
                            ? AppTheme.primary.withValues(alpha: 0.1)
                            : AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        enrollment.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: enrollment.status.toLowerCase() == 'active'
                              ? AppTheme.primary
                              : AppTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  enrollment.course.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Enrolled on ${_formatDate(enrollment.enrolledAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressCard(Enrollment enrollment) {
    final double fraction = enrollment.progressPercent / 100.0;
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enrollment Progress',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 10,
                    backgroundColor: AppTheme.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fraction >= 0.8 ? AppTheme.success : AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${enrollment.progressPercent.toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fraction >= 1.0
                ? 'Congratulations! You have completed this course.'
                : 'Keep learning to complete the remaining modules.',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusList(
    List<dynamic> modules,
    Enrollment enrollment,
  ) {
    final lessonProgress = enrollment.lessonProgress;
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Course Modules & Lessons',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final module = modules[index];
              final String moduleTitle =
                  module['title']?.toString() ?? 'Module ${index + 1}';
              final String description = module['description']?.toString() ?? '';
              final List lessonsList = module['lessons'] as List? ?? [];

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      moduleTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    subtitle: lessonsList.isNotEmpty
                        ? Text(
                            '${lessonsList.length} topics',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textLight,
                            ),
                          )
                        : null,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.topLeft,
                    children: [
                      if (description.isNotEmpty) ...[
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMedium,
                            height: 1.4,
                          ),
                        ),
                        if (lessonsList.isNotEmpty) const SizedBox(height: 12),
                      ],
                      if (lessonsList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: lessonsList.map((lesson) {
                            final int lessonId = lesson['id'] ?? 0;
                            final String title = lesson['title']?.toString() ?? '';
                            
                            // Find matching progress
                            final matchedProgress = lessonProgress.firstWhereOrNull(
                              (p) => p.lessonId == lessonId,
                            );
                            
                            final status = (matchedProgress?.status ?? 'not_started').toLowerCase();
                            final isCompleted = status == 'completed';
                            final isAttended = status == 'attended';

                            // Style choices
                            IconData statusIcon = Icons.circle_outlined;
                            Color statusColor = AppTheme.textLight;
                            String statusLabel = 'Not Started';

                            if (isCompleted) {
                              statusIcon = Icons.check_circle_rounded;
                              statusColor = AppTheme.success;
                              statusLabel = 'Completed';
                            } else if (isAttended) {
                              statusIcon = Icons.play_circle_filled_rounded;
                              statusColor = AppTheme.primary;
                              statusLabel = 'Attended';
                            }

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LessonDetailScreen(
                                      lesson: Map<String, dynamic>.from(lesson),
                                      enrollment: enrollment,
                                      progress: matchedProgress,
                                      detailController: _detailController,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        statusIcon,
                                        size: 18,
                                        color: statusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isCompleted || isAttended
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isCompleted
                                                  ? AppTheme.textMedium
                                                  : AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isCompleted && matchedProgress?.completedAt != null
                                                ? 'Completed on: ${_formatDateTime(matchedProgress!.completedAt!)}'
                                                : isAttended && matchedProgress?.attendedAt != null
                                                    ? 'Attended on: ${_formatDateTime(matchedProgress!.attendedAt!)}'
                                                    : statusLabel,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 20,
                                        color: AppTheme.primary,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LessonDetailScreen(
                                              lesson: Map<String, dynamic>.from(lesson),
                                              enrollment: enrollment,
                                              progress: matchedProgress,
                                              detailController: _detailController,
                                            ),
                                          ),
                                        );
                                      },
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }



  String _formatClassType(String? type) {
    if (type == null) return 'Class';
    switch (type.toLowerCase()) {
      case 'online_video':
        return 'Online Video';
      case 'offline_class':
        return 'Offline Class';
      case 'practical':
        return 'Practical';
      default:
        return type.replaceAll('_', ' ').capitalizeFirst ?? type;
    }
  }

  IconData _getClassTypeIcon(String? type) {
    if (type == null) return Icons.class_outlined;
    switch (type.toLowerCase()) {
      case 'online_video':
        return Icons.play_circle_outline_rounded;
      case 'offline_class':
        return Icons.school_outlined;
      case 'practical':
        return Icons.science_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  Widget _buildCertificateCard(Enrollment enrollment) {
    final bool isUnlocked = enrollment.completedAt != null &&
        enrollment.completedAt!.isNotEmpty &&
        enrollment.certificate != null;

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Certificate',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Base Card Content
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isUnlocked 
                          ? Colors.amber.shade400 
                          : AppTheme.divider,
                      width: 1.5,
                    ),
                    color: isUnlocked 
                        ? Colors.amber.shade50.withValues(alpha: 0.2) 
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: isUnlocked ? Colors.amber.shade700 : AppTheme.textLight,
                            size: 44,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isUnlocked ? 'Course Completed!' : 'Certificate Locked',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isUnlocked ? Colors.amber.shade900 : AppTheme.textMedium,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isUnlocked
                                      ? 'Your official course certificate is ready to download.'
                                      : 'Achieve 100% course completion progress to unlock your verified certificate.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: isUnlocked ? Colors.amber.shade800 : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isUnlocked) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchUrl(enrollment.certificate!.url),
                                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                label: const Text('Download'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showCertificateDetailsSheet(context, enrollment.certificate!),
                                icon: const Icon(Icons.verified_user_outlined, size: 18),
                                label: const Text('View Details'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: const BorderSide(color: AppTheme.primary, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Lock Overlay if not unlocked
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Complete Course to Unlock',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(url);
      }
      if (!launched) {
        Get.snackbar(
          'Error',
          'Could not open link in browser.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
      try {
        final Uri url = Uri.parse(urlString);
        await launchUrl(url);
      } catch (fallbackError) {
        Get.snackbar(
          'Error',
          'Failed to open link: $fallbackError',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  void _showCertificateDetailsSheet(BuildContext context, EnrollmentCertificate certificate) {
    _detailController.fetchCertificateDetail(certificate.code);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Certificate Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppTheme.divider),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (_detailController.isFetchingCertificate.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        ),
                      );
                    }

                    final detail = _detailController.certificateDetail.value;
                    if (detail == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                              const SizedBox(height: 12),
                              const Text(
                                'Failed to load details',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => _detailController.fetchCertificateDetail(certificate.code),
                                child: const Text('Retry'),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (detail.verified)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified_rounded, color: Colors.green.shade700, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Verified Certificate',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'This is a dynamically verified, secure learning credential.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Verification Pending',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'This certificate verification is not yet completed on the server.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        _buildVerificationRow('Course Name', detail.course.title),
                        const SizedBox(height: 14),
                        _buildVerificationRow('Recipient', detail.student.name),
                        const SizedBox(height: 14),
                        _buildVerificationRow('Recipient Email', detail.student.email),
                        const SizedBox(height: 14),
                        _buildVerificationRow('Issued On', _formatDate(detail.issuedAt)),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: AppTheme.divider),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            border: Border.all(color: AppTheme.divider),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Certificate Code',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMedium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      detail.certificateCode,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: detail.certificateCode));
                                  Get.snackbar(
                                    'Copied!',
                                    'Certificate code copied to clipboard.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: AppTheme.success,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(12),
                                    borderRadius: 12,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Close'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.textMedium,
                                  side: const BorderSide(color: AppTheme.divider, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _launchUrl(certificate.url);
                                },
                                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                label: const Text('Open Online'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfoCard(Enrollment enrollment) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Name', enrollment.user.name),
          const SizedBox(height: 8),
          _buildInfoRow('Email', enrollment.user.email),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(Enrollment enrollment) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enrollment & Payment Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Amount Paid', '₹${enrollment.amountPaid.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildInfoRow('Payment Status', enrollment.paymentStatus.toUpperCase()),
          const SizedBox(height: 8),
          _buildInfoRow('Enrollment Date', _formatDate(enrollment.enrolledAt)),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Completion Date',
            enrollment.completedAt != null && enrollment.completedAt!.isNotEmpty
                ? _formatDate(enrollment.completedAt!)
                : 'In Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRawLessonProgressList(Enrollment enrollment) {
    final lessonProgress = enrollment.lessonProgress;
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lesson Progress Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (lessonProgress.isEmpty)
            const Text(
              'No lesson progress records found.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lessonProgress.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.divider),
              itemBuilder: (context, index) {
                final progress = lessonProgress[index];
                
                final status = progress.status.toLowerCase();
                final isCompleted = status == 'completed';
                final isAttended = status == 'attended';

                IconData statusIcon = Icons.circle_outlined;
                Color statusColor = AppTheme.textLight;
                String statusLabel = 'Not Started';

                if (isCompleted) {
                  statusIcon = Icons.check_circle_rounded;
                  statusColor = AppTheme.success;
                  statusLabel = 'Completed';
                } else if (isAttended) {
                  statusIcon = Icons.play_circle_filled_rounded;
                  statusColor = AppTheme.primary;
                  statusLabel = 'Attended';
                }

                return InkWell(
                  onTap: _detailController.isUpdatingProgress.value
                      ? null
                      : () {
                          final nextStatus = isCompleted ? 'not_started' : 'completed';
                          _detailController.updateProgress(
                            enrollment.id,
                            progress.lessonId,
                            nextStatus,
                          );
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lesson ID: #${progress.lessonId}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              if (isCompleted && progress.completedAt != null)
                                Text(
                                  'Completed on: ${_formatDateTime(progress.completedAt!)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textLight,
                                  ),
                                )
                              else if (isAttended && progress.attendedAt != null)
                                Text(
                                  'Attended on: ${_formatDateTime(progress.attendedAt!)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final minutesStr = dt.minute.toString().padLeft(2, '0');
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minutesStr $amPm';
    } catch (_) {
      return dateStr;
    }
  }
}
