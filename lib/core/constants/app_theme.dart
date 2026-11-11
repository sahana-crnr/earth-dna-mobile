import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_design_tokens.dart';

class AppTheme {
  static ThemeData get light {
    final text = GoogleFonts.manropeTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      visualDensity: VisualDensity.standard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.buttonLime,
        primary: AppColors.buttonLime,
        surface: Colors.white,
        onSurface: AppColors.textLightPrimary,
        error: AppColors.error,
      ),
      textTheme: text.copyWith(
        headlineSmall: GoogleFonts.instrumentSans(
          fontSize: 32,
          height: 1.25,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.32,
          color: AppColors.textLightPrimary,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 22,
          height: 1.27,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightPrimary,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightPrimary,
        ),
        titleSmall: GoogleFonts.manrope(
          fontSize: 18,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightPrimary,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.32,
          color: AppColors.textLightPrimary,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          height: 1.43,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.28,
          color: AppColors.textLightSecondary,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          height: 1.33,
          color: AppColors.textLightSecondary,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          height: 1.45,
          color: AppColors.textLightMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textLightPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.cardLightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.cardLightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.cardLightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primaryGreenDark, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonLime,
          foregroundColor: AppColors.textLightPrimary,
          elevation: 0,
          minimumSize: const Size(48, 56),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
