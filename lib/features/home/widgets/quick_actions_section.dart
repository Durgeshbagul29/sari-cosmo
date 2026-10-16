import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/features/courses/screens/course/courses_screen.dart';
import 'package:saris_cosmo_center/features/appointments/screens/appointments_screen.dart';
import 'package:saris_cosmo_center/features/shop/screens/products/products_screen.dart';
import 'package:saris_cosmo_center/features/profile/wishlist_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  static const _quickActions = [
    {
      'icon': Icons.shopping_bag_rounded,
      'label': 'Shop',
      'color': Color(0xFF16A085),
    },
    {
      'icon': Icons.school_rounded,
      'label': 'Courses',
      'color': Color(0xFF8E44AD),
    },
    {
      'icon': Icons.calendar_month_rounded,
      'label': 'Book',
      'color': Color(0xFF2980B9),
    },
    {
      'icon': Icons.favorite_rounded,
      'label': 'Wishlist',
      'color': Color(0xFFE74C3C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _quickActions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (a['label'] == 'Shop') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()),
                  );
                } else if (a['label'] == 'Courses') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoursesScreen()),
                  );
                } else if (a['label'] == 'Book') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                  );
                } else if (a['label'] == 'Wishlist') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (a['color'] as Color).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: a['color'] as Color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
