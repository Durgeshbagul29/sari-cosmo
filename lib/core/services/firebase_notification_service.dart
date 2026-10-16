import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../../features/shop/screens/order/order_detail_screen.dart';
import '../../features/profile/my_appointments_screen.dart';
import '../../features/courses/screens/enrollment_detail/enrollment_detail_screen.dart';
import '../../features/profile/controllers/notification_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔔 FCM Trace: [Background Handler] Received message ID: ${message.messageId}");
  debugPrint("🔔 FCM Trace: [Background Handler] Payload Data: ${message.data}");
  if (message.notification != null) {
    debugPrint("🔔 FCM Trace: [Background Handler] Notification Title: ${message.notification!.title}");
    debugPrint("🔔 FCM Trace: [Background Handler] Notification Body: ${message.notification!.body}");
  }
}

class FirebaseNotificationService {
  static final FirebaseNotificationService instance = FirebaseNotificationService._();
  FirebaseNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  // Flag to check if initialization is complete
  bool _initialized = false;

  // Cache initial payload if app launched from terminated state
  Map<String, dynamic>? initialNotificationData;

  // High Importance Notification Channel for Android
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint("🔔 FCM Trace: Initializing Firebase Notification Service...");

    try {
      // 1. Request Permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint("🔔 FCM Trace: Permission Status: ${settings.authorizationStatus}");

      // 2. Configure Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Initialize Flutter Local Notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint("🔔 FCM Trace: [Local Notification Click] Payload: ${response.payload}");
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              handleNotificationTap(data);
            } catch (e) {
              debugPrint("🔔 FCM Trace: Error decoding local notification payload: $e");
            }
          }
        },
      );

      // Create high importance channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // 4. Setup FCM Message Listeners
      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("🔔 FCM Trace: [Foreground Message Received] Message ID: ${message.messageId}");
        debugPrint("🔔 FCM Trace: [Foreground Message Received] Data: ${message.data}");
        
        RemoteNotification? notification = message.notification;

        if (notification != null) {
          debugPrint("🔔 FCM Trace: Foreground Notification Title: ${notification.title}");
          debugPrint("🔔 FCM Trace: Foreground Notification Body: ${notification.body}");

          // Display native heads-up local notification
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
                playSound: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.data),
          );

          // Update Home Notification Badge count if screen is open or trigger unread refresh
          try {
            if (Get.isRegistered<NotificationController>()) {
              Get.find<NotificationController>().fetchUnreadCount();
              Get.find<NotificationController>().fetchNotifications();
            }
          } catch (e) {
            debugPrint("🔔 FCM Trace: NotificationController is not registered yet: $e");
          }
        }
      });

      // App opened from background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("🔔 FCM Trace: [App Opened from Background] Message ID: ${message.messageId}");
        debugPrint("🔔 FCM Trace: [App Opened from Background] Data: ${message.data}");
        handleNotificationTap(message.data);
      });

      // App opened from completely terminated state
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint("🔔 FCM Trace: [App Opened from Terminated State] Message ID: ${initialMessage.messageId}");
        debugPrint("🔔 FCM Trace: [App Opened from Terminated State] Data: ${initialMessage.data}");
        initialNotificationData = initialMessage.data;
      }

      // 5. Setup Token Refresh Listener
      _messaging.onTokenRefresh.listen((String newToken) {
        debugPrint("🔔 FCM Trace: FCM Token Refreshed: $newToken");
        _updateTokenOnServer(newToken);
      });

      _initialized = true;
      debugPrint("🔔 FCM Trace: Firebase Notification Service initialized successfully.");
    } catch (e) {
      debugPrint("🔔 FCM Trace: Failed to initialize notifications service: $e");
    }
  }

  // Get current device token
  Future<String?> getFcmToken() async {
    try {
      String? token = await _messaging.getToken();
      debugPrint("🔔 FCM Trace: Current FCM Device Token: $token");
      return token;
    } catch (e) {
      debugPrint("🔔 FCM Trace: Error getting FCM token: $e");
      return null;
    }
  }

  // Registers the token on the backend server
  Future<void> registerDeviceToken() async {
    String? token = await getFcmToken();
    if (token != null) {
      await _updateTokenOnServer(token);
    }
  }

  // Upload/register token on backend
  Future<void> _updateTokenOnServer(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      // Cache token locally
      await prefs.setString('fcm_token', fcmToken);

      if (authToken != null) {
        debugPrint("🔔 FCM Trace: Uploading FCM token to backend...");
        final response = await _apiService.registerFcmToken(authToken, fcmToken);
        debugPrint("🔔 FCM Trace: Backend Register Token Response: $response");
        
        // Remove pending token since it's successfully registered
        await prefs.remove('pending_fcm_token');
      } else {
        debugPrint("🔔 FCM Trace: User is not logged in. Caching FCM token as pending.");
        await prefs.setString('pending_fcm_token', fcmToken);
      }
    } catch (e) {
      debugPrint("🔔 FCM Trace: Failed to update FCM token on server: $e");
    }
  }

  // Check and register pending token (call after login)
  Future<void> handlePendingTokenRegistration(String authToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? pendingToken = prefs.getString('pending_fcm_token');
      if (pendingToken == null) {
        pendingToken = await getFcmToken();
      }

      if (pendingToken != null) {
        debugPrint("🔔 FCM Trace: Registering pending FCM token...");
        final response = await _apiService.registerFcmToken(authToken, pendingToken);
        debugPrint("🔔 FCM Trace: Backend Register Pending Token Response: $response");
        
        await prefs.setString('fcm_token', pendingToken);
        await prefs.remove('pending_fcm_token');
      }
    } catch (e) {
      debugPrint("🔔 FCM Trace: Error registering pending token: $e");
    }
  }

  // Remove token from backend (call on logout or when user disables notifications)
  Future<void> deleteDeviceToken(String authToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentToken = prefs.getString('fcm_token') ?? await getFcmToken();
      if (currentToken != null) {
        debugPrint("🔔 FCM Trace: Removing FCM token from backend...");
        final response = await _apiService.deleteFcmToken(authToken, currentToken);
        debugPrint("🔔 FCM Trace: Backend Delete Token Response: $response");
      }
      await prefs.remove('fcm_token');
    } catch (e) {
      debugPrint("🔔 FCM Trace: Error deleting FCM token from backend: $e");
    }
  }

  // Handle Action Routing on Tap
  void handleNotificationTap(Map<String, dynamic> data) {
    debugPrint("🔔 FCM Trace: Navigating for notification payload: $data");
    
    final String? type = data['type'];
    if (type == null) {
      debugPrint("🔔 FCM Trace: Notification has no payload type. Skipping routing.");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (type) {
        case 'order_status':
          final orderIdStr = data['order_id'];
          final int? orderId = orderIdStr != null ? int.tryParse(orderIdStr.toString()) : null;
          if (orderId != null) {
            debugPrint("🔔 FCM Trace: Routing to OrderDetailScreen for Order ID: $orderId");
            Get.to(() => OrderDetailScreen(orderId: orderId));
          } else {
            debugPrint("🔔 FCM Trace: Missing or invalid order_id: $orderIdStr");
          }
          break;

        case 'appointment_status':
        case 'appointment_rescheduled':
          debugPrint("🔔 FCM Trace: Routing to MyAppointmentsScreen");
          Get.to(() => const MyAppointmentsScreen());
          break;

        case 'enrollment_status':
          final enrollmentIdStr = data['enrollment_id'];
          final int? enrollmentId = enrollmentIdStr != null ? int.tryParse(enrollmentIdStr.toString()) : null;
          if (enrollmentId != null) {
            debugPrint("🔔 FCM Trace: Routing to EnrollmentDetailScreen for Enrollment ID: $enrollmentId");
            Get.to(() => EnrollmentDetailScreen(enrollmentId: enrollmentId));
          } else {
            debugPrint("🔔 FCM Trace: Missing or invalid enrollment_id: $enrollmentIdStr");
          }
          break;

        default:
          debugPrint("🔔 FCM Trace: Unknown notification type '$type'. No routing matches.");
          break;
      }
    });
  }

  // Process initial notification if launched from terminated state
  void processInitialNotification() {
    if (initialNotificationData != null) {
      debugPrint("🔔 FCM Trace: Processing initial notification payload from launch: $initialNotificationData");
      final data = Map<String, dynamic>.from(initialNotificationData!);
      initialNotificationData = null; // Clear to prevent double processing
      handleNotificationTap(data);
    }
  }
}
