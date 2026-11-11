import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/shoe_model.dart';

class ShareShoeBottomSheet extends StatelessWidget {
  final ShoeProfileModel shoe;

  const ShareShoeBottomSheet({super.key, required this.shoe});

  static Future<void> show(
    BuildContext context, {
    required ShoeProfileModel shoe,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareShoeBottomSheet(shoe: shoe),
    );
  }

  String get _shareSlug {
    final sanitized = (shoe.model ?? 'shoe').toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    return 'earthdna.app/s/$sanitized';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = shoe.photos.isNotEmpty ? shoe.photos.first.url : null;
    final shareUrl = 'https://$_shareSlug';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Share Shoe Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF0F172A),
                      size: 22,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Give your pair a little spotlight. Share its photos, condition and estimated resale value.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Preview Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(19),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: photoUrl != null
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.roller_skating,
                                  size: 64,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.roller_skating,
                                size: 64,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                    ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.all(16),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${shoe.shoeType ?? "Athletic"} • ${(shoe.color != null && shoe.color!.isNotEmpty) ? shoe.color : "Original"}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Condition & Value Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Condition',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'A · ${shoe.conditionBadgeText}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Est. Resale Value',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    shoe.resaleValueFormatted ?? 'Estimate pending',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Your Profile Link Label
              const Text(
                'Your Profile Link',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              // Link Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 20, color: Color(0xFF0F172A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _shareSlug,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Disclaimer
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF94A3B8)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Anyone with the link can view this shoe profile. Your personal details stay private.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Share button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A5A5A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text(
                    'Share shoe profile',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    Share.share(
                      'Check out my verified ${shoe.brand} ${shoe.model} on EarthDNA: $shareUrl',
                      subject: '${shoe.brand} ${shoe.model} on EarthDNA',
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Copy link button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text(
                    'Copy link',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
