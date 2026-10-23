import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna mengikuti referensi desain (ungu + aksen peach).
class AppColors {
  static const Color purple = Color(0xFF8B5FCF);
  static const Color violet = Color(0xFF7440C4);
  static const Color deepPurple = Color(0xFF4F2896);
  static const Color lilac = Color(0xFFC795F2);
  static const Color lavender = Color(0xFFF3ECFB);
  static const Color peach = Color(0xFFFFB48B);
  static const Color ink = Color(0xFF2A1A4A);
  static const Color muted = Color(0xFF8F82A8);
}

TextStyle appText({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.ink,
  double? height,
}) {
  return GoogleFonts.poppins(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

TextStyle arabicText({
  double size = 28,
  Color color = AppColors.ink,
  double height = 2.0,
}) {
  return GoogleFonts.amiri(fontSize: size, color: color, height: height);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet,
        primary: AppColors.violet,
        surface: Colors.white,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.deepPurple,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: appText(
          size: 17,
          weight: FontWeight.w600,
          color: AppColors.deepPurple,
        ),
      ),
    );
  }
}
