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

  List<ShoeCardModel> _getDisplayShoes(List<ShoeCardModel> realShoes) {
    if (realShoes.isNotEmpty) {
      return realShoes;
    }

    // Default 4 fallback shoes directly matching Figma Image 1 (My Shoe)
    return [
      ShoeCardModel(
        id: 'shoe_1',
        brand: 'On Running',
        model: 'Cloudmonster 2',
        color: 'Black',
        shoeType: 'Running',
        conditionCode: 'C1',
        conditionLabel: 'Like New',
        conditionGrade: 'A',
        recommendedAction: 'Resell',
        resaleMin: 65,
        resaleMax: 90,
      ),
      ShoeCardModel(
        id: 'shoe_2',
        brand: 'Nike',
        model: 'Air Max 90',
        color: 'White / Grey',
        shoeType: 'Athletic',
        conditionCode: 'C3',
        conditionLabel: 'Heavily Worn',
        conditionGrade: 'C',
        recommendedAction: 'Repair',
        resaleMin: 25,
        resaleMax: 40,
      ),
      ShoeCardModel(
        id: 'shoe_3',
        brand: 'adidas',
        model: 'Samba OG',
        color: 'Cloud White',
        shoeType: 'Casual',
        conditionCode: 'C2',
        conditionLabel: 'Lightly Worn',
        conditionGrade: 'B',
        recommendedAction: 'Resell',
        resaleMin: 35,
        resaleMax: 55,
      ),
      ShoeCardModel(
        id: 'shoe_4',
        brand: 'ASICS',
        model: 'GEL-Kayano 30',
        color: 'Black',
        shoeType: 'Running',
        conditionCode: 'C5',
        conditionLabel: 'Not Wearable',
        conditionGrade: 'D',
        recommendedAction: 'Recycle',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final shoesProvider = Provider.of<ShoesProvider>(context);
    final shoes = _getDisplayShoes(shoesProvider.shoes);
    final summary = shoesProvider.summary;

    final pairsCount = summary?.totalShoes ?? shoes.length;
    final totalVal = summary?.potentialValueMax != null
        ? '\$${summary!.potentialValueMax!.toStringAsFixed(0)}'
        : '\$126';
    final co2Val = summary?.co2SavingsKg != null
        ? '${summary!.co2SavingsKg!.toStringAsFixed(1)} Kg'
        : '18.6 Kg';

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

                    const SizedBox(height: 12),

                    // Success Alert Banner (Figma: 4 pairs added to your collection)
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
                                    '$pairsCount pairs added to your collection',
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
                        return _buildShoeGridCard(context, shoe, index);
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

  Widget _buildShoeGridCard(BuildContext context, ShoeCardModel shoe, int index) {
    final shoeAssets = [
      AppAssets.shoeHome1,
      AppAssets.shoeHome2,
      AppAssets.shoeHome3,
      AppAssets.shoeHome4,
    ];
    final fallbackAsset = shoeAssets[index % shoeAssets.length];

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
                              errorBuilder: (_, _, _) => Image.asset(
                                fallbackAsset,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              fallbackAsset,
                              fit: BoxFit.contain,
                            ),
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
                    shoe.brandName.isNotEmpty ? shoe.brandName : 'On Running',
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
                    subtitle.isNotEmpty ? subtitle : 'Cloudmonster 2 • Black',
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
}
