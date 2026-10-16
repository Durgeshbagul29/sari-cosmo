import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';
import 'package:saris_cosmo_center/features/courses/screens/course_detail/course_detail_screen.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_filter_controller.dart';

// ─── Course List Card ────────────────────────────────────────────────────────

class CourseListCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseListCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    void defaultOnTap() {
      Get.find<CourseFilterController>().reset();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
      );
    }
    final tap = onTap ?? defaultOnTap;

    return GestureDetector(
      onTap: tap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardImage(course: course),
              _CardBody(course: course, onTap: tap),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Image section ───────────────────────────────────────────────────────────

class _CardImage extends StatelessWidget {
  final Course course;
  const _CardImage({required this.course});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Thumbnail
        SizedBox(
          height: 160,
          width: double.infinity,
          child: course.imageUrl != null && course.imageUrl!.isNotEmpty
              ? NetworkImageWidget(
                  url: course.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  borderRadius: BorderRadius.zero,
                )
              : ColoredBox(
                  color: AppTheme.primary.withOpacity(0.06),
                  child: Center(
                    child: Icon(
                      Icons.school_rounded,
                      size: 56,
                      color: AppTheme.primary.withOpacity(0.25),
                    ),
                  ),
                ),
        ),

        // Bottom Gradient Overlay for Badge Readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.45),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Category Badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              course.category.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),

        // Free badge
        if (course.isFree)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.success,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Text(
                'FREE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),

        // Lessons pill
        if (course.lessons > 0)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${course.lessons} Lessons',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Duration Pill
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  course.duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Body section ────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const _CardBody({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            course.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Instructor info
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1),
                ),
                child: Center(
                  child: Text(
                    course.instructor.name.isNotEmpty
                        ? course.instructor.name[0].toUpperCase()
                        : 'I',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructor',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      course.instructor.name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 0.5, color: AppTheme.divider),
          ),

          // Price + CTA button
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Fee',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  course.isFree
                      ? const Text(
                          'Free',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.success,
                          ),
                        )
                      : Text(
                          '₹${course.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                ],
              ),
              const Spacer(),
              _EnrollButton(onTap: onTap),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Enroll Button ───────────────────────────────────────────────────────────

class _EnrollButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EnrollButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer Loading Card ─────────────────────────────────────────────────────

class CourseListCardShimmer extends StatefulWidget {
  const CourseListCardShimmer({super.key});

  @override
  State<CourseListCardShimmer> createState() => _CourseListCardShimmerState();
}

class _CourseListCardShimmerState extends State<CourseListCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider.withOpacity(0.4), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              _ShimmerBox(
                height: 160,
                width: double.infinity,
                borderRadius: 0,
                gradient: _buildGradient(context),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton lines
                    _ShimmerBox(
                      height: 16,
                      width: double.infinity,
                      borderRadius: 4,
                      gradient: _buildGradient(context),
                    ),
                    const SizedBox(height: 6),
                    _ShimmerBox(
                      height: 16,
                      width: 200,
                      borderRadius: 4,
                      gradient: _buildGradient(context),
                    ),
                    const SizedBox(height: 16),

                    // Instructor skeleton
                    Row(
                      children: [
                        _ShimmerBox(
                          height: 28,
                          width: 28,
                          borderRadius: 14,
                          gradient: _buildGradient(context),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerBox(
                              height: 10,
                              width: 60,
                              borderRadius: 2,
                              gradient: _buildGradient(context),
                            ),
                            const SizedBox(height: 4),
                            _ShimmerBox(
                              height: 12,
                              width: 120,
                              borderRadius: 3,
                              gradient: _buildGradient(context),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, thickness: 0.5, color: AppTheme.divider),
                    ),

                    // Bottom Row skeleton
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerBox(
                              height: 10,
                              width: 50,
                              borderRadius: 2,
                              gradient: _buildGradient(context),
                            ),
                            const SizedBox(height: 4),
                            _ShimmerBox(
                              height: 18,
                              width: 70,
                              borderRadius: 4,
                              gradient: _buildGradient(context),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _ShimmerBox(
                          height: 38,
                          width: 110,
                          borderRadius: 12,
                          gradient: _buildGradient(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _buildGradient(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.06);
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.12);

    return LinearGradient(
      begin: Alignment(_animation.value - 1, 0),
      end: Alignment(_animation.value + 1, 0),
      colors: [base, highlight, base],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final LinearGradient gradient;

  const _ShimmerBox({
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
