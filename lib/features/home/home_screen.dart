import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:saris_cosmo_center/features/home/widgets/home_banner_section.dart';
import 'package:saris_cosmo_center/features/home/widgets/quick_actions_section.dart';
import 'package:saris_cosmo_center/features/home/widgets/product_card.dart';
import 'package:saris_cosmo_center/features/home/widgets/course_card.dart';
import 'package:saris_cosmo_center/features/home/widgets/expert_chip.dart';
import 'package:saris_cosmo_center/features/search/search_screen.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/main.dart';
import 'package:saris_cosmo_center/features/appointments/screens/appointments_screen.dart';
import 'package:saris_cosmo_center/features/appointments/screens/experts_screen.dart';
import 'package:saris_cosmo_center/features/shop/controllers/cart_controller.dart';
import 'package:saris_cosmo_center/features/shop/controllers/product_controller.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_controller.dart';
import 'package:saris_cosmo_center/features/appointments/controllers/appointment_controller.dart';
import 'package:saris_cosmo_center/features/shop/screens/cart/cart_screen.dart';
import 'package:saris_cosmo_center/features/profile/notifications_screen.dart';
import 'package:saris_cosmo_center/features/profile/controllers/notification_controller.dart';
import 'package:saris_cosmo_center/features/address/controllers/address_controller.dart';
import 'package:saris_cosmo_center/features/address/saved_addresses_screen.dart';
import 'package:saris_cosmo_center/core/widgets/bubble_loading_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          final addressController = Get.put(AddressController());
          final productController = Get.put(ProductController());
          final courseController = Get.put(CourseController());
          final appointmentController = Get.put(AppointmentController());
          final notificationController = Get.put(NotificationController());

          await Future.wait([
            addressController.fetchAddresses(),
            productController.fetchProducts(isRefresh: true),
            courseController.fetchCourses(isRefresh: true),
            appointmentController.fetchExperts(isRefresh: true),
            appointmentController.fetchServices(),
            notificationController.fetchUnreadCount(),
          ]);
        },
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.primary,
              expandedHeight: 122.0,
              toolbarHeight:
                  0, // Hide the default toolbar so we don't get extra space
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildTopHeader(context),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildSearchBar(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const QuickActionsSection(),
                  const SizedBox(height: 16),
                  const HomeBannerSection(),
                  const SizedBox(height: 24),
                  _buildFeaturedProducts(),
                  const SizedBox(height: 16),
                  _buildFeaturedCourses(),
                  const SizedBox(height: 16),
                  _buildExperts(),
                  const SizedBox(height: 16),
                  _buildFeaturedServices(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final addressController = Get.put(AddressController());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          final isLoading = addressController.isLoading.value;
          final hasAddress = addressController.addresses.isNotEmpty;

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoading
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: BubbleLoadingIndicator(color: Colors.white),
                      )
                    : hasAddress
                        ? GestureDetector(
                            onTap: () {
                              debugPrint('🔔 Home Trace: Opening SavedAddressesScreen');
                              Get.to(() => const SavedAddressesScreen());
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'Delivery to',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                                (() {
                                  final defaultAddress = addressController.addresses.firstWhereOrNull((e) => e.isDefault == true) ??
                                      addressController.addresses.first;
                                  
                                  String displayAddress = 'Mumbai, Maharashtra';
                                  final city = defaultAddress.city ?? '';
                                  final state = defaultAddress.state ?? '';
                                  if (city.isNotEmpty && state.isNotEmpty) {
                                    displayAddress = '$city, $state';
                                  } else if (city.isNotEmpty) {
                                    displayAddress = city;
                                  } else if (state.isNotEmpty) {
                                    displayAddress = state;
                                  }
                                  
                                  return Text(
                                    displayAddress,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                })(),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              Get.to(() => const SavedAddressesScreen());
                            },
                            behavior: HitTestBehavior.opaque,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery to',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Add Address',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
              Row(
                children: [
                  // Cart Icon
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Obx(() {
                          final cartController = Get.find<CartController>();
                          if (cartController.itemCount == 0)
                            return const SizedBox.shrink();
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '${cartController.itemCount}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification Icon
                  GestureDetector(
                    onTap: () {
                      debugPrint('🔔 Notification Tap: Opening Notifications Screen');
                      Get.to(() => const NotificationsScreen());
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Obx(() {
                          final notificationController = Get.put(NotificationController());
                          final unread = notificationController.unreadCount.value;
                          if (unread == 0) return const SizedBox.shrink();
                          return Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.textLight, size: 22),
            SizedBox(width: 10),
            Text(
              'Search products, courses...',
              style: TextStyle(color: AppTheme.textLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Obx(() {
      final pc = Get.find<ProductController>();
      final isLoading = pc.isLoading.value;
      final displayProducts = pc.products.take(6).toList();

      if (!isLoading && displayProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Bestselling Products',
            subtitle: 'Highly recommended by experts',
            onSeeAll: () => Get.find<NavigationController>().changeIndex(1),
          ),
          isLoading
              ? SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    itemBuilder: (ctx, i) => const ProductCardShimmer(),
                  ),
                )
              : SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayProducts.length,
                    itemBuilder: (ctx, i) => ProductCard(product: displayProducts[i]),
                  ),
                ),
        ],
      );
    });
  }

  Widget _buildFeaturedCourses() {
    return Obx(() {
      final cc = Get.put(CourseController());
      final isLoading = cc.isLoading.value;
      final displayCourses = cc.courses.take(5).toList();

      if (!isLoading && displayCourses.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Top Courses',
            subtitle: 'Learn skills from top educators',
            onSeeAll: () => Get.find<NavigationController>().changeIndex(2),
          ),
          isLoading
              ? SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    itemBuilder: (ctx, i) => const CourseCardShimmer(),
                  ),
                )
              : SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayCourses.length,
                    itemBuilder: (ctx, i) => CourseCard(course: displayCourses[i]),
                  ),
                ),
        ],
      );
    });
  }

  Widget _buildExperts() {
    return Obx(() {
      final ac = Get.put(AppointmentController());
      final isLoading = ac.isLoadingExperts.value;
      final displayExperts = ac.expertsList.toList();

      if (!isLoading && displayExperts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Consult Experts',
            subtitle: 'Book sessions easily',
            onSeeAll: () => Get.to(() => const ExpertsScreen()),
          ),
          isLoading
              ? SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    itemBuilder: (ctx, i) => const ExpertChipShimmer(),
                  ),
                )
              : SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayExperts.length,
                    itemBuilder: (ctx, i) => ExpertChip(expert: displayExperts[i]),
                  ),
                ),
        ],
      );
    });
  }

  Widget _buildFeaturedServices() {
    return Obx(() {
      final ac = Get.put(AppointmentController());
      final isLoading = ac.isLoadingServices.value;
      final displayServices = ac.services.take(4).toList();

      if (!isLoading && displayServices.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Our Services',
            subtitle: 'Premium wellness & styling sessions',
            onSeeAll: () => Get.find<NavigationController>().changeIndex(3),
          ),
          isLoading
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (ctx, i) => const ServiceCardShimmer(),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayServices.length,
                  itemBuilder: (ctx, i) => ServiceCard(service: displayServices[i]),
                ),
        ],
      );
    });
  }
}
