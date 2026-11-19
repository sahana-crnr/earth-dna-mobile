import 'package:flutter/material.dart';
import '../core/constants/app_styles.dart';

/// Reusable bottom sheet drag handle indicator.
/// Replaces repeated inline Container(width: 44, height: 4, decoration: ...) boilerplate.
class BottomSheetDragHandle extends StatelessWidget {
  final Color? color;
  final EdgeInsetsGeometry padding;

  const BottomSheetDragHandle({
    super.key,
    this.color,
    this.padding = const EdgeInsets.only(bottom: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Container(
          width: 44,
          height: 4,
          decoration: AppStyles.dragHandleDecoration(color: color),
        ),
      ),
    );
  }
}
