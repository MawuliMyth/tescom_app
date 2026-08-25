import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tescon_app/screens/onboarding_screen.dart';

void main() {
  testWidgets('onboarding experience renders primary call to action', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump();

    expect(find.text('TESCON'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
