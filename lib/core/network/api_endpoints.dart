class ApiEndpoints {
  static const String baseUrl = 'https://saricosmo.abraca-dabra.com/api';
  
  // Auth endpoints
  static const String register = '$baseUrl/v1/register';
  static const String login = '$baseUrl/v1/login';
  static const String logout = '$baseUrl/v1/logout';
  static const String forgotPassword = '$baseUrl/v1/forgot-password';

  // Profile & User endpoints
  static const String dashboard = '$baseUrl/v1/dashboard';
  static const String profile = '$baseUrl/v1/me';
  static const String changePassword = '$baseUrl/v1/me/password';
  static const String addresses = '$baseUrl/v1/addresses';

  // Course endpoints
  static const String courses = '$baseUrl/v1/courses';
  static const String courseCategories = '$baseUrl/v1/course-categories';
  static String courseDetail(String slug) => '$baseUrl/v1/courses/$slug';
  static const String myEnrollments = '$baseUrl/v1/enrollments/my';
  static String enrollmentDetail(int enrollmentId) => '$baseUrl/v1/enrollments/$enrollmentId';
  static String enrollInCourse(int courseId) => '$baseUrl/v1/courses/$courseId/enroll';
  static const String razorpayCreateOrder = '$baseUrl/v1/razorpay/create-order';
  static String updateLessonProgress(int enrollmentId) => '$baseUrl/v1/enrollments/$enrollmentId/progress';
  static String certificateDetail(String code) => '$baseUrl/v1/certificates/$code';

  // Product endpoints
  static const String products = '$baseUrl/v1/products';
  static const String productCategories = '$baseUrl/v1/categories';
  static String productReviews(String slug) => '$baseUrl/v1/products/$slug/reviews';
  static String productDetail(String slug) => '$baseUrl/v1/products/$slug';

  // Cart endpoints
  static const String cart = '$baseUrl/v1/cart';
  static const String cartAdd = '$baseUrl/v1/cart/add';
  static String cartItem(int cartItemId) => '$baseUrl/v1/cart/items/$cartItemId';

  // Order endpoints
  static const String orders = '$baseUrl/v1/orders';
  static String orderDetail(String orderNumber) => '$baseUrl/v1/orders/$orderNumber';

  // Search endpoint
  static const String search = '$baseUrl/v1/search';

  // Coupons endpoint
  static const String availableCoupons = '$baseUrl/v1/coupons/available';
  static const String cartCoupon = '$baseUrl/v1/cart/coupon';

  // Checkout endpoints
  static const String ordersCheckout = '$baseUrl/v1/orders/checkout';
  static const String razorpayVerify = '$baseUrl/v1/razorpay/verify';

  // Cancel Order endpoint
  static String cancelOrder(int orderId) => '$baseUrl/v1/orders/$orderId/cancel';

  // Salon Services endpoints
  static const String services = '$baseUrl/v1/services';
  static String serviceDetail(String slug) => '$baseUrl/v1/services/$slug';
  static String serviceReviews(String slug) => '$baseUrl/v1/services/$slug/reviews';
  static const String serviceCategories = '$baseUrl/v1/service-categories';

  // Appointment endpoints
  static const String availableSlots = '$baseUrl/v1/time-slots/available';
  static const String appointments = '$baseUrl/v1/appointments';
  static String appointmentDetail(int id) => '$baseUrl/v1/appointments/$id';
  static String rescheduleAppointment(int id) => '$baseUrl/v1/appointments/$id/reschedule';
  static String cancelAppointment(int id) => '$baseUrl/v1/appointments/$id/cancel';
  
  // Experts endpoint
  static const String experts = '$baseUrl/v1/experts';

  // Wishlist endpoints
  static const String wishlist = '$baseUrl/v1/wishlist';
  static const String wishlistToggle = '$baseUrl/v1/wishlist/toggle';

  // Notification endpoints
  static const String fcmToken = '$baseUrl/v1/fcm-token';
  static const String notifications = '$baseUrl/v1/notifications';
  static const String unreadCount = '$baseUrl/v1/notifications/unread-count';
  static String markNotificationRead(String notificationId) => '$baseUrl/v1/notifications/$notificationId/read';
  static const String markAllNotificationsRead = '$baseUrl/v1/notifications/read-all';
}
