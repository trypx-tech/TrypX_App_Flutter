/// TrypX core enums and constants.
/// Ported verbatim from the Android reference repo (OnboardingEnums.kt + PlaceDepth.kt).
/// These encode system invariants 11, 12, 14, 17, 19 — do not change values.

/// Hard ceiling of verified suppliers per location (invariant 17).
const int kLocationSupplierCap = 50;

/// Default length of a reviewer interview slot, in minutes.
const int kDefaultInterviewMinutes = 30;

/// Supply-side personas (invariant 11).
enum Persona { publicCreator, silentExpert }

enum ApplicationStatus {
  draft,
  submitted,
  inReview,
  interviewScheduled,
  approved,
  waitlisted,
  rejected,
}

/// none = manual, no-social claim path (invariant 19).
enum SocialPlatform { instagram, facebook, youtube, tiktok, none }

enum ProficiencyLevel { native, fluent, conversational, basic }

enum EvidenceType {
  socialProfile,
  postLink,
  photo,
  document,
  reference,
  voiceSample,
}

enum InterviewStatus { proposed, confirmed, completed, noShow, cancelled }

enum DecisionOutcome { approve, waitlist, reject, requestMoreInfo }

/// How well an applicant knows a place. An application needs at least one deep place.
enum PlaceDepth {
  livedThere(isDeep: true),
  frequent(isDeep: true),
  visited(isDeep: false);

  const PlaceDepth({required this.isDeep});
  final bool isDeep;
}
