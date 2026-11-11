import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

class SnapTipsBottomSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SnapTipsContent(),
    );
  }
}

class _SnapTipsContent extends StatelessWidget {
  const _SnapTipsContent();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.84,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Snap tips',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontSize: 32, height: 1.1),
            ),
            const SizedBox(height: 6),
            Text(
              'These views help us identify your shoe, assess its condition, and recommend what to do next.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Capture Each Shoe From 4 Angles',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _example(AppAssets.snapTop, 'TOP'),
                        _example(AppAssets.snapRight, 'RIGHT'),
                        _example(AppAssets.snapLeft, 'LEFT'),
                        _example(AppAssets.snapBottom, 'BOTTOM'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF7FF),
                        border: Border.all(color: const Color(0xFF1D45B0)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'For best results',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF1D45B0),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 10),
                          _guidanceLine(context, 'One shoe at a time'),
                          const SizedBox(height: 4),
                          _guidanceLine(
                            context,
                            'Place it on a flat surface with good lighting',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: Text(
                        'Avoid',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _example(
                          AppAssets.avoidMultiple,
                          'Multiple',
                          avoid: true,
                        ),
                        _example(
                          AppAssets.avoidCropped,
                          'Cropped',
                          avoid: true,
                        ),
                        _example(AppAssets.avoidDark, 'Too Dark', avoid: true),
                        _example(AppAssets.avoidBlurry, 'Blurry', avoid: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guidanceLine(BuildContext context, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('• ', style: _guidanceStyle(context)),
      Expanded(child: Text(text, style: _guidanceStyle(context))),
    ],
  );

  TextStyle? _guidanceStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: const Color(0xFF1D45B0));

  Widget _example(String asset, String label, {bool avoid = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset(asset, fit: BoxFit.cover),
                    ),
                  ),
                  if (avoid)
                    const Positioned(
                      right: -1,
                      top: -1,
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: Color(0xFFFE354E),
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7FF),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF1D45B0),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
