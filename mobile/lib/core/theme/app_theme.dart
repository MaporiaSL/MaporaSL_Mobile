import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark);

    final textTheme = _applyDisplayFont(baseTextTheme, AppColors.textDark);

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.textDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.surfaceMuted,
        onSecondaryContainer: AppColors.textDark,
        tertiary: AppColors.primaryLight,
        onTertiary: AppColors.textDark,
        tertiaryContainer: AppColors.surfaceMuted,
        onTertiaryContainer: AppColors.textDark,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFDECEC),
        onErrorContainer: AppColors.error,
        background: AppColors.background,
        onBackground: AppColors.textDark,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
        surfaceVariant: AppColors.surfaceMuted,
        onSurfaceVariant: AppColors.textMuted,
        outline: AppColors.border,
        outlineVariant: AppColors.surfaceMuted,
        shadow: Color(0x14000000),
        scrim: Color(0x66000000),
        inverseSurface: AppColors.textDark,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primaryLight,
        surfaceTint: AppColors.primary,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primaryContainer,
        disabledColor: AppColors.surfaceMuted,
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.textDark),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.textDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: AppColors.textLight, displayColor: AppColors.textLight);

    final textTheme = _applyDisplayFont(baseTextTheme, AppColors.textLight);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.backgroundDark,
        primaryContainer: Color(0xFF0C2F36),
        onPrimaryContainer: AppColors.textLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textLight,
        secondaryContainer: Color(0xFF1E293B),
        onSecondaryContainer: AppColors.textLight,
        tertiary: AppColors.primary,
        onTertiary: AppColors.backgroundDark,
        tertiaryContainer: Color(0xFF10343B),
        onTertiaryContainer: AppColors.textLight,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFF3B0B0B),
        onErrorContainer: Color(0xFFFFC8C8),
        background: AppColors.backgroundDark,
        onBackground: AppColors.textLight,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textLight,
        surfaceVariant: Color(0xFF1B2430),
        onSurfaceVariant: AppColors.textMutedDark,
        outline: AppColors.borderDark,
        outlineVariant: Color(0xFF1B2430),
        shadow: Color(0x66000000),
        scrim: Color(0x99000000),
        inverseSurface: AppColors.surface,
        onInverseSurface: AppColors.textDark,
        inversePrimary: AppColors.primary,
        surfaceTint: AppColors.primaryLight,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B2430),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textMutedDark,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textLight,
          side: const BorderSide(color: AppColors.borderDark),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1B2430),
        selectedColor: const Color(0xFF10343B),
        disabledColor: const Color(0xFF1B2430),
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.textLight),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.textLight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textMutedDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      useMaterial3: true,
    );
  }

  static TextTheme _applyDisplayFont(
    TextTheme baseTextTheme,
    Color displayColor,
  ) {
    return baseTextTheme.copyWith(
      displayLarge: GoogleFonts.fraunces(
        textStyle: baseTextTheme.displayLarge,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
      displayMedium: GoogleFonts.fraunces(
        textStyle: baseTextTheme.displayMedium,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
      displaySmall: GoogleFonts.fraunces(
        textStyle: baseTextTheme.displaySmall,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
      headlineLarge: GoogleFonts.fraunces(
        textStyle: baseTextTheme.headlineLarge,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
      headlineMedium: GoogleFonts.fraunces(
        textStyle: baseTextTheme.headlineMedium,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
      headlineSmall: GoogleFonts.fraunces(
        textStyle: baseTextTheme.headlineSmall,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
    );
  }
}
