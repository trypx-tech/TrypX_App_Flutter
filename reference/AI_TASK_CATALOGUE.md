# TrypX AI Task Catalogue (ported from Android `core/ai/`)

Invariant 9: NO feature/data module calls an LLM directly — everything routes through
a single AI layer (lib/core/ai/). Invariant 10: all AI output is schema-constrained JSON,
no free-text parsing. Invariant 12: AI is ADVISORY for verification — it never auto-approves.

## Router concept
An AiRouter chooses an engine by task metadata:
- Cloud engine (Gemini cloud) for complex/online tasks.
- On-device engine (Gemini Nano on Android) for offline/low-latency/private tasks.
  NOTE: Nano is Android-only. On iOS, route those to cloud (or Apple on-device later).
  This is a known cross-platform design task, not a blocker.
Guardrails present in the Android layer (port as services): PiiScrubber,
PromptInjectionFilter, SafetyClassifier, SessionMemory, AiTelemetry, ToolRegistry.

## The 18 tasks (name — metadata: complexity / offline / PII / maxLatencyMs / tools / streamable)
TripPlannerTask           HIGH   / no  / PII / 5000 / tools / stream
ReelToAssetsTask          MEDIUM / no  / -   / 3000 / tools / -
NicheClassifierTask       LOW    / yes / -   / 500  / -     / -
ScamAlertTask             LOW    / yes / -   / 300  / -     / -
DmReplyTask               MEDIUM / no  / PII / 2000 / tools / -
StorefrontCopyTask        MEDIUM / no  / -   / 3000 / -     / stream
PricingCoachTask          MEDIUM / no  / -   / 2000 / tools / -
ItineraryReoptimizerTask  HIGH   / no  / PII / 4000 / tools / stream
StylometricScanTask       LOW    / yes / -   / 500  / -     / -
ImageForensicsTask        MEDIUM / yes / -   / 1000 / -     / -
EntityLinkerTask          MEDIUM / no  / -   / 1500 / tools / -
EmbeddingTask             LOW    / yes / -   / 200  / -     / -
ConsultationSummarizerTask HIGH  / no  / PII / 5000 / -     / stream
InterviewQuestionerTask   (advisory follow-up questions for the HUMAN reviewer)
LanguageProficiencyScorerTask  (scores the 60s voice sample — invariant 14)
EvidenceOfStayVerifierTask     (advisory)
ApplicantAuthenticityScoreTask (advisory; recommender stays advisory until ~500 human decisions)
LocationSaturationEvaluatorTask (advisory; relates to 50-cap, invariant 17)

Tools available to tasks (port as needed): SearchPlacesTool, GetItineraryTool,
LookupSupplierPriceTool, GetCreatorProfileTool.

This file is a SPEC. Implement incrementally in later F-tasks; do not build all 18 at once.
