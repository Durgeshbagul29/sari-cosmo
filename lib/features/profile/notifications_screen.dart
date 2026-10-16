import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/services/firebase_notification_service.dart';
import 'controllers/notification_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String? type) {
    if (type == null) return Icons.notifications_outlined;
    final lower = type.toLowerCase();
    if (lower.contains('order')) {
      return Icons.local_shipping_outlined;
    } else if (lower.contains('appointment')) {
      return Icons.calendar_month_outlined;
    } else if (lower.contains('enrollment') || lower.contains('course')) {
      return Icons.school_outlined;
    }
    return Icons.notifications_outlined;
  }

  Color _getColorForType(String? type) {
    if (type == null) return AppTheme.primary;
    final lower = type.toLowerCase();
    if (lower.contains('order')) {
      return const Color(0xFF2980B9);
    } else if (lower.contains('appointment')) {
      return const Color(0xFFE67E22);
    } else if (lower.contains('enrollment') || lower.contains('course')) {
      return const Color(0xFF8E44AD);
    }
    return AppTheme.primary;
  }

  String _formatTime(String? createdAtStr) {
    if (createdAtStr == null) return '';
    try {
      final DateTime createdAt = DateTime.parse(createdAtStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(createdAt);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
      }
    } catch (e) {
      return createdAtStr.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    
    // Fetch notifications on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (controller.notificationsList.isEmpty) return const SizedBox.shrink();
            return controller.isActionLoading.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () => controller.markAllAsRead(),
                    child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                  );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notificationsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notificationsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppTheme.primary.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You will see status updates about your orders,\ncourses, and appointments here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!controller.isLoading.value &&
                  scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                controller.fetchNotifications(loadMore: true);
              }
              return true;
            },
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 8,
                bottom: 8 + MediaQuery.of(context).padding.bottom,
              ),
              itemCount: controller.notificationsList.length +
                  (controller.isLoading.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notificationsList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = controller.notificationsList[index];
                return _buildNotificationTile(context, item, controller);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    Map<String, dynamic> item,
    NotificationController controller,
  ) {
    final String id = item['id']?.toString() ?? '';
    final String? type = item['type']?.toString() ?? item['data']?['type']?.toString();
    final String title = item['title']?.toString() ?? item['data']?['title']?.toString() ?? 'Notification';
    final String body = item['message']?.toString() ?? item['data']?['message']?.toString() ?? '';
    final String time = _formatTime(item['created_at']?.toString());
    final bool isRead = item['read_at'] != null;

    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isRead ? AppTheme.surface : AppTheme.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: isRead ? null : Border.all(color: AppTheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            // Mark as read immediately on backend/locally
            if (!isRead && id.isNotEmpty) {
              controller.markAsRead(id);
            }
            
            // Extract raw data map and build payload
            final rawData = item['data'];
            Map<String, dynamic> payload = {};
            if (rawData is Map) {
              payload = Map<String, dynamic>.from(rawData);
            }
            
            // Ensure payload has the type key
            final String finalType = (payload['type'] ?? type ?? '').toString();
            if (finalType.contains('OrderStatusNotification') || finalType == 'order_status') {
              payload['type'] = 'order_status';
            } else if (finalType.contains('AppointmentStatusNotification') || 
                       finalType.contains('AppointmentRescheduledNotification') || 
                       finalType == 'appointment_status' || 
                       finalType == 'appointment_rescheduled') {
              payload['type'] = 'appointment_status';
            } else if (finalType.contains('EnrollmentStatusNotification') || finalType == 'enrollment_status') {
              payload['type'] = 'enrollment_status';
            }

            debugPrint('🔔 Notification Tile Click: payload = $payload');
            FirebaseNotificationService.instance.handleNotificationTap(payload);
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMedium, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
              ],
            ),
            trailing: isRead
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  ),
          ),
        ),
      ),
    );
  }
}
