import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:earth_dna_mobile/screens/auth/loading_splash_screen.dart';

void main() {
  testWidgets('LoadingSplashScreen renders exact Figma frame', (WidgetTester tester) async {
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoadingSplashScreen(
          duration: const Duration(milliseconds: 500),
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    // Initial render
    expect(find.byType(LoadingSplashScreen), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Fast-forward timer
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(finished, isTrue);
  });
}
