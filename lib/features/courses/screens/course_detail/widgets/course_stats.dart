import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';

class CourseStats extends StatelessWidget {
  final Course course;

  const CourseStats({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final showLessons = course.lessons > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppTheme.divider.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context: context,
            icon: Icons.timer_rounded,
            value: course.duration,
            label: 'Duration',
            color: AppTheme.success,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context: context,
            icon: Icons.info_outline_rounded,
            value: course.status.toUpperCase(),
            label: 'Status',
            color: AppTheme.primary,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context: context,
            icon: Icons.group_rounded,
            value: course.maxStudents != null ? '${course.maxStudents}' : 'Unlimited',
            label: 'Max Seats',
            color: Colors.orange,
          ),
          if (showLessons) ...[
            _buildVerticalDivider(),
            _buildStatItem(
              context: context,
              icon: Icons.menu_book_rounded,
              value: '${course.lessons} Lessons',
              label: 'Curriculum',
              color: const Color(0xFF8E44AD),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  fontSize: 14,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 36,
      width: 1,
      color: AppTheme.divider.withOpacity(0.6),
    );
  }
}
