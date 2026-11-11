import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/app_assets.dart';

/// Hero widget for FTUE Slide 1 showing Earth with satellite orbits.
///
/// Seamlessly plays the looping satellite video from [videoAssetPath] when provided.
/// Gracefully falls back to the high-resolution Figma asset [fallbackImagePath]
/// if the video is loading or has not been added yet by the user.
class EarthVideoHero extends StatefulWidget {
  final String? videoAssetPath;
  final String fallbackImagePath;
  final double height;

  const EarthVideoHero({
    super.key,
    this.videoAssetPath = AppAssets.earthOrbitVideo,
    this.fallbackImagePath = AppAssets.earthSatelliteGlobe,
    this.height = 240.0,
  });

  @override
  State<EarthVideoHero> createState() => _EarthVideoHeroState();
}

class _EarthVideoHeroState extends State<EarthVideoHero> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoAssetPath != null && widget.videoAssetPath!.isNotEmpty) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final path = widget.videoAssetPath;
    if (path == null || path.isEmpty) return;

    try {
      final controller = VideoPlayerController.asset(path);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isVideoInitialized = true;
        });
      } else {
        await controller.dispose();
      }
    } catch (_) {
      // Graceful fallback to Figma high-res static asset if video is not yet placed
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isVideoInitialized && _controller != null
              ? AspectRatio(
                  key: const ValueKey('video_player'),
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : Image.asset(
                  widget.fallbackImagePath,
                  key: const ValueKey('fallback_image'),
                  height: widget.height,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
        ),
      ),
    );
  }
}
