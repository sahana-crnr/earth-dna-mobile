import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_design_tokens.dart';
import '../../models/shoe_model.dart';
import '../../providers/shoes_provider.dart';

class DonationFlowSheet extends StatefulWidget {
  final ShoeProfileModel? shoeProfile;
  final ShoeCardModel? shoeCard;

  const DonationFlowSheet({
    super.key,
    this.shoeProfile,
    this.shoeCard,
  });

  static Future<void> show(
    BuildContext context, {
    ShoeProfileModel? shoeProfile,
    ShoeCardModel? shoeCard,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DonationFlowSheet(
        shoeProfile: shoeProfile,
        shoeCard: shoeCard,
      ),
    );
  }

  @override
  State<DonationFlowSheet> createState() => _DonationFlowSheetState();
}

class _DonationFlowSheetState extends State<DonationFlowSheet> {
  int _selectedMethod = 0; // 0 = Local Drop-Off, 1 = Prepaid Mail-In Kit
  int _selectedPartner = 0;
  String? _selectedShoeId;
  bool _isSubmitting = false;
  bool _isCompleted = false;

  final List<Map<String, String>> _dropOffLocations = [
    {
      'name': 'Soles4Souls Drop Box',
      'distance': '1.2 miles away',
      'address': 'Community Hub, 452 Broadway, New York, NY',
      'hours': 'Mon - Sat: 9 AM - 7 PM',
    },
    {
      'name': 'EarthDNA Circular Partner Center',
      'distance': '2.8 miles away',
      'address': 'GreenTech Plaza, 110 5th Ave, New York, NY',
      'hours': 'Open daily: 8 AM - 8 PM',
    },
    {
      'name': 'One World Running Collection',
      'distance': '4.1 miles away',
      'address': 'Athletic Fields Park, Brooklyn, NY',
      'hours': 'Weekends: 10 AM - 5 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedShoeId = widget.shoeProfile?.id ?? widget.shoeCard?.id;
  }

  String _getShoeTitle(ShoeCardModel shoe) {
    if (shoe.model != null && shoe.model!.isNotEmpty) {
      return '${shoe.brand} · ${shoe.model}';
    }
    return shoe.brand;
  }

  Future<void> _handleConfirmDonation() async {
    setState(() => _isSubmitting = true);

    final provider = Provider.of<ShoesProvider>(context, listen: false);

    if (_selectedShoeId != null && _selectedShoeId!.isNotEmpty) {
      await provider.updateShoeAction(_selectedShoeId!, 'donated');
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoesProvider = Provider.of<ShoesProvider>(context);
    final availableShoes = shoesProvider.shoes
        .where((s) => s.actionTaken != 'donated')
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: _isCompleted
                  ? _buildSuccessView(context)
                  : _buildFlowForm(context, availableShoes),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlowForm(BuildContext context, List<ShoeCardModel> availableShoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle pill
        Center(
          child: Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header (Headline hierarchy in Urbanist)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Donate Footwear',
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            // Minimum touch target 44x44
            SizedBox(
              width: AppTouchTarget.min,
              height: AppTouchTarget.min,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 22, color: Color(0xFF64748B)),
                splashRadius: 22,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Keep footwear in circulation to support communities and divert waste from landfills.',
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Impact Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Color(0xFF166534),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environmental & Social Impact',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diverts ~1.2 kg of CO2e per pair and provides footwear directly to people in need.',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF15803D),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Shoe Selection (if not launched from shoe profile)
        if (widget.shoeProfile == null && widget.shoeCard == null && availableShoes.isNotEmpty) ...[
          Text(
            'SELECT PAIR TO DONATE',
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedShoeId,
                isExpanded: true,
                hint: Text(
                  'Choose a shoe from your closet',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                items: availableShoes.map((shoe) {
                  return DropdownMenuItem<String>(
                    value: shoe.id,
                    child: Text(
                      _getShoeTitle(shoe),
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (id) => setState(() => _selectedShoeId = id),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Method Toggle (Local Drop-Off vs Prepaid Mail-In)
        Text(
          'DONATION METHOD',
          style: GoogleFonts.urbanist(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMethodPill(
                index: 0,
                title: 'Drop-Off Partner',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMethodPill(
                index: 1,
                title: 'Mail-In Kit',
                icon: Icons.markunread_mailbox_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Method details
        if (_selectedMethod == 0) ...[
          Text(
            'SELECT DROP-OFF LOCATION',
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_dropOffLocations.length, (idx) {
            final loc = _dropOffLocations[idx];
            final isSelected = _selectedPartner == idx;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => _selectedPartner = idx),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(minHeight: AppTouchTarget.min),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreenDark
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.primaryGreenDark
                            : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc['name']!,
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  loc['distance']!,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreenDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc['address']!,
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc['hours']!,
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
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
          }),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.primaryGreenDark,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Prepaid Return Label Kit',
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'We will email you a prepaid shipping label and instructions. Simply pack your shoes in any recycled box and drop it at your nearest postal drop.',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Action Button (Minimum touch target 44px, actually 52px)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonLime,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            onPressed: _isSubmitting ? null : _handleConfirmDonation,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Text(
                    _selectedMethod == 0
                        ? 'Confirm Drop-Off'
                        : 'Request Mail-In Kit',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodPill({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == index;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: AppTouchTarget.min),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7FEE7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreenDark
                : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.primaryGreenDark
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryGreenDark
                      : const Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF166534),
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Donation Initiated!',
          style: GoogleFonts.urbanist(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedMethod == 0
              ? 'Your drop-off details have been saved. Bring your pair to the selected drop location whenever you are ready.'
              : 'A prepaid shipping kit confirmation has been sent. Check your email for printing instructions.',
          textAlign: TextAlign.center,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonLime,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
