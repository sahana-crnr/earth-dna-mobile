import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/scan_service.dart';
import '../../models/catalog_model.dart';
import '../../providers/shoes_provider.dart';
import '../../widgets/condition_badge.dart';
import '../navigation/main_nav_scaffold.dart';

class MatchReviewScreen extends StatefulWidget {
  final Map<String, dynamic>? resultsData;

  const MatchReviewScreen({super.key, this.resultsData});

  @override
  State<MatchReviewScreen> createState() => _MatchReviewScreenState();
}

class _MatchReviewScreenState extends State<MatchReviewScreen> {
  final CatalogService _catalogService = CatalogService();
  final ScanService _scanService = ScanService();

  late Map<String, dynamic> _data;
  List<CatalogBrand> _brands = [];
  List<CatalogSize> _sizes = [];
  bool _isSubmitting = false;
  int _activeShoeIndex = 0;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.resultsData ?? {});
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final brands = await _catalogService.getBrands();
    final sizes = await _catalogService.getSizes();
    if (mounted) {
      setState(() {
        _brands = brands;
        _sizes = sizes;
      });
    }
  }

  List<dynamic> get _shoes => _data['shoes'] as List? ?? [];

  void _confirmMatch(Map<String, dynamic> shoeItem) async {
    setState(() => _isSubmitting = true);
    final scanId = _data['scanId'] as String? ?? '';
    final shoeId = shoeItem['shoeId'] as String;

    try {
      await _scanService.confirmShoe(scanId: scanId, shoeId: shoeId);

      final updated = await _scanService.getResults(scanId);
      if (mounted) {
        setState(() {
          _data = updated;
          if (_activeShoeIndex < _shoes.length - 1) {
            _activeShoeIndex++;
          }
        });
        Provider.of<ShoesProvider>(
          context,
          listen: false,
        ).fetchShoesAndSummary();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_activeShoeIndex < _shoes.length - 1) {
            _activeShoeIndex++;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showFindMyShoeModal(Map<String, dynamic> shoeItem) {
    final shoeId = shoeItem['shoeId'] as String;
    final result = shoeItem['result'] as Map<String, dynamic>? ?? {};

    String? selectedBrandId = _brands.isNotEmpty ? _brands.first.id : null;
    final modelCtrl = TextEditingController(
      text: result['model'] as String? ?? 'Sneaker',
    );
    final colorCtrl = TextEditingController(
      text: result['colorway'] as String? ?? 'Black/White',
    );
    String? selectedSizeId = _sizes.isNotEmpty ? _sizes[8].id : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  padding: EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Find Your Shoe',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select brand and model to correct the ShoeDNA match.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Brand Dropdown
                        const Text(
                          'Brand',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedBrandId,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items: _brands
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setModalState(() => selectedBrandId = v),
                        ),
                        const SizedBox(height: 14),

                        // Model Field
                        const Text(
                          'Model',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: modelCtrl,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonLime,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final scanId = _data['scanId'] as String? ?? '';
                              await _scanService.rejectShoe(
                                scanId: scanId,
                                shoeId: shoeId,
                                brandId: selectedBrandId ?? '',
                                model: modelCtrl.text,
                                color: colorCtrl.text,
                                sizeId: selectedSizeId ?? '',
                              );
                              final updated = await _scanService.getResults(
                                scanId,
                              );
                              if (mounted) setState(() => _data = updated);
                            },
                            child: const Text(
                              'Update & Confirm Match',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _finishAndGoHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavScaffold(initialIndex: 1)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shoes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Matches'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'All matches confirmed!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonLime,
                  foregroundColor: Colors.black,
                ),
                onPressed: _finishAndGoHome,
                child: const Text('Go to My Shoes'),
              ),
            ],
          ),
        ),
      );
    }

    final currentShoe =
        _shoes[_activeShoeIndex.clamp(0, _shoes.length - 1)]
            as Map<String, dynamic>;
    final result = currentShoe['result'] as Map<String, dynamic>? ?? {};
    final brandName = result['brand'] as String? ?? 'Brand unavailable';
    final modelName = result['model'] as String? ?? 'Model details unavailable';
    final matchPercent = result['matchPercent'] as int?;
    final condMap = result['condition'] as Map<String, dynamic>?;

    final progressVal = (_activeShoeIndex + 1) / _shoes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
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
        title: const Text(
          'Review Matches',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 22),
            onPressed: _finishAndGoHome,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progressVal,
            backgroundColor: const Color(0xFFEAF8D7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF84CC16)),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We found matches for ${_shoes.length} pairs. Take a quick look at each one to make sure we got it right.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Match Review Card (Figma match_found.png)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Top: Shoe 01 & 1 of 4 Reviewed
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentShoe['label'] as String? ??
                                    'Shoe 0${_activeShoeIndex + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_activeShoeIndex + 1} Of ${_shoes.length} Reviewed',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 4 Scanned Photos Montage
                        Builder(
                          builder: (context) {
                            final rawPhotos =
                                currentShoe['photos'] as List? ?? [];
                            return SizedBox(
                              height: 160,
                              child: Row(
                                children: List.generate(4, (photoIdx) {
                                  final labels = [
                                    'top',
                                    'left',
                                    'right',
                                    'bottom',
                                  ];
                                  final photoUrl = photoIdx < rawPhotos.length
                                      ? rawPhotos[photoIdx]['url'] as String?
                                      : null;

                                  return Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: photoIdx == 0 ? 0 : 2,
                                        right: photoIdx == 3 ? 0 : 2,
                                      ),
                                      color: const Color(0xFFF1F5F9),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (photoUrl != null)
                                            Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  _buildAnglePlaceholder(
                                                    labels[photoIdx],
                                                  ),
                                            )
                                          else
                                            _buildAnglePlaceholder(
                                              labels[photoIdx],
                                            ),
                                          if (photoIdx == 0)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'YOUR SCAN',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),

                        // Divider with Centered Pill: "⚡ 94% Match"
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Divider(
                              height: 32,
                              thickness: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFC7D2FE),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: Color(0xFF4338CA),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    matchPercent == null
                                        ? 'Match score unavailable'
                                        : '$matchPercent% Match',
                                    style: const TextStyle(
                                      color: Color(0xFF4338CA),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Catalog Match Details
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.roller_skating,
                                    size: 32,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ConditionBadge(
                                      code: condMap?['code'] as String?,
                                      label:
                                          condMap?['label'] as String? ??
                                          'Condition unavailable',
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      brandName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      modelName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Bottom Section: This Shoe Was Added To My Shoes
                  const Center(
                    child: Text(
                      'This Shoe Was Added To My Shoes',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'You can change this decision later from My Shoes.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Two Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => _showFindMyShoeModal(currentShoe),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'No, find my shoe',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonLime,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () => _confirmMatch(currentShoe),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "That's my shoe",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Carousel Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_shoes.length, (idx) {
                      final isActive = _activeShoeIndex == idx;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF84CC16)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Footer Note
                  const Center(
                    child: Text(
                      'ShoeDNA™ Is Always Learning. Confirming The Match Helps Improve\nFuture Circularity Options.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnglePlaceholder(String label) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_camera_outlined,
              size: 24,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
