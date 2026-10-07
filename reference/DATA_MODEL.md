# TrypX Data Model (ported from Android `core/database/`)

In Flutter this becomes Dart models (freezed) + Firestore collections. We skip Room:
the Android app was local-only (the #1 gap in the handoff). Go Firestore-first.

## Enums (see lib/core/models/enums.dart — F-01)
Persona: publicCreator, silentExpert  (invariant 11)
ApplicationStatus: draft, submitted, inReview, interviewScheduled, approved, waitlisted, rejected
SocialPlatform: instagram, facebook, youtube, tiktok, none  (none = no-social path, invariant 19)
ProficiencyLevel: native, fluent, conversational, basic
EvidenceType: socialProfile, postLink, photo, document, reference, voiceSample
InterviewStatus: proposed, confirmed, completed, noShow, cancelled
DecisionOutcome: approve, waitlist, reject, requestMoreInfo
PlaceDepth: livedThere(deep), frequent(deep), visited(not deep)
Constants: kLocationSupplierCap=50 (invariant 17), kDefaultInterviewMinutes=30

## Entities / collections
locations        : id(slug), name, countryCode, supplierCap=50, createdAt
applicants       : id, persona, displayName, homeLocationId->locations, primarySocial,
                   socialHandle?, status, createdAt, updatedAt
language_proficiencies : (applicantId, languageCode BCP-47), level, voiceSampleScore?(0..1), verified
                   — language is MANDATORY (invariant 14)
evidence         : id, applicantId, type, uri, note?, addedAt
interview_slots  : id, applicantId, reviewerId, startsAt, durationMinutes=30, status
reviewer_decisions : id, applicantId, reviewerId, outcome, reason(>=10 chars),
                   aiRecommendation?(advisory only, never auto-applied), decidedAt
place_claims     : (applicantId, locationId), depth, yearsKnown?, note?, isPrimary

## Submission models (lib/core/models/ — F-03)
SocialLink(platform, handle)
PlaceClaim(name, countryCode, depth, yearsKnown?, note?)
LanguageClaim(languageCode, level)
ApplicationSubmission(persona, displayName, social?(null=manual path), places[], languages[],
                      interviewStartsAt)
UNASSIGNED_REVIEWER_ID = "unassigned"

## Business rules (lib/core/policy/ — F-02) — PURE functions, unit-tested
ApprovalGate.evaluate(input) -> Approved | Blocked(reason). Order:
  1 human decision exists  2 reviewer is human  3 outcome==approve
  4 languageCount>=1       5 approvedInLocation < locationCap
  BlockReason: applicantNotFound, noHumanDecision, nonHumanReviewer, decisionNotApprove,
               missingLanguage, locationFull. (invariant 12 = human-first)
ReviewerIds.isHuman(id): false for blank, "unassigned", "ai:*", "system:*"
DecisionPolicy: reason >= 10 chars; reviewable = submitted,inReview,interviewScheduled,waitlisted;
  statusFor(approve)=null (only ApprovalGate approves), waitlist->waitlisted,
  reject->rejected, requestMoreInfo->inReview
LocationIds.slug(name): lowercase, non-letters/digits -> "-", trim "-"; keeps all scripts
  (so "京都" stays). of(country,name)="jp-gion-kyoto". Backs the 50-cap count (invariant 17).
