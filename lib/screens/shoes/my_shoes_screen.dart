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
    final totalVal = summary?.potentialValueMax != null
        ? '\$${summary!.potentialValueMax!.toStringAsFixed(0)}'
        : (shoes.isNotEmpty ? '\$0' : '--');
    final co2Val = summary?.co2SavingsKg != null
        ? '${summary!.co2SavingsKg!.toStringAsFixed(1)} Kg'
        : (shoes.isNotEmpty ? '0 Kg' : '--');

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
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: 110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: MY SHOES + Filter icon (Figma My Shoe)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MY SHOES',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Filter shoes',
                          icon: AppAssets.svg(
                            AppAssets.filter,
                            color: const Color(0xFF0F172A),
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

                      // Success Alert Banner (Figma: N pairs added to your collection)
                      if (_showBanner)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$pairsCount ${pairsCount == 1 ? "pair" : "pairs"} added to your collection',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
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
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Summary 3-Metric Values Box (Figma My Shoe)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
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
                            Expanded(
                              child: _buildSummaryMetric(
                                AppAssets.metricShoes,
                                '$pairsCount',
                                'Pairs Scanned',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 38,
                              color: const Color(0xFFF1F5F9),
                            ),
                            Expanded(
                              child: _buildSummaryMetric(
                                AppAssets.metricValue,
                                totalVal,
                                'Potential Value',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 38,
                              color: const Color(0xFFF1F5F9),
                            ),
                            Expanded(
                              child: _buildSummaryMetric(
                                AppAssets.metricImpact,
                                co2Val,
                                'CO\u2082e Impact',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2-Column Shoe Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: shoes.length,
                        itemBuilder: (context, index) {
                          final shoe = shoes[index];
                          return _buildShoeGridCard(context, shoe);
                        },
                      ),
                    ] else if (shoesProvider.isLoading) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      _buildEmptyState(context),
                    ],
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
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppAssets.svg(
              svgPath,
              width: 18,
              height: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildShoeGridCard(BuildContext context, ShoeCardModel shoe) {
    String subtitle = '';
    if (shoe.model != null && shoe.model!.isNotEmpty) {
      subtitle = shoe.model!;
      if (shoe.color != null && shoe.color!.isNotEmpty) {
        subtitle += ' • ${shoe.color}';
      }
    }

    String actionTag = shoe.recommendedAction ?? 'Resell';
    if (shoe.resaleValueFormatted != null) {
      actionTag += ' • ${shoe.resaleValueFormatted}';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(22),
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
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFF8FAFC),
                      child: shoe.primaryPhotoUrl != null
                          ? Image.network(
                              shoe.primaryPhotoUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: ConditionBadge(
                      code: shoe.conditionCode,
                      label: shoe.conditionLabel ?? 'Like New',
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shoe.brandName.isNotEmpty ? shoe.brandName : 'Footwear',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.isNotEmpty ? subtitle : 'Model details',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    actionTag,
                    style: TextStyle(
                      color: actionTag.toLowerCase().contains('recycle')
                          ? const Color(0xFF059669)
                          : (actionTag.toLowerCase().contains('repair')
                              ? const Color(0xFFD97706)
                              : const Color(0xFF15803D)),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
        child: Icon(Icons.photo_camera_outlined, color: Color(0xFF94A3B8), size: 36),
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
          color: const Color(0xFFEDFAD7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.roller_skating_outlined,
                size: 64,
                color: Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 20),
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
                    fontWeight: FontWeight.w800,
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
}
