import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';
import 'package:saris_cosmo_center/features/courses/screens/course_detail/course_detail_screen.dart';
import 'package:saris_cosmo_center/features/home/widgets/product_card.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: course))),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider, width: 0.8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            course.imageUrl != null && course.imageUrl!.isNotEmpty
                ? NetworkImageWidget(
                    url: course.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)))
                : Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(Icons.school_rounded,
                          size: 48, color: AppTheme.primary.withOpacity(0.3)),
                    ),
                  ),
          ]),
          Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(course.instructor.name,
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textLight)),
              const SizedBox(height: 8),
              Row(children: [
                course.isFree
                    ? const BadgeChip(label: 'FREE', bg: AppTheme.success)
                    : Text('₹${course.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class CourseCardShimmer extends StatelessWidget {
  const CourseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerWidget(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerWidget(
                  width: 160,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                SizedBox(height: 6),
                ShimmerWidget(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                SizedBox(height: 8),
                ShimmerWidget(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                SizedBox(height: 12),
                ShimmerWidget(
                  width: 60,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
