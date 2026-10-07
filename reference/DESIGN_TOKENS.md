# TrypX Design Tokens (ported from Android `core/designsystem/theme/`)

Dark theme only. Port into a Flutter `ThemeData` + a `TrypXSpacing` constants class.

## Colors (exact hex — from TrypXColors.kt)
| Token | Hex | Role |
|---|---|---|
| SurfaceNavy | #0A1128 | background / surface |
| CardNavy | #111C35 | cards / surfaceVariant |
| PrimaryOrange | #FF5E00 | primary action |
| SecondaryCyan | #00D5E6 | selection / secondary / tertiary |
| NavyContainerLow | #0E1730 | surfaceContainerLow |
| NavyContainerHigh | #16223F | surfaceContainerHigh |
| NavyContainerHighest | #1B2849 | surfaceContainerHighest |
| TextPrimary | #FFFFFF | onBackground / onSurface |
| TextSecondary | #94A3B8 | onSurfaceVariant |
| TextTertiary | #64748B | muted |
| SuccessGreen | #22C55E | success |
| WarningOrange | #FF6B35 | warning |
| ErrorRed | #EF4444 | error |
| BorderSubtle | #1E293B | outlineVariant |
| BorderDefault | #334155 | outline |

ColorScheme mapping (dark): primary=PrimaryOrange, onPrimary=white,
secondary/tertiary=SecondaryCyan, onSecondary=SurfaceNavy, background/surface=SurfaceNavy,
surfaceVariant=CardNavy, error=ErrorRed.

## Typography (from TrypXTypography.kt) — fonts: Inter (body/headings), JetBrains Mono (mono accents)
| Style | Weight | Size (sp→use logical px) | Line height |
|---|---|---|---|
| displayLarge | Bold | 36 | 40 |
| displayMedium | Bold | 32 | 36 |
| displaySmall | Bold | 28 | 32 |
| headlineLarge | Bold | 24 | 28 |
| headlineMedium | Bold | 20 | 24 |
| headlineSmall | Bold | 18 | 22 |
| titleLarge | SemiBold | 18 | 22 |
| titleMedium | SemiBold | 16 | 20 |
| titleSmall | SemiBold | 14 | 18 |
| bodyLarge | Regular | 15 | 22 |
| bodyMedium | Regular | 14 | 20 |
| bodySmall | Regular | 13 | 18 |
| labelLarge | SemiBold | 14 | 16 |
| labelMedium | SemiBold | 12 | — |

Add the Inter + JetBrains Mono font files to the Flutter project (pubspec `fonts:`),
or use `google_fonts` (Inter, JetBrains Mono) — but a version/dependency add needs
Gopal's approval first (invariant 21).

## Spacing (from TrypXSpacing.kt) — logical pixels
xs=4, s=8, m=12, base=16, l=20, xl=24, xxl=32, xxxl=48,
screenHorizontal=20, bottomNavClearance=88, stickyCtaClearance=96
