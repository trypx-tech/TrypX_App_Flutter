/// TrypX onboarding flow controller (pure Dart, no UI / Firebase / AI).
/// Navigation + per-step validation state machine for the supply-side funnel.
/// Invariants 11, 12, 14, 19.
library;

import '../models/enums.dart';
import '../models/submission.dart';
import 'onboarding_step.dart';

/// Immutable snapshot of data collected during onboarding.
class OnboardingState {
  /// Creates an onboarding state snapshot.
  const OnboardingState({
    this.step = OnboardingStep.roleSelect,
    this.persona,
    this.social,
    this.socialSkipped = false,
    this.places = const <PlaceClaim>[],
    this.languages = const <LanguageClaim>[],
    this.interviewStartsAt,
  });

  static const Object _unset = Object();

  /// Current step.
  final OnboardingStep step;

  /// Selected persona (invariant 11).
  final Persona? persona;

  /// Provided social link; null = no-social / manual path (invariant 19).
  final SocialLink? social;

  /// Whether the social step was explicitly skipped.
  final bool socialSkipped;

  /// Claimed places.
  final List<PlaceClaim> places;

  /// Claimed languages (invariant 14).
  final List<LanguageClaim> languages;

  /// Chosen interview start time.
  final DateTime? interviewStartsAt;

  /// Returns a copy with the given fields replaced.
  OnboardingState copyWith({
    OnboardingStep? step,
    Object? persona = _unset,
    Object? social = _unset,
    bool? socialSkipped,
    List<PlaceClaim>? places,
    List<LanguageClaim>? languages,
    Object? interviewStartsAt = _unset,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      persona: identical(persona, _unset) ? this.persona : persona as Persona?,
      social: identical(social, _unset) ? this.social : social as SocialLink?,
      socialSkipped: socialSkipped ?? this.socialSkipped,
      places: places ?? this.places,
      languages: languages ?? this.languages,
      interviewStartsAt: identical(interviewStartsAt, _unset)
          ? this.interviewStartsAt
          : interviewStartsAt as DateTime?,
    );
  }
}

/// Reason a step failed validation.
enum StepReason {
  personaNotSelected,
  noDeepPlace,
  missingLanguage,
  interviewNotChosen,
}

/// Result of validating the current step.
sealed class StepValidation {
  const StepValidation();
}

/// The current step's data is valid.
final class StepValid extends StepValidation {
  const StepValid();
}

/// The current step's data is invalid.
final class StepInvalid extends StepValidation {
  const StepInvalid(this.reason);
  final StepReason reason;
}

/// Pure navigation + validation controller. No I/O.
class OnboardingFlow {
  /// Creates a flow controller.
  const OnboardingFlow();

  /// Validates ONLY the current step of [s].
  StepValidation validate(OnboardingState s) {
    switch (s.step) {
      case OnboardingStep.roleSelect:
        if (s.persona == null) {
          return const StepInvalid(StepReason.personaNotSelected);
        }
        return const StepValid();
      case OnboardingStep.placesYouKnow:
        if (!s.places.any((p) => p.depth.isDeep)) {
          return const StepInvalid(StepReason.noDeepPlace);
        }
        return const StepValid();
      case OnboardingStep.languages:
        if (s.languages.isEmpty) {
          return const StepInvalid(StepReason.missingLanguage);
        }
        return const StepValid();
      case OnboardingStep.interviewSlot:
        if (s.interviewStartsAt == null) {
          return const StepInvalid(StepReason.interviewNotChosen);
        }
        return const StepValid();
      case OnboardingStep.connectSocial:
        return const StepValid();
      case OnboardingStep.applicantLanding:
      case OnboardingStep.connectStory:
      case OnboardingStep.manualPlaces:
      case OnboardingStep.whatHappensNext:
        return const StepValid();
    }
  }

  /// Next step in [kOnboardingStepOrder], or null if [current] is last.
  OnboardingStep? nextStep(OnboardingStep current) {
    final i = kOnboardingStepOrder.indexOf(current);
    if (i < 0 || i >= kOnboardingStepOrder.length - 1) {
      return null;
    }
    return kOnboardingStepOrder[i + 1];
  }

  /// Previous step in [kOnboardingStepOrder], or null at the first step.
  OnboardingStep? previousStep(OnboardingStep current) {
    final i = kOnboardingStepOrder.indexOf(current);
    if (i <= 0) {
      return null;
    }
    return kOnboardingStepOrder[i - 1];
  }

  /// Validates the current step; advances only if valid.
  ({OnboardingState state, StepValidation validation}) next(OnboardingState s) {
    final v = validate(s);
    if (v is StepInvalid) {
      return (state: s, validation: v);
    }
    final n = nextStep(s.step);
    if (n == null) {
      return (state: s, validation: v);
    }
    return (state: s.copyWith(step: n), validation: v);
  }

  /// True only at [OnboardingStep.whatHappensNext] with all mandatory data.
  /// Does NOT perform approval (invariant 12).
  bool isComplete(OnboardingState s) {
    return s.step == OnboardingStep.whatHappensNext &&
        s.persona != null &&
        s.places.any((p) => p.depth.isDeep) &&
        s.languages.isNotEmpty &&
        s.interviewStartsAt != null;
  }
}
