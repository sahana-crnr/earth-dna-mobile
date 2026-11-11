import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:earth_dna_mobile/core/constants/app_assets.dart';
import 'package:earth_dna_mobile/screens/auth/welcome_screen.dart';
import 'package:earth_dna_mobile/widgets/earth_video_hero.dart';

void main() {
  testWidgets('WelcomeScreen renders exact Slide 1 matching Figma FTUE 1',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );
    await tester.pump();

    // 1. Tag
    expect(find.text('SPACESHIP EARTH • 2026'), findsOneWidget);

    // 2. Earth Hero widget
    expect(find.byType(EarthVideoHero), findsOneWidget);

    // 3. Headline
    expect(find.text('Time to act now'), findsOneWidget);

    // 4. Statistics RichText
    expect(
      find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final plain = widget.text.toPlainText();
          return plain.contains('23.9 billion') &&
              plain.contains('8 billion') &&
              plain.contains('one planet');
        }
        return false;
      }),
      findsOneWidget,
    );

    // 5. Community title & subtitle
    expect(find.text("This is EarthDNA's\nProject S.H.O.E.S."), findsOneWidget);
    expect(
      find.text(
          "You've just been recruited as a Sole Saver —\nand welcomed into our Planetary Healers community."),
      findsOneWidget,
    );

    // 6. Buttons
    expect(find.text('Accept the Mission'), findsOneWidget);
    expect(find.text('Skip To Scan'), findsOneWidget);

    // 7. Advance to Slide 2 (FTUE 2)
    await tester.tap(find.text('Accept the Mission'));
    await tester.pumpAndSettle();
    expect(find.text('MISSION BRIEFING'), findsOneWidget);
    expect(find.text('The problem lives in\nyour closet.'), findsOneWidget);
    expect(find.text("What we're building"), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == AppAssets.ftue2HeelIllustration),
      findsOneWidget,
    );

    // 8. Advance to Slide 3 (FTUE 3)
    await tester.tap(find.text("What we're building"));
    await tester.pumpAndSettle();
    expect(find.text('EVERY SHOE HAS A STORY'), findsOneWidget);
    expect(find.text('Made'), findsOneWidget);
    expect(find.text('Worn'), findsOneWidget);
    expect(find.text('What Next?'), findsOneWidget);
    expect(find.text('Point. Scan. Discover.'), findsOneWidget);
    expect(find.text("See what's possible"), findsOneWidget);

    // 9. Advance to Slide 4 (FTUE 4)
    await tester.tap(find.text("See what's possible"));
    await tester.pumpAndSettle();
    expect(find.text('BUILT IN BOSTON'), findsOneWidget);
    expect(find.text("An OS for Earth's\nsustainable future."), findsOneWidget);
    expect(find.text('— R. Buckminster Fuller'), findsOneWidget);
    expect(find.text('Join the mission'), findsOneWidget);

    // 10. Advance to Slide 5 (FTUE 5)
    await tester.tap(find.text('Join the mission'));
    await tester.pumpAndSettle();
    expect(find.text('STAR DATE: 04.20.2026'), findsOneWidget);
    expect(find.text('Your badge awaits'), findsOneWidget);
    expect(find.text('Scan my shoes'), findsOneWidget);
    expect(find.text('Takes 60 seconds · no account required'), findsOneWidget);
    expect(find.text('Skip To Scan'), findsNothing);
  });
}

