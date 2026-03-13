import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0D0D1A);
  static const surface = Color(0xFF12122A);
  static const surfaceVariant = Color(0xFF1A1A35);
  static const neonPurple = Color(0xFF7B2FFF);
  static const neonBlue = Color(0xFF00D4FF);
  static const neonPink = Color(0xFFFF2F7B);
  static const neonGreen = Color(0xFF00FF9F);
  static const neonOrange = Color(0xFFFF6B00);
  static const neonRed = Color(0xFFFF2222);
  static const textPrimary = Color(0xFFE8E8FF);
  static const textSecondary = Color(0xFF8888AA);
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonPurple,
          secondary: AppColors.neonBlue,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          titleMedium: TextStyle(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );

  static ThemeData get lightTheme => darkTheme;
}
