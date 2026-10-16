import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/home/widgets/product_card.dart';
import 'package:saris_cosmo_center/features/courses/screens/course/widgets/course_list_card.dart';
import 'package:saris_cosmo_center/features/shop/models/product_model.dart';
import 'package:saris_cosmo_center/features/courses/models/course_model.dart';
import 'package:saris_cosmo_center/features/appointments/models/service_model.dart';
import 'package:saris_cosmo_center/features/appointments/screens/appointments_screen.dart';

class SearchResultsSection extends StatelessWidget {
  final List<Product> products;
  final List<Course> courses;
  final List<ServiceModel> services;

  const SearchResultsSection({
    super.key,
    required this.products,
    required this.courses,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Products (${products.length})'),
            Tab(text: 'Courses (${courses.length})'),
            Tab(text: 'Services (${services.length})'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildProductsGrid(context, products),
              _buildCoursesList(context, courses),
              _buildServicesList(context, services),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(BuildContext context, List<Product> productsList) {
    if (productsList.isEmpty) return _buildEmptyState('No products found');
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: productsList.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: productsList[index],
          margin: const EdgeInsets.only(bottom: 12),
        );
      },
    );
  }

  Widget _buildCoursesList(BuildContext context, List<Course> coursesList) {
    if (coursesList.isEmpty) return _buildEmptyState('No courses found');
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: coursesList.length,
      itemBuilder: (context, index) {
        return CourseListCard(course: coursesList[index]);
      },
    );
  }

  Widget _buildServicesList(BuildContext context, List<ServiceModel> servicesList) {
    if (servicesList.isEmpty) return _buildEmptyState('No services found');
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: servicesList.length,
      itemBuilder: (context, index) {
        return ServiceCard(service: servicesList[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textLight.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppTheme.textLight, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
