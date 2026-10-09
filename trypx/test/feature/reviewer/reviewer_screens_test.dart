import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trypx/core/design_system/widgets/trypx_primary_button.dart';
import 'package:trypx/core/design_system/widgets/trypx_text_field.dart';
import 'package:trypx/feature/reviewer/screens/reviewer_screens.dart';

void main() {
  testWidgets('decision form keeps submit disabled for <10-char reason and enables it at >=10 chars', (tester) async {
    final mockData = {
      'displayName': 'Test User',
      'persona': 'public_creator',
      'locationId': 'us-ny',
      'languageCodes': ['en'],
      'status': 'submitted',
    };

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ApplicantDetailScreen(
            applicantUid: 'app-001',
            applicantData: mockData,
          ),
        ),
      ),
    );

    // Initial state: not enabled
    final submitButton = find.widgetWithText(TrypXPrimaryButton, 'Submit Decision');
    expect(tester.widget<TrypXPrimaryButton>(submitButton).enabled, isFalse);

    // Select an outcome
    await tester.tap(find.text('approve'));
    await tester.pumpAndSettle();

    // Still disabled because reason is empty
    expect(tester.widget<TrypXPrimaryButton>(submitButton).enabled, isFalse);

    // Enter a reason with 9 characters
    await tester.enterText(find.byType(TrypXTextField), '123456789');
    await tester.pumpAndSettle();
    expect(tester.widget<TrypXPrimaryButton>(submitButton).enabled, isFalse);

    // Enter a reason with 10 characters
    await tester.enterText(find.byType(TrypXTextField), '1234567890');
    await tester.pumpAndSettle();
    expect(tester.widget<TrypXPrimaryButton>(submitButton).enabled, isTrue);
  });
}
