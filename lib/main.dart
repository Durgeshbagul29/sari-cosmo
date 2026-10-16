import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/services/firebase_notification_service.dart';
import 'package:saris_cosmo_center/features/home/home_screen.dart';
import 'package:saris_cosmo_center/features/courses/screens/course/courses_screen.dart';
import 'package:saris_cosmo_center/features/appointments/screens/appointments_screen.dart';
import 'package:saris_cosmo_center/features/profile/profile_screen.dart';
import 'package:saris_cosmo_center/features/onboarding/onboarding_screen.dart';
import 'package:saris_cosmo_center/features/auth/login_screen.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/features/shop/screens/products/products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saris_cosmo_center/core/controllers/network_controller.dart';
import 'package:saris_cosmo_center/features/shop/controllers/product_controller.dart';
import 'package:saris_cosmo_center/features/shop/controllers/product_filter_controller.dart';
import 'package:saris_cosmo_center/features/shop/controllers/cart_controller.dart';
import 'package:saris_cosmo_center/features/shop/controllers/product_category_controller.dart';
import 'package:saris_cosmo_center/features/courses/controllers/course_filter_controller.dart';
import 'package:saris_cosmo_center/features/appointments/controllers/appointment_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase and FCM Messaging
  try {
    await Firebase.initializeApp();
    debugPrint("🔔 FCM Trace: Firebase initialized successfully in main()");
    await FirebaseNotificationService.instance.initialize();
  } catch (e) {
    debugPrint("🔔 FCM Trace: Failed to initialize Firebase: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  final isLoggedIn = prefs.getString('auth_token') != null;

  // Register device token on launch if logged in
  if (isLoggedIn) {
    try {
      await FirebaseNotificationService.instance.registerDeviceToken();
    } catch (e) {
      debugPrint("🔔 FCM Trace: Failed to register device token on launch: $e");
    }
  }

  runApp(
    IICTNApp(onboardingComplete: onboardingComplete, isLoggedIn: isLoggedIn),
  );
}

class IICTNApp extends StatelessWidget {
  final bool onboardingComplete;
  final bool isLoggedIn;
  const IICTNApp({
    super.key,
    required this.onboardingComplete,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize Controllers
    Get.put(NetworkController(), permanent: true);
    Get.put(ProductController(), permanent: true);
    Get.put(ProductFilterController(), permanent: true);
    Get.put(ProductCategoryController(), permanent: true);
    Get.put(CourseFilterController(), permanent: true);
    Get.put(CartController(), permanent: true);

    Widget homeScreen;
    if (!onboardingComplete) {
      homeScreen = const OnboardingScreen();
    } else if (isLoggedIn) {
      homeScreen = const MainNavigation();
    } else {
      homeScreen = const LoginScreen();
    }

    return GetMaterialApp(
      title: 'Saris Cosmo Center',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      home: homeScreen,
    );
  }
}

class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    if (Get.isRegistered<ProductFilterController>()) {
      final filterController = Get.find<ProductFilterController>();
      if (currentIndex.value == 1 && index != 1) {
        filterController.reset();
      }
    }
    if (Get.isRegistered<CourseFilterController>()) {
      final courseFilterController = Get.find<CourseFilterController>();
      if (currentIndex.value == 2 && index != 2) {
        courseFilterController.reset();
      }
    }
    if (Get.isRegistered<AppointmentController>()) {
      final appointmentController = Get.find<AppointmentController>();
      if (currentIndex.value == 3 && index != 3) {
        appointmentController.resetFilters();
      }
    }

    currentIndex.value = index;
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final NavigationController _navController = Get.put(NavigationController());

  final _screens = const [
    HomeScreen(),
    ProductsScreen(),
    CoursesScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Ensure core controllers are registered (handles re-login after logout deletion)
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController(), permanent: true);
    }
    if (!Get.isRegistered<ProductFilterController>()) {
      Get.put(ProductFilterController(), permanent: true);
    }
    if (!Get.isRegistered<ProductCategoryController>()) {
      Get.put(ProductCategoryController(), permanent: true);
    }
    if (!Get.isRegistered<CourseFilterController>()) {
      Get.put(CourseFilterController(), permanent: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseNotificationService.instance.processInitialNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: IndexedStack(index: _navController.currentIndex.value, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _navItem(
                  1,
                  Icons.shopping_bag_rounded,
                  Icons.shopping_bag_outlined,
                  'Shop',
                ),
                _navItem(
                  2,
                  Icons.school_rounded,
                  Icons.school_outlined,
                  'Courses',
                ),
                _navItem(
                  3,
                  Icons.calendar_month_rounded,
                  Icons.calendar_month_outlined,
                  'Book',
                ),
                _navItem(
                  4,
                  Icons.person_rounded,
                  Icons.person_outlined,
                  'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _navItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isActive = _navController.currentIndex.value == index;
    return GestureDetector(
      onTap: () {
        _navController.changeIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppTheme.primary : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppTheme.primary : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
