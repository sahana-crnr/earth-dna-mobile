import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Camera viewfinder canvas rendering the live camera feed, loading indicator,
/// permission prompt, and floating angle instruction banner.
class CameraViewfinderCanvas extends StatelessWidget {
  final bool isCameraReady;
  final bool isLoadingCamera;
  final CameraController? cameraController;
  final bool isUploading;
  final String activeView;
  final String? confirmedView;
  final VoidCallback onEnableCamera;

  const CameraViewfinderCanvas({
    super.key,
    required this.isCameraReady,
    required this.isLoadingCamera,
    required this.cameraController,
    required this.isUploading,
    required this.activeView,
    required this.confirmedView,
    required this.onEnableCamera,
  });

  String _formatViewTitle(String v) {
    switch (v) {
      case 'top':
        return 'Top View';
      case 'right':
        return 'Right View';
      case 'left':
        return 'Left View';
      case 'sole':
      case 'bottom':
        return 'Sole View';
      default:
        return '${v[0].toUpperCase()}${v.substring(1)} View';
    }
  }

  String _formatViewBanner(String v) {
    switch (v) {
      case 'top':
        return 'Top view';
      case 'right':
        return 'Right view';
      case 'left':
        return 'Left view';
      case 'sole':
      case 'bottom':
        return 'Sole view';
      default:
        return '${v[0].toUpperCase()}${v.substring(1)} view';
    }
  }

  String _getInstructionText(String v) {
    switch (v) {
      case 'top':
        return 'Place the shoe flat and capture it from above';
      case 'right':
        return 'Turn the shoe to its right side profile';
      case 'left':
        return 'Turn the shoe to its left side profile';
      case 'sole':
      case 'bottom':
        return 'Hold the shoe and show the bottom sole';
      default:
        return 'Capture the shoe clearly from this angle';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E242B),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Live Camera Feed or Clean Camera Placeholder
          if (isCameraReady &&
              cameraController != null &&
              cameraController!.value.isInitialized)
            Center(
              child: CameraPreview(cameraController!),
            )
          else if (isLoadingCamera)
            const ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            Container(
              color: const Color(0xFF111827),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white70,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Camera inactive or permission needed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap Enable Camera to grant access, or tap the shutter below to take/upload a photo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: onEnableCamera,
                      icon: const Icon(Icons.videocam_outlined, size: 16),
                      label: const Text(
                        'Enable Camera',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonLime,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 2. Floating Dynamic Instruction Banner (matches Figma screens 1-5)
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC000000), // Semi-transparent black pill
                  borderRadius: BorderRadius.circular(16),
                ),
                child: confirmedView != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_formatViewBanner(confirmedView!)} captured',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.0,
                            ),
                          ),
                          if (activeView != confirmedView) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Next: ${_formatViewTitle(activeView)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Text(
                        _getInstructionText(activeView),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
              ),
            ),
          ),

          if (isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
