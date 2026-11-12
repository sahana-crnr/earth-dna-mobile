import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/shoes_service.dart';
import '../../models/shoe_model.dart';
import '../../providers/shoes_provider.dart';
import '../../widgets/condition_badge.dart';
import 'condition_feedback_screen.dart';
import 'widgets/manage_shoe_bottom_sheet.dart';
import 'widgets/resale_value_bottom_sheet.dart';

class ShoeProfileScreen extends StatefulWidget {
  final String shoeId;

  const ShoeProfileScreen({super.key, required this.shoeId});

  @override
  State<ShoeProfileScreen> createState() => _ShoeProfileScreenState();
}

class _ShoeProfileScreenState extends State<ShoeProfileScreen> {
  final ShoesService _shoesService = ShoesService();
  ShoeProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _shoesService.getShoeDetail(widget.shoeId);
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showManageSheet() {
    if (_profile == null) return;
    ManageShoeBottomSheet.show(
      context,
      shoe: _profile!,
      onUpdated: _loadProfile,
      onDeleted: () async {
        final provider = Provider.of<ShoesProvider>(context, listen: false);
        await provider.deleteShoe(widget.shoeId);
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 40),
                const SizedBox(height: 16),
                Text('Shoe details could not load', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: _loadProfile, child: const Text('Try again')),
              ],
            ),
          ),
        ),
      );
    }

    final p = _profile!;
    final brand = p.brand.isNotEmpty ? p.brand : 'Brand unavailable';
    final model = p.model ?? 'Model details unavailable';
    final colorway = p.color ?? 'Colorway unavailable';
    final photos = p.photos;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Shoe Profile',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 26),
            onPressed: _showManageSheet,
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shoe summary and the best available product image
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brand.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Colorway: $colorway',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.roller_skating,
                          size: 48,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // "Your Scans" Section
            const Text(
              'Your Scans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildScanThumbnail(
                    'Top',
                    photos.isNotEmpty ? photos[0].url : null,
                  ),
                  const SizedBox(width: 10),
                  _buildScanThumbnail(
                    'Left',
                    photos.length > 1 ? photos[1].url : null,
                  ),
                  const SizedBox(width: 10),
                  _buildScanThumbnail(
                    'Right',
                    photos.length > 2 ? photos[2].url : null,
                  ),
                  const SizedBox(width: 10),
                  _buildScanThumbnail(
                    'Bottom',
                    photos.length > 3 ? photos[3].url : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Two Side-by-Side Metric Cards: Condition & Est. Resale Value
            Row(
              children: [
                // Condition Card (Tappable to submit condition feedback - Page 66)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (_profile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConditionFeedbackScreen(shoe: _profile!),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 140,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Condition',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.flag_outlined,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                          Builder(
                            builder: (context) {
                              final condConfig = ConditionBadge.getBadgeConfig(
                                code: p.conditionCode,
                                label: p.conditionLabel,
                              );
                              final gradeLetter = p.conditionGrade ??
                                  (p.conditionCode != null && p.conditionCode!.length >= 2
                                      ? p.conditionCode!.substring(1)
                                      : 'N/A');
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: condConfig.$1,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        gradeLetter,
                                        style: TextStyle(
                                          color: condConfig.$2,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    p.conditionLabel ?? condConfig.$3,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: condConfig.$2,
                                    ),
                                  ),
                                  Text(
                                    p.conditionDescription ?? 'Condition details unavailable',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Resale Value Card (Info icon opens Resale Value Sheet - Page 67)
                Expanded(
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Est. Resale Value',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ResaleValueBottomSheet.show(context),
                              child: const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          p.resaleValueFormatted ?? 'Resale estimate unavailable',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: 0.82,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF84CC16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'High Demand Silhouette',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // "Recommended for you" Card (Resell this pair)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
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
                      const Text(
                        'Recommended for you',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ValueLens™',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Resell this pair',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Due to high demand and exceptional condition, keeping this pair in circulation maximizes value.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonLime,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Start resale process',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See other options',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Material Profile Section
            const Text(
              'Material Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMaterialRow('Upper', 'Mesh / Synthetic Leather'),
                  const Divider(height: 20),
                  _buildMaterialRow('Midsole', 'Air-Sole Cushioning / EVA'),
                  const Divider(height: 20),
                  _buildMaterialRow('Outsole', 'Rubber Waffle (75% natural)'),
                  const Divider(height: 20),
                  _buildMaterialRow('Laces', 'Recycled Polyester'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Carbon Footprint Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimated carbon footprint',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'CircularSort™',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '12.4 Kg CO₂e',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Estimated based on shoe type, materials, and construction.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildScanThumbnail(String label, String? url) {
    return Container(
      width: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: url != null
                ? Image.network(url, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.photo_camera, color: Colors.grey),
                  ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
