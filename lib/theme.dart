import 'package:flutter/material.dart';

class AppColors {
  static const Color primary      = Color(0xFF5B21B6);
  static const Color primaryDark  = Color(0xFF3B0764);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color grey         = Color(0xFF6B7280);
  static const Color greyLight    = Color(0xFFF3F4F6);
  static const Color green        = Color(0xFF22C55E);
  static const Color orange       = Color(0xFFF97316);
  static const Color red          = Color(0xFFEF4444);
  static const Color blue         = Color(0xFF3B82F6);
  static const Color background   = Color(0xFFF8F7FF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
