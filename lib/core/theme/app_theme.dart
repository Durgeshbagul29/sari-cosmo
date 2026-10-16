export 'app_colors.dart';
export 'light_theme.dart';

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'light_theme.dart';

// Maintaining old AppTheme class for backward compatibility with static UI references.
class AppTheme {
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color accent = AppColors.accent;
  static const Color ratingStar = AppColors.ratingStar;
  
  static const Color background = AppColors.backgroundLight;
  static const Color surface = AppColors.surfaceLight;
  static const Color cardBg = AppColors.cardBgLight;
  
  static const Color textDark = AppColors.textDarkLight;
  static const Color textMedium = AppColors.textMediumLight;
  static const Color textLight = AppColors.textLightLight;
  static const Color divider = AppColors.dividerLight;
  
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;

  static ThemeData get theme => lightTheme;
}
