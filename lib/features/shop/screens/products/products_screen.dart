import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/search/search_screen.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/product_filter_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../cart/cart_screen.dart';
import 'widgets/product_grid_card.dart';
import 'widgets/product_list_card.dart';
import 'widgets/product_filter_bottom_sheet.dart';
import '../../../home/widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final ProductFilterController _filterController =
      Get.find<ProductFilterController>();
  final ScrollController _scrollController = ScrollController();

  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _productController.fetchProducts();
    }
  }

  List<Product> get _filtered {
    List<Product> items = _productController.products.toList();
    if (_filterController.selectedCategories.isNotEmpty) {
      items = items
          .where((p) => _filterController.selectedCategories.contains(p.categorySlug))
          .toList();
    }
    if (_filterController.sortOption.value == 'Price: Low to High') {
      items.sort((a, b) => a.price.compareTo(b.price));
    } else if (_filterController.sortOption.value == 'Price: High to Low') {
      items.sort((a, b) => b.price.compareTo(a.price));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Products',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              _filterController.reset();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: Icon(_isGridView
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSortBottomSheet,
          ),
          Stack(alignment: Alignment.topRight, children: [
            IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  _filterController.reset();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen()));
                }),
            Obx(() {
              final cartController = Get.find<CartController>();
              if (cartController.itemCount == 0) return const SizedBox.shrink();
              return Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: AppTheme.primary, shape: BoxShape.circle),
                    child: Center(
                        child: Text('${cartController.itemCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold))),
                  ));
            }),
          ]),
        ],
      ),
      body: Obx(() {
        final filtered = _filtered;
        final isLoading = _productController.isLoading.value;

        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () => _productController.fetchProducts(isRefresh: true),
          child: filtered.isEmpty
              ? (isLoading
                  ? (_isGridView
                      ? GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.58),
                          itemCount: 6,
                          itemBuilder: (ctx, i) => const ProductCardShimmer(
                            width: double.infinity,
                            margin: EdgeInsets.zero,
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: 6,
                          itemBuilder: (ctx, i) => const ProductCardShimmer(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12),
                          ),
                        ))
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(
                            child: Text('No products found',
                                style: TextStyle(color: AppTheme.textMedium)),
                          ),
                        ),
                      ],
                    ))
              : Column(
                  children: [
                    Expanded(
                      child: _isGridView
                          ? GridView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.58),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) => ProductGridCard(product: filtered[i]),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) => ProductListCard(product: filtered[i]),
                            ),
                    ),
                    if (_productController.isPaginating.value)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Center(
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        ),
                      ),
                  ],
                ),
        );
      }),
    );
  }

  void _showFilterSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductFilterBottomSheet(
        initialSelectedCategories: _filterController.selectedCategories.toSet(),
        initialSortOption: _filterController.sortOption.value,
        onApply: (selectedCategories, sortOption) {
          setState(() {
            _filterController.applyFilters(selectedCategories, sortOption);
          });
        },
      ),
    );
  }
}
