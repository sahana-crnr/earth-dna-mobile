import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/shoe_model.dart';
import '../../scan/camera_capture_screen.dart';
import '../edit_shoe_screen.dart';
import 'remove_shoe_bottom_sheet.dart';
import 'share_shoe_bottom_sheet.dart';

class ManageShoeBottomSheet extends StatelessWidget {
  final ShoeProfileModel shoe;
  final VoidCallback onUpdated;
  final VoidCallback onDeleted;

  const ManageShoeBottomSheet({
    super.key,
    required this.shoe,
    required this.onUpdated,
    required this.onDeleted,
  });

  static Future<void> show(
    BuildContext context, {
    required ShoeProfileModel shoe,
    required VoidCallback onUpdated,
    required VoidCallback onDeleted,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (_) => Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
          child: ManageShoeBottomSheet(
            shoe: shoe,
            onUpdated: onUpdated,
            onDeleted: onDeleted,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Manage This Shoe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionItem(
              icon: Icons.edit_outlined,
              label: 'Edit shoe details',
              onTap: () async {
                Navigator.pop(context);
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => EditShoeScreen(shoe: shoe)),
                );
                if (updated == true) onUpdated();
              },
            ),

            _buildActionItem(
              icon: Icons.share_outlined,
              label: 'Share shoe profile',
              onTap: () {
                Navigator.pop(context);
                ShareShoeBottomSheet.show(context, shoe: shoe);
              },
            ),

            _buildActionItem(
              icon: Icons.crop_free,
              label: 'Rescan shoe',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
                );
              },
            ),

            _buildActionItem(
              icon: Icons.delete_outline,
              label: 'Remove Shoe',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                RemoveShoeBottomSheet.show(
                  context,
                  shoe: shoe,
                  onConfirmRemove: onDeleted,
                );
              },
            ),

            const SizedBox(height: 8),
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

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : const Color(0xFF0F172A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

