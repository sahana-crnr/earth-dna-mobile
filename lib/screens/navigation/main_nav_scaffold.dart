import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/shoes_provider.dart';
import '../home/home_dashboard_screen.dart';
import '../shoes/my_shoes_screen.dart';
import '../scan/camera_capture_screen.dart';
import '../scan/album_upload_screen.dart';

class MainNavScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoesProvider>(context, listen: false).fetchShoesAndSummary();
    });
  }

  void _showScanOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Start Footwear Scan',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Capture 4 views (top, left, right, bottom) for instant ShoeDNA identification.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Option 1: Live 4-Angle Guided Camera
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tileColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.black87),
                  ),
                  title: const Text(
                    'Guided Camera Scan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Step-by-step 4-angle reticle guide',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CameraCaptureScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Option 2: Batch Album Upload
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tileColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.blueAccent,
                    ),
                  ),
                  title: const Text(
                    'Batch Upload from Album',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Upload up to 3 pairs (12 photos) at once',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AlbumUploadScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
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
    final screens = [
      HomeDashboardScreen(
        onMarketplaceTap: () => setState(() => _currentIndex = 2),
        onViewAllTap: () => setState(() => _currentIndex = 1),
      ),
      const MyShoesScreen(),
      _buildMarketplaceTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              IndexedStack(index: _currentIndex, children: screens),

              // Floating Bottom Navigation Dock (Optimized for iOS Home Bar & Android Gesture Nav)
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom + 6
                    : 16,
                child: Row(
                  children: [
                    // Navigation Pill (Home, My Shoe, Marketplace)
                    Expanded(
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildNavItem(0, AppAssets.navHome, 'Home'),
                            ),
                            Expanded(
                              child: _buildNavItem(
                                1,
                                AppAssets.navShoes,
                                'My Shoe',
                              ),
                            ),
                            Expanded(
                              child: _buildNavItem(
                                2,
                                AppAssets.navMarketplace,
                                'Marketplace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Floating Circular Scan Button (Figma Lime Green Button)
                    Semantics(
                      button: true,
                      label: 'Scan a pair',
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showScanOptionsModal();
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.buttonLime,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AppAssets.svg(
                              AppAssets.navScan,
                              color: Colors.black,
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String svgPath, String label) {
    final isSelected = _currentIndex == index;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAssets.svg(
                svgPath,
                color: isSelected
                    ? AppColors.textLightPrimary
                    : AppColors.textLightMuted,
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textLightPrimary
                        : AppColors.textLightMuted,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Marketplace', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_outlined, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Marketplace', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Listings will appear here when they are available.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
