import 'package:flutter/material.dart';

import '../../../models/shoe_model.dart';

class RemoveShoeBottomSheet extends StatelessWidget {
  final ShoeProfileModel shoe;
  final VoidCallback onConfirmRemove;

  const RemoveShoeBottomSheet({
    super.key,
    required this.shoe,
    required this.onConfirmRemove,
  });

  static Future<void> show(
    BuildContext context, {
    required ShoeProfileModel shoe,
    required VoidCallback onConfirmRemove,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          RemoveShoeBottomSheet(shoe: shoe, onConfirmRemove: onConfirmRemove),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = shoe.photos.isNotEmpty ? shoe.photos.first.url : null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header with trash icon
            Row(
              children: [
                const Icon(
                  Icons.delete_outline,
                  size: 24,
                  color: Color(0xFF1E293B),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Remove This Shoe?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Shoe Preview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: photoUrl != null
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.roller_skating,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        : const Icon(
                            Icons.roller_skating,
                            color: Color(0xFF94A3B8),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shoe.brand.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shoe.model ?? 'Footwear',
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
                          'Colorway: ${(shoe.color != null && shoe.color!.isNotEmpty) ? shoe.color : "Original"}',
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
            const SizedBox(height: 16),

            // Explanation
            Text(
              '${shoe.model} will be removed from My Shoes, along with its saved photos and scan results. Its shared profile link will no longer work.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),

            // Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This action can\'t be undone.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Remove Button
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
                onPressed: () {
                  Navigator.pop(context);
                  onConfirmRemove();
                },
                child: const Text(
                  'Remove Shoe',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel Button
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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
