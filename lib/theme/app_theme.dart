import 'package:flutter/material.dart';

/// Colors carried over from the presentation deck so the app, slides,
/// and paper all look like one consistent piece of work.
class AppColors {
  static const navy = Color(0xFF1F3A5F);
  static const grey = Color(0xFF5B6670);
  static const lightGrey = Color(0xFFEDEFF1);
  static const line = Color(0xFFD9DEE3);
  static const green = Color(0xFF2E7D4F);
  static const red = Color(0xFFB23A2E);
  static const amber = Color(0xFFF2A65A);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        surface: AppColors.white,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.navy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
