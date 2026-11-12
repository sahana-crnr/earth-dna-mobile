import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/primary_button.dart';
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

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
      limit: 12,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedFiles.clear();
        _selectedFiles.addAll(images.take(12));
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Review Photos',
          style: TextStyle(
            color: Colors.black,
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
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Your Photos Are Ready',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Make sure each pair includes all 4 views:\ntop, left, right, and sole.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: _selectedFiles.isEmpty
                    ? GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Select Photos from Album',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Pick 4 views per shoe (up to 12 photos / 3 pairs)',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.buttonLime,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Browse Gallery',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
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
                                  '${_selectedFiles.length} photos uploaded',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  onPressed: _pickImages,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: GridView.builder(
                                itemCount: _selectedFiles.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 0.75,
                                    ),
                                itemBuilder: (context, index) {
                                  final file = _selectedFiles[index];
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: FutureBuilder<Uint8List>(
                                          future: file.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                              );
                                            }
                                            return Container(
                                              color: Colors.grey.shade200,
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(
                                              () => _selectedFiles.removeAt(
                                                index,
                                              ),
                                            );
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
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 16),
              PrimaryButton(
                text: _selectedFiles.isEmpty
                    ? 'Pick Photos from Gallery'
                    : 'Finish Scanning',
                isLoading: _isUploading,
                onPressed: _selectedFiles.isEmpty ? _pickImages : _handleUpload,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}
