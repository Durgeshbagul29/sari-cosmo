import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/shop/controllers/product_category_controller.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final Set<String> initialSelectedCategories;
  final String initialSortOption;
  final Function(Set<String> selectedCategories, String sortOption) onApply;

  const ProductFilterBottomSheet({
    super.key,
    required this.initialSelectedCategories,
    required this.initialSortOption,
    required this.onApply,
  });

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late Set<String> _tempCategories;
  late String _tempSort;
  final ProductCategoryController _categoryController =
      Get.find<ProductCategoryController>();

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Categories',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(
                          _tempCategories.isEmpty
                              ? 'All products'
                              : '${_tempCategories.length} selected',
                          style: const TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pick one or more categories to narrow the product list.',
                      style: TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (_categoryController.isLoading.value &&
                          _categoryController.categories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                            ),
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
                          final isSelected = _tempCategories.contains(category.slug);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _tempCategories.remove(category.slug);
                                  } else {
                                    _tempCategories.add(category.slug);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary.withOpacity(0.08)
                                      : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.divider,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.category_outlined,
                                        color: AppTheme.primary.withOpacity(0.8),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (category.description.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              category.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textMedium,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${category.productsCount} products',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          color: isSelected
                                              ? AppTheme.primary
                                              : AppTheme.textLight,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
