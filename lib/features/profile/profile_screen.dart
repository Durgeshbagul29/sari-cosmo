import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/features/auth/controllers/auth_controller.dart';
import 'package:saris_cosmo_center/features/profile/controllers/profile_controller.dart';
import 'package:saris_cosmo_center/features/profile/profile_update_screen.dart';
import 'package:saris_cosmo_center/features/shop/screens/order/my_orders_screen.dart';
import 'package:saris_cosmo_center/features/courses/screens/my_courses/my_courses_screen.dart';
import 'package:saris_cosmo_center/features/profile/my_appointments_screen.dart';
import 'package:saris_cosmo_center/features/profile/wishlist_screen.dart';
import 'package:saris_cosmo_center/features/profile/refer_earn_screen.dart';
import 'package:saris_cosmo_center/features/shop/screens/coupon/my_coupons_screen.dart';
import 'package:saris_cosmo_center/features/profile/notifications_screen.dart';
import 'package:saris_cosmo_center/features/profile/privacy_security_screen.dart';
import 'package:saris_cosmo_center/features/shop/controllers/wishlist_controller.dart';
import 'package:saris_cosmo_center/features/profile/help_support_screen.dart';
import 'package:saris_cosmo_center/features/profile/about_screen.dart';
import 'package:saris_cosmo_center/features/address/saved_addresses_screen.dart';
import 'package:saris_cosmo_center/features/address/controllers/address_controller.dart';
import 'package:saris_cosmo_center/features/shop/controllers/coupon_controller.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());
  final AddressController addressController = Get.put(AddressController());
  final CouponController couponController = Get.put(CouponController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchAllData();
      addressController.fetchAddresses();
      couponController.fetchCoupons();
    });
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
      profileController.fetchAllData();
      addressController.fetchAddresses();
      couponController.fetchCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: Obx(() {
        final data = profileController.dashboardData.value;
        final isLoading = profileController.isLoading.value;
        final hasLoaded = profileController.hasLoaded.value;

        if (isLoading && !hasLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        return RefreshIndicator(
          onRefresh: () => profileController.fetchAllData(),
          color: AppTheme.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildHeader(context, profileController),
              _buildStats(data),
              const SizedBox(height: 8),
              _buildSection('My Activity', [
                _menuItem(
                    Icons.shopping_bag_outlined,
                    'My Orders',
                    '${data.totalOrders} orders',
                    AppTheme.primary,
                    () => _navigate(context, const MyOrdersScreen())),
                _menuItem(
                    Icons.location_on_outlined,
                    'Saved Addresses',
                    '${addressController.addresses.length} addresses',
                    const Color(0xFF1ABC9C),
                    () => _navigate(context, const SavedAddressesScreen())),
                _menuItem(
                    Icons.school_outlined,
                    'My Courses',
                    '${data.enrolledCourses} enrolled',
                    const Color(0xFF8E44AD),
                    () => _navigate(context, const MyCoursesScreen())),
                _menuItem(
                    Icons.calendar_month_outlined,
                    'My Appointments',
                    '${data.appointments} bookings',
                    const Color(0xFF2980B9),
                    () => _navigate(context, const MyAppointmentsScreen())),
                Obx(() {
                  final wishlistController = Get.put(WishlistController());
                  final count = wishlistController.rxProducts.length + wishlistController.rxCourses.length;
                  return _menuItem(
                      Icons.favorite_border_rounded,
                      'Wishlist',
                      '$count items',
                      const Color(0xFFE74C3C),
                      () => _navigate(context, const WishlistScreen()));
                }),
              ]),
              _buildSection('Benefits', [
                _menuItem(
                    Icons.card_giftcard_outlined,
                    'Refer & Earn',
                    '₹200 per referral',
                    AppTheme.success,
                    () => _navigate(context, const ReferEarnScreen())),
                Obx(() {
                  final activeCount = couponController.coupons.where((c) => c.isActive).length;
                  return _menuItem(
                      Icons.local_offer_outlined,
                      'My Coupons',
                      '$activeCount active',
                      const Color(0xFFF39C12),
                      () => _navigate(context, const MyCouponsScreen()));
                }),
              ]),
              _buildSection('Account', [
                _menuItem(
                    Icons.notifications_outlined,
                    'Notifications',
                    '',
                    AppTheme.textMedium,
                    () => _navigate(context, const NotificationsScreen())),
                _menuItem(
                    Icons.lock_outline_rounded,
                    'Privacy & Security',
                    '',
                    AppTheme.textMedium,
                    () => _navigate(context, const PrivacySecurityScreen())),
                _menuItem(
                    Icons.help_outline_rounded,
                    'Help & Support',
                    '',
                    AppTheme.textMedium,
                    () => _navigate(context, const HelpSupportScreen())),
                _menuItem(
                    Icons.info_outline_rounded,
                    'About Us',
                    '',
                    AppTheme.textMedium,
                    () => _navigate(context, const AboutScreen())),
              ]),
              Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton.icon(
                  icon: authController.isLoading.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                    : const Icon(Icons.logout_rounded, color: AppTheme.primary),
                  label: Text(authController.isLoading.value ? 'Signing Out...' : 'Sign Out',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  onPressed: authController.isLoading.value ? null : () => authController.logout(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileController controller) {
    String initials = 'U';
    if (controller.userName.value.isNotEmpty) {
      final names = controller.userName.value.split(' ');
      if (names.length > 1) {
        initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        initials = names[0][0].toUpperCase();
      }
    }

    final user = controller.currentUser.value;
    final phone = user?.phone ?? '';
    final role = user?.role ?? 'IICTN Member';

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Obx(() {
          final isUpdating = controller.isProfileUpdating.value;
          final user = controller.currentUser.value;
          final currentAvatarUrl = _resolveAvatarUrl(user?.avatar);
          final localPath = controller.localAvatarPath.value;

          final hasLocalFile = localPath.isNotEmpty && File(localPath).existsSync();

          return GestureDetector(
            onTap: isUpdating ? null : () => _showImageSourceSheet(context, controller),
            child: Stack(children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: ClipOval(
                  child: hasLocalFile
                      ? Image.file(
                          File(localPath),
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        )
                      : (currentAvatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: currentAvatarUrl,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 38,
                                  color: AppTheme.primary,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            )),
                ),
              ),
              if (isUpdating)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 14),
                    )),
            ]),
          );
        }),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(controller.userName.value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Text(controller.userEmail.value,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(phone,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
              ],
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(role.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ])),
        IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => _navigate(context, const ProfileUpdateScreen())),
      ]),
    );
  }

  Widget _buildStats(dynamic data) => Container(
        color: AppTheme.surface,
        margin: const EdgeInsets.only(top: 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _stat('${data.totalOrders}', 'Orders'),
          _vDivider(),
          _stat('${data.enrolledCourses}', 'Courses'),
          _vDivider(),
          _stat('${data.appointments}', 'Appointments'),
          _vDivider(),
          _stat('₹${data.totalSpent}', 'Spent'),
        ]),
      );

  Widget _stat(String val, String label) => Column(children: [
        Text(val,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
      ]);

  Widget _vDivider() =>
      Container(height: 32, width: 1, color: AppTheme.divider);

  Widget _buildSection(String title, List<Widget> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                      letterSpacing: 0.5))),
          Container(color: AppTheme.surface, child: Column(children: items)),
        ],
      );

  Widget _menuItem(IconData icon, String title, String subtitle, Color color,
          [VoidCallback? onTap]) =>
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.primary))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppTheme.textLight, size: 20),
        onTap: onTap,
      );

  void _showImageSourceSheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
                title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickAndUploadImage(controller, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primary),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickAndUploadImage(controller, ImageSource.gallery);
                },
              ),
              if (controller.currentUser.value?.avatar != null &&
                  controller.currentUser.value!.avatar!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.removeProfileImage();
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ProfileController controller, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (file != null) {
        debugPrint('🔔 Image Picked: ${file.path}');
        await controller.uploadProfileImage(file.path);
      }
    } catch (e) {
      debugPrint('🔔 Image Pick Error: $e');
      AppSnackbar.error('Error', 'Failed to pick image: $e');
    }
  }

  String? _resolveAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final clean = path.startsWith('/') ? path.substring(1) : path;
    if (clean.startsWith('storage/')) {
      return 'https://saricosmo.abraca-dabra.com/$clean';
    }
    return 'https://saricosmo.abraca-dabra.com/storage/$clean';
  }
}
