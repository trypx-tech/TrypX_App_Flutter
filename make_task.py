"""
TrypX - Task Generator
======================
Turns a one-line goal into a detailed tasks/F-XX.md spec, written by Claude Opus
(the same proxy brain the loop uses). You then run:  python auto_dev.py F-XX

Usage (run from the folder that contains auto_dev.py and tasks/):
  python make_task.py F-04 "Port the design system theme + core widgets from reference/DESIGN_TOKENS.md and reference/COMPONENT_CATALOGUE.md"

It reuses auto_dev's proxy call + reference pack, so no extra config is needed.
Requires env var GSK_API_KEY (same as the loop).
"""

import sys
from pathlib import Path

import auto_dev  # reuse the proven proxy call + paths

TASK_AUTHOR_SYSTEM = (
    "You are a senior engineer writing a build-task spec for an autonomous coding loop. "
    "The loop: Claude Opus plans, DeepSeek writes Dart files, `flutter analyze` + "
    "`flutter test` verify, then it auto-commits. Your job: turn a one-line goal into a "
    "precise, self-contained task file.\n\n"
    "Output format (plain markdown, no code fences around the whole thing):\n"
    "  First line: `SUMMARY: <short summary used as the git commit message>`\n"
    "  Then: `TASK F-XX - <title>` and clear numbered requirements.\n"
    "  Specify EXACT file paths under lib/ and test/. Prefer giving exact Dart where you "
    "can. Require matching unit tests. Insist on lint-clean Dart (a `library;` directive "
    "after any file-level doc comment; braces on all control-flow bodies).\n"
    "  End with a line listing the done tokens: "
    "`F-XX DONE | F-XX BLOCKED - <reason> | F-XX NEEDS-DECISION - <question>`.\n\n"
    "Hard rules the task MUST respect: never change pubspec versions / Firebase config / "
    "secrets (those need human approval, invariant 21); AI never auto-approves applicants "
    "(invariant 12); language is mandatory (14); 50-per-location cap (17); no-social path "
    "allowed (19). Keep scope to ONE coherent step. Reuse the TrypX design tokens and "
    "component names from the reference pack when relevant."
)

def main():
    if len(sys.argv) < 3:
        print('Usage: python make_task.py F-XX "one-line goal"')
        return
    task_id = sys.argv[1].strip()
    goal = " ".join(sys.argv[2:]).strip()

    if not auto_dev.API_KEY:
        print("ERROR: GSK_API_KEY not set.")
        return

    # Attach the whole reference pack so Opus authors against the real TrypX spec.
    refs = []
    for ref in sorted(auto_dev.REF_DIR.glob("*.md")):
        refs.append(f"--- reference/{ref.name} ---\n{ref.read_text(encoding='utf-8')}")
    ref_block = "\n\n".join(refs)

    print(f"Asking Opus to author {task_id} ...")
    spec = auto_dev.llm(auto_dev.VERIFIER_MODEL, [
        {"role": "system", "content": TASK_AUTHOR_SYSTEM},
        {"role": "user", "content":
            f"Reference pack for TrypX:\n{ref_block}\n\n"
            f"Write the task file for {task_id}. Goal:\n{goal}\n\n"
            f"Remember: first line must be `SUMMARY: ...`. Use {task_id} in the done tokens."},
    ], max_tokens=6000)

    # strip accidental surrounding code fences
    spec = spec.strip()
    if spec.startswith("```"):
        spec = spec.split("\n", 1)[1]
        if spec.endswith("```"):
            spec = spec.rsplit("```", 1)[0]
    spec = spec.strip() + "\n"

    out = auto_dev.TASKS_DIR / f"{task_id}.md"
    out.write_text(spec, encoding="utf-8")
    print(f"Wrote {out}")
    print("---- preview (first 25 lines) ----")
    print("\n".join(spec.splitlines()[:25]))
    print("----------------------------------")
    print(f"Review it, then run:  python auto_dev.py {task_id}")

if __name__ == "__main__":
    main()
