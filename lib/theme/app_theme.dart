import 'package:flutter/material.dart';

// ─── Color Palette ─────────────────────────────────────────────────────────
const Color kPrimary = Color(0xFF6C63FF);
const Color kPrimaryDark = Color(0xFF4B44C8);
const Color kBackground = Color(0xFF0F0E1A);
const Color kSurface = Color(0xFF1C1B2E);
const Color kCard = Color(0xFF252440);
const Color kBorder = Color(0xFF33315A);
const Color kTextPrimary = Color(0xFFEEEDF5);
const Color kTextSecondary = Color(0xFF9896B8);
const Color kSuccess = Color(0xFF4CAF50);
const Color kWarning = Color(0xFFFF9800);
const Color kError = Color(0xFFEF5350);
const Color kCritical = Color(0xFFFF5252);
const Color kInfo = Color(0xFF29B6F6);

// ─── Stock Status Colors ───────────────────────────────────────────────────
const Map<String, Color> kStatusColors = {
  'Normal': kSuccess,
  'Low': kWarning,
  'Critical': kCritical,
  'Out of Stock': kError,
};

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    primaryColor: kPrimary,
    colorScheme: const ColorScheme.dark(
      primary: kPrimary,
      secondary: kInfo,
      surface: kSurface,
      error: kError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: kTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: const CardThemeData(
      color: kCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: kBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kError),
      ),
      labelStyle: const TextStyle(color: kTextSecondary),
      hintStyle: const TextStyle(color: kTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kPrimary),
    ),
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800),
      headlineMedium:
          TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(
          color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: 17),
      titleMedium: TextStyle(
          color: kTextPrimary, fontWeight: FontWeight.w500, fontSize: 15),
      bodyLarge: TextStyle(color: kTextPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: kTextSecondary, fontSize: 13),
      labelLarge: TextStyle(
          color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: 14),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: kSurface,
      indicatorColor: Color(0x336C63FF),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kCard,
      selectedColor: kPrimary.withValues(alpha: 0.3),
      labelStyle: const TextStyle(color: kTextPrimary),
      side: const BorderSide(color: kBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kCard,
      contentTextStyle: const TextStyle(color: kTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
