import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Shutter dock containing Gallery button, central Shutter button, and Retake / Done button.
class CameraShutterDock extends StatelessWidget {
  final bool isUploading;
  final bool isCurrentViewCaptured;
  final int capturedCount;
  final VoidCallback onOpenGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback onCompleteShoe;

  const CameraShutterDock({
    super.key,
    required this.isUploading,
    required this.isCurrentViewCaptured,
    required this.capturedCount,
    required this.onOpenGallery,
    required this.onTakePhoto,
    required this.onCompleteShoe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gallery Button -> opens Upload Photos modal
          GestureDetector(
            onTap: onOpenGallery,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Main Shutter Button
          GestureDetector(
            onTap: isUploading ? null : onTakePhoto,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 78,
              height: 78,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Retake / Done button (Matches Figma: Retake when angle captured, Done when complete)
          GestureDetector(
            onTap: () {
              if (isCurrentViewCaptured) {
                onTakePhoto();
              } else if (capturedCount >= 4) {
                onCompleteShoe();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please capture all 4 views first ($capturedCount/4 captured)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF334155),
                  ),
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 50,
                minHeight: 50,
              ),
              alignment: Alignment.center,
              child: Text(
                isCurrentViewCaptured ? 'Retake' : 'Done',
                style: TextStyle(
                  color: isCurrentViewCaptured
                      ? AppColors.buttonLime
                      : (capturedCount >= 4
                          ? AppColors.primaryGreen
                          : Colors.white24),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
