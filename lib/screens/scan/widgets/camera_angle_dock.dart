import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../models/scan_session_model.dart';
import '../../../providers/scan_provider.dart';
import '../../../widgets/dashed_rrect_painter.dart';

/// Bottom dock displaying the active shoe angle title, counter, and 4 angle thumbnail slots.
class CameraAngleDock extends StatelessWidget {
  final String activeView;
  final int capturedCount;
  final ScanProvider scan;
  final ScanShoe? shoe;
  final ValueChanged<String> onSelectView;
  final ValueChanged<String> onRemoveViewPhoto;

  const CameraAngleDock({
    super.key,
    required this.activeView,
    required this.capturedCount,
    required this.scan,
    required this.shoe,
    required this.onSelectView,
    required this.onRemoveViewPhoto,
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

  Widget _buildAngleIllustration(String assetPath, bool isActive) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        color: isActive ? Colors.white : const Color(0xFF94A3B8),
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }

  Widget _buildAngleSlot(
    String key,
    String assetPath,
    bool isActive,
    ScanPhoto? photo,
  ) {
    final localFile = scan.getLocalPhoto(scan.activeShoeIndex, key);
    final hasRemote = photo?.url != null && photo!.url!.isNotEmpty;
    final isCaptured = localFile != null || hasRemote;

    final borderColor = isActive
        ? const Color(0xFFD2F544) // Figma lime dashed border for active
        : const Color(0xFF475569); // Figma subtle dashed slate for inactive

    return GestureDetector(
      onTap: () => onSelectView(key),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dark Container Fill
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E242B),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Dashed Border (lime for active, slate for inactive)
            if (!isCaptured)
              Positioned.fill(
                child: CustomPaint(
                  painter: DashedRRectPainter(
                    color: borderColor,
                    strokeWidth: isActive ? 1.5 : 1.0,
                    radius: 10.0,
                  ),
                ),
              ),

            // Content: Captured Photo or Outline Illustration
            if (isCaptured)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: localFile != null
                      ? (kIsWeb
                            ? Image.network(localFile.path, fit: BoxFit.cover)
                            : Image.file(
                                io.File(localFile.path),
                                fit: BoxFit.cover,
                              ))
                      : Image.network(
                          photo!.url!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _buildAngleIllustration(assetPath, isActive),
                        ),
                ),
              )
            else
              _buildAngleIllustration(assetPath, isActive),

            // '×' retake badge on captured slot
            if (isCaptured)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => onRemoveViewPhoto(key),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E242B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 0.8),
                    ),
                    child: const Center(
                      child: Icon(Icons.close, size: 10, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Left: View title & progress counter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatViewTitle(activeView),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$capturedCount/4',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: 4 Angle thumbnail slots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAngleSlot(
                'top',
                AppAssets.snapTop,
                activeView == 'top',
                shoe?.photoForView('top'),
              ),
              const SizedBox(width: 6),
              _buildAngleSlot(
                'left',
                AppAssets.snapLeft,
                activeView == 'left',
                shoe?.photoForView('left'),
              ),
              const SizedBox(width: 6),
              _buildAngleSlot(
                'right',
                AppAssets.snapRight,
                activeView == 'right',
                shoe?.photoForView('right'),
              ),
              const SizedBox(width: 6),
              _buildAngleSlot(
                'sole',
                AppAssets.snapBottom,
                activeView == 'sole',
                shoe?.photoForView('sole'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
