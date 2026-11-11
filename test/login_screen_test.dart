import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:earth_dna_mobile/providers/auth_provider.dart';
import 'package:earth_dna_mobile/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders Forgot password link and opens reset modal',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify Welcome Back and inputs
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify Forgot password? link is present
    final forgotBtn = find.text('Forgot password?');
    expect(forgotBtn, findsOneWidget);

    // Tap Forgot password?
    await tester.tap(forgotBtn);
    await tester.pumpAndSettle();

    // Verify Reset Password bottom sheet opens
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(
      find.text(
          "Enter the email address associated with your account and we'll send you a password reset link."),
      findsOneWidget,
    );
  });
}
