import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ConditionBadge extends StatelessWidget {
  final String? code;
  final String? label;
  final String? grade;

  const ConditionBadge({
    super.key,
    this.code,
    this.label,
    this.grade,
  });

  static (Color bg, Color text, String defaultLabel) getBadgeConfig({
    String? code,
    String? label,
  }) {
    switch (code) {
      case 'C1':
        return (AppColors.badgeGreenBg, AppColors.badgeGreenText, 'Like New');
      case 'C2':
        return (AppColors.badgeBlueBg, AppColors.badgeBlueText, 'Lightly Worn');
      case 'C3':
      case 'C4':
        return (AppColors.badgeOrangeBg, AppColors.badgeOrangeText, 'Heavily Worn');
      case 'C5':
        return (AppColors.badgeRedBg, AppColors.badgeRedText, 'Not Wearable');
      default:
        final normalized = (label ?? '').toLowerCase();
        if (normalized.contains('like') || normalized.contains('new')) {
          return (AppColors.badgeGreenBg, AppColors.badgeGreenText, 'Like New');
        } else if (normalized.contains('light')) {
          return (AppColors.badgeBlueBg, AppColors.badgeBlueText, 'Lightly Worn');
        } else if (normalized.contains('heavy')) {
          return (AppColors.badgeOrangeBg, AppColors.badgeOrangeText, 'Heavily Worn');
        } else if (normalized.contains('not') || normalized.contains('poor')) {
          return (AppColors.badgeRedBg, AppColors.badgeRedText, 'Not Wearable');
        }
        return (
          AppColors.cardLightBorder,
          AppColors.textLightSecondary,
          label ?? 'Condition unavailable',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, textColor, defaultLabel) = getBadgeConfig(code: code, label: label);
    final displayText = label ?? defaultLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
