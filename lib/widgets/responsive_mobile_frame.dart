import 'package:flutter/material.dart';

/// Centralized responsive mobile wrapper.
/// Centers the layout and constrains it to standard mobile width (default 430px)
/// across desktop browsers, tablets, and phones, eliminating repetitive clamp logic.
class ResponsiveMobileFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveMobileFrame({
    super.key,
    required this.child,
    this.maxWidth = 430.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: backgroundColor,
        constraints: BoxConstraints(maxWidth: maxWidth),
        width: MediaQuery.of(context).size.width.clamp(0.0, maxWidth),
        child: child,
      ),
    );
  }
}
