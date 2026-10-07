# TrypX Flutter — Autonomous Two-LLM Build System

## Roles
- BRAIN (plan + verify): Claude Opus 4.8 via Genspark proxy
- HANDS (write code): DeepSeek v4 Pro via Genspark proxy
- JUDGE (truth): flutter analyze (errors only) + flutter test
Two different models cross-check; a red build can never be committed.

## Files (keep all of these in E:\TrypX_App_Flutter\)
- auto_dev.py      the loop
- make_task.py     Opus-powered task generator (one-line goal -> tasks/F-XX.md)
- OPUS_SYSTEM.md   verifier rulebook
- ROADMAP.md       your backlog (F-05+ goals to feed make_task.py)
- tasks/           F-00..F-04 ready; generate F-05+ yourself
- reference/       TrypX spec ported from the Android repo (tokens, data model, invariants, screens, AI tasks)
- state.txt        last completed task (auto)
- run.log          full log (auto)
The Flutter app itself lives in E:\TrypX_App_Flutter\trypx\

## One-time setup
- GSK_API_KEY env var must be set (setx GSK_API_KEY "..." then reopen PowerShell).
- Run commands from E:\TrypX_App_Flutter\ (NOT from inside trypx\).

## Daily workflow (fully solo, no external help)
1. python make_task.py F-05 "<goal from ROADMAP.md>"   # Opus writes the spec
2. (open tasks/F-05.md, 30-sec skim)
3. python auto_dev.py F-05                              # build + verify + auto-commit
4. cd trypx; git push; cd ..                            # push when happy

Run many at once: drop several task files, then `python auto_dev.py` (runs all pending,
resumes from state.txt, stops on any real problem).

## When to STOP and bring in a human / Claude / ChatGPT Plus
- Anything touching money, auth, or Firestore SECURITY RULES (F-08+).
- Any task that wants a pubspec version change (invariant 21) — approve + add deps manually.
- The loop prints NEEDS-DECISION or BLOCKED after 3 tries.

## When can I run the app on my OnePlus from Android Studio?
You can run it RIGHT NOW (it's a valid Flutter app since F-00). But it shows meaningful
UI only after F-06 (onboarding screens). Recommended first run: after F-06.
Steps:
  1. Open E:\TrypX_App_Flutter\trypx in Android Studio.
  2. Plug in the OnePlus (USB debugging on), accept the prompt.
  3. Pick the device in the toolbar, press Run (or: `cd trypx; flutter run`).
Before F-06 you'll see the default counter screen; after F-06, the onboarding flow;
after F-08/F-09, real data via Firestore.

## Safety rules enforced in code
- PASS only if flutter test passes AND no analyze ERRORS AND Opus verifies spec+invariants.
- Ground truth wins: Opus can't pass a red build.
- Never writes secrets/Firebase config/versions (auto-STOP).
- Max 3 fix attempts/task, then STOP.
- One task = one commit. Never pushes (you review + push).
