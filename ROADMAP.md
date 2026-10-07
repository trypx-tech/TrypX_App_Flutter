# TrypX Flutter — Build Roadmap (your solo backlog)

Workflow for each step:
  1. `python make_task.py F-XX "<goal below>"`   # Opus writes tasks/F-XX.md
  2. open tasks/F-XX.md, skim it (30 sec sanity check)
  3. `python auto_dev.py F-XX`                     # loop builds + verifies + commits
  4. review the commit, then `git push`

Ready-made task files already provided by Claude: F-01, F-02, F-03, F-04.
Generate F-05+ yourself with make_task.py using the goals below.

---

## DONE (committed)
- F-00  scaffold Flutter project
- F-01  core enums + constants
- F-02  policy engines (ApprovalGate, DecisionPolicy, ReviewerIds, LocationIds)
- F-02b freezed/json deps (approved)
- F-03  submission data models

## READY (task file provided)
- F-04  design system: theme + core widgets   -> run: python auto_dev.py F-04

## GENERATE WITH make_task.py (pure ports / UI — safe for the loop)
- F-05  "Build the onboarding flow controller: an OnboardingStep enum and OnboardingFlow
         (S-01 role select .. S-09 manual places) with next()/validation logic, pure Dart
         + unit tests, matching reference/SCREENS.md. No UI yet, no Firebase."
- F-06  "Build the onboarding UI screens S-01..S-09 as Flutter widgets using the F-04
         design system and the F-05 flow controller + a Riverpod state notifier. In-memory
         state only (no Firebase yet). Widget tests for role select and the languages step."
- F-07  "Build the reviewer console UI (R-01 queue, R-02 applicant detail + decision form
         with >=10 char reason, R-04 saturation n/50) using the design system and the F-02
         policy engines. In-memory data. Widget tests for the decision form validation."

## ARCHITECT CHECKPOINTS (do NOT auto-generate blind — bring Claude / ChatGPT Plus in)
- F-08  Firebase + Firestore schema + SECURITY RULES. Rules must enforce invariant 12
        server-side (only a verified human reviewer can write an APPROVE decision) and the
        50-cap (17). THIS IS A SECURITY-CRITICAL DESIGN STEP — have a human/architect design
        the rules before the loop implements them. Needs pubspec Firebase deps (invariant 21
        approval) + google-services.json / firebase_options (manual, never committed).
- F-09  Wire onboarding + reviewer to Firestore (replace in-memory with the shared backend).
- F-10  AI layer (lib/core/ai): AiTask catalogue + AiRouter per reference/AI_TASK_CATALOGUE.md.
        Start advisory-only (invariant 12). Design review recommended before building.

## LATER (traveller app, Phase 1) — per reference/SCREENS.md
Home, Discover, reel viewer + tagged places, place detail + property authenticity,
AI trip planner, review & pay (suppliers), wallet/trips. Each is its own F-task.

---

## Rule of thumb
- Pure ports + UI from the reference pack  -> make_task.py + loop (cheap, hands-free).
- Money / auth / security / Firestore rules -> human architect designs first, THEN loop builds.
