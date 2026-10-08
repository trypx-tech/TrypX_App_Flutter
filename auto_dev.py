"""
TrypX Flutter - Two-LLM Autonomous Build Orchestrator (proxy-only, no Gemini CLI)
=================================================================================
BRAIN  : Claude Opus (via Genspark proxy)      -> plans + VERIFIES
HANDS  : DeepSeek v4 pro (via Genspark proxy)   -> writes the code (returns JSON files)
JUDGE  : flutter analyze + flutter test         -> objective pass/fail

Two DIFFERENT models (DeepSeek writes, Opus reviews), both over the SAME proxy that
we proved works - so NO Google quota, NO Gemini CLI, NO cmd.exe limits, NO tool-call
hallucination. Python writes the files the doer returns, deterministically.

Per task:
  1) OPUS turns the task spec (+reference) into precise doer instructions.
  2) DEEPSEEK returns a strict JSON array [{path, content}, ...]; Python writes them.
  3) flutter analyze + flutter test  (ground truth).
  4) OPUS verifies spec + invariants + flutter result -> PASS / FIX / NEEDS-DECISION.
     On FIX, Opus writes a correction -> back to (2), max 3. PASS -> git commit.

Requires env var GSK_API_KEY. Python 3.8+, stdlib only.

Run:  python auto_dev.py            (all pending tasks)
      python auto_dev.py F-02       (one task)
      python auto_dev.py --dry-run  (plan only)
"""

import json
import os
import re
import subprocess
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

# ------------------------------------------------------------------ CONFIG
PROJECT_DIR = Path(r"E:\TrypX_App_Flutter\trypx")
HERE        = Path(__file__).parent
TASKS_DIR   = HERE / "tasks"
REF_DIR     = HERE / "reference"
OPUS_SYS    = HERE / "OPUS_SYSTEM.md"
STATE_FILE  = HERE / "state.txt"
LOG_FILE    = HERE / "run.log"

PROXY_URL   = "https://www.genspark.ai/api/llm_proxy/v1/chat/completions"
API_KEY     = os.environ.get("GSK_API_KEY", "")

VERIFIER_MODEL = "claude-opus-4-8"     # the brain (plan + verify)
DOER_MODEL     = "deep-seek-v4-pro"    # the hands (write code). Swap to "gpt-5-codex" if needed.

MAX_FIX_ATTEMPTS = 3
FLUTTER_TIMEOUT  = 600
LLM_TIMEOUT      = 240
LLM_HTTP_RETRIES = 4     # retry transient proxy/network errors (not quota)

DECISION_MARKERS = ["TASK-REQUIRES-HUMAN"]
FORBIDDEN_TOUCH = [
    "firebase_options.dart", "google-services.json", "GoogleService-Info.plist",
    "api_key", "apikey", "secret",
]
IS_WINDOWS = os.name == "nt"

# ------------------------------------------------------------------ IO
def log(msg):
    line = f"[{time.strftime('%H:%M:%S')}] {msg}"
    print(line)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")

def run(cmd, cwd, timeout):
    """Run a command. On Windows, shell=True so .bat/.cmd (flutter, git) resolve."""
    try:
        if IS_WINDOWS:
            quoted = subprocess.list2cmdline(cmd)
            r = subprocess.run(quoted, cwd=str(cwd), capture_output=True,
                               text=True, timeout=timeout, shell=True)
        else:
            r = subprocess.run(cmd, cwd=str(cwd), capture_output=True,
                               text=True, timeout=timeout)
        return r.returncode, (r.stdout or "") + (r.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, f"TIMEOUT after {timeout}s: {' '.join(cmd)}"
    except FileNotFoundError as e:
        return 127, f"Command not found: {e}"

# ------------------------------------------------------------------ PROXY LLM
def llm(model, messages, max_tokens=8000):
    """Call any proxy model. Returns the message content string."""
    if not API_KEY:
        raise RuntimeError("GSK_API_KEY env var is not set.")
    body = json.dumps({"model": model, "messages": messages,
                       "max_tokens": max_tokens}).encode()
    req = urllib.request.Request(
        PROXY_URL, data=body,
        headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"})
    last = None
    for attempt in range(1, LLM_HTTP_RETRIES + 1):
        try:
            with urllib.request.urlopen(req, timeout=LLM_TIMEOUT) as resp:
                data = json.load(resp)
            return data["choices"][0]["message"]["content"] or ""
        except (urllib.error.URLError, KeyError, json.JSONDecodeError) as e:
            last = e
            log(f"     [llm {model}] transient error (try {attempt}): {e}")
            time.sleep(3 * attempt)
    raise RuntimeError(f"LLM call to {model} failed after retries: {last}")

def opus(messages, max_tokens=4000):
    return llm(VERIFIER_MODEL, messages, max_tokens)

# ------------------------------------------------------------------ DOER (DeepSeek)
DOER_SYSTEM = (
    "You are a precise coding executor. You receive exact instructions and output ONLY "
    "a single JSON object of the form "
    '{"files":[{"path":"relative/path.dart","content":"<full file content>"}]} . '
    "Rules: paths are RELATIVE to the project root and use forward slashes. Include the "
    "FULL content of each file (not a diff). Output ONLY the JSON, no markdown fences, no "
    "prose. Create exactly the files the instructions specify, with exactly the given "
    "content. Never change package versions, Firebase config, or secrets.\n"
    "Write lint-clean Dart for `flutter analyze`: put a `library;` directive after any "
    "file-level doc comment (to avoid dangling_library_doc_comments), and always wrap "
    "if/for/while bodies in { } braces (curly_braces_in_flow_control_structures)."
)

def _extract_json(text):
    """Pull the JSON object out of a model reply, tolerating stray fences/prose."""
    t = text.strip()
    if t.startswith("```"):
        t = re.sub(r"^```[a-zA-Z]*\n?", "", t)
        t = re.sub(r"\n?```$", "", t).strip()
    # find first { ... last }
    start = t.find("{")
    end = t.rfind("}")
    if start != -1 and end != -1 and end > start:
        t = t[start:end + 1]
    return json.loads(t)

def doer(instructions):
    """
    Ask DeepSeek for the files as JSON, then WRITE them to disk with Python.
    Returns (written_paths, ok). ok=False if the model gave no usable files.
    """
    log(f"  -> Doer ({DOER_MODEL}) generating files...")
    try:
        reply = llm(DOER_MODEL, [
            {"role": "system", "content": DOER_SYSTEM},
            {"role": "user", "content": instructions},
        ], max_tokens=12000)
    except RuntimeError as e:
        log(f"     doer LLM failed: {e}")
        return [], False
    try:
        obj = _extract_json(reply)
        files = obj["files"]
        assert isinstance(files, list) and files
    except (json.JSONDecodeError, KeyError, AssertionError) as e:
        log(f"     doer returned unparseable JSON ({e}); first 200 chars: {reply[:200]!r}")
        return [], False

    written = []
    for f in files:
        rel = str(f["path"]).replace("\\", "/").lstrip("/")
        dest = PROJECT_DIR / rel
        low = (rel + " " + str(f.get("content", ""))).lower()
        if any(b in low for b in FORBIDDEN_TOUCH):
            log(f"     REFUSING forbidden file write: {rel}")
            return [], False
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(f["content"], encoding="utf-8")
        written.append(rel)
    log(f"     wrote {len(written)} file(s): {', '.join(written)}")
    return written, True

# ------------------------------------------------------------------ JUDGE
def verify_flutter():
    """
    Ground truth. `flutter analyze` exits non-zero even for INFO-level lints, which are
    cosmetic, not correctness problems. So we FAIL only on analyze ERROR-level issues,
    and always require `flutter test` to pass. Info/warning lints are reported (so the
    doer can clean them) but do not block a task whose tests pass.
    """
    a_code, a_out = run(["flutter", "analyze"], cwd=PROJECT_DIR, timeout=FLUTTER_TIMEOUT)
    # count true errors ("error - ..." lines); ignore info/warning
    error_lines = [ln for ln in a_out.splitlines()
                   if re.search(r"^\s*error\b|\berror\s+-\s", ln, re.IGNORECASE)]
    if error_lines:
        return False, "FLUTTER ANALYZE ERRORS:\n" + "\n".join(error_lines) + "\n\n" + a_out

    t_code, t_out = run(["flutter", "test"], cwd=PROJECT_DIR, timeout=FLUTTER_TIMEOUT)
    if t_code != 0:
        return False, "FLUTTER TEST FAILED:\n" + t_out

    lint_note = ""
    if a_code != 0:
        lint_note = ("\nNOTE: analyze reported info/warning lints (non-blocking). "
                     "Prefer clean code, but tests pass:\n" + a_out)
    return True, "FLUTTER OK (tests pass):\n" + t_out + lint_note

def git_diff():
    # Stage everything first so NEW (untracked) files appear in the diff. Without this,
    # `git diff HEAD` omits brand-new files and the verifier sees an empty change set.
    run(["git", "add", "-A"], cwd=PROJECT_DIR, timeout=60)
    _, s = run(["git", "--no-pager", "diff", "--cached", "--stat"], cwd=PROJECT_DIR, timeout=60)
    _, d = run(["git", "--no-pager", "diff", "--cached"], cwd=PROJECT_DIR, timeout=60)
    return (s + "\n" + d)[:8000]

def git_commit(task_id, summary):
    run(["git", "add", "-A"], cwd=PROJECT_DIR, timeout=60)
    run(["git", "commit", "-m", f"{task_id}: {summary}"], cwd=PROJECT_DIR, timeout=60)
    log(f"  committed: {task_id}: {summary}")

# ------------------------------------------------------------------ STATE
def load_state(): return STATE_FILE.read_text().strip() if STATE_FILE.exists() else ""
def save_state(t): STATE_FILE.write_text(t)
def task_files(): return sorted(TASKS_DIR.glob("F-*.md"))

def opus_system_prompt():
    base = OPUS_SYS.read_text(encoding="utf-8") if OPUS_SYS.exists() else ""
    inv = REF_DIR / "INVARIANTS.md"
    if inv.exists():
        base += "\n\n## TrypX INVARIANTS (law)\n" + inv.read_text(encoding="utf-8")
    return base

def reference_context(task_body):
    chunks = []
    for ref in REF_DIR.glob("*.md"):
        if ref.name in task_body:
            chunks.append(f"--- reference/{ref.name} ---\n{ref.read_text(encoding='utf-8')}")
    return "\n\n".join(chunks)

def existing_source_context():
    """
    Give the doer the ACTUAL existing lib/core source so it uses real class/enum APIs
    instead of inventing incompatible ones (e.g. SocialLink.handle, PlaceDepth.livedThere).
    Includes all current .dart files under lib/core, capped for size.
    """
    core = PROJECT_DIR / "lib" / "core"
    if not core.exists():
        return ""
    chunks, total = [], 0
    for f in sorted(core.rglob("*.dart")):
        try:
            text = f.read_text(encoding="utf-8")
        except OSError:
            continue
        rel = f.relative_to(PROJECT_DIR).as_posix()
        block = f"--- EXISTING FILE: {rel} (use these exact APIs; do not redefine) ---\n{text}"
        total += len(block)
        if total > 24000:   # keep the prompt bounded
            break
        chunks.append(block)
    return "\n\n".join(chunks)

def git_clean_worktree():
    """Discard uncommitted changes so a FAILED task never leaves broken files on disk.
    Unstage first (git_diff stages via `git add -A`), then restore tracked + delete new."""
    run(["git", "reset"], cwd=PROJECT_DIR, timeout=60)
    run(["git", "checkout", "--", "."], cwd=PROJECT_DIR, timeout=60)
    run(["git", "clean", "-fd", "lib", "test"], cwd=PROJECT_DIR, timeout=60)

def parse_verdict(text):
    m = re.search(r"(?im)^\s*VERDICT:\s*(PASS|FIX|NEEDS-DECISION)\b", text)
    return m.group(1).upper() if m else "FIX"

# ------------------------------------------------------------------ CORE
def do_task(path, dry_run=False):
    task_id = path.stem
    body = path.read_text(encoding="utf-8")
    sm = re.search(r"SUMMARY:\s*(.+)", body)
    summary = sm.group(1).strip() if sm else task_id

    for marker in DECISION_MARKERS:
        if re.search(rf"(?m)^\s*{re.escape(marker)}\b", body):
            log(f"STOP. {task_id} is a human-only task ({marker}).")
            return "STOP"

    log(f"=== {task_id}: {summary} ===")
    if dry_run:
        log("  (dry-run) would: Opus plan -> DeepSeek write -> flutter -> Opus verify.")
        return "DRY"

    sys_prompt = opus_system_prompt()
    refs = reference_context(body)
    existing = existing_source_context()

    # 1) OPUS PLANS
    log("  -> Opus (orchestrator) planning doer instructions...")
    plan = opus([
        {"role": "system", "content": sys_prompt},
        {"role": "user", "content":
            f"TASK {task_id}.\n\nTask spec:\n{body}\n\n"
            + (f"Reference material:\n{refs}\n\n" if refs else "")
            + (f"EXISTING project source (use these EXACT class names, fields, enum values, "
               f"and import paths; NEVER invent APIs or import files that are not shown "
               f"here):\n{existing}\n\n" if existing else "")
            + "Write precise, literal instructions for the coding model to perform ONLY "
              "this task: exact file paths and exact file contents. Imports and type names "
              "MUST match the existing source shown above. No added scope. "
              "Output only the instructions."},
    ])

    # 2) DOER WRITES
    written, ok = doer(plan)
    if not ok:
        log(f"STOP. {task_id}: doer produced no usable files. Cleaning up. Re-run later.")
        git_clean_worktree()
        return "BLOCKED"

    # 3+4) JUDGE + OPUS VERIFY (fix loop)
    for attempt in range(1, MAX_FIX_ATTEMPTS + 1):
        flut_ok, flutter_logs = verify_flutter()
        diff = git_diff()
        log(f"  -> Opus verifying (attempt {attempt}, flutter_ok={flut_ok})...")
        verdict_text = opus([
            {"role": "system", "content": sys_prompt},
            {"role": "user", "content":
                f"You are VERIFYING task {task_id}.\n\nTask spec:\n{body}\n\n"
                f"Code diff since last commit:\n{diff}\n\n"
                f"Flutter ground-truth result:\n{flutter_logs[:6000]}\n\n"
                "A task PASSES only if flutter analyze AND tests pass AND the code matches "
                "the spec AND no invariant is violated. If flutter failed you must NOT pass. "
                "Never approve editing tests merely to force them green. If flutter is green "
                "and the required files/symbols exist, PASS - do not nitpick style.\n"
                "First line EXACTLY one of: `VERDICT: PASS` / `VERDICT: FIX` / "
                "`VERDICT: NEEDS-DECISION`. If FIX, follow with literal corrected instructions "
                "for the coding model. If NEEDS-DECISION, follow with the question for Gopal."},
        ])
        verdict = parse_verdict(verdict_text)

        if verdict == "PASS" and flut_ok:
            log(f"  PASS (Opus verified + flutter green) on attempt {attempt}.")
            git_commit(task_id, summary)
            save_state(task_id)
            return "DONE"
        if verdict == "NEEDS-DECISION":
            log(f"STOP. Opus raised NEEDS-DECISION:\n{verdict_text}")
            log("  (leaving files in place for human review; run `git status` to inspect)")
            return "STOP"
        if verdict == "PASS" and not flut_ok:
            log("  Opus said PASS but flutter is RED -> overriding to FIX (ground truth wins).")
        if attempt == MAX_FIX_ATTEMPTS:
            break

        log(f"  FIX attempt {attempt}/{MAX_FIX_ATTEMPTS}.")
        fix_instr = re.sub(r"(?is)^.*?VERDICT:\s*FIX\b", "", verdict_text).strip() or (
            f"Fix the code so flutter analyze and test pass. Errors:\n{flutter_logs[:5000]}")
        written, ok = doer(
            "Do NOT change versions, Firebase config, or secrets. Do NOT edit tests to "
            f"force them green. Apply exactly this fix for {task_id}:\n\n{fix_instr}")
        if not ok:
            log(f"STOP. {task_id}: doer produced no fix. Cleaning up. Re-run later.")
            git_clean_worktree()
            return "BLOCKED"

    log(f"STOP. {task_id} still failing after {MAX_FIX_ATTEMPTS} attempts. "
        "Discarding the broken attempt so the tree stays clean. Re-run later.")
    git_clean_worktree()
    return "BLOCKED"

def main():
    args = sys.argv[1:]
    dry = "--dry-run" in args
    single = next((a for a in args if a.startswith("F-")), None)

    if not API_KEY and not dry:
        log("ERROR: GSK_API_KEY not set. setx GSK_API_KEY \"...\" then reopen PowerShell.")
        return
    if not PROJECT_DIR.exists() and single != "F-00" and not dry:
        log(f"NOTE: {PROJECT_DIR} missing. Run flutter create first or fix PROJECT_DIR.")

    files = task_files()
    if not files:
        log("No task files in ./tasks/.")
        return
    if single:
        match = [f for f in files if f.stem == single]
        if not match:
            log(f"Task {single} not found.")
            return
        do_task(match[0], dry)
        return

    last = load_state()
    started = (last == "")
    for f in files:
        if not started:
            if f.stem == last:
                started = True
            continue
        if do_task(f, dry) in ("STOP", "BLOCKED"):
            log("Loop halted. Resolve, then re-run.")
            break

if __name__ == "__main__":
    main()
