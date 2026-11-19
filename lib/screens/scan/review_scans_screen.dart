import 'dart:io' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/scan_session_model.dart';
import '../../providers/scan_provider.dart';
import 'scan_processing_screen.dart';

class ReviewScansScreen extends StatelessWidget {
  const ReviewScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = Provider.of<ScanProvider>(context);
    final session = scan.session;
    final shoes = session?.shoes ?? [];

    final completedCount = shoes
        .where((s) => s.complete || scan.isShoeComplete(shoes.indexOf(s)))
        .length;
    final totalCount = shoes.isNotEmpty ? shoes.length : 1;
    final allComplete = completedCount == totalCount && shoes.isNotEmpty;
    final inProgressShoeNumber = shoes.indexWhere(
          (s) => !s.complete && !scan.isShoeComplete(shoes.indexOf(s)),
        ) +
        1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Review Scans',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF0F172A), size: 22),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Figma auto-layout padding: T 12, B 20, L 16, R 16
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic Header based on completion (Matches Figma: 2 Shoes Complete · Shoe 3 In Progress)
                        Text(
                          allComplete
                              ? '$totalCount Shoes Complete'
                              : '$completedCount Shoes Complete · Shoe ${inProgressShoeNumber > 0 ? inProgressShoeNumber : totalCount} In Progress',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          allComplete
                              ? 'Review your photos before finishing the scan.'
                              : 'Review your photos and complete any missing views.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        // Figma auto-layout Gap: 24 between header and cards list
                        const SizedBox(height: 24),

                        // List of Shoes (Figma auto-layout Gap: 8 between cards)
                        if (shoes.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'No shoes added to this scan session yet.',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ),
                          )
                        else
                          for (int i = 0; i < shoes.length; i++) ...[
                            _buildShoeCard(
                              context,
                              scan: scan,
                              shoe: shoes[i],
                              shoeIndex: i,
                            ),
                            if (i < shoes.length - 1)
                              const SizedBox(height: 8), // Figma gap: 8 between shoe cards
                          ],
                      ],
                    ),
                  ),
                ),

                // Bottom Finish Scanning Button (Figma: W 398 Fill x H 56 Fill, Radius 100)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56, // Figma W 398 x H 56
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: allComplete
                            ? AppColors.buttonLime // Figma #B5E076
                            : const Color(0xFFF1F5F9), // Action/Disabled/Background
                        foregroundColor: allComplete
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8), // Action/Disabled/Content
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100), // Corner radius 100
                        ),
                      ),
                      onPressed: allComplete
                          ? () async {
                              await scan.finishScanSession();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ScanProcessingScreen(),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: const Text(
                        'Finish Scanning',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoeCard(
    BuildContext context, {
    required ScanProvider scan,
    required ScanShoe shoe,
    required int shoeIndex,
  }) {
    final shoeNum = (shoeIndex + 1).toString().padLeft(2, '0');
    final isComplete = shoe.complete || scan.isShoeComplete(shoeIndex);
    final capturedCount = scan.getCapturedCount(shoeIndex);
    final missingCount = 4 - capturedCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Shoe 01 Complete / Missing 3 images ... Three dots menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Shoe $shoeNum',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Missing $missingCount images',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onPressed: () {
                  _showShoeOptions(
                    context,
                    scan: scan,
                    shoeNum: shoeNum,
                    shoeIndex: shoeIndex,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4-View Thumbnails Row (Figma: W 86 x H 86 each, Gap: 10)
          Row(
            children: [
              _buildViewSlot(context, scan, shoe, shoeIndex, 'top', 'Top'),
              const SizedBox(width: 10), // Gap: 10
              _buildViewSlot(context, scan, shoe, shoeIndex, 'left', 'Left'),
              const SizedBox(width: 10), // Gap: 10
              _buildViewSlot(context, scan, shoe, shoeIndex, 'right', 'Right'),
              const SizedBox(width: 10), // Gap: 10
              _buildViewSlot(context, scan, shoe, shoeIndex, 'sole', 'Bottom'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewSlot(
    BuildContext context,
    ScanProvider scan,
    ScanShoe shoe,
    int shoeIndex,
    String viewName,
    String label,
  ) {
    final localPhoto = scan.getLocalPhoto(shoeIndex, viewName);
    final remotePhoto = shoe.photoForView(viewName);
    final hasPhoto = localPhoto != null ||
        (remotePhoto?.url != null && remotePhoto!.url!.isNotEmpty);

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0, // Figma W 86 x H 86
        child: hasPhoto
            ? GestureDetector(
                onTap: () {
                  // Tapping existing thumbnail -> opens that view to retake (Blue Note spec)
                  scan.switchActiveShoe(shoeIndex);
                  scan.setActiveView(viewName);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), // Corner radius 12
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (localPhoto != null)
                        kIsWeb
                            ? Image.network(localPhoto.path, fit: BoxFit.cover)
                            : Image.file(
                                io.File(localPhoto.path),
                                fit: BoxFit.cover,
                              )
                      else if (remotePhoto?.url != null)
                        Image.network(
                          remotePhoto!.url!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackAsset(viewName),
                        )
                      else
                        _fallbackAsset(viewName),

                      // Pill Label overlay at bottom center (e.g. Top, Left, Right, Bottom)
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  // Tapping placeholder -> return to camera and capture missing view (Blue Note spec)
                  scan.switchActiveShoe(shoeIndex);
                  scan.setActiveView(viewName);
                  Navigator.pop(context);
                },
                child: CustomPaint(
                  painter: const DashedBorderPainter(
                    color: Color(0xFFF59E0B),
                    strokeWidth: 1.2,
                    radius: 12,
                    dashWidth: 4,
                    dashSpace: 3,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB), // Light cream
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, size: 20, color: Color(0xFFD97706)),
                        SizedBox(height: 2),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _fallbackAsset(String viewName) {
    switch (viewName.toLowerCase()) {
      case 'top':
        return Image.asset(AppAssets.viewfinderTop, fit: BoxFit.cover);
      case 'left':
        return Image.asset(AppAssets.viewfinderLeft, fit: BoxFit.cover);
      case 'right':
        return Image.asset(AppAssets.viewfinderRight, fit: BoxFit.cover);
      case 'sole':
      case 'bottom':
        return Image.asset(AppAssets.viewfinderBottom, fit: BoxFit.cover);
      default:
        return Image.asset(AppAssets.snapTop, fit: BoxFit.cover);
    }
  }

  void _showShoeOptions(
    BuildContext context, {
    required ScanProvider scan,
    required String shoeNum,
    required int shoeIndex,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Text(
                          'Shoe $shoeNum Options',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage photos grouped for this shoe',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Material(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              scan.removeShoe(shoeIndex);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Remove Shoe',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for the dashed orange border around missing view slots (Figma spec)
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.radius = 12.0,
    this.dashWidth = 4.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
