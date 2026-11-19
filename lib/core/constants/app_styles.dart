import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_design_tokens.dart';

/// Centralized reusable styles ("CSS-like" utility classes) for the entire app.
/// Eliminates repeated inline BoxDecorations, ButtonStyles, and TextStyles across screens.
class AppStyles {
  // ─── Box / Container Decorations (CSS Classes) ─────────────────────────────

  /// Standard white card with subtle border and rounded corners
  static BoxDecoration cardDecoration({
    Color backgroundColor = Colors.white,
    Color borderColor = AppColors.cardLightBorder,
    double borderRadius = AppRadii.lg,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
    );
  }

  /// Elevated card with soft drop shadow
  static BoxDecoration cardElevatedDecoration({
    Color backgroundColor = Colors.white,
    double borderRadius = AppRadii.lg,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: AppElevation.card,
    );
  }

  /// Neutral surface container (e.g. #F8FAFC)
  static BoxDecoration surfaceDecoration({
    Color backgroundColor = const Color(0xFFF8FAFC),
    Color borderColor = const Color(0xFFE2E8F0),
    double borderRadius = AppRadii.md,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
    );
  }

  /// Standard bottom sheet modal container decoration
  static const BoxDecoration bottomSheetDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  );

  /// Drag handle indicator for bottom sheets
  static BoxDecoration dragHandleDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    );
  }

  /// Capsule / Pill decoration (for tags, chips, status badges)
  static BoxDecoration pillDecoration({
    Color backgroundColor = const Color(0xFFF1F5F9),
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: borderColor != null ? Border.all(color: borderColor) : null,
    );
  }

  /// Lime green accent pill decoration
  static const BoxDecoration limePillDecoration = BoxDecoration(
    color: AppColors.buttonLime,
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.pill)),
  );

  /// Dark surface decoration (for dark mode screens/cards)
  static BoxDecoration darkCardDecoration({
    Color backgroundColor = AppColors.cardDark,
    Color borderColor = const Color(0xFF262933),
    double borderRadius = AppRadii.md,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
    );
  }

  // ─── Button Styles (Reusable CSS Button Classes) ───────────────────────────

  /// Primary Lime Green Action Pill Button
  static ButtonStyle limePillButtonStyle({
    double height = 50,
    double borderRadius = 26,
    Color backgroundColor = AppColors.buttonLime,
    Color foregroundColor = const Color(0xFF0F172A),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      minimumSize: Size(double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      textStyle: GoogleFonts.urbanist(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
      ),
    );
  }

  /// Secondary Outlined White Pill Button
  static ButtonStyle outlinedPillButtonStyle({
    double height = 50,
    double borderRadius = 26,
    Color borderColor = const Color(0xFFCBD5E1),
    Color foregroundColor = const Color(0xFF0F172A),
    Color backgroundColor = Colors.white,
  }) {
    return OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      side: BorderSide(color: borderColor),
      elevation: 0,
      minimumSize: Size(double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      textStyle: GoogleFonts.urbanist(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
      ),
    );
  }

  /// Dark Action Pill Button
  static ButtonStyle darkPillButtonStyle({
    double height = 50,
    double borderRadius = 26,
    Color backgroundColor = const Color(0xFF0F172A),
    Color foregroundColor = Colors.white,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      minimumSize: Size(double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      textStyle: GoogleFonts.urbanist(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
      ),
    );
  }

  // ─── Text Styles (Reusable CSS Typography Classes) ─────────────────────────

  /// Large Screen Title (H1)
  static TextStyle get h1 => GoogleFonts.urbanist(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textLightPrimary,
        letterSpacing: 0.0,
      );

  /// Section Header (H2)
  static TextStyle get h2 => GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textLightPrimary,
        letterSpacing: 0.0,
      );

  /// Subtitle / Card Title (H3)
  static TextStyle get h3 => GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textLightPrimary,
      );

  /// Regular Body Text
  static TextStyle get body => GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textLightSecondary,
        height: 1.45,
      );

  /// Muted Description / Explanatory Text
  static TextStyle get bodyMuted => GoogleFonts.urbanist(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textLightMuted,
        height: 1.4,
      );

  /// Small Monospace/Badge Label
  static TextStyle get labelSmall => GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textLightMuted,
        letterSpacing: 0.5,
      );
}
