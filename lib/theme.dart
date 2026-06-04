import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Purple ──
  static const Color primary = Color(0xFF5B21B6);
  static const Color primaryDark = Color(0xFF3B0764);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color background = Color(0xFFF9FAFB);
  static const Color white = Colors.white;

  // ── Text ──
  static const Color grey = Color(0xFF6B7280);
 static const Color greyLight = Color(0xFFF3F4F6);

  // ── Feature card colors ──
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF97316);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}