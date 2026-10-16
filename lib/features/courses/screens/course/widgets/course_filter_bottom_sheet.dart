import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_category_controller.dart';

class CourseFilterBottomSheet extends StatefulWidget {
  final Set<String> initialSelectedCategories;
  final String initialSortOption;
  final Function(Set<String> selectedCategories, String sortOption) onApply;

  const CourseFilterBottomSheet({
    super.key,
    required this.initialSelectedCategories,
    required this.initialSortOption,
    required this.onApply,
  });

  @override
  State<CourseFilterBottomSheet> createState() => _CourseFilterBottomSheetState();
}

class _CourseFilterBottomSheetState extends State<CourseFilterBottomSheet> {
  late Set<String> _tempCategories;
  late String _tempSort;
  final CourseCategoryController _categoryController = Get.find<CourseCategoryController>();

  @override
  void initState() {
    super.initState();
    _tempCategories = Set.from(widget.initialSelectedCategories);
    _tempSort = widget.initialSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter & Sort',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sort By',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...[
                      'Relevance',
                      'Price: Low to High',
                      'Price: High to Low'
                    ].map((option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _tempSort,
                          onChanged: (val) =>
                              setState(() => _tempSort = val!),
                          activeColor: AppTheme.primary,
                          contentPadding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(
                              horizontal: -4, vertical: -4),
                        )),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: AppTheme.divider),
                    const SizedBox(height: 24),
                    const Text('Categories',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (_categoryController.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(color: AppTheme.primary),
                          ),
                        );
                      }

                      if (_categoryController.categories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'No categories available',
                            style: TextStyle(color: AppTheme.textMedium),
                          ),
                        );
                      }

                      return Column(
                        children: _categoryController.categories.map((category) {
                          final categoryName = category.name;
                          return CheckboxListTile(
                            title: Text(categoryName),
                            value: _tempCategories.contains(categoryName),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _tempCategories.add(categoryName);
                                } else {
                                  _tempCategories.remove(categoryName);
                                }
                              });
                            },
                            activeColor: AppTheme.primary,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppTheme.surface, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ]),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _tempCategories.clear();
                            _tempSort = 'Relevance';
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(_tempCategories, _tempSort);
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
