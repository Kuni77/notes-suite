import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF111827);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color textLightColor = Color(0xFF9CA3AF);

  // Card Colors (for visibility badges)
  static const Color privateColor = Color(0xFFF3F4F6);
  static const Color sharedColor = Color(0xFFDBEAFE);
  static const Color publicColor = Color(0xFFD1FAE5);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),

    // Scaffold
    scaffoldBackgroundColor: backgroundColor,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimaryColor),
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceColor,
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: const TextStyle(
        color: textPrimaryColor,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textLightColor,
      ),
    ),
  );

  // Dark Theme (bonus si besoin)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1F2937),
      background: Color(0xFF111827),
      error: errorColor,
    ),
  );
}