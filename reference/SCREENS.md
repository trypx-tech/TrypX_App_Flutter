# TrypX Screens (25 Figma screens + the onboarding/reviewer flows already specced)

## Supply-side (BUILT in Android — port first, these have tested logic)
Onboarding funnel (feature/onboarding), persona fork at step 1 (invariant 11):
  S-01 Role select: Traveller -> traveller home; Creator/Expert -> continue
  S-02 Applicant landing ("Become a TrypX local")
  S-03 Connect story ("How travellers will find you")
  S-08 Multi-social connect (IG/FB/YT/TikTok) OR skip -> S-09 (social NEVER required, invariant 19)
  S-09 Manual places claim
  S-04 Places you know (>=1 DEEP place required)
  S-05 Languages (MANDATORY, invariant 14; voice sample deferred)
  S-06 Interview slot
  S-07 What happens next -> submit (writes status=SUBMITTED only; never auto-approves, invariant 12)

Reviewer console (feature/reviewer, debug/role-gated):
  R-01 Queue (oldest first) + Google sign-in card
  R-02 Applicant detail: summary, claims, decision form (outcome chips, reason >=10 chars)
  R-03 Interview slot confirmation
  R-04 Location saturation (n / 50, invariant 17)

## Traveller-side (NOT built yet — Phase 1 targets, map to feature modules)
  01-02 Reel viewer / discovery with tagged venues
  03    Place tagged in a reel (timestamp quotes, add to plan)
  04    Place detail
  05    More on a place (related reels/lists)
  06-07 AI trip planner: itinerary + reasoning
  08    Review & pay (multi-supplier)
  09    Multi-supplier booking confirmation
  10-12 Trips / Wallet: bookings, itinerary, empty state
  13    Discover ("Where to next?")
  14    Home (trip progress, airport info, local guides)
  15    Messages inbox
  16    Live paid consultation chat
  17    Consultation booked confirmation
  18-19 Choose date/time / book time with a creator
  20    Review consultation booking
  21    Creator profile, services, earnings (storefront incl. physical merch, invariant 18)
  22    Role select (== S-01)
  23-25 Welcome / sign in (Apple, email magic link), follow local guides

Build order: port supply-side (onboarding + reviewer) first since logic+tests exist,
then traveller features per the handoff pipeline.
