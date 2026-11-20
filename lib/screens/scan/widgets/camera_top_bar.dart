import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Top bar for the camera capture screen (Close, Shoe Selector Pill, Tips, Flash).
class CameraTopBar extends StatelessWidget {
  final int activeShoeIndex;
  final bool isFlashOn;
  final VoidCallback onClose;
  final VoidCallback onSelectShoe;
  final VoidCallback onShowTips;
  final VoidCallback onToggleFlash;

  const CameraTopBar({
    super.key,
    required this.activeShoeIndex,
    required this.isFlashOn,
    required this.onClose,
    required this.onSelectShoe,
    required this.onShowTips,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Shoe selector pill (Tappable - Scanned Collections)
          GestureDetector(
            onTap: onSelectShoe,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shoe 0${activeShoeIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Right action buttons (Tips & Flash)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onShowTips,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onToggleFlash,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isFlashOn ? Colors.white24 : Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: isFlashOn ? AppColors.buttonLime : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
