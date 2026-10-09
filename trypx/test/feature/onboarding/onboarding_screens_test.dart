import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/onboarding/onboarding_step.dart';
import 'package:trypx/core/onboarding/onboarding_flow.dart';
import 'package:trypx/feature/onboarding/screens/onboarding_host.dart';
import 'package:trypx/feature/onboarding/state/onboarding_controller.dart';

void main() {
  testWidgets('role-select renders both persona options and selecting one advances', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: OnboardingHost(onSubmit: (_) {}),
        ),
      ),
    );

    // Initial state is roleSelect
    expect(find.text('How will you use TrypX?'), findsOneWidget);

    // Both options rendered
    expect(find.text('Public Creator'), findsOneWidget);
    expect(find.text('Silent Expert'), findsOneWidget);

    // Tap Creator
    await tester.tap(find.text('Public Creator'));
    await tester.pumpAndSettle();

    // Advanced to applicantLanding
    expect(find.text('Tell us about yourself'), findsOneWidget);
  });

  testWidgets('languages step blocks advance with zero languages and allows it after adding one', (tester) async {
    final controller = OnboardingController();
    controller.loadDraft(const OnboardingDraft(
      flowState: OnboardingState(step: OnboardingStep.languages),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          home: OnboardingHost(onSubmit: (_) {}),
        ),
      ),
    );

    expect(find.text('Languages'), findsOneWidget);

    // Tap Next with 0 languages
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Should still be on languages, and show error
    expect(find.text('Languages'), findsOneWidget);
    expect(find.textContaining('missingLanguage'), findsOneWidget); // The error reason is StepReason.missingLanguage

    // Add language
    await tester.tap(find.text('+ Add English'));
    await tester.pumpAndSettle();

    // Tap Next again
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Advanced to interviewSlot
    expect(find.text('Schedule Interview'), findsOneWidget);
  });
}
