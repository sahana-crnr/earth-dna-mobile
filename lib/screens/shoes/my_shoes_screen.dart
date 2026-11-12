import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shoe_model.dart';
import '../../providers/shoes_provider.dart';
import '../../widgets/condition_badge.dart';
import 'shoe_profile_screen.dart';
import 'widgets/filter_bottom_sheet.dart';
import '../scan/camera_capture_screen.dart';

class MyShoesScreen extends StatefulWidget {
  const MyShoesScreen({super.key});

  @override
  State<MyShoesScreen> createState() => _MyShoesScreenState();
}

class _MyShoesScreenState extends State<MyShoesScreen> {
  bool _showBanner = true;

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoesProvider = Provider.of<ShoesProvider>(context);
    final shoes = shoesProvider.shoes;
    final summary = shoesProvider.summary;

    final pairsCount = summary?.totalShoes ?? shoes.length;
    final totalVal = summary?.potentialValueMax == null
        ? 'N/A'
        : '\$${summary!.potentialValueMax!.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: RefreshIndicator(
              onRefresh: () => shoesProvider.fetchShoesAndSummary(),
              color: AppColors.primaryGreenDark,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: 110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: MY SHOES + Filter icon (Figma filter SVG)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MY SHOES',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.24,
                            color: AppColors.textLightPrimary,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Filter shoes',
                          icon: AppAssets.svg(
                            AppAssets.filter,
                            color: AppColors.textLightPrimary,
                            width: 22,
                            height: 22,
                          ),
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          onPressed: () => _showFilters(context),
                        ),
                      ],
                    ),

                    if (shoes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Success Alert Banner (Figma SVGs)
                      if (_showBanner)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              AppAssets.svg(
                                AppAssets.success,
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$pairsCount pairs in your collection',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF14532D),
                                      ),
                                    ),
                                    const Text(
                                      'Your ShoeDNA profiles are ready.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _showBanner = false),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  alignment: Alignment.center,
                                  child: AppAssets.svg(
                                    AppAssets.dismiss,
                                    width: 14,
                                    height: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Summary values
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryMetric(
                              AppAssets.metricShoes,
                              '$pairsCount',
                              'Pairs Scanned',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade200,
                            ),
                            _buildSummaryMetric(
                              AppAssets.metricValue,
                              totalVal,
                              'Potential Value',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else
                      const SizedBox(height: 20),

                // 2-Column Shoe Grid
                if (shoes.isEmpty && shoesProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 56),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (shoes.isEmpty && shoesProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.cardLightBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 36),
                        const SizedBox(height: 12),
                        Text(
                          'Your shoes could not load',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check your connection and try again.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: shoesProvider.fetchShoesAndSummary,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                else if (shoes.isEmpty)
                  _buildEmptyState(context)
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.94,
                        ),
                    itemCount: shoes.length,
                    itemBuilder: (context, index) {
                      final shoe = shoes[index];
                      return _buildShoeGridCard(context, shoe);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildSummaryMetric(
    String svgPath,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppAssets.svg(
              svgPath,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShoeGridCard(BuildContext context, ShoeCardModel shoe) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ShoeProfileScreen(shoeId: shoe.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Top Left Condition Badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: shoe.primaryPhotoUrl != null
                        ? Image.network(
                            shoe.primaryPhotoUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: ConditionBadge(
                      code: shoe.conditionCode,
                      label: shoe.conditionLabel ?? 'Condition unavailable',
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shoe.brandName.isNotEmpty ? shoe.brandName : 'Brand unavailable',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [shoe.model, shoe.color]
                            .whereType<String>()
                            .where((value) => value.isNotEmpty)
                            .join(' - ')
                            .isEmpty
                        ? 'Model details unavailable'
                        : [shoe.model, shoe.color]
                              .whereType<String>()
                              .where((value) => value.isNotEmpty)
                              .join(' - '),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    shoe.resaleValueFormatted != null
                        ? '${shoe.recommendedAction ?? "Resell"} · ${shoe.resaleValueFormatted}'
                        : (shoe.recommendedAction != null
                            ? shoe.recommendedAction!
                            : 'Scan completed'),
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFEDFAD7), // Surface/Brand_Light from Figma
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // Elevation/md
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.emptyShoes,
              height: 280,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.roller_skating_outlined,
                size: 72,
                color: Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Shoes Scanned Yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start your sustainable journey by scanning your first pair. We\'ll help you find the best way to reuse or recycle them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonLime,
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CameraCaptureScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Scan your first pair',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.roller_skating, color: Color(0xFF94A3B8), size: 40),
      ),
    );
  }
}
