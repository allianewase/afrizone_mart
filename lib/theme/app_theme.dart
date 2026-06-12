import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AfriZoneMart brand tokens — the Flutter equivalent of index.css :root
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
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.orange,
        ),
        useMaterial3: true,
      );
}

/// Heading style helper — Instrument Serif (like .page-title / .serif).
/// Use AppText.serif(size: 38) anywhere you want a big serif heading.
class AppText {
  static TextStyle serif({
    double size = 32,
    Color color = AppColors.navy,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.instrumentSerif(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.1,
      );
}
