import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/scan_session_model.dart';
import '../../providers/scan_provider.dart';
import 'album_upload_screen.dart';
import 'review_scans_screen.dart';
import 'scan_processing_screen.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isLoadingCamera = true;
  bool _isFlashOn = false;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _initHardwareCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanProvider>(context, listen: false).startNewScan();
    });
  }

  Future<void> _initHardwareCamera() async {
    if (mounted) {
      setState(() => _isLoadingCamera = true);
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final backCam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        _cameraController = CameraController(
          backCam,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
            _isLoadingCamera = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Hardware camera init skipped: $e');
    }
    if (mounted) {
      setState(() {
        _isLoadingCamera = false;
        _isCameraReady = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    setState(() => _isFlashOn = !_isFlashOn);
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    HapticFeedback.mediumImpact();
    try {
      XFile? photo;
      if (_isCameraReady &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        photo = await _cameraController!.takePicture();
      } else {
        photo = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
      }

      if (photo != null) {
        await _processCapturedPhoto(photo);
      }
    } catch (_) {
      // Show native Camera Permission dialog on permission exception
      if (mounted) {
        _showCameraPermissionDialog();
      }
      _pickFromGallery();
    }
  }

  void _showCameraPermissionDialog() {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('"SHOES" Would Like to Access the Camera'),
          content: const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Allow access to the camera to take photos.'),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Don't Allow"),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Camera Permission Needed'),
          content: const Text(
            'Allow EarthDNA to access the camera to capture shoes for ShoeDNA identification.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Don't Allow"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Allow'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.selectionClick();
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null) {
        await _processCapturedPhoto(photo);
      }
    } catch (_) {}
  }

  void _showUploadFromAlbumModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Color(0xFF1E242B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Upload Photos For Up To 3 Pairs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select 4 different angles of each pair, up to 12 photos total.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary Button: Upload from album
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonLime,
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlbumUploadScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Upload from album',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary Button: Keep scanning
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF15191E),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Keep scanning',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Future<void> _processCapturedPhoto(XFile photo) async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final success = await scanProvider.captureAndUploadView(imageFile: photo);

    if (success && mounted) {
      HapticFeedback.lightImpact();
      _bannerTimer?.cancel();
      _bannerTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Provider.of<ScanProvider>(
            context,
            listen: false,
          ).clearLastCapturedConfirmation();
        }
      });

      _checkCompleteness();
    }
  }

  void _checkCompleteness() {
    final scan = Provider.of<ScanProvider>(context, listen: false);
    if (scan.isShoeComplete(scan.activeShoeIndex)) {
      Timer(const Duration(milliseconds: 1400), () {
        if (mounted) {
          HapticFeedback.heavyImpact();
          _showShoeCompleteModal();
        }
      });
    }
  }

  void _selectView(String view) {
    HapticFeedback.selectionClick();
    _bannerTimer?.cancel();
    Provider.of<ScanProvider>(context, listen: false).setActiveView(view);
  }

  void _removeViewPhoto(String view) {
    HapticFeedback.lightImpact();
    _bannerTimer?.cancel();
    final scan = Provider.of<ScanProvider>(context, listen: false);
    scan.removePhoto(scan.activeShoeIndex, view);
  }

  void _showShoeCompleteModal() {
    final scan = Provider.of<ScanProvider>(context, listen: false);
    final shoeNumber = scan.activeShoeIndex + 1;
    final shoe = scan.currentShoe;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E242B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Checkmark in Lime green circle (Figma confirm modal)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors
                              .buttonLime, // Action/Primary/BG/default #B5E076
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            size: 34,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Shoe 0$shoeNumber Is Complete',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'All 4 views are captured.\nWhat would you like to do next?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2x2 Photo Review Grid (Figma confirm modal)
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (int i = 0; i < 4; i++)
                              Builder(
                                builder: (_) {
                                  final vKey = ScanProvider.viewsOrder[i];
                                  final localFile = scan.getLocalPhoto(
                                    scan.activeShoeIndex,
                                    vKey,
                                  );
                                  final photo = shoe?.photoForView(vKey);

                                  Widget content;
                                  if (localFile != null) {
                                    content = kIsWeb
                                        ? Image.network(
                                            localFile.path,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            io.File(localFile.path),
                                            fit: BoxFit.cover,
                                          );
                                  } else if (photo?.url != null &&
                                      photo!.url!.isNotEmpty) {
                                    content = Image.network(
                                      photo.url!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _buildAngleIllustration(
                                            _getAssetForView(vKey),
                                            true,
                                          ),
                                    );
                                  } else {
                                    content = _buildAngleIllustration(
                                      _getAssetForView(vKey),
                                      false,
                                    );
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      color: const Color(0xFFF1F5F9),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: content,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Finish Scanning Button (Figma Lime green pill)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonLime,
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await scan.finishScanSession();
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const ScanProcessingScreen(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Finish Scanning',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Scan Another Shoe Button (Figma Outlined pill)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await scan.addAnotherShoe();
                          },
                          child: const Text(
                            'Scan another shoe',
                            style: TextStyle(
                              fontSize: 15,
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
        );
      },
    );
  }

  void _showExitConfirmationModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E242B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Text(
                        "You're Almost Done!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your photos are saved automatically, so\nyou can exit now and finish anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Continue Scanning Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonLime,
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'Continue Scanning',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Save & Exit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Save & Exit',
                            style: TextStyle(
                              fontSize: 15,
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
        );
      },
    );
  }

  void _showScannedCollectionsDropdown() {
    final scan = Provider.of<ScanProvider>(context, listen: false);
    final session = scan.session;
    final shoes = session?.shoes ?? [];

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
              color: const Color(0xFF1E242B),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Scanned Collections',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${shoes.isNotEmpty ? shoes.length : 1} Shoes Total',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        for (
                          int i = 0;
                          i < (shoes.isNotEmpty ? shoes.length : 1);
                          i++
                        ) ...[
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              scan.switchActiveShoe(i);
                              Navigator.pop(ctx);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.roller_skating,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Shoe 0${i + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          i < shoes.length && shoes[i].complete
                                              ? 'Fully Scanned'
                                              : 'In Progress',
                                          style: TextStyle(
                                            color:
                                                i < shoes.length &&
                                                    shoes[i].complete
                                                ? AppColors.primaryGreen
                                                : Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  i < shoes.length && shoes[i].complete
                                      ? const Icon(
                                          Icons.check,
                                          color: AppColors.primaryGreen,
                                          size: 20,
                                        )
                                      : const Icon(
                                          Icons.radio_button_unchecked,
                                          color: Colors.white30,
                                          size: 20,
                                        ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(color: Colors.white12),
                        ],
                        const SizedBox(height: 8),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReviewScansScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Review all',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
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

  void _showSnapTipsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Snap tips',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'These views help us identify your shoe, assess its condition, and recommend what to do next.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Capture Each Shoe From 4 Angles',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4 Angles preview row (Figma Snap Tips Page 17)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAngleTip('TOP', AppAssets.snapTop),
                          _buildAngleTip('RIGHT', AppAssets.snapRight),
                          _buildAngleTip('LEFT', AppAssets.snapLeft),
                          _buildAngleTip('BOTTOM', AppAssets.snapBottom),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // For best results card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'For best results',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '• One shoe at a time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '• Place it on a flat surface with good lighting',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Avoid Section (Figma Page 17)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Avoid',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAvoidTip('Multiple', AppAssets.avoidMultiple),
                          _buildAvoidTip('Cropped', AppAssets.avoidCropped),
                          _buildAvoidTip('Too Dark', AppAssets.avoidDark),
                          _buildAvoidTip('Blurry', AppAssets.avoidBlurry),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A5A5A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Got it',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
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
        );
      },
    );
  }

  Widget _buildAngleTip(String label, String assetPath) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.camera_alt_outlined, color: Color(0xFF94A3B8)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildAvoidTip(String label, String assetPath) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.block, color: Color(0xFFEF4444)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  String _formatViewTitle(String view) {
    switch (view.toLowerCase()) {
      case 'top':
        return 'Top View';
      case 'right':
        return 'Right View';
      case 'left':
        return 'Left View';
      case 'sole':
      case 'bottom':
        return 'Bottom View';
      default:
        return '${view[0].toUpperCase()}${view.substring(1)} View';
    }
  }

  String _formatViewBanner(String view) {
    switch (view.toLowerCase()) {
      case 'top':
        return 'Top view';
      case 'right':
        return 'Right view';
      case 'left':
        return 'Left view';
      case 'sole':
      case 'bottom':
        return 'Bottom view';
      default:
        return '${view[0].toUpperCase()}${view.substring(1)} view';
    }
  }

  String _getInstructionText(String activeView) {
    switch (activeView.toLowerCase()) {
      case 'top':
        return 'Place the shoe flat and capture it from above';
      case 'right':
        return 'Capture the Right side of the shoe.';
      case 'left':
        return 'Capture the Left side of the shoe.';
      case 'sole':
      case 'bottom':
        return 'Capture the Bottom of the shoe.';
      default:
        return 'Capture the shoe.';
    }
  }

  String _getViewfinderAsset(String view) {
    switch (view.toLowerCase()) {
      case 'top':
        return AppAssets.viewfinderTop;
      case 'right':
        return AppAssets.viewfinderRight;
      case 'left':
        return AppAssets.viewfinderLeft;
      case 'sole':
      case 'bottom':
        return AppAssets.viewfinderBottom;
      default:
        return AppAssets.viewfinderTop;
    }
  }

  String _getAssetForView(String view) {
    switch (view.toLowerCase()) {
      case 'top':
        return AppAssets.snapTop;
      case 'right':
        return AppAssets.snapRight;
      case 'left':
        return AppAssets.snapLeft;
      case 'sole':
      case 'bottom':
      default:
        return AppAssets.snapBottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scan = Provider.of<ScanProvider>(context);
    final activeView = scan.activeView;
    final shoe = scan.currentShoe;
    final capturedCount = scan.getCapturedCount(scan.activeShoeIndex);
    final confirmedView = scan.lastCapturedView;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmationModal();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                children: [
                  // Top Bar: ✕, Shoe 01 ⌵, Lightbulb, Flash
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: math.max(MediaQuery.of(context).padding.top + 8.0, 24.0),
                      bottom: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _showExitConfirmationModal,
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

                        // Shoe selector pill (Tappable - Page 32 Scanned Collections)
                        GestureDetector(
                          onTap: _showScannedCollectionsDropdown,
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
                                  'Shoe 0${scan.activeShoeIndex + 1}',
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

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _showSnapTipsModal,
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
                              onTap: _toggleFlash,
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
                                    color: _isFlashOn
                                        ? Colors.white24
                                        : Colors.white12,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isFlashOn
                                        ? Icons.flash_on
                                        : Icons.flash_off,
                                    color: _isFlashOn
                                        ? AppColors.buttonLime
                                        : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Camera Viewfinder Canvas with floating instructions (Matches Figma screens)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF1E242B),
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                              // 1. Live Camera Feed or Authentic Shoe Viewfinder Preview
                              if (_isCameraReady &&
                                  _cameraController != null &&
                                  _cameraController!.value.isInitialized)
                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _cameraController!
                                            .value.previewSize?.height ??
                                        1,
                                    height: _cameraController!
                                            .value.previewSize?.width ??
                                        1,
                                    child: CameraPreview(_cameraController!),
                                  ),
                                )
                              else if (_isLoadingCamera)
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
                                          onPressed: _initHardwareCamera,
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
                                                '${_formatViewBanner(confirmedView)} captured',
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

                              if (scan.isUploading)
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
                        ),
                      ),

                  // Angle Selector Strip
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAngleSlot(
                              'top',
                              AppAssets.snapTop,
                              activeView == 'top',
                              shoe?.photoForView('top'),
                              scan,
                            ),
                            const SizedBox(width: 6),
                            _buildAngleSlot(
                              'left',
                              AppAssets.snapLeft,
                              activeView == 'left',
                              shoe?.photoForView('left'),
                              scan,
                            ),
                            const SizedBox(width: 6),
                            _buildAngleSlot(
                              'right',
                              AppAssets.snapRight,
                              activeView == 'right',
                              shoe?.photoForView('right'),
                              scan,
                            ),
                            const SizedBox(width: 6),
                            _buildAngleSlot(
                              'sole',
                              AppAssets.snapBottom,
                              activeView == 'sole',
                              shoe?.photoForView('sole'),
                              scan,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shutter Controls Row
                  Builder(
                    builder: (context) {
                      final bool isCurrentViewCaptured =
                          scan.isViewCaptured(scan.activeShoeIndex, activeView);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Gallery Button -> opens "Upload Photos For Up To 3 Pairs" modal
                            GestureDetector(
                              onTap: _showUploadFromAlbumModal,
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
                              onTap: scan.isUploading ? null : _takePhoto,
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
                                  _takePhoto();
                                } else if (capturedCount >= 4) {
                                  _showShoeCompleteModal();
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
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAngleSlot(
    String key,
    String assetPath,
    bool isActive,
    ScanPhoto? photo,
    ScanProvider scan,
  ) {
    final localFile = scan.getLocalPhoto(scan.activeShoeIndex, key);
    final hasRemote = photo?.url != null && photo!.url!.isNotEmpty;
    final isCaptured = localFile != null || hasRemote;

    final borderColor = isActive
        ? const Color(0xFFD2F544) // Figma lime/yellow dashed border for active
        : const Color(0xFF475569); // Figma subtle dashed slate for inactive

    return GestureDetector(
      onTap: () => _selectView(key),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dark Container Fill
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E242B),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Dashed Border (lime for active, slate for inactive)
            if (!isCaptured)
              Positioned.fill(
                child: CustomPaint(
                  painter: DashedRRectPainter(
                    color: borderColor,
                    strokeWidth: isActive ? 1.5 : 1.0,
                    radius: 12.0,
                  ),
                ),
              ),

            // Content: Captured Photo or Outline Illustration
            if (isCaptured)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 44,
                  height: 44,
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

            // Figma '×' retake badge on captured slot
            if (isCaptured)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeViewPhoto(key),
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

  Widget _buildAngleIllustration(String assetPath, bool isActive) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        color: isActive ? Colors.white : const Color(0xFF94A3B8),
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}

class DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.2,
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

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        ),
        Radius.circular(radius),
      ));

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = math.min(dashWidth, metric.length - distance);
        final segment = metric.extractPath(distance, distance + length);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
