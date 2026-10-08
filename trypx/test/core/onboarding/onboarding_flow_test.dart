import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/models/enums.dart';
import 'package:trypx/core/models/submission.dart';
import 'package:trypx/core/onboarding/onboarding_flow.dart';
import 'package:trypx/core/onboarding/onboarding_step.dart';

void main() {
  const OnboardingFlow flow = OnboardingFlow();

  const PlaceClaim visitedPlace = PlaceClaim(
    name: 'Paris',
    countryCode: 'FR',
    depth: PlaceDepth.visited,
  );
  const PlaceClaim livedPlace = PlaceClaim(
    name: 'Kyoto',
    countryCode: 'JP',
    depth: PlaceDepth.livedThere,
  );
  const PlaceClaim frequentPlace = PlaceClaim(
    name: 'Lisbon',
    countryCode: 'PT',
    depth: PlaceDepth.frequent,
  );
  const LanguageClaim english = LanguageClaim(
    languageCode: 'en',
    level: ProficiencyLevel.native,
  );

  group('validate roleSelect (invariant 11)', () {
    test('invalid when persona null', () {
      const OnboardingState s = OnboardingState();
      final StepValidation v = flow.validate(s);
      expect(v, isA<StepInvalid>());
      expect((v as StepInvalid).reason, StepReason.personaNotSelected);
    });

    test('valid for publicCreator', () {
      const OnboardingState s =
          OnboardingState(persona: Persona.publicCreator);
      expect(flow.validate(s), isA<StepValid>());
    });

    test('valid for silentExpert', () {
      const OnboardingState s =
          OnboardingState(persona: Persona.silentExpert);
      expect(flow.validate(s), isA<StepValid>());
    });
  });

  group('validate placesYouKnow', () {
    test('invalid (noDeepPlace) when only visited place', () {
      const OnboardingState s = OnboardingState(
        step: OnboardingStep.placesYouKnow,
        places: <PlaceClaim>[visitedPlace],
      );
      final StepValidation v = flow.validate(s);
      expect(v, isA<StepInvalid>());
      expect((v as StepInvalid).reason, StepReason.noDeepPlace);
    });

    test('valid with livedThere place', () {
      const OnboardingState s = OnboardingState(
        step: OnboardingStep.placesYouKnow,
        places: <PlaceClaim>[visitedPlace, livedPlace],
      );
      expect(flow.validate(s), isA<StepValid>());
    });

    test('valid with frequent place', () {
      const OnboardingState s = OnboardingState(
        step: OnboardingStep.placesYouKnow,
        places: <PlaceClaim>[frequentPlace],
      );
      expect(flow.validate(s), isA<StepValid>());
    });
  });

  group('validate languages (invariant 14)', () {
    test('invalid (missingLanguage) when empty', () {
      const OnboardingState s =
          OnboardingState(step: OnboardingStep.languages);
      final StepValidation v = flow.validate(s);
      expect(v, isA<StepInvalid>());
      expect((v as StepInvalid).reason, StepReason.missingLanguage);
    });

    test('valid with one language', () {
      const OnboardingState s = OnboardingState(
        step: OnboardingStep.languages,
        languages: <LanguageClaim>[english],
      );
      expect(flow.validate(s), isA<StepValid>());
    });
  });

  group('validate interviewSlot', () {
    test('invalid (interviewNotChosen) when null', () {
      const OnboardingState s =
          OnboardingState(step: OnboardingStep.interviewSlot);
      final StepValidation v = flow.validate(s);
      expect(v, isA<StepInvalid>());
      expect((v as StepInvalid).reason, StepReason.interviewNotChosen);
    });

    test('valid when set', () {
      final OnboardingState s = OnboardingState(
        step: OnboardingStep.interviewSlot,
        interviewStartsAt: DateTime.utc(2025, 3, 4, 9),
      );
      expect(flow.validate(s), isA<StepValid>());
    });
  });

  group('skippable social (invariant 19)', () {
    test('connectSocial is valid with no social data', () {
      const OnboardingState s =
          OnboardingState(step: OnboardingStep.connectSocial);
      expect(flow.validate(s), isA<StepValid>());
    });

    test('connectSocial is valid when marked skipped', () {
      const OnboardingState s = OnboardingState(
        step: OnboardingStep.connectSocial,
        socialSkipped: true,
      );
      expect(flow.validate(s), isA<StepValid>());
    });
  });

  group('step ordering is a single source of truth', () {
    test('order matches enum declaration order', () {
      expect(kOnboardingStepOrder, OnboardingStep.values);
    });

    test('nextStep walks every step in order', () {
      final List<OnboardingStep> walked = <OnboardingStep>[
        OnboardingStep.roleSelect,
      ];
      OnboardingStep? cursor = flow.nextStep(OnboardingStep.roleSelect);
      while (cursor != null) {
        walked.add(cursor);
        cursor = flow.nextStep(cursor);
      }
      expect(walked, kOnboardingStepOrder);
    });

    test('nextStep returns null at the final step', () {
      expect(flow.nextStep(OnboardingStep.whatHappensNext), isNull);
    });

    test('previousStep returns null at the first step', () {
      expect(flow.previousStep(OnboardingStep.roleSelect), isNull);
    });

    test('previousStep moves backwards one step', () {
      expect(
        flow.previousStep(OnboardingStep.languages),
        OnboardingStep.placesYouKnow,
      );
    });
  });

  group('next()', () {
    test('does not advance when the current step is invalid', () {
      const OnboardingState s = OnboardingState();
      final ({OnboardingState state, StepValidation validation}) r =
          flow.next(s);
      expect(r.state.step, OnboardingStep.roleSelect);
      expect(r.validation, isA<StepInvalid>());
    });

    test('advances when the current step is valid', () {
      const OnboardingState s =
          OnboardingState(persona: Persona.publicCreator);
      final ({OnboardingState state, StepValidation validation}) r =
          flow.next(s);
      expect(r.state.step, OnboardingStep.applicantLanding);
      expect(r.validation, isA<StepValid>());
    });

    test('holds at the final step', () {
      final OnboardingState s = OnboardingState(
        step: OnboardingStep.whatHappensNext,
        persona: Persona.silentExpert,
        places: const <PlaceClaim>[livedPlace],
        languages: const <LanguageClaim>[english],
        interviewStartsAt: DateTime.utc(2025, 3, 4, 9),
      );
      final ({OnboardingState state, StepValidation validation}) r =
          flow.next(s);
      expect(r.state.step, OnboardingStep.whatHappensNext);
      expect(r.validation, isA<StepValid>());
    });
  });

  group('isComplete never approves (invariant 12)', () {
    OnboardingState complete() {
      return OnboardingState(
        step: OnboardingStep.whatHappensNext,
        persona: Persona.publicCreator,
        places: const <PlaceClaim>[livedPlace],
        languages: const <LanguageClaim>[english],
        interviewStartsAt: DateTime.utc(2025, 3, 4, 9),
      );
    }

    test('false when not on the final step', () {
      final OnboardingState s =
          complete().copyWith(step: OnboardingStep.interviewSlot);
      expect(flow.isComplete(s), isFalse);
    });

    test('true when all mandatory data is present', () {
      expect(flow.isComplete(complete()), isTrue);
    });

    test('false when persona is missing', () {
      final OnboardingState s = OnboardingState(
        step: OnboardingStep.whatHappensNext,
        places: const <PlaceClaim>[livedPlace],
        languages: const <LanguageClaim>[english],
        interviewStartsAt: DateTime.utc(2025, 3, 4, 9),
      );
      expect(flow.isComplete(s), isFalse);
    });

    test('false when there is no deep place', () {
      final OnboardingState s = OnboardingState(
        step: OnboardingStep.whatHappensNext,
        persona: Persona.publicCreator,
        places: const <PlaceClaim>[visitedPlace],
        languages: const <LanguageClaim>[english],
        interviewStartsAt: DateTime.utc(2025, 3, 4, 9),
      );
      expect(flow.isComplete(s), isFalse);
    });

    test('false when languages are empty', () {
      final OnboardingState s = OnboardingState(
        step: OnboardingStep.whatHappensNext,
        persona: Persona.publicCreator,
        places: const <PlaceClaim>[livedPlace],
        interviewStartsAt: DateTime.utc(2025, 3, 4, 9),
      );
      expect(flow.isComplete(s), isFalse);
    });

    test('false when the interview is not chosen', () {
      final OnboardingState s = OnboardingState(
        step: OnboardingStep.whatHappensNext,
        persona: Persona.publicCreator,
        places: const <PlaceClaim>[livedPlace],
        languages: const <LanguageClaim>[english],
      );
      expect(flow.isComplete(s), isFalse);
    });

    test('manual/no-social path can still complete (invariant 19)', () {
      final OnboardingState s = OnboardingState(
        step: OnboardingStep.whatHappensNext,
        persona: Persona.silentExpert,
        socialSkipped: true,
        places: const <PlaceClaim>[frequentPlace],
        languages: const <LanguageClaim>[english],
        interviewStartsAt: DateTime.utc(2025, 3, 4, 9),
      );
      expect(flow.isComplete(s), isTrue);
    });
  });
}
