import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AfriZoneMart brand tokens — the Flutter equivalent of index.css :root.
/// Wonolo-inspired layout (Poppins, pill buttons, rounded cards) with the
/// Afrizone navy + orange brand colors kept.
class AppColors {
  static const navy = Color(0xFF000066);
  static const navyPress = Color(0xFF00004D);
  static const orange = Color(0xFFFBAC34);

  static const bg = Color(0xFFF4F5FA);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFEEF0F7);
  static const border = Color(0xFFE6E8F1);

  static const text = Color(0xFF14163A);
  static const text2 = Color(0xFF565D77);
  static const text3 = Color(0xFF9298B0);

  static const success = Color(0xFF2F9E6B);
  static const danger = Color(0xFFD6493C);
  static const accent2 = Color(0xFFC47F12);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.orange,
        ),
        useMaterial3: true,
        // Pill-shaped buttons (Wonolo style)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            shape: const StadiumBorder(),
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        // Rounder inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.orange, width: 2),
          ),
        ),
      );
}

/// Heading style helper. Despite the name, this now uses Poppins (bold) for the
/// Wonolo look — kept as `serif()` so existing call sites don't change.
class AppText {
  static TextStyle serif({
    double size = 32,
    Color color = AppColors.navy,
    FontWeight weight = FontWeight.w700,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.1,
        letterSpacing: -0.5,
      );
}
