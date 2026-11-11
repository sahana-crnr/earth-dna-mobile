import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:earth_dna_mobile/providers/auth_provider.dart';
import 'package:earth_dna_mobile/providers/shoes_provider.dart';
import 'package:earth_dna_mobile/screens/home/home_dashboard_screen.dart';

void main() {
  testWidgets('HomeDashboardScreen renders section headers, marketplace preview, and profile modal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ShoesProvider()),
        ],
        child: const MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );

    // Section headers
    expect(find.text('S.H.O.E.S.'), findsOneWidget);
    expect(find.text('Your Recent Scans'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);

    // Marketplace action
    expect(find.text('Browse All'), findsOneWidget);

    // Empty state scans banner
    expect(find.text("Got Shoes You Don't\nWear Anymore?"), findsOneWidget);
    expect(find.text('Scan your first pair'), findsOneWidget);

    // Marketplace shoe cards
    expect(find.text('On Running · Cloudmonster'), findsOneWidget);
    expect(find.text(r'$35'), findsOneWidget);
    expect(find.text('Nike · Air Max 90 · White / Grey'), findsOneWidget);
    expect(find.text(r'$25'), findsOneWidget);

    // Profile Avatar tap opens profile bottom sheet
    final avatarButton = find.bySemanticsLabel('User profile and account settings');
    expect(avatarButton, findsOneWidget);
    await tester.tap(avatarButton);
    await tester.pumpAndSettle();

    // Verify User Profile Modal elements
    expect(find.text('Guest Healer'), findsOneWidget);
    expect(find.text('Sign In to Account'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
