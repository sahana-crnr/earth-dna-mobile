import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../providers/shoes_provider.dart';
import '../../../widgets/bottom_sheet_drag_handle.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _actionTaken;
  late List<String> _recommendedAction;

  final List<Map<String, String>> _actionTakenOptions = [
    {'label': 'No action yet', 'value': 'none'},
    {'label': 'Resold', 'value': 'resold'},
    {'label': 'Repaired', 'value': 'repaired'},
    {'label': 'Donated', 'value': 'donated'},
    {'label': 'Recycled', 'value': 'recycled'},
  ];

  final List<Map<String, String>> _recommendedOptions = [
    {'label': 'Resell', 'value': 'resell'},
    {'label': 'Repair', 'value': 'repair'},
    {'label': 'Donate', 'value': 'donate'},
    {'label': 'Recycle', 'value': 'recycle'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ShoesProvider>(context, listen: false);
    _actionTaken = List.from(provider.selectedActionTaken);
    _recommendedAction = List.from(provider.selectedRecommendedAction);
  }

  void _toggle(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoesProvider>(context, listen: false);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
        child: Container(
          decoration: AppStyles.bottomSheetDecoration,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BottomSheetDragHandle(padding: EdgeInsets.only(bottom: 16)),

                  // Title and Reset Button (Figma My Shoe_Filter)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            _actionTaken.clear();
                            _recommendedAction.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section: Action Taken (Figma My Shoe_Filter)
                  const Text(
                    'Action Taken',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final opt in _actionTakenOptions)
                    _buildCheckboxRow(
                      label: opt['label']!,
                      isSelected: _actionTaken.contains(opt['value']),
                      onTap: () => _toggle(_actionTaken, opt['value']!),
                    ),
                  const SizedBox(height: 20),

                  // Section: Recommended Action (Figma My Shoe_Filter)
                  const Text(
                    'Recommended Action',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final opt in _recommendedOptions)
                    _buildCheckboxRow(
                      label: opt['label']!,
                      isSelected: _recommendedAction.contains(opt['value']),
                      onTap: () => _toggle(_recommendedAction, opt['value']!),
                    ),
                  const SizedBox(height: 28),

                  // Apply Button (Figma Lime Green Pill)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonLime,
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        provider.updateFilters(
                          actionTaken: _actionTaken,
                          condition: provider.selectedCondition,
                          recommendedAction: _recommendedAction,
                          resaleBucket: provider.selectedResaleBucket,
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.buttonLime : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                color: isSelected ? AppColors.buttonLime : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.black,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
