/// F-06: Onboarding Controller
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/submission.dart';
import '../../../core/onboarding/onboarding_flow.dart';

class OnboardingDraft {
  const OnboardingDraft({
    this.flowState = const OnboardingState(),
    this.displayName = '',
    this.validation = const StepValid(),
  });

  final OnboardingState flowState;
  final String displayName;
  final StepValidation validation;

  OnboardingDraft copyWith({
    OnboardingState? flowState,
    String? displayName,
    StepValidation? validation,
  }) {
    return OnboardingDraft(
      flowState: flowState ?? this.flowState,
      displayName: displayName ?? this.displayName,
      validation: validation ?? this.validation,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingDraft> {
  OnboardingController() : super(const OnboardingDraft());

  static const _flow = OnboardingFlow();

  void loadDraft(OnboardingDraft draft) {
    state = draft;
  }

  void setRole(Persona persona) {
    state = state.copyWith(
      flowState: state.flowState.copyWith(persona: persona),
      validation: const StepValid(),
    );
  }

  void setDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }

  void setSocial(SocialLink? social, {bool skipped = false}) {
    state = state.copyWith(
      flowState: state.flowState.copyWith(social: social, socialSkipped: skipped),
      validation: const StepValid(),
    );
  }

  void addPlace(PlaceClaim place) {
    state = state.copyWith(
      flowState: state.flowState.copyWith(
        places: [...state.flowState.places, place],
      ),
      validation: const StepValid(),
    );
  }

  void removePlace(PlaceClaim place) {
    state = state.copyWith(
      flowState: state.flowState.copyWith(
        places: state.flowState.places.where((p) => p != place).toList(),
      ),
      validation: const StepValid(),
    );
  }

  void addLanguage(LanguageClaim language) {
    state = state.copyWith(
      flowState: state.flowState.copyWith(
        languages: [...state.flowState.languages, language],
      ),
      validation: const StepValid(),
    );
  }

  void removeLanguage(LanguageClaim language) {
    state = state.copyWith(
      flowState: state.flowState.copyWith(
        languages: state.flowState.languages.where((l) => l != language).toList(),
      ),
      validation: const StepValid(),
    );
  }

  void setInterviewSlot(DateTime time) {
    state = state.copyWith(
      flowState: state.flowState.copyWith(interviewStartsAt: time),
      validation: const StepValid(),
    );
  }

  bool advance() {
    final result = _flow.next(state.flowState);
    if (result.validation is StepInvalid) {
      state = state.copyWith(validation: result.validation);
      return false;
    } else {
      state = state.copyWith(
        flowState: result.state,
        validation: const StepValid(),
      );
      return true;
    }
  }

  void goBack() {
    final prev = _flow.previousStep(state.flowState.step);
    if (prev != null) {
      state = state.copyWith(
        flowState: state.flowState.copyWith(step: prev),
        validation: const StepValid(),
      );
    }
  }

  ApplicationSubmission? buildSubmission() {
    if (!_flow.isComplete(state.flowState) || state.displayName.isEmpty) {
      return null;
    }
    return ApplicationSubmission(
      persona: state.flowState.persona!,
      displayName: state.displayName,
      social: state.flowState.social,
      places: state.flowState.places,
      languages: state.flowState.languages,
      interviewStartsAtEpochMs: state.flowState.interviewStartsAt!.millisecondsSinceEpoch,
    );
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingDraft>((ref) {
  return OnboardingController();
});
