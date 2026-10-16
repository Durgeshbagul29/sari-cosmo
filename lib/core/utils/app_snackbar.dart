import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class AppSnackbar {
  static void _show(
    String title,
    String message, {
    required Color backgroundColor,
    required IconData iconData,
    Widget? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss any active snackbars first to avoid layout overlapping issues
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: icon ?? Icon(iconData, color: Colors.white),
      duration: duration,
    );
  }

  static void success(String title, String message, {Widget? icon}) {
    _show(
      title,
      message,
      backgroundColor: AppColors.success,
      iconData: Icons.check_circle_outline_rounded,
      icon: icon,
    );
  }

  static void warning(String title, String message, {Widget? icon}) {
    _show(
      title,
      message,
      backgroundColor: AppColors.warning,
      iconData: Icons.warning_amber_rounded,
      icon: icon,
      duration: const Duration(seconds: 4),
    );
  }

  static void error(String title, String message, {Widget? icon}) {
    _show(
      title,
      message,
      backgroundColor: AppColors.error,
      iconData: Icons.error_outline_rounded,
      icon: icon,
      duration: const Duration(seconds: 4),
    );
  }

  static void normal(String title, String message, {Widget? icon}) {
    _show(
      title,
      message,
      backgroundColor: AppColors.info,
      iconData: Icons.info_outline_rounded,
      icon: icon,
    );
  }

  static void primary(String title, String message, {Widget? icon}) {
    _show(
      title,
      message,
      backgroundColor: AppColors.primary,
      iconData: Icons.info_outline_rounded,
      icon: icon,
    );
  }

  static void black(String title, String message, {Widget? icon}) {
    _show(
      title,
      message,
      backgroundColor: Colors.black,
      iconData: Icons.info_outline_rounded,
      icon: icon,
    );
  }

  static void pink(String title, String message, {Widget? icon}) {
    _show(
      title,
      message,
      backgroundColor: Colors.pink,
      iconData: Icons.favorite_border_rounded,
      icon: icon,
    );
  }
}
