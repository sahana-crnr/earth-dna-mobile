import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_design_tokens.dart';
import '../core/constants/app_styles.dart';

/// Reusable card container replacing repeated Container(decoration: BoxDecoration(...))
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final bool elevated;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.cardLightBorder,
    this.borderRadius = AppRadii.lg,
    this.elevated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: elevated
          ? AppStyles.cardElevatedDecoration(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            )
          : AppStyles.cardDecoration(
              backgroundColor: backgroundColor,
              borderColor: borderColor,
              borderRadius: borderRadius,
            ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }
    return card;
  }
}
