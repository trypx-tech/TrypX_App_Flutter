# TrypX Design-System Components (ported from Android `core/designsystem/components/`)

Build these as Flutter widgets in lib/core/design_system/. Use the design tokens
(reference/DESIGN_TOKENS.md). Feature screens must use THESE widgets, never raw
Material widgets styled ad hoc (mirrors the Android rule).

## buttons
TrypXPrimaryButton(text, onPressed, {enabled=true, trailingIcon?, fillsWidth=false})
TrypXSecondaryButton(text, onPressed, {...})
TrypXTextButton(text, onPressed)
TrypXIconButton(icon, onPressed)

## cards
TrypXCard({onTap?, borderAccent?, child})
TrypXCreatorRow(...)       # a creator/expert list row
TrypXPlaceRow(...)         # a place list row
TrypXItineraryStop(...)    # one stop in a trip plan
TrypXReasoningCheck(...)   # AI "reasoning" check row (trip planner)

## chips
TrypXCategoryChip(text, onTap, {selected=false})
TrypXMetaPill(text)
TrypXRecentChip(text, onTap)

## inputs
TrypXTextField(label, value, onChanged, {placeholder?, singleLine=true, trailing?})
TrypXSearchField(...)
TrypXChatComposer(...)     # message composer (messaging / consultation)

## navigation
TrypXTopBar(title, {eyebrow?, onBack?, trailing?})
TrypXBottomBar(...)        # main tab bar (Home/Discover/Trips/...)
TrypXStepIndicator(...)    # onboarding step progress
TrypXDayScroller(...)      # itinerary day selector

## media
TrypXAvatar(imageUrl, {size})
TrypXReelPlayer(...)       # short-video player (discovery). Not Instagram-scale.

## status
TrypXStatusBadge(status)   # application status pill
TrypXEmptyState(title, body, {action?})
TrypXSuccessMedallion(...) # confirmation success graphic

Port incrementally (design-system task F-04 does theme + the core buttons/cards/inputs/
nav/status first; media + chat composer come with their features).
