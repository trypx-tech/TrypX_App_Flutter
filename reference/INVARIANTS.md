# TrypX System Invariants

The following 20 invariants are strictly enforced across all modules in the TrypX repository:

1. Meta Graph API is LOCKED at v21.0.
2. Long-lived token refresh cron runs Day 50–59 (WorkManager PeriodicWorkRequest).
3. Automated DM cap is 200/hour/account. HUMAN_AGENT tag extends the window to 7 days.
4. Never serve Instagram media_url directly — always through :core:media-cdn (SHA-256 hashed → S3 → CloudFront).
5. Stripe uses Destination Charges only; escrow releases 50% on booking confirm, 50% post-departure.
6. Creator retention: 100% consultations, 97% group trips; platform takes 8–30% Viator/GYG, 3–7% Expedia Rapid, 1–1.5% Duffel.
7. US SOT operates under Credit Card Pass-Through Exception (Form 750 annually, California).
8. EU operates as Retailer facilitating Linked Travel Arrangements (LTAs), never as Organizer under PTR 2018.
9. NO feature or data module may call an LLM directly — everything routes through :core:ai.
10. All AI outputs must be schema-constrained JSON (responseSchema on Cloud; strict JSON prompt on Nano). No free-text parsing.
11. Two supply-side personas exist: PUBLIC CREATOR and SILENT EXPERT. Both share one onboarding funnel with a persona fork at step 1. From the traveller's POV, results merge.
12. Phase 1 verification is HUMAN-FIRST. AI tasks assist the reviewer but do not auto-approve. No applicant is approved without a human reviewer decision until ~500 approved decisions calibrate the recommender.
13. Free first-touch chat is LOAD-BEARING, not a promo tier. Instrumented but never gated behind a paywall.
14. Language proficiency is MANDATORY on every supplier profile — established via a 60-second on-device voice sample scored by Nano. Filter in every traveller-facing discovery surface.
15. Property authenticity is a first-class product surface, reachable directly from Home search (route property/{propertyId}).
16. ANTI-DISINTERMEDIATION: contact info (phone, email, WhatsApp handles, "let's move off app" phrasings) is BLOCKED in every chat surface — free AND paid — by real-time on-device Nano filter (ContactExfiltrationGuardTask). Contact info released ONLY after a paid transaction closes.
17. LOCATION CAP: each location has a hard ceiling of 50 verified suppliers. Applicants beyond the cap are wait-listed until an existing creator churns or a stronger applicant displaces the median.
18. MERCHANDISE STOREFRONT: :feature:storefront supports physical goods alongside consults/guides/group trips. Physical-goods orders route through Stripe Connect with shipping addresses.
19. MULTI-SOCIAL ONBOARDING: connect-social step supports Instagram, Facebook, YouTube, TikTok OAuth PLUS a no-social manual claim path. Instagram is NEVER required.
20. REWARDS ABSTRACTION: payout wallet balance is decoupled from payout method. v1 = cash via Stripe; v2 = miles/vouchers/points via partnerships, no refactor.
21. The version catalog (gradle/libs.versions.toml) is the ONLY source of truth for versions. No in-IDE Upgrade Assistant runs, no AI-suggested bumps, no spontaneous upgrades. Any version change is a dedicated, human-approved command.
