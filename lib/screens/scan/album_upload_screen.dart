import 'dart:io' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/scan_provider.dart';
import 'scan_processing_screen.dart';

class AlbumUploadScreen extends StatefulWidget {
  const AlbumUploadScreen({super.key});

  @override
  State<AlbumUploadScreen> createState() => _AlbumUploadScreenState();
}

class _AlbumUploadScreenState extends State<AlbumUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Auto-prompt picker on screen open (Matches "Album Opened" flow)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImages();
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        limit: 12,
      );

      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedFiles.clear();
          _selectedFiles.addAll(images.take(12));
        });
      }
    } catch (_) {}
  }

  Future<void> _handleUpload() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);
    final scan = Provider.of<ScanProvider>(context, listen: false);

    try {
      await scan.startNewScan();

      // Upload selected files sequentially into the session
      for (int i = 0; i < _selectedFiles.length; i++) {
        final viewIndex = i % 4;
        if (i > 0 && viewIndex == 0) {
          await scan.addAnotherShoe();
        }
        await scan.captureAndUploadView(imageFile: _selectedFiles[i]);
      }

      await scan.finishScanSession();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ScanProcessingScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showShoeOptions(BuildContext context, int shoeIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        final shoeNum = (shoeIndex + 1).toString().padLeft(2, '0');
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
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
                    const SizedBox(height: 20),

                    // Rename Shoe
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20, color: Color(0xFF0F172A)),
                            SizedBox(width: 14),
                            Text(
                              'Rename Shoe',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    // Remove Shoe
                    InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          final start = shoeIndex * 4;
                          final end = (start + 4).clamp(0, _selectedFiles.length);
                          if (start < _selectedFiles.length) {
                            _selectedFiles.removeRange(start, end);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                            SizedBox(width: 14),
                            Text(
                              'Remove Shoe',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Total pairs represented (each pair expects 4 views)
    final int count = _selectedFiles.length;
    final int totalPairs = count == 0 ? 1 : ((count + 3) ~/ 4).clamp(1, 3);
    final int expectedSlots = totalPairs * 4;
    final int missingCount = expectedSlots - count;
    final bool isComplete = count > 0 && missingCount == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Review Photos',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Headline & Subtitle (Figma: Incomplete vs Complete)
                        Center(
                          child: Text(
                            isComplete
                                ? 'Your Photos Are Ready'
                                : 'Check Each Pair Has 4 Views',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            isComplete
                                ? 'Make sure each pair includes all 4 views:\ntop, left, right, and sole.'
                                : 'Each pair needs 4 different views:\ntop, left, right, and sole.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Card: "X photos uploaded" with 3-dots icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$count photos uploaded',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 20,
                                      color: Color(0xFF64748B),
                                    ),
                                    onPressed: () => _showShoeOptions(context, 0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 4-Column Photo Grid with Dashed Placeholders
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: expectedSlots,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.85,
                                ),
                                itemBuilder: (context, index) {
                                  if (index < count) {
                                    final file = _selectedFiles[index];
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: kIsWeb
                                              ? Image.network(file.path, fit: BoxFit.cover)
                                              : Image.file(
                                                  io.File(file.path),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedFiles.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Missing view slot (Figma dashed + Add Image)
                                    return GestureDetector(
                                      onTap: _pickImages,
                                      child: CustomPaint(
                                        painter: const _AlbumDashedPainter(
                                          color: Color(0xFFF59E0B),
                                          strokeWidth: 1.2,
                                          radius: 12,
                                          dashWidth: 4,
                                          dashSpace: 3,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFBEB),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.add,
                                                size: 20,
                                                color: Color(0xFFD97706),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                '+ Add Image',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFD97706),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Section: Button & Subtext
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isComplete
                                ? AppColors.buttonLime
                                : const Color(0xFFF1F5F9),
                            foregroundColor: isComplete
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: isComplete && !_isUploading
                              ? _handleUpload
                              : null,
                          child: _isUploading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0F172A),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Finish Scanning',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      if (!isComplete && count > 0) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Add $missingCount More ${missingCount == 1 ? "Photo" : "Photos"} To Continue',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumDashedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const _AlbumDashedPainter({
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
  bool shouldRepaint(covariant _AlbumDashedPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
