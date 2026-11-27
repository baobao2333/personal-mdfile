#!/bin/bash
# Run the real Forge pipeline with deterministic, offline Pi and AGY processes.
set -euo pipefail
src="$(cd "$(dirname "$0")/.." && pwd)"
sandbox="$(mktemp -d "${TMPDIR:-/tmp}/forge-arbiter-test.XXXXXX")"
trap 'wait; rm -rf "$sandbox"' EXIT
root="$sandbox/forge repo"
mkdir -p "$root/bin" "$root/tasks" "$root/records" "$sandbox/mocks" "$sandbox/tmp"
cp "$src"/bin/* "$root/bin/"

export TMPDIR="$sandbox/tmp" MOCK_ROOT="$root" PATH="$sandbox/mocks:$PATH"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_AUTHOR_NAME=Forge GIT_COMMITTER_NAME=Forge
export GIT_AUTHOR_EMAIL=forge@example.invalid GIT_COMMITTER_EMAIL=forge@example.invalid
export PI_EXEC_MODEL=openai/gpt-6.2-sol PI_EXEC_FALLBACK_MODEL=openai/gpt-6.2-astra
export PI_REVIEW_LOGIC_MODEL=openai/gpt-6.2-astra PI_REVIEW_STYLE_MODEL=openai/gpt-6.2-sol
export PI_REVIEW_MODEL="$PI_REVIEW_LOGIC_MODEL" PI_AUDIT_MODEL=google/gemini-4-neon
export PI_LIGHT_MODEL=google/gemini-4-hydrogen
export REVIEW_MODE=multi FRESH_ROUNDS=1 MAX_ROUNDS=3 TOP_AUDIT_LIGHT=0 TOP_AUDIT=1
unset FORGE_GATE_HEAD
export AGY_BIN="$sandbox/mocks/agy" AGY_ARBITER_AGENT=pragmatic-arbiter
export AGY_ARBITER_MODEL=gemini-4-carbon-medium ARBITER_ENABLED=1 ARBITER_MIN_ROUND=2 ARBITER_TIMEOUT=5

git -C "$root" init -q -b main
printf 'base\n' > "$root/result.txt"
git -C "$root" add result.txt
git -C "$root" commit -qm base

cat > "$sandbox/mocks/pi" <<'PY'
#!/usr/bin/env python3
import json, os, subprocess, sys, time
from pathlib import Path

args = sys.argv[1:]
prompt = args[-1]
model = args[args.index("--model") + 1]
root = Path(os.environ["MOCK_ROOT"])
id = Path.cwd().name
record = root / "records" / id
mode = (record / "mode").read_text().strip()


def issue(severity, msg, file="result.txt"):
    return dict(severity=severity, file=file, line=1, msg=msg)


def emit(**text):
    print(json.dumps(dict(type="message_end", message=dict(role="assistant", content=[
        dict(type="text", text=json.dumps(text))]))))


if "--session-id" in args:
    sid = args[args.index("--session-id") + 1]
    if "-r" in sid:
        round = int(sid.rsplit("-r", 1)[1].split("-", 1)[0])
    else:
        prev_r = int((record / "round").read_text().strip()) if (record / "round").exists() else 0
        round = prev_r + 1
    thinking = args[args.index("--thinking") + 1] if "--thinking" in args else ""
    (record / "round").write_text(str(round))
    (record / f"exec-{round}.prompt").write_text(prompt)
    (record / f"exec-{round}.model").write_text(model)
    (record / f"exec-{round}.thinking").write_text(thinking)
    (record / f"exec-{round}.sid").write_text(sid)
    if mode == "parallel":
        (record / "at-barrier").touch()
        peer = root / "records" / ("parallel-b" if id == "parallel-a" else "parallel-a")
        deadline = time.monotonic() + 4
        while not (peer / "at-barrier").exists():
            assert time.monotonic() < deadline, "batch did not overlap both tasks"
            time.sleep(0.025)
    elif mode == "sched-overflow":
        (record / "at-barrier").touch()
        peer = root / "records" / ("sched-b" if id == "sched-a" else "sched-a")
        deadline = time.monotonic() + 4
        while not (peer / "at-barrier").exists():
            assert time.monotonic() < deadline, "sched tasks did not overlap"
            time.sleep(0.025)
        if model == "openai/gpt-6.2-sol":
            picked = subprocess.check_output(
                [str(root / "bin" / "sched"), "pick-style", "--default-model", "openai/gpt-6.2-sol"],
                text=True,
            ).strip()
            (record / "picked-style").write_text(picked)
        time.sleep(0.1)
    elif mode == "transport-failover" and round == 1:
        print(json.dumps(dict(
            type="message_end",
            message=dict(role="assistant", content=[], stopReason="error", errorMessage="429 rate limit exceeded"),
        )))
        sys.exit(0)
    elif mode == "neon-transport-failover" and round == 1:
        print(json.dumps(dict(
            type="message_end",
            message=dict(role="assistant", content=[], stopReason="error", errorMessage="terminated: read ETIMEDOUT"),
        )))
        sys.exit(0)
    elif mode == "sigterm":
        (record / "running").touch()
        time.sleep(15)
        sys.exit(0)
    value = "gate_failure" if mode == "fallback" and round == 1 else f"{mode} round {round}"
    Path("result.txt").write_text(value + "\n")
    subprocess.run(["git", "commit", "-qam", value], check=True)
    (root / "tasks" / id / "status.json").write_text('{"state":"done","note":"mock completed"}')
    sys.exit(0)

round = int((record / "round").read_text())
if prompt.startswith("你是 forge 流程中的 L2"):
    (record / "audit.prompt").write_text(prompt)
    (record / "audit.model").write_text(model)
    emit(verdict="approve", summary_zh="audit checked", arch_risks=[], premise="audit premise")
    sys.exit(0)

role = "style" if prompt.startswith("你是代码审查者 B") else "logic"
assert prompt.startswith("你是代码审查者 ")
with (record / f"{role}-{round}.attempts").open("a") as fp:
    print("call", file=fp)
if mode == "serial-finding":
    if role == "logic":
        time.sleep(0.1)  # Parallel style would finish first.
    with (record / "order").open("a") as fp:
        print(role, file=fp)
if role == "style":
    if mode == "serial-finding":
        emit(verdict="fail", issues=[issue("high", "style contract violation")])
        sys.exit(0)
    emit(verdict="pass", issues=[], premise="")
    sys.exit(23 if mode == "crash" else 0)  # Valid JSON from a crashed process must not count.

if mode == "malformed":
    emit(verdict="fail", issues=None)
    sys.exit(0)
if mode == "bad-item":
    emit(verdict="fail", issues=[dict(severity="high", msg=" ")])
    sys.exit(0)
if mode == "moving":
    # An independent writer changes the branch while L1 reads the gated commit.
    live = root / "worktrees" / id
    Path(live, "result.txt").write_text("gate_failure\n")
    subprocess.run(["git", "-C", str(live), "commit", "-qam", "untested commit"], check=True)
    assert Path("result.txt").read_text() != "gate_failure\n"
    assert subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip() == os.environ["FORGE_GATE_HEAD"]
    emit(verdict="fail", issues=[issue("med", "speculative input")])
    sys.exit(0)
issues, premise = [], ""
if mode == "grounding":
    issues = [issue("med", "hallucinated", "invented.txt"),
              issue("med", "host file", "/etc/hosts"),
              issue("low", "dup severity", str(Path.cwd() / "result.txt")),
              issue("high", "dup severity", "result.txt")]
elif mode == "grounding-pass":
    issues = [issue("med", "hallucinated only", "invented.txt")]
elif mode == "empty-fail":
    emit(verdict="fail", issues=[], premise="")
    sys.exit(0)
elif mode in ("simplify", "accept", "reraise", "narrow", "disabled") and round == 1:
    issues = [issue("low", "low noise"), issue("med", "first review blocker")]
    premise = "reuse repository mechanism"
elif mode == "simplify" and round == 2:
    issues = [issue("low", "round two low noise"), issue("med", "second real bug"),
              issue("high", "first real bug"), issue("med", "speculative switch"),
              issue("med", "speculative input")]
elif mode in ("accept", "disabled") and round == 2:
    issues = [issue("high", "speculative switch"), issue("med", "speculative input")]
elif mode in ("reraise", "narrow") and round == 2:
    issues = [issue("high", "first real bug"), issue("med", "speculative input")]
elif mode == "reraise" and round == 3:
    issues = [issue("med", "speculative input")]
if mode == "simplify" and round == 3:
    # This marker must not enter a future, shorter audit of the same task.
    premise = "old round three audit marker"
emit(verdict="fail" if issues else "pass", issues=issues, premise=premise)
PY

cat > "$sandbox/mocks/agy" <<'PY'
#!/usr/bin/env python3
import json, os, re, stat, subprocess, sys, time
from pathlib import Path

args = sys.argv[1:]
assert "--json-schema" not in args
assert "--settings" not in args
assert "--disable-slash-commands" in args
assert args[args.index("--agent") + 1] == "pragmatic-arbiter"
assert args[args.index("--model") + 1] == "gemini-4-carbon-medium"
assert args[args.index("--output-format") + 1] == "json"
assert args[args.index("--print-timeout") + 1] == os.environ["ARBITER_TIMEOUT"] + "s"
add_dirs = [Path(args[i + 1]) for i, a in enumerate(args) if a == "--add-dir"]
ro_arg, bundle_arg = add_dirs
paths = [p.resolve() for p in add_dirs]
ro, bundle = paths
assert Path.cwd().resolve() == ro
prompt, = [a[3:] for a in args if a.startswith("-p=")]
assert len(prompt) < 1500 and "read_file" in prompt
assert str(ro_arg) in prompt and str(bundle_arg / "context.md") in prompt
context_file = bundle / "context.md"
context = context_file.read_text()
id, round = re.match(r"# Task (.*?)\nround: (\d+)\n", context).groups()
root = Path(os.environ["MOCK_ROOT"]).resolve()
state = root / "logs" / id
record = root / "records" / id
mode = (record / "mode").read_text().strip()
(record / f"agy-{round}.paths").write_text(f"{ro}\n{bundle}\n")
assert all(p.parent == Path(os.environ["TMPDIR"]).resolve() for p in paths)
live_paths = [p for base in (root, Path(os.environ["MOCK_ROOT"])) for p in (base / "logs" / id, base / "worktrees" / id)]
assert not any(str(p) in arg for p in live_paths for arg in args)
assert not any(str(p) in context for p in live_paths)
for text in (prompt, context):
    for forbidden in ("accept.out", "smoke.out", "check.out", "PRIVATE_CHECK_SENTINEL", "ROUND_NONPUBLIC_SENTINEL"):
        assert forbidden not in text
assert not (ro / ".git").exists() and not (ro / "accept.out").exists()
assert list(bundle.iterdir()) == [context_file]
assert all(not (p.stat().st_mode & (stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH))
           for p in [ro, ro / "result.txt", bundle, context_file])
assert (ro / "result.txt").is_file() and "UNCOMMITTED_SENTINEL" not in (ro / "result.txt").read_text()
assert "public forge task specification" in context and "# PUBLIC_CHECK" in context
assert "# PUBLIC_SMOKE" in context and f"Round {round}: churn:" in context
assert "## git diff --stat" in context and "## git diff --name-only" in context
assert "## Current review premise" in context and f"## review-{round}.json" in context
if mode == "truncated":
    assert len(prompt) < 1500 and "DIFF TRUNCATED" in context
    assert "big.txt" in context and "before rebutting" in context
    assert "TRUNCATED_TAIL" not in context and (ro / "big.txt").read_text().endswith("TRUNCATED_TAIL\n")
current = context.split("## Current high/med issues (adjudicate every ID)\n", 1)[1]
issues, _ = json.JSONDecoder().raw_decode(current)
ids = [issue["id"] for issue in issues]
assert ids == [f"I{n}" for n in range(1, len(ids) + 1)] and ids
if mode == "timeout":
    time.sleep(10)
    sys.exit(24)
if mode == "invalid":
    print("not JSON")
    sys.exit(0)
if mode == "head-changed":
    # Simulate a concurrent writer outside the arbiter checkout.
    subprocess.run(["git", "-C", str(root), "update-ref", f"refs/heads/task/{id}",
                    (state / "base").read_text().strip()], check=True)

keep = []
decision = "accept_as_is"
directives = []
if mode == "simplify":
    assert ids == ["I1", "I2", "I3", "I4"]
    decision, keep, directives = "simplify_and_fix", ids[:2], ["remove duplicate state machine"]
elif mode in ("reraise", "narrow") and round == "2":
    decision, keep = "narrow_fix", ids[:1]
elif mode in ("inconsistent", "bad-fix"):
    keep = ids[:1]
elif mode == "partial-fix":
    keep = ids
elif mode == "missing":
    ids = ids[:-1]
elif mode == "escalate":
    decision, ids = "escalate", []
rulings = [dict(id=i, action="keep" if i in keep else "rebut",
                reason_zh="real defect" if i in keep else "no real caller evidence", evidence="") for i in ids]
if mode == "no-evidence":
    rulings[0]["reason_zh"] = " \t "
result = dict(decision=decision, rationale_zh=" checked\n  context \t now ",
              praise_zh=" solid\n  execution \t and sharp review ", issue_rulings=rulings,
              must_fix=[], drop_issues=[], simplify_directives=directives)
if mode == "bad-fix":
    result["must_fix"] = [{}]
elif mode == "rebutted-fix":
    result["decision"] = "narrow_fix"
    result["must_fix"] = [dict(issues[-1], msg="contradicts rebut")]
elif mode == "partial-fix":
    result["must_fix"] = [dict(issues[0], msg="targeted fix")]
response = "```json\n" + json.dumps(result) + "\n```"
status = "FAILURE" if mode == "cli-error" else "SUCCESS"
print("⠋ working {spinner}")
print(json.dumps(dict(conversation_id="mock", status=status, response=response)))
print("done")
print("mock diagnostics", file=sys.stderr)
PY
chmod +x "$sandbox/mocks/pi" "$sandbox/mocks/agy"

fail() { echo "FAIL: $*" >&2; exit 1; }
contains() { grep -Fq -- "$1" "$2" || fail "missing '$1' in $2"; }
excludes() { if grep -Fq -- "$1" "$2"; then fail "unexpected '$1' in $2"; fi; }
absent() { [ ! -e "$1" ] || fail "unexpected file: $1"; }
json() {
  if ! jq -e "$1" "$2" >/dev/null; then
    cat "$2" >&2
    if [ -f "${2%.json}.err" ]; then cat "${2%.json}.err" >&2; fi
    fail "JSON assertion '$1' in $2"
  fi
}
line_is() { [ "$(tail -n "$1" "$3" | head -n 1)" = "$2" ] || fail "incorrect summary tail: $3"; }

make_task() {
  mkdir -p "$root/tasks/$1" "$root/records/$1" "$root/accept/$1"
  echo 'public forge task specification' > "$root/tasks/$1/spec.md"
  printf '# PUBLIC_SMOKE\ntrue\n' > "$root/tasks/$1/smoke.sh"
  printf '# PUBLIC_CHECK\n! grep -q gate_failure result.txt\n' > "$root/tasks/$1/check.sh"
  printf 'echo PRIVATE_CHECK_SENTINEL\n' > "$root/accept/$1/check.sh"
  echo "$2" > "$root/records/$1/mode"
}

run_expect() {
  local expected="$1" id="$2" rc=0
  "$root/bin/run" "$id" > "$root/records/$id/run.out" 2> "$root/records/$id/run.err" || rc=$?
  if [ "$rc" != "$expected" ]; then
    cat "$root/records/$id/run.out" "$root/records/$id/run.err" >&2
    fail "$id: expected rc=$expected, got $rc"
  fi
  absent "$root/logs/$id/run.lock"
  cmp -s "$root/records/$id/run.out" "$root/logs/$id/summary.txt" || fail "$id: summary mismatch"
}

arbiter_expect() {
  local expected="$1" rc=0
  shift
  "$root/bin/arbiter" "$@" > "$root/records/$1/direct.out" 2> "$root/records/$1/direct.err" || rc=$?
  if [ "$rc" != "$expected" ]; then
    cat "$root/records/$1/direct.out" "$root/records/$1/direct.err" >&2
    fail "arbiter $*: expected rc=$expected, got $rc"
  fi
}

# 1. Three rounds, Carbon-pruned feedback, deterministic IDs, no L1-only fallback.
make_task simplify simplify
s="$root/logs/simplify"; r="$root/records/simplify"
# Exercise AGY path agreement even when the host TMPDIR has no trailing slash.
TMPDIR="$TMPDIR//" run_expect 0 simplify
for n in 1 2 3; do contains 'openai/gpt-6.2-sol' "$r/exec-$n.model"; done
contains '[med] (I1) result.txt:1 [logic] first review blocker' "$r/exec-2.prompt"
contains '参考简化提示' "$r/exec-2.prompt"
contains 'reuse repository mechanism' "$r/exec-2.prompt"
contains '收敛硬约束' "$r/exec-2.prompt"
excludes 'low noise' "$r/exec-2.prompt"
json '[.issues[] | [.id, .severity]] == [["I1","high"],["I2","med"],["I3","med"],["I4","med"],["I5","low"]]' "$s/review-2.json"
json '.decision == "simplify_and_fix" and [.must_fix[].id] == ["I1","I2"] and (.drop_issues | length) == 2 and .praise_zh == "solid execution and sharp review"' "$s/arbiter-2.json"
contains '团队肯定与亮点：solid execution and sharp review' "$r/exec-3.prompt"
contains '本轮唯一必须修复的真实问题' "$r/exec-3.prompt"
contains 'first real bug' "$r/exec-3.prompt"
contains 'second real bug' "$r/exec-3.prompt"
contains '必须剥离/简化的过度防御代码' "$r/exec-3.prompt"
contains 'remove duplicate state machine' "$r/exec-3.prompt"
contains '严禁为此增加防御代码或分支' "$r/exec-3.prompt"
contains 'I3 (result.txt:1): no real caller evidence' "$r/exec-3.prompt"
contains 'I4 (result.txt:1): no real caller evidence' "$r/exec-3.prompt"
excludes 'speculative switch' "$r/exec-3.prompt"
excludes 'round two low noise' "$r/exec-3.prompt"
contains 'rounds=3' "$s/summary.txt"
line_is 2 'READY  (merge: bin/merge simplify)' "$s/summary.txt"

# 2. Direct assertion stops the loop; audit and status keep their tail contract.
make_task accept accept
s="$root/logs/accept"; r="$root/records/accept"
run_expect 0 accept
absent "$r/exec-3.prompt"
contains 'rounds=2' "$s/summary.txt"
contains 'ARBITER  round=2 decision=accept_as_is model=gemini-4-carbon-medium  checked context now' "$s/summary.txt"
contains 'PRAISE  solid execution and sharp review' "$s/summary.txt"
contains 'L2_AUDIT  verdict=approve' "$s/summary.txt"
contains 'L2_PREMISE  audit premise' "$s/summary.txt"
line_is 2 'READY  (merge: bin/merge accept)' "$s/summary.txt"
line_is 1 'AUDIT  required (rounds=2 arbiter=accept_as_is)' "$s/summary.txt"
contains '## Carbon 业务仲裁记录' "$r/audit.prompt"
contains 'no real caller evidence' "$r/audit.prompt"
contains 'PRIVATE_CHECK_SENTINEL' "$s/accept.out"
contains 'mock diagnostics' "$s/arbiter-2.err"
while IFS= read -r path; do absent "$path"; done < "$r/agy-2.paths"
if git -C "$root" worktree list --porcelain | grep -E '^worktree .*/forge-arbiter-tree\.[^/]+$'; then
  fail 'stale arbiter worktree registration'
fi
"$root/bin/status" accept > "$r/status.out"
contains '| AUDIT  required (rounds=2 arbiter=accept_as_is)' "$r/status.out"

# 3. Carbon decides on new, per-round IDs when L1 re-raises a dismissed issue.
make_task reraise reraise
run_expect 0 reraise
s="$root/logs/reraise"
json '.decision == "narrow_fix" and .must_fix[0].id == "I1" and (.drop_issues[0] | startswith("I2"))' "$s/arbiter-2.json"
json '.decision == "accept_as_is" and .issue_rulings[0].id == "I1"' "$s/arbiter-3.json"
contains 'rounds=3' "$s/summary.txt"
line_is 2 'READY  (merge: bin/merge reraise)' "$s/summary.txt"

# 4. A remaining fix at the round cap is a hard escalation.
make_task narrow narrow
MAX_ROUNDS=2 run_expect 1 narrow
s="$root/logs/narrow"
json '.decision == "narrow_fix"' "$s/arbiter-2.json"
line_is 1 'ESCALATE  failed after 2 round(s) (arbiter-narrow_fix: remaining must_fix after round 2)' "$s/summary.txt"
excludes 'speculative input' "$s/summary.txt"

# 5. External response validation, process failures, context isolation and truncation.
# This task is independent of 6/7; overlap the CLI timeout test with those runs.
(
s="$root/logs/accept"; r="$root/records/accept"
printf 'ROUND_NONPUBLIC_SENTINEL\n' >> "$s/round-2.txt"
echo inconsistent > "$r/mode"
arbiter_expect 0 accept 2
json '.decision == "narrow_fix" and .must_fix[0].id == "I1" and .rationale_zh == "checked context now"' "$s/arbiter-2.json"
echo escalate > "$r/mode"
arbiter_expect 0 accept 2
json '.decision == "escalate" and .issue_rulings == []' "$s/arbiter-2.json"
echo partial-fix > "$r/mode"
arbiter_expect 0 accept 2
json '.decision == "narrow_fix" and [.must_fix[].id] == ["I1","I2"] and .must_fix[0].msg == "targeted fix"' "$s/arbiter-2.json"
for mode in missing invalid no-evidence cli-error bad-fix rebutted-fix; do
  echo "$mode" > "$r/mode"
  arbiter_expect 1 accept 2
  json '.decision == "error" and (.error | length) > 0' "$s/arbiter-2.json"
done
echo timeout > "$r/mode"
ARBITER_TIMEOUT=1 arbiter_expect 1 accept 2
json '.decision == "error" and (.error | startswith("agy exited"))' "$s/arbiter-2.json"
while IFS= read -r path; do absent "$path"; done < "$r/agy-2.paths"
arbiter_expect 1 accept 2 "$s/nonexistent-review.json"
json '.decision == "error" and .error == "missing head or review json"' "$s/arbiter-2.json"

# Neither a symlinked public input nor an escaping committed link may reach AGY.
rm "$r/agy-2.paths"
public_smoke="$root/tasks/accept/smoke.sh"
mv "$public_smoke" "$r/real-smoke"
ln -s "$root/accept/accept/check.sh" "$public_smoke"
arbiter_expect 1 accept 2
json '.decision == "error"' "$s/arbiter-2.json"
absent "$r/agy-2.paths"
mv -f "$r/real-smoke" "$public_smoke"
wt="$root/worktrees/accept"
ln -s "$s/accept.out" "$wt/external-link"
git -C "$wt" add external-link
git -C "$wt" commit -qm 'external link'
arbiter_expect 1 accept 2
contains 'external snapshot symlink' "$r/direct.err"
absent "$r/agy-2.paths"
git -C "$wt" rm -q external-link
{ awk 'BEGIN {for (i=0; i<1600; i++) printf "%090d\n", i}'; echo TRUNCATED_TAIL; } > "$wt/big.txt"
git -C "$wt" add big.txt
git -C "$wt" commit -qm 'large diff'
echo UNCOMMITTED_SENTINEL >> "$wt/result.txt"
# The previous review cannot adjudicate this new commit. Review it first.
arbiter_expect 1 accept 2
contains 'review HEAD does not match' "$r/direct.err"
echo accept > "$r/mode"
"$root/bin/review" accept > "$s/review-2.json"
echo truncated > "$r/mode"
cp "$s/review-2.json" "$r/review override.json"
arbiter_expect 0 accept 2 "$r/review override.json"
json '.decision == "accept_as_is"' "$s/arbiter-2.json"
echo head-changed > "$r/mode"
arbiter_expect 1 accept 2
json '.decision == "error" and .error == "task HEAD changed during arbitration"' "$s/arbiter-2.json"

) &
validation_pid=$!

# 6. Disabled Carbon and positive L0 fallback control.
make_task disabled disabled
ARBITER_ENABLED=0 run_expect 0 disabled
r="$root/records/disabled"
absent "$r/agy-2.paths"
absent "$root/logs/disabled/arbiter-2.json"
contains 'speculative switch' "$r/exec-3.prompt"
contains 'openai/gpt-6.2-sol' "$r/exec-3.model"
make_task fallback fallback
MAX_ROUNDS=2 run_expect 0 fallback
contains 'openai/gpt-6.2-astra' "$root/records/fallback/exec-2.model"
absent "$root/logs/fallback/review-1.json"

# 7. Reviewer crash retries even with valid JSON, then blocks rather than silently passing.
make_task crash crash
run_expect 1 crash
s="$root/logs/crash"; r="$root/records/crash"
json '.verdict == "error" and .reviewers.logic.verdict == "pass" and .reviewers.style.verdict == "error"' "$s/review-1.json"
[ "$(grep -c '^call$' "$r/style-1.attempts")" = 4 ] || fail 'expected two style attempts per L1 review, twice'
line_is 1 'ESCALATE  failed after 1 round(s) (review-error: L1 reviewer output invalid)' "$s/summary.txt"
absent "$r/exec-2.prompt"
REVIEW_MODE=single "$root/bin/review" crash > "$r/serial-style-crash.json"
json '.verdict == "pass"' "$r/serial-style-crash.json"
echo grounding > "$r/mode"
"$root/bin/review" crash > "$r/grounded.json"
json '.verdict == "fail" and .issues[0].id == "I1" and .issues[0].severity == "high" and .issues[0].file == "result.txt" and .issues[1].severity == "low" and .issues[2].severity == "low" and (.issues[2].msg | contains("[unverified file]"))' "$r/grounded.json"
echo grounding-pass > "$r/mode"
"$root/bin/review" crash > "$r/grounded-pass.json"
json '.verdict == "pass" and (.issues | length == 1) and .issues[0].id == "I1" and .issues[0].severity == "low" and (.issues[0].msg | contains("[unverified file]"))' "$r/grounded-pass.json"
echo empty-fail > "$r/mode"
"$root/bin/review" crash > "$r/empty-fail.json"
json '.verdict == "pass" and (.issues | length == 0)' "$r/empty-fail.json"
REVIEW_MODE=single "$root/bin/review" crash > "$r/single.json"
json '.verdict == "pass" and .reviewers.mode == "single" and (.reviewers | has("style") | not)' "$r/single.json"

echo serial-finding > "$r/mode"
"$root/bin/review" crash > "$r/serial.json"
json '.verdict == "fail" and (.issues[0].msg | contains("[style]"))' "$r/serial.json"
REVIEW_MODE=single "$root/bin/review" crash > "$r/serial-single.json"
json '.verdict == "pass" and (.issues | length == 0)' "$r/serial-single.json"
for mode in malformed bad-item; do
  echo "$mode" > "$r/mode"
  before="$(wc -l < "$r/logic-1.attempts")"
  "$root/bin/review" crash > "$r/invalid.json"
  json '.verdict == "error"' "$r/invalid.json"
  [ "$(wc -l < "$r/logic-1.attempts")" -eq "$((before + 2))" ] || fail 'invalid report did not retry'
done

make_task moving moving
ARBITER_MIN_ROUND=1 MAX_ROUNDS=1 run_expect 1 moving
contains 'FAIL check.sh' "$root/logs/moving/summary.txt"
contains 'WARN task HEAD changed' "$root/logs/moving/summary.txt"
absent "$root/logs/moving/review-1.json"
absent "$root/records/moving/agy-1.paths"

wait "$validation_pid"

# 8. Re-run cleanup, per-task lock ownership and truly overlapping batch jobs.
s="$root/logs/simplify"; r="$root/records/simplify"
contains 'old round three audit marker' "$r/audit.prompt"
echo accept > "$r/mode"
mkdir "$s/run.lock"
echo "$$" > "$s/run.lock/pid"
rc=0
"$root/bin/run" simplify > "$r/locked.out" 2> "$r/locked.err" || rc=$?
[ "$rc" = 1 ] || fail 'same-task live lock was not rejected'
contains 'run already active' "$r/locked.err"
contains 'old round three audit marker' "$s/review-3.json"
# A confirmed dead subprocess PID, not a platform-dependent guess at PID_MAX.
bash -c 'echo "$$"' > "$s/run.lock/pid"
touch "$s/arbiter-3.json" "$s/arbiter-3.raw.json" "$s/arbiter-3.err"
TOP_AUDIT_LIGHT=1 run_expect 0 simplify
for stale in round-3.txt review-3.json arbiter-3.json arbiter-3.raw.json arbiter-3.err; do absent "$s/$stale"; done
excludes 'old round three audit marker' "$r/audit.prompt"
contains 'speculative switch' "$r/audit.prompt"
contains 'google/gemini-4-hydrogen' "$r/audit.model"
line_is 1 'AUDIT  required (rounds=2 arbiter=accept_as_is)' "$s/summary.txt"
# An explicit review wins even if a higher-numbered file exists; legacy usage still works.
printf '{"premise":"stale review probe"}\n' > "$s/review-9.json"
"$root/bin/audit" --review "$s/review-2.json" --arbiter "$s/arbiter-2.json" simplify >/dev/null
excludes 'stale review probe' "$r/audit.prompt"
"$root/bin/audit" --light simplify >/dev/null
contains 'stale review probe' "$r/audit.prompt"
# Recovery also works if PID publication never completed. An advisory L2
# command failure must be visible even if there was no stdout to parse.
make_task unpublished pass
mkdir -p "$root/logs/unpublished/run.lock"
chmod -x "$root/bin/audit"
TOP_AUDIT=1 run_expect 0 unpublished
chmod +x "$root/bin/audit"
contains 'L2_AUDIT  verdict=error' "$root/logs/unpublished/summary.txt"
line_is 1 'READY  (merge: bin/merge unpublished)' "$root/logs/unpublished/summary.txt"
make_task parallel-a parallel
make_task parallel-b parallel
"$root/bin/batch" --jobs 2 parallel-a parallel-b > "$sandbox/batch.out" || { cat "$sandbox/batch.out" >&2; fail 'batch failed'; }
for id in parallel-a parallel-b; do
  line_is 1 "READY  (merge: bin/merge $id)" "$root/logs/$id/summary.txt"
  contains "[$id] finished (rc=0): READY" "$sandbox/batch.out"
  absent "$root/logs/$id/run.lock"
done
# Merge refuses a branch that moved after READY approval, then succeeds on approved HEAD.
approved="$(cat "$root/logs/parallel-a/approved_head")"
echo extra >> "$root/worktrees/parallel-a/result.txt"
git -C "$root/worktrees/parallel-a" commit -qam "unapproved post-ready commit"
if "$root/bin/merge" parallel-a >/dev/null 2>&1; then fail "merge allowed unapproved HEAD move"; fi
git -C "$root/worktrees/parallel-a" reset -q --hard "$approved"
"$root/bin/merge" parallel-a >/dev/null

# 9. Concurrency slot leasing, Sol->Neon(xhigh) overflow, transport failover, and SIGTERM cleanup.
sched_dir="$sandbox/sched-test"
mkdir -p "$sched_dir"
make_task sched-a sched-overflow
make_task sched-b sched-overflow
FORGE_SCHED_DIR="$sched_dir" SOL_MAX_PROCS=1 FORGE_EXEC_SCHED=auto \
  "$root/bin/batch" --jobs 2 sched-a sched-b > "$sandbox/sched-batch.out" \
  || { cat "$sandbox/sched-batch.out" >&2; fail 'sched-overflow batch failed'; }
ma="$(cat "$root/records/sched-a/exec-1.model")"
mb="$(cat "$root/records/sched-b/exec-1.model")"
ta="$(cat "$root/records/sched-a/exec-1.thinking")"
tb="$(cat "$root/records/sched-b/exec-1.thinking")"
[ "$ta" = "xhigh" ] && [ "$tb" = "xhigh" ] || fail "expected xhigh thinking on both executors, got $ta and $tb"
if ! { [ "$ma" = "openai/gpt-6.2-sol" ] && [ "$mb" = "google/gemini-4-neon" ]; } \
  && ! { [ "$ma" = "google/gemini-4-neon" ] && [ "$mb" = "openai/gpt-6.2-sol" ]; }; then
  fail "expected exactly one sol and one neon under SOL_MAX_PROCS=1, got $ma and $mb"
fi
sol_task="sched-a"; neon_task="sched-b"
[ "$mb" = "openai/gpt-6.2-sol" ] && { sol_task="sched-b"; neon_task="sched-a"; }
contains 'sched=sol(slot=1/1)' "$root/logs/$sol_task/summary.txt"
contains 'sched=overflow(sol_busy=1/1)' "$root/logs/$neon_task/summary.txt"
[ "$(cat "$root/records/$sol_task/picked-style")" = "google/gemini-4-neon" ] || fail "expected style reviewer overflow while sol slot occupied"
FORGE_SCHED_DIR="$sched_dir" SOL_MAX_PROCS=1 "$root/bin/sched" status --json > "$sandbox/sched-after.json"
json '.occupied_exec_slots == 0' "$sandbox/sched-after.json"

# Upstream transport failure on round 1 switches immediately on round 2 with full spec even under FRESH_ROUNDS=0.
make_task tfail transport-failover
FORGE_SCHED_DIR="$sched_dir" SOL_MAX_PROCS=2 FRESH_ROUNDS=0 run_expect 0 tfail
contains 'openai/gpt-6.2-sol' "$root/records/tfail/exec-1.model"
contains 'google/gemini-4-neon' "$root/records/tfail/exec-2.model"
contains 'xhigh' "$root/records/tfail/exec-2.thinking"
contains 'public forge task specification' "$root/records/tfail/exec-2.prompt"

# Neon transport failure when Sol slots are 0 falls over to Astra rather than bouncing back to Neon.
make_task nfail neon-transport-failover
FORGE_SCHED_DIR="$sched_dir" SOL_MAX_PROCS=0 run_expect 0 nfail
contains 'google/gemini-4-neon' "$root/records/nfail/exec-1.model"
contains 'openai/gpt-6.2-astra' "$root/records/nfail/exec-2.model"

# SIGTERM sent to bin/run reaps sched + pi, clears run.lock, and releases slot lease.
make_task sigtask sigterm
FORGE_SCHED_DIR="$sched_dir" SOL_MAX_PROCS=1 "$root/bin/run" sigtask > "$root/records/sigtask/run.out" 2> "$root/records/sigtask/run.err" &
sig_run_pid=$!
for _ in $(seq 1 80); do [ -f "$root/records/sigtask/running" ] && break; sleep 0.05; done
[ -f "$root/records/sigtask/running" ] || fail 'sigtask never reached running state'
FORGE_SCHED_DIR="$sched_dir" SOL_MAX_PROCS=1 "$root/bin/sched" status --json > "$sandbox/sched-live.json"
json '.occupied_exec_slots == 1' "$sandbox/sched-live.json"
kill -TERM "$sig_run_pid"
wait "$sig_run_pid" 2>/dev/null || true
absent "$root/logs/sigtask/run.lock"
FORGE_SCHED_DIR="$sched_dir" SOL_MAX_PROCS=1 "$root/bin/sched" status --json > "$sandbox/sched-killed.json"
json '.occupied_exec_slots == 0' "$sandbox/sched-killed.json"

echo 'arbiter pipeline: all 9 offline scenarios passed'
