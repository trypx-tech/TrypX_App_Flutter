# TrypX Flutter — Antigravity Development Brief

## Your role
You are the DOER + TESTER for the TrypX Flutter app, running in Antigravity on Windows.
You write multi-file Dart changes AND run `flutter analyze` / `flutter test` yourself,
iterating until green. One task = one focused change = one commit.

## Project
- Path: E:\TrypX_App_Flutter\trypx   (open THIS folder in Antigravity)
- TrypX = AI-powered travel platform; real human creators/experts help travellers.
- Being rebuilt in Flutter (Riverpod + go_router) from a proven Android/Kotlin app.
- Target: Android (test on a real OnePlus) AND iOS later — so keep code cross-platform,
  no Android-only APIs in shared logic.

## Ground truth (non-negotiable)
A task is DONE only when, from E:\TrypX_App_Flutter\trypx:
  flutter analyze   → no ERROR-level issues (info/warning lints are OK but prefer clean)
  flutter test      → all tests pass
Never edit a test just to make it pass. Never commit a red build.

## What already exists (USE these exact APIs — do NOT redefine or invent)
- lib/core/models/enums.dart : Persona{publicCreator,silentExpert}, ApplicationStatus,
  SocialPlatform{instagram,facebook,youtube,tiktok,none}, ProficiencyLevel, EvidenceType,
  InterviewStatus, DecisionOutcome, PlaceDepth{livedThere,frequent,visited (isDeep)}.
  Constants kLocationSupplierCap=50, kDefaultInterviewMinutes=30.
- lib/core/models/submission.dart : SocialLink(platform,handle), PlaceClaim(name,
  countryCode,depth,yearsKnown?,note?), LanguageClaim(languageCode,level),
  ApplicationSubmission(persona,displayName,social?,places[],languages[],
  interviewStartsAtEpochMs) with hasAtLeastOneDeepPlace + toJson/fromJson.
- lib/core/policy/ : ApprovalGate, DecisionPolicy, ReviewerIds, LocationIds (pure rules).
- lib/core/design_system/ : TrypXColors, TrypXSpacing, trypxDarkTheme, and widgets
  TrypXPrimaryButton, TrypXCard, TrypXTextField (+ others). USE these, not raw Material.
- lib/core/onboarding/ : OnboardingStep enum + OnboardingFlow (next/validation/canSubmit).
Before writing, OPEN these files and match their real signatures exactly.

## The 21 invariants (never violate) — critical ones:
- 11 two personas (publicCreator, silentExpert), one funnel, fork at step 1.
- 12 HUMAN-first: AI never auto-approves; UI only builds a SUBMITTED application.
- 14 language MANDATORY to complete onboarding.
- 17 50 verified suppliers per location cap.
- 19 social NEVER required; a no-social manual path must exist.
- 21 NO pubspec version / Firebase config / secret changes without explicit human approval.
(Full list lives in the reference pack; honour all 21.)

## Working rules
- One task per commit. Commit message: "F-XX: <summary>".
- Stay in scope: only create/edit files the task names.
- Never add pubspec dependencies without asking the human first (invariant 21).
- Never touch firebase config / google-services.json / secrets.
- Lint-clean Dart: `library;` after any file-level doc comment; braces on all control flow.
- If a referenced API differs from what a task assumes, use the REAL one and keep behaviour.

## Done so far (committed): F-00 scaffold, F-01 enums, F-02 policy, F-03 models,
   F-04 design system, F-05 onboarding flow controller. 52 tests passing.

## NEXT TASK — F-06: Onboarding UI screens S-01…S-09 (in-memory, no Firebase)
Build the onboarding UI on top of F-04 (design system) + F-05 (OnboardingFlow):
1. lib/feature/onboarding/state/onboarding_controller.dart — a Riverpod StateNotifier
   holding an OnboardingDraft (persona?, displayName, social?, places[], languages[],
   interviewStartsAtEpochMs). Methods to set each field and advance via OnboardingFlow.next.
2. Screens in lib/feature/onboarding/screens/ for:
   S-01 role select (persona fork: traveller vs creator/expert),
   S-02 applicant landing, S-03 connect story,
   S-08 multi-social connect WITH a "Skip / add manually" button → S-09 (invariant 19),
   S-09 manual places, S-04 places you know (≥1 deep place),
   S-05 languages (MANDATORY — block advance until ≥1 language, invariant 14),
   S-06 interview slot, S-07 what-happens-next → submit.
   Use TrypXColors / trypxDarkTheme / TrypXPrimaryButton / TrypXCard / TrypXTextField.
3. A host widget (PageView or Navigator) that advances with OnboardingFlow.next and, when
   OnboardingFlow.canSubmit is true, builds an ApplicationSubmission and calls an injected
   onSubmit callback (NO status mutation — invariant 12).
4. Widget tests: role-select renders both persona options and selecting one advances;
   languages step blocks advance with zero languages and allows it after adding one.
Acceptance: flutter analyze (no errors) + flutter test all pass. Then commit "F-06: ...".

## After F-06 — run it on the OnePlus
  flutter devices        # confirm the phone
  flutter run            # builds + installs + launches

## Roadmap after F-06
F-07 reviewer console UI · F-08 Firebase + Firestore SECURITY RULES (STOP — human/architect
designs these first) · F-09 wire to Firestore · F-10 AI layer (advisory only).
