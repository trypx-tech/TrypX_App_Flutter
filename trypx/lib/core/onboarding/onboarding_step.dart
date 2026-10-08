/// TrypX supply-side onboarding step model.
/// Screen order per reference/SCREENS.md with persona fork at step 1 (invariant 11)
/// and skippable social (invariant 19).
library;

/// The supply-side onboarding funnel in screen order.
enum OnboardingStep {
  roleSelect, // S-01
  applicantLanding, // S-02
  connectStory, // S-03
  connectSocial, // S-08 (skippable — invariant 19)
  manualPlaces, // S-09
  placesYouKnow, // S-04
  languages, // S-05 (mandatory — invariant 14)
  interviewSlot, // S-06
  whatHappensNext, // S-07 (submit)
}

/// Single source of truth for step ordering.
const List<OnboardingStep> kOnboardingStepOrder = <OnboardingStep>[
  OnboardingStep.roleSelect,
  OnboardingStep.applicantLanding,
  OnboardingStep.connectStory,
  OnboardingStep.connectSocial,
  OnboardingStep.manualPlaces,
  OnboardingStep.placesYouKnow,
  OnboardingStep.languages,
  OnboardingStep.interviewSlot,
  OnboardingStep.whatHappensNext,
];
