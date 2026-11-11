import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/shoes_service.dart';
import '../../models/shoe_model.dart';

class EditShoeScreen extends StatefulWidget {
  final ShoeProfileModel shoe;

  const EditShoeScreen({super.key, required this.shoe});

  @override
  State<EditShoeScreen> createState() => _EditShoeScreenState();
}

class _EditShoeScreenState extends State<EditShoeScreen> {
  final CatalogService _catalogService = CatalogService();
  final ShoesService _shoesService = ShoesService();

  late TextEditingController _modelController;
  late TextEditingController _colorController;
  String? _selectedBrand;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSize;
  String? _selectedColor;

  bool _isSaving = false;

  final List<String> _commonBrands = [
    'ON RUNNING',
    'NIKE',
    'ADIDAS',
    'NEW BALANCE',
    'HOKA',
    'ASICS',
    'VEJA',
  ];

  final List<String> _categories = [
    'Running',
    'Athletic',
    'Casual',
    'Basketball',
    'Training',
  ];

  final List<String> _subcategories = [
    'Running',
    'Road Running',
    'Trail Running',
    'Lifestyle',
  ];

  final List<String> _colors = [
    'Black',
    'White',
    'Grey',
    'Blue',
    'Red',
    'Green',
    'Multi-color',
  ];

  final List<String> _defaultSizes = [
    'US M-8',
    'US M-8.5',
    'US M-9',
    'US M-9.5',
    'US M-10',
    'US M-10.5',
    'US M-11',
    'US W-7',
    'US W-7.5',
    'US W-8',
    'US W-8.5',
  ];

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.shoe.model);
    _colorController = TextEditingController(text: widget.shoe.color);

    _selectedBrand = widget.shoe.brand.toUpperCase();
    if (!_commonBrands.contains(_selectedBrand)) {
      _selectedBrand = 'ON RUNNING';
    }

    _selectedCategory = widget.shoe.shoeType ?? 'Running';
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Running';
    }

    _selectedSubcategory = 'Running';
    _selectedColor =
        (widget.shoe.color != null && widget.shoe.color!.isNotEmpty)
        ? widget.shoe.color!
        : 'Black';
    if (!_colors.contains(_selectedColor)) {
      _selectedColor = 'Black';
    }

    _selectedSize = 'US M-9';
    _loadCatalog();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final brands = await _catalogService.getBrands();
      final sizes = await _catalogService.getSizes();
      final types = await _catalogService.getShoeTypes();

      if (mounted) {
        setState(() {
          if (brands.isNotEmpty) {
            final names = brands.map((b) => b.name.toUpperCase()).toList();
            for (final n in names) {
              if (!_commonBrands.contains(n)) _commonBrands.add(n);
            }
          }
          if (sizes.isNotEmpty) {
            final labels = sizes.map((s) => s.label).toList();
            for (final l in labels) {
              if (!_defaultSizes.contains(l)) _defaultSizes.add(l);
            }
          }
          if (types.isNotEmpty) {
            final typeNames = types.map((t) => t.name).toList();
            for (final t in typeNames) {
              if (!_categories.contains(t)) _categories.add(t);
            }
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await _shoesService.updateShoe(widget.shoe.id, {
        'brand': _selectedBrand,
        'model': _modelController.text.trim(),
        'color': _selectedColor,
        'shoeType': _selectedCategory,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.shoe.photos;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Shoe Details',
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
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF0F172A), size: 22),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos section (4/8) matching Figma Page 61
              Text(
                'Photos (${photos.isNotEmpty ? photos.length : 4}/8)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // Photos Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (
                    int i = 0;
                    i < (photos.isNotEmpty ? photos.length : 4);
                    i++
                  )
                    _buildPhotoTile(
                      index: i,
                      isMain: i == 0,
                      imageUrl: i < photos.length ? photos[i].url : null,
                    ),
                  _buildAddPhotoTile(),
                ],
              ),
              const SizedBox(height: 28),

              // Shoe Details Header
              const Text(
                'Shoe Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 18),

              // BRAND Field
              _buildFieldLabel('BRAND'),
              Container(
                decoration: _fieldBoxDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBrand,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF64748B),
                    ),
                    items: _commonBrands.map((b) {
                      return DropdownMenuItem(value: b, child: Text(b));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedBrand = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // MODEL Field
              _buildFieldLabel('MODEL'),
              TextField(
                controller: _modelController,
                decoration: _inputDecoration(hint: 'Model name'),
              ),
              const SizedBox(height: 16),

              // CATEGORY Field
              _buildFieldLabel('CATEGORY'),
              Container(
                decoration: _fieldBoxDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF64748B),
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SUBCATEGORY Field
              _buildFieldLabel('SUBCATEGORY'),
              Container(
                decoration: _fieldBoxDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubcategory,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF64748B),
                    ),
                    items: _subcategories.map((sc) {
                      return DropdownMenuItem(value: sc, child: Text(sc));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSubcategory = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // COLOR Field
              _buildFieldLabel('COLOR'),
              Container(
                decoration: _fieldBoxDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedColor,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF64748B),
                    ),
                    items: _colors.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedColor = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SIZE Field
              _buildFieldLabel('SIZE'),
              Container(
                decoration: _fieldBoxDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSize,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF64748B),
                    ),
                    items: _defaultSizes.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSize = val),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Changes Button (Page 61 Figma Dark Grey Pill)
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
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  BoxDecoration _fieldBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
      ),
    );
  }

  Widget _buildPhotoTile({
    required int index,
    required bool isMain,
    String? imageUrl,
  }) {
    final size = (MediaQuery.of(context).size.width - 64) / 3;

    return Container(
      width: size,
      height: size * 1.25,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(Icons.roller_skating, color: Color(0xFF94A3B8)),
              ),
            )
          else
            const Center(
              child: Icon(
                Icons.roller_skating,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
            ),

          // Main Tag (Page 61)
          if (isMain)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Main',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Options "..." icon
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_horiz,
                size: 14,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoTile() {
    final size = (MediaQuery.of(context).size.width - 64) / 3;

    return Container(
      width: size,
      height: size * 1.25,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Icon(Icons.add, size: 32, color: Color(0xFF64748B)),
      ),
    );
  }
}
