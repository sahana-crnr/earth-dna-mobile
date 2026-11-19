import 'dart:io' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/scan_service.dart';
import '../../models/catalog_model.dart';
import '../../providers/scan_provider.dart';
import '../../providers/shoes_provider.dart';
import '../../widgets/bottom_sheet_drag_handle.dart';
import '../../widgets/condition_badge.dart';
import '../navigation/main_nav_scaffold.dart';
import 'camera_capture_screen.dart';

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
  bool _isSubmitting = false;
  int _activeShoeIndex = 0;

  // Track confirmation per shoe index
  final Map<int, bool> _confirmedShoes = {};

  // Custom added brands
  final List<String> _availableBrands = [
    'On Running',
    'New Balance',
    'On',
    'Hoka',
    'Nike',
    'Adidas',
    'ASICS',
    'Puma',
    'Salomon',
  ];

  late List<Map<String, dynamic>> _shoes;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.resultsData ?? {});
    _initializeShoes();
    _loadCatalog();
  }

  void _initializeShoes() {
    final rawShoes = _data['shoes'] as List?;
    if (rawShoes != null && rawShoes.isNotEmpty) {
      _shoes = rawShoes.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final res = Map<String, dynamic>.from(m['result'] as Map? ?? {});
        final cond = res['condition'] as Map? ?? {};
        return {
          'shoeId': m['shoeId']?.toString() ?? 'shoe_${DateTime.now().millisecondsSinceEpoch}',
          'label': m['label']?.toString() ?? 'Shoe 01',
          'brand': res['brand']?.toString() ?? 'Identified Shoe',
          'model': res['model']?.toString() ?? 'Sneaker',
          'category': res['category']?.toString() ?? 'Athletic Shoes',
          'subcategory': res['subcategory']?.toString() ?? 'Running Shoes',
          'condition': cond['label']?.toString() ?? 'Like New',
          'conditionCode': cond['code']?.toString() ?? 'C1',
          'color': res['colorway']?.toString() ?? 'Original',
          'size': res['size']?.toString() ?? 'US M-9',
          'matchPercent': res['matchPercent'] as int? ?? 95,
          'photos': m['photos'] as List? ?? [],
        };
      }).toList();
    } else {
      final session = Provider.of<ScanProvider>(context, listen: false).session;
      if (session != null && session.shoes.isNotEmpty) {
        _shoes = session.shoes.asMap().entries.map((entry) {
          final idx = entry.key;
          final s = entry.value;
          return {
            'shoeId': s.id.isNotEmpty ? s.id : 'shoe_${idx + 1}',
            'label': s.label.isNotEmpty ? s.label : 'Shoe 0${idx + 1}',
            'brand': 'Identified Shoe',
            'model': 'Sneaker',
            'category': 'Athletic Shoes',
            'subcategory': 'Running Shoes',
            'condition': 'Like New',
            'conditionCode': 'C1',
            'color': 'Original',
            'size': 'US M-9',
            'matchPercent': 95,
            'photos': s.photos.map((p) => {'view': p.view, 'url': p.url}).toList(),
          };
        }).toList();
      } else {
        _shoes = [];
      }
    }
  }

  Future<void> _loadCatalog() async {
    try {
      final brands = await _catalogService.getBrands();
      if (mounted) {
        setState(() {
          for (final b in brands) {
            if (!_availableBrands.contains(b.name)) {
              _availableBrands.add(b.name);
            }
          }
        });
      }
    } catch (_) {}
  }

  void _confirmMatch(Map<String, dynamic> shoeItem) async {
    setState(() {
      _isSubmitting = true;
      _confirmedShoes[_activeShoeIndex] = true;
    });

    final scanId = (_data['scanId'] as String?)?.isNotEmpty == true
        ? _data['scanId'] as String
        : (Provider.of<ScanProvider>(context, listen: false).session?.id ?? '');
    final shoeId = shoeItem['shoeId'] as String;

    try {
      await _scanService.confirmShoe(scanId: scanId, shoeId: shoeId);
      if (mounted) {
        Provider.of<ShoesProvider>(context, listen: false).fetchShoesAndSummary();
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _onNextShoeTapped() {
    if (_activeShoeIndex < _shoes.length - 1) {
      setState(() {
        _activeShoeIndex++;
      });
    } else {
      _showAllMatchesConfirmedModal();
    }
  }

  void _showFindMyShoeModal(Map<String, dynamic> shoeItem) {
    String selectedBrand = shoeItem['brand'] as String? ?? (_availableBrands.isNotEmpty ? _availableBrands.first : 'Nike');
    final modelCtrl = TextEditingController(text: shoeItem['model'] as String? ?? '');
    String selectedCategory = shoeItem['category'] as String? ?? 'Athletic Shoes';
    String selectedSubcategory = shoeItem['subcategory'] as String? ?? 'Running Shoes';
    String selectedCondition = shoeItem['condition'] as String? ?? 'Like New';
    String selectedColor = shoeItem['color'] as String? ?? 'Black';
    String selectedSize = shoeItem['size'] as String? ?? 'US M-9';

    final categoryOptions = [
      'Athletic Shoes',
      'Casual Shoes',
      'Dress Shoes',
      'Boots',
      'Sandals',
      'Slippers',
    ];

    final subcategoryOptions = [
      'Running Shoes',
      'Walking',
      'Training',
      'Basketball',
      'Lifestyle',
      'Hiking',
      'Trail Running',
    ];

    final conditionOptions = [
      'Like New',
      'Lightly Worn',
      'Heavily Worn',
      'Not Wearable',
    ];

    final colorOptions = [
      'Black',
      'White',
      'Grey',
      'Blue',
      'Red',
      'Green',
      'Multi-color',
      'Brown',
      'Beige',
    ];

    final sizeOptions = [
      'US W-6',
      'US W-6.5',
      'US W-7',
      'US W-7.5',
      'US W-8',
      'US W-8.5',
      'US W-9',
      'US W-9.5',
      'US W-10',
      'US M-8',
      'US M-8.5',
      'US M-9',
      'US M-9.5',
      'US M-10',
      'US M-10.5',
      'US M-11',
      'US M-11.5',
      'US M-12',
    ];

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
                    top: 16,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  decoration: AppStyles.bottomSheetDecoration,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BottomSheetDragHandle(padding: EdgeInsets.only(bottom: 14)),

                        // Header Row: Title & Close
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Find Your Shoe',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 22, color: Color(0xFF0F172A)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Row 1: Brand & Model
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // *BRAND Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '*BRAND',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () {
                                      _showBrandPicker(
                                        context,
                                        selectedBrand,
                                        (newBrand) {
                                          setModalState(() {
                                            selectedBrand = newBrand;
                                          });
                                        },
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedBrand,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF64748B)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // MODEL Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MODEL',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: modelCtrl,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF84CC16), width: 1.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 2: Category & Subcategory
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // *CATEGORY
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '*CATEGORY',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: categoryOptions.contains(selectedCategory)
                                        ? selectedCategory
                                        : categoryOptions.first,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF64748B)),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    items: categoryOptions
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(
                                                c,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => selectedCategory = v);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SUBCATEGORY
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SUBCATEGORY',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: subcategoryOptions.contains(selectedSubcategory)
                                        ? selectedSubcategory
                                        : subcategoryOptions.first,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF64748B)),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    items: subcategoryOptions
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                s,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => selectedSubcategory = v);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 3: *CONDITION Pills
                        const Text(
                          '*CONDITION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: conditionOptions.map((cond) {
                              final isSel = selectedCondition.toLowerCase() == cond.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      selectedCondition = cond;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: isSel ? const Color(0xFF1E392A) : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSel ? const Color(0xFF1E392A) : const Color(0xFFCBD5E1),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      cond,
                                      style: TextStyle(
                                        color: isSel ? Colors.white : const Color(0xFF0F172A),
                                        fontSize: 13,
                                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Row 4: *COLOR & *SIZE
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // *COLOR
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '*COLOR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: colorOptions.contains(selectedColor)
                                        ? selectedColor
                                        : colorOptions.first,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF64748B)),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    items: colorOptions
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(
                                                c,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => selectedColor = v);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // *SIZE
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '*SIZE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: sizeOptions.contains(selectedSize)
                                        ? selectedSize
                                        : sizeOptions[2],
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF64748B)),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                                    items: sizeOptions
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                s,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => selectedSize = v);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Full-width Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonLime,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              final updatedModel = modelCtrl.text.trim().isNotEmpty
                                  ? modelCtrl.text.trim()
                                  : (shoeItem['model'] as String? ?? 'Sneaker');

                              shoeItem['brand'] = selectedBrand;
                              shoeItem['model'] = updatedModel;
                              shoeItem['category'] = selectedCategory;
                              shoeItem['subcategory'] = selectedSubcategory;
                              shoeItem['condition'] = selectedCondition;
                              shoeItem['color'] = selectedColor;
                              shoeItem['size'] = selectedSize;

                              if (selectedCondition.toLowerCase().contains('like')) {
                                shoeItem['conditionCode'] = 'C1';
                              } else if (selectedCondition.toLowerCase().contains('light')) {
                                shoeItem['conditionCode'] = 'C2';
                              } else if (selectedCondition.toLowerCase().contains('heavy')) {
                                shoeItem['conditionCode'] = 'C3';
                              } else {
                                shoeItem['conditionCode'] = 'C5';
                              }

                              Navigator.pop(ctx);

                              setState(() {
                                _confirmedShoes[_activeShoeIndex] = true;
                              });

                              // Fire background API call to persist corrections
                              final scanId = _data['scanId'] as String? ?? '';
                              final shoeId = shoeItem['shoeId'] as String? ?? '';
                              _scanService.rejectShoe(
                                scanId: scanId,
                                shoeId: shoeId,
                                brandId: selectedBrand,
                                model: updatedModel,
                                color: selectedColor,
                                sizeId: selectedSize,
                              ).catchError((_) => <String, dynamic>{});
                            },
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Footer Note
                        const Center(
                          child: Text(
                            'Not Sure About The Model? Check The Label Inside Your Shoe Or On The Tongue For More Details.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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

  void _showBrandPicker(BuildContext context, String currentBrand, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (pickerCtx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Brand',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _availableBrands.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (_, index) {
                        final b = _availableBrands[index];
                        final isSel = b.toLowerCase() == currentBrand.toLowerCase();
                        return ListTile(
                          title: Text(
                            b,
                            style: TextStyle(
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                            ),
                          ),
                          trailing: isSel
                              ? const Icon(Icons.check, color: Color(0xFF16A34A), size: 20)
                              : null,
                          onTap: () {
                            Navigator.pop(pickerCtx);
                            onSelect(b);
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  // "I don't see my brand" option
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline, color: Color(0xFF65A30D)),
                    title: const Text(
                      'I don\'t see my brand',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(pickerCtx);
                      _showAddBrandModal(context, (newBrand) {
                        setState(() {
                          if (!_availableBrands.contains(newBrand)) {
                            _availableBrands.insert(0, newBrand);
                          }
                        });
                        onSelect(newBrand);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddBrandModal(BuildContext context, Function(String) onBrandAdded) {
    final brandCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (addCtx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(addCtx).viewInsets.bottom + 28,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
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
                    'Add your brand',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter the brand shown on your shoe\'s label. We\'ll use it to help find your match.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'BRAND NAME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: brandCtrl,
                    autofocus: true,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Veja',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF84CC16), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonLime,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        final text = brandCtrl.text.trim();
                        if (text.isNotEmpty) {
                          onBrandAdded(text);
                          Navigator.pop(addCtx);
                        }
                      },
                      child: const Text(
                        'Add brand',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(addCtx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAllMatchesConfirmedModal() {
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: AppStyles.bottomSheetDecoration,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BottomSheetDragHandle(padding: EdgeInsets.only(bottom: 24)),

                    // Big Circular Lime Green Checkmark
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB5E076),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          size: 38,
                          color: Color(0xFF1E392A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title & Subtitle
                    const Text(
                      'All Matches Confirmed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'All shoes are added to My Shoes.\nYou can start to explore!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Shoes List
                    Container(
                      decoration: AppStyles.surfaceDecoration(borderRadius: 18),
                      child: Column(
                        children: List.generate(_shoes.length, (idx) {
                          final item = _shoes[idx];
                          final isLast = idx == _shoes.length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          AppAssets.ftue3ViewfinderShoe,
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.roller_skating,
                                            size: 22,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['brand']} ${item['model']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          ConditionBadge(
                                            label: item['condition'] as String?,
                                            code: item['conditionCode'] as String?,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Button: View My Shoes
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonLime,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _finishAndGoHome();
                        },
                        child: const Text(
                          'View My Shoes',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Secondary Button: Scan another pair
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          final scan = Provider.of<ScanProvider>(context, listen: false);
                          scan.startNewScan();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text(
                          'Scan another pair',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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

    final currentShoe = _shoes[_activeShoeIndex.clamp(0, _shoes.length - 1)];
    final isConfirmed = _confirmedShoes[_activeShoeIndex] == true;
    final progressVal = (_activeShoeIndex + 1) / _shoes.length;
    final matchPercent = currentShoe['matchPercent'] as int? ?? 98;
    final scanProvider = Provider.of<ScanProvider>(context);

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
          onPressed: () {
            if (_activeShoeIndex > 0) {
              setState(() {
                _activeShoeIndex--;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confirmation Banner (Figma: ✓ Added to "MY SHOES")
                  if (isConfirmed)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                          SizedBox(width: 10),
                          Text(
                            '✓ Added to "MY SHOES"',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Intro Text
                  Text(
                    'We found matches for ${_shoes.length} ${_shoes.length == 1 ? "pair" : "pairs"}. Take a quick look ${_shoes.length == 1 ? "to make sure we got it right." : "at each one to make sure we got it right."}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Match Review Card (Figma Match Found)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
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
                        // Card Top: Shoe 01 & 1 Of 4 Reviewed
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentShoe['label'] as String? ?? 'Shoe 0${_activeShoeIndex + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_activeShoeIndex + 1} Of ${_shoes.length} Reviewed',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 4 Scanned Photos Montage with "YOUR SCAN" Badge
                        ClipRRect(
                          child: SizedBox(
                            height: 140,
                            child: Stack(
                              children: [
                                Row(
                                  children: List.generate(4, (photoIdx) {
                                    final views = ['top', 'left', 'right', 'sole'];
                                    final viewKey = views[photoIdx];

                                    // Check local captured photo from ScanProvider
                                    final localXFile = scanProvider.getLocalPhoto(_activeShoeIndex, viewKey);

                                    return Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: photoIdx == 0 ? 0 : 2,
                                          right: photoIdx == 3 ? 0 : 2,
                                        ),
                                        color: const Color(0xFFF1F5F9),
                                        child: localXFile != null
                                            ? (kIsWeb
                                                ? Image.network(localXFile.path, fit: BoxFit.cover)
                                                : Image.file(io.File(localXFile.path), fit: BoxFit.cover))
                                            : _buildAngleAssetOrPlaceholder(viewKey),
                                      ),
                                    );
                                  }),
                                ),
                                // "YOUR SCAN" Pill Badge
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'YOUR SCAN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Match Box Subcard (Figma: ✨ 98% Match, On Running, Like New)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Match Score Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFC7D2FE)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        size: 13,
                                        color: Color(0xFF4338CA),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$matchPercent% Match',
                                        style: const TextStyle(
                                          color: Color(0xFF4338CA),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Shoe Thumbnail & Details
                                Row(
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          AppAssets.ftue3ViewfinderShoe,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.roller_skating,
                                            size: 30,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ConditionBadge(
                                            label: currentShoe['condition'] as String?,
                                            code: currentShoe['conditionCode'] as String?,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${currentShoe['brand']} ${currentShoe['model']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${currentShoe['category']} • ${currentShoe['subcategory']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bottom Decision Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: isConfirmed
                              ? // When Confirmed: Single Full-width "Review next shoe >" Button
                              SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.buttonLime,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    onPressed: _onNextShoeTapped,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _activeShoeIndex < _shoes.length - 1
                                              ? 'Review next shoe'
                                              : 'See All Matches',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.chevron_right, size: 20),
                                      ],
                                    ),
                                  ),
                                )
                              : // When Not Yet Confirmed: Prompt & 2 Action Buttons
                              Column(
                                  children: [
                                    const Center(
                                      child: Text(
                                        'This Shoe Was Added To My Shoes',
                                        style: TextStyle(
                                          fontSize: 15,
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        // "No, find my shoe"
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(28),
                                              ),
                                            ),
                                            onPressed: () => _showFindMyShoeModal(currentShoe),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'No, find my shoe',
                                                  style: TextStyle(
                                                    color: Color(0xFF0F172A),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // "That's my shoe >"
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.buttonLime,
                                              foregroundColor: Colors.black,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(28),
                                              ),
                                            ),
                                            onPressed: _isSubmitting
                                                ? null
                                                : () => _confirmMatch(currentShoe),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  "That's my shoe",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
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
                                  ],
                                ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Carousel Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_shoes.length, (idx) {
                      final isActive = _activeShoeIndex == idx;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 22 : 6,
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
                  const SizedBox(height: 20),

                  // Footer Note (Figma Match Found)
                  const Center(
                    child: Text(
                      'ShoeDNA™ Is Always Learning, Confirming The Match Helps Improve\nFuture Circularity Options.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAngleAssetOrPlaceholder(String viewKey) {
    String assetPath;
    switch (viewKey) {
      case 'top':
        assetPath = AppAssets.viewfinderTop;
        break;
      case 'left':
        assetPath = AppAssets.viewfinderLeft;
        break;
      case 'right':
        assetPath = AppAssets.viewfinderRight;
        break;
      case 'sole':
      default:
        assetPath = AppAssets.viewfinderBottom;
        break;
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFF1F5F9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                size: 22,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 4),
              Text(
                viewKey.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
