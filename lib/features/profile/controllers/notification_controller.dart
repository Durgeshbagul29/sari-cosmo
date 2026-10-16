import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var notificationsList = <Map<String, dynamic>>[].obs;
  var unreadCount = 0.obs;

  int currentPage = 1;
  int lastPage = 1;
  int totalCount = 0;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  Future<void> fetchNotifications({bool loadMore = false}) async {
    if (isLoading.value) return;

    if (loadMore) {
      if (currentPage >= lastPage) return;
      currentPage++;
    } else {
      currentPage = 1;
      notificationsList.clear();
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await _apiService.getNotifications(token, page: currentPage, perPage: 20);
        debugPrint('🔔 Notification Trace: List Response: $response');

        final List<dynamic> data = response['data'] ?? [];
        final Map<String, dynamic> meta = response['meta'] ?? {};
        
        lastPage = meta['last_page'] ?? 1;
        totalCount = meta['total'] ?? 0;

        final List<Map<String, dynamic>> items = data.map((e) => Map<String, dynamic>.from(e)).toList();
        if (loadMore) {
          notificationsList.addAll(items);
        } else {
          notificationsList.assignAll(items);
        }
      }
    } catch (e) {
      debugPrint('🔔 Notification Trace: Fetch Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await _apiService.getUnreadCount(token);
        debugPrint('🔔 Notification Trace: Unread Count Response: $response');
        
        unreadCount.value = response['data']?['unread_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('🔔 Notification Trace: Unread Count Fetch Error: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        debugPrint('🔔 Notification Trace: Marking notification $notificationId as read');
        final response = await _apiService.markNotificationRead(token, notificationId);
        debugPrint('🔔 Notification Trace: Mark Read Response: $response');

        // Update local item read status
        final index = notificationsList.indexWhere((element) => element['id'] == notificationId);
        if (index != -1) {
          final updated = Map<String, dynamic>.from(notificationsList[index]);
          updated['read_at'] = DateTime.now().toIso8601String();
          notificationsList[index] = updated;
        }

        // Fetch new unread count
        fetchUnreadCount();
      }
    } catch (e) {
      debugPrint('🔔 Notification Trace: Mark Read Error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (isActionLoading.value) return;

    isActionLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        debugPrint('🔔 Notification Trace: Marking all notifications as read');
        final response = await _apiService.markAllNotificationsRead(token);
        debugPrint('🔔 Notification Trace: Mark All Read Response: $response');

        // Update all local items
        for (int i = 0; i < notificationsList.length; i++) {
          if (notificationsList[i]['read_at'] == null) {
            final updated = Map<String, dynamic>.from(notificationsList[i]);
            updated['read_at'] = DateTime.now().toIso8601String();
            notificationsList[i] = updated;
          }
        }
        
        unreadCount.value = 0;
      }
    } catch (e) {
      debugPrint('🔔 Notification Trace: Mark All Read Error: $e');
    } finally {
      isActionLoading.value = false;
    }
  }
}
