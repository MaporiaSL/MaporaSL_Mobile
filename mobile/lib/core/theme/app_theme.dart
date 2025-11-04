import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.deepEmeraldGreen,
        scaffoldBackgroundColor: AppColors.offWhite,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          bodyMedium: const TextStyle(color: AppColors.darkSlate),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.deepEmeraldGreen,
          secondary: AppColors.oceanBlue,
          tertiary: AppColors.goldenAmber,
        ),
      );

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.deepEmeraldGreen,
        scaffoldBackgroundColor: AppColors.charcoalGray,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          bodyMedium: const TextStyle(color: Colors.white),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.deepEmeraldGreen,
          secondary: AppColors.oceanBlue,
          tertiary: AppColors.goldenAmber,
        ),
      );
}
