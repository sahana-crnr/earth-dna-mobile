import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

/// Exact Figma "LOADING SCREEN" / Project S.H.O.E.S. Splash Screen
/// Preserves the designer's exact frame without slicing, shifting, or re-typing elements.
class LoadingSplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final Duration duration;

  const LoadingSplashScreen({
    super.key,
    this.onFinished,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<LoadingSplashScreen> createState() => _LoadingSplashScreenState();
}

class _LoadingSplashScreenState extends State<LoadingSplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.onFinished != null) {
      _timer = Timer(widget.duration, () {
        if (mounted) {
          widget.onFinished!();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Image.asset(
            AppAssets.loadingScreen,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, _, _) => const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
