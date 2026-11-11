import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:earth_dna_mobile/providers/scan_provider.dart';
import 'package:earth_dna_mobile/screens/scan/camera_capture_screen.dart';

void main() {
  testWidgets(
    'CameraCaptureScreen renders Figma workflow: aiming instruction, dynamic banner, counter, slots, and retake badge',
    (WidgetTester tester) async {
      final scanProvider = ScanProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ScanProvider>.value(value: scanProvider),
          ],
          child: const MaterialApp(
            home: CameraCaptureScreen(),
          ),
        ),
      );

      // Initial load pump
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Initial State: Top View aiming instruction
      expect(
        find.text('Place the shoe flat and capture it from above'),
        findsOneWidget,
      );
      expect(find.text('Top View'), findsOneWidget);
      expect(find.text('0/4'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // 2. Simulate capturing the top view
      final mockImage = XFile('https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200');
      await scanProvider.captureAndUploadView(imageFile: mockImage);
      await tester.pump();

      // 3. Dynamic transition banner after capture
      expect(find.text('Top view captured'), findsOneWidget);
      expect(find.text('Next: Right View'), findsOneWidget);

      // 4. Counter advances to Right View and 1/4
      expect(find.text('Right View'), findsOneWidget);
      expect(find.text('1/4'), findsOneWidget);

      // 5. Captured slot now has the '×' retake badge
      final closeBadge = find.byIcon(Icons.close);
      // Top bar has close (Icons.close), and the slot has close badge (Icons.close)
      expect(closeBadge, findsNWidgets(2));

      // 6. Tapping '×' retake badge removes the photo
      final slotRetakeBadge = closeBadge.last;
      await tester.tap(slotRetakeBadge);
      await tester.pump();

      // After removal: counter goes back to 0/4 and active view is top
      expect(find.text('0/4'), findsOneWidget);
      expect(find.text('Top View'), findsOneWidget);
      expect(
        find.text('Place the shoe flat and capture it from above'),
        findsOneWidget,
      );
    },
  );
}
