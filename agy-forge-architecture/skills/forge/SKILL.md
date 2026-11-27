---
name: forge
description: >-
  Dispatch coding work to the local Pi agent (default openai/gpt-6.2-sol at
  xhigh thinking + ultrafast) via ~/forge and accept it cheaply. Use by default
  for any planned/non-trivial coding task (AGY owns framing/design/spec, GPT
  writes code), or when the user says /forge, "交给 pi", "派给 pi", "用 forge 做".
  Skip for small adjustments that do not need a plan.
---

# forge: AGY owns intent & acceptance, Cross-Model Multi-Agent Pi executes

Workspace: `~/forge` (git repo, `main` branch; external repos supported via `tasks/<id>/repo` and `tasks/<id>/base_ref`).
Always invoke scripts with `bash`, never `source bin/lib.sh` in `zsh`.
Default Pi model is `google/gemini-4-neon` (`PI_MODEL` in `~/forge/bin/lib.sh` and `~/.pi/agent/settings.json`), with a clear cross-model division of labor:
- **Top-level Plan, Framing & Spec**: **owned exclusively by AGY** (never delegated to Pi).
- **Coding Execution & Concurrency Scheduler** (`bin/sched` + `bin/run`: primary `PI_EXEC_MODEL=openai/gpt-6.2-sol` at `PI_EXEC_THINKING=xhigh` + `ultrafast` tier in `~/.pi/agent/gpt-fast-mode.json`, overflow `PI_EXEC_OVERFLOW_MODEL=google/gemini-4-neon` at `PI_EXEC_OVERFLOW_THINKING=xhigh`, `SOL_MAX_PROCS=2`, `FORGE_EXEC_SCHED=auto`, L0 fallback `PI_EXEC_FALLBACK_MODEL=openai/gpt-6.2-astra`): surgical localized coding & test loop in isolated git worktrees. Non-blocking kernel `flock` slots prioritize `gpt-6.2-sol` up to `SOL_MAX_PROCS` concurrent executors across all terminals/sessions and immediately spill excess concurrent executions over to `google/gemini-4-neon` + `xhigh` without queueing; unrecovered Round-1 upstream transport/rate errors (`429`/`503`/`ETIMEDOUT`/`UND_ERR_SOCKET`) with `0` commits also fast-failover on the next round; switches to L0 fallback `astra` **only** when L0 `gate` fails/stagnates (never when `gate` is green and only L1 review failed).
- **L1 In-Loop Process Review** (`bin/review`, `REVIEW_MODE=multi`): parallel orthogonal cross-model reviewers — Logic/Side-Effects/Caller-Audit (`PI_REVIEW_LOGIC_MODEL=openai/gpt-6.2-astra`, `PI_REVIEW_THINKING=high`, cross-model vs `sol` executor) + Security/Simplicity/Anti-Over-Engineering (`PI_REVIEW_STYLE_MODEL=openai/gpt-6.2-sol`, automatically overflowing to `google/gemini-4-neon` via `bin/sched pick-style` when `sol` coding slots are full) with deterministic `file:line` grounding, stable issue IDs (`I1`, `I2`, ...), and production trust-boundary severity calibration (multi-fault hypothetical coincidences downgraded to non-blocking `low`).
- **Pragmatic Business Arbiter** (`bin/arbiter <id> <round>`, independent AGY agent `pragmatic-arbiter` on `AGY_ARBITER_MODEL=gemini-4-carbon-medium`): automatically intervenes (`round >= ARBITER_MIN_ROUND`, default `1`, `ARBITER_TIMEOUT=420` with outer alarm grace) whenever `gate` is green (`rc=0`) and L1 `review` fails. Holds **direct authority to assert which exceptions/edge-case findings are unnecessary to fix (`rebut`)** while emitting `praise_zh` recognizing strong work by both executor and reviewers:
  - In Round 1, requires concrete `file:line` disproof before rebutting money/ledger/state/reachable-caller defects while immediately pruning multi-fault speculative noise (`narrow_fix` or `accept_as_is`).
  - `accept_as_is`: all remaining `high`/`med` L1 findings are asserted unnecessary to fix -> immediately marks `READY` without burning another round or inflating diff churn.
  - `narrow_fix` / `simplify_and_fix`: keeps only real business/caller/ledger defects (`must_fix`), strikes dismissed edge cases (`drop_issues` — executor is forbidden from adding defensive code for them), and orders stripping of any defensive state bloat (`simplify_directives`).
  - `escalate`: flags genuine `spec.md` premise conflicts or product trade-offs back to AGY.
- **Standalone Pre-MR Diff Audit** (`bin/mr-review <repo> <base> <head> [--peer <repo>:<ref>] [--spec <spec.md>] [--arbiter <arbiter.json>]`): SHA-deduplicated `openai/gpt-6.2-astra` (`high` thinking, `--tools read,grep,find,ls`) audit. Skip re-running standalone `mr-review` on an identical single-repo `(repo, base_sha, head_sha)` already approved by `forge` (`gate` + `L1`/`arbiter`) with no post-forge manual/rebase commits and no unverified `--peer` contract; run once at integration/rebase/direct-edit/`--peer` boundaries with `--spec` and `--arbiter` attached.
- **L2 Top-Level Architectural & Intent Audit** (`bin/audit`): **Gemini API only at the top level** — `PI_AUDIT_MODEL=google/gemini-4-neon` (or `--light` / `PI_LIGHT_MODEL=google/gemini-4-hydrogen`), `TOP_AUDIT=0` by default (invoke manually by AGY or set `TOP_AUDIT=1` for large architectural merges).

**Division of labor**: The user never talks to GPT directly. AGY owns 100% of intent reconstruction, framing, tight specs, hidden/public checks, and final diff acceptance in plain Chinese. Pi is strictly a non-interactive code executor and L1 static code reviewer.

## 0. Frame (before any task exists)
The user names a method ("写个鼠标脚本把 20 个 Excel 拼起来"); what they want is the outcome ("每周有张总表"). Pi will faithfully build whatever the spec says—or spec-game a weak check—so this is where wrong premises and ambiguous intent must be resolved before any code is written. Spend a few minutes in the real code/data first using `run_command` (`rg`/`grep`) and targeted `read_file` calls:
- **Source**: where does the input really come from? If it is derived from something reachable (DB, API, an existing field), go to the source instead of automating the copy.
- **Already there**: grep for what the fix would produce. Is it already computed, passed or stored?
- **Premise**: list each factual claim in the request and check the cheap ones in code. Mark the rest unverified.
- **Platform first**: what the CDN/proxy/framework already provides (`CF-Connecting-IP`, `ProxyFix`, DB views) beats hand-rolled logic.
- **Delete before automate**: can the step be removed rather than done faster?
- **Task suitability**: never dispatch open-ended exploration, UX/aesthetic judgment, or vague intent tasks to Pi. Resolve architecture, state transitions, and exact UI/output contracts in AGY first; give Pi only closed, deterministically verifiable coding slices.

If this finds a shorter path or a false premise, stop and tell the user in a few lines: what they asked, what you found (`file:line`), the alternative, the trade-off. Wait for their choice before writing tasks. If nothing turns up, say so in one line and go on.

## 1. Plan (spend effort here)
Split the goal into small, independently verifiable tasks. **Write `spec.md` and all instructions/feedback sent to Pi in English** (keep user-facing replies in Chinese). For each task create `~/forge/tasks/<NNN-slug>/` using `write_file`:
- `spec.md`:
  - Starts with `## 背景与前提` (the real goal, facts verified in step 0 with `file:line`, alternatives rejected and why).
  - Goal, explicit constraints, and acceptance criteria in plain, concrete terms.
  - **Pre-decided defaults**: explicitly state that internal naming, helper structure, and unspecified edge defaults must follow repo conventions (Pi is forbidden from blocking on internal implementation details; only `前提:` with `file:line` or `环境:`/`权限:` may block).
  - **Negative constraints**: explicitly forbid swallowing errors (`try/except`/`catch`), unrequested fallback branches, weakening existing tests/fixtures, or trading off baseline invariants (latency/behavior) to game a check.
- **Checks** (at least one of `check.sh` or hidden `accept/<id>/check.sh`):
  - `tasks/<id>/check.sh`: executable public acceptance script run with `bash` from the repo root (`forge` automatically symlinks gitignored `.venv`, `node_modules`, `tools/node_modules`, and `local.properties` from `$REPO`). Cover edge cases, invalid input, multiple values. When wiring existing repo check scripts or custom Gradle/build flags into `check.sh`, verify they pass on `base_ref` first so pre-existing broken checks or missing release keys do not block Round 1.
  - For tasks at risk of spec gaming (parsers, metric thresholds, perf/size targets, UI parity): put a minimal `tasks/<id>/smoke.sh` for Pi's self-test and put the strict holdout verification in `~/forge/accept/<id>/check.sh` (run only by `bin/gate`; **never** mention `accept/<id>/` in `spec.md` or prompts, and make failure stdout concise without dumping test fixtures).
- `scope` (strongly recommended): one glob per line of files Pi may change, preventing edits to shared test harnesses or unrelated files.
- `repo` / `base_ref` (optional): path to an external git repo and starting ref when work targets another repo instead of `~/forge`.

Ask the user first if a task needs dependency installs, network services, system config, or touches secrets/auth/data deletion.
If work targets another repo instead of `forge` itself, wire `tasks/<id>/repo` (and `base_ref` if not `HEAD`) or put the code under `~/forge`, confirming with the user if unclear.

## 2. Dispatch
Before running Pi, verify `~/.pi/agent/gpt-fast-mode.json` has `"ultrafast"` for `"gpt-6.2-sol"` (and `"fast"` for `"gpt-6.2-astra"` — note legacy `{"enabled": true}` only applies to `gpt-6-astra`), and match model/thinking level to task complexity (default execution: `openai/gpt-6.2-sol` + `PI_EXEC_THINKING=xhigh`).
Run independent tasks in parallel using multiple `run_command` calls in the same turn.
Because `pi` calls external model APIs (`api.openai.com`), set **`BypassSandbox: true`** and **`WaitMsBeforeAsync: 500`** so each task runs in the background:

```bash
bash ~/forge/bin/run <id>
# Or for multiple independent tasks in parallel (bounded concurrency):
bash ~/forge/bin/batch --jobs 3 <id1> <id2> <id3>
# Or manually run post-Round-2 Carbon pragmatic business arbiter on a review round:
bash ~/forge/bin/arbiter <id> <round>
# Or manually trigger L2 top-level Gemini architectural/intent audit:
bash ~/forge/bin/audit [--light] <id>
```

Do not poll with `manage_task` or shell `sleep`; end your turn and wait for AGY's reactive completion notification.
Env knobs (updated defaults): `MAX_ROUNDS` (default `3`), `EXEC_TIMEOUT` seconds (default `1800`), `CHECK_TIMEOUT` seconds (default `600`), `FRESH_ROUNDS` (default `1`, fresh Pi session per round to prevent context rot), `PI_MODEL` (default `google/gemini-4-neon`), `PI_LIGHT_MODEL` (default `google/gemini-4-hydrogen`), `PI_EXEC_MODEL` (default `openai/gpt-6.2-sol`), `PI_EXEC_THINKING` (default `xhigh`), `PI_EXEC_FALLBACK_MODEL` (default `openai/gpt-6.2-astra`, L0 gate failure fallback only), `PI_REVIEW_LOGIC_MODEL` (default `openai/gpt-6.2-astra`), `PI_REVIEW_STYLE_MODEL` (default `openai/gpt-6.2-sol`), `PI_REVIEW_THINKING` (default `high`), `AGY_ARBITER_AGENT` (default `pragmatic-arbiter`), `AGY_ARBITER_MODEL` (default `gemini-4-carbon-medium`), `ARBITER_ENABLED` (default `1`), `ARBITER_MIN_ROUND` (default `2`), `ARBITER_TIMEOUT` (default `300`), `PI_AUDIT_MODEL` (default `google/gemini-4-neon`), `REVIEW_MODE` (`multi` or `single`, default `multi`), `TOP_AUDIT` (default `1` when `AUDIT` triggers; set `0` to skip), `TOP_AUDIT_LIGHT` (set `1` to use `google/gemini-4-hydrogen` for L2 audit).

## 3. Accept (AGY translates & guards intent)
Read `~/forge/logs/<id>/summary.txt` via `read_file`:
- **Never forward raw GPT prose/jargon to the user.** AGY inspects and translates outcomes into clear Chinese aligned with the user's original intent.
- `READY` **without** `AUDIT` (1 round, `churn <= 100`, `<= 200KB` diff, 0 gate warnings, 0 med/high review issues) and not high-risk: run `bash ~/forge/bin/merge <id>` (note: external-repo tasks keep branch `task/<id>` in that repo without auto-merging).
- `READY` + `AUDIT` (triggered deterministically by `rounds > 1`, `churn > 100`, `diff_bytes > 200000`, gate `WARN`, or review `med/high` issues), or any high-risk change: **mandatory AGY diff review** (`git -C ~/forge diff $(cat ~/forge/logs/<id>/base) task/<id>`, or in the external repo) and spot-check behavior against the user's real intent before merging.
  - **Anti-over-defensive audit**: check for redundant `try/except`/`catch` swallowing errors, duplicate checks on internal invariants, dead fallback branches, or unnecessary wrappers. Strip them or reject to Pi with exact `file:line` references before merging.
- `PREMISE` line (reviewer thinks the task itself is the wrong approach): do not merge. Check its `file:line` evidence yourself with `read_file`; if it holds, bring it to the user with your recommendation.
- `ESCALATE` (including `no-progress` / `thrashing` early aborts): read `~/forge/logs/<id>/round-*.txt` and the last `review-*.json`; fix `spec.md`/checks, finish the remaining surgical fix directly in AGY, or switch `PI_MODEL=openai/gpt-6.2-sol` rather than blindly retrying the same failing prompt.
- `BLOCKED`: `bin/gate` only permits `前提:` (with `file:line`), `环境:`, or `权限:` blocks (other excuses are rejected automatically). Verify Pi's evidence first and bring a crisp Chinese decision summary to the user.

Never read `~/forge/logs/<id>/*.jsonl` unless debugging the pipeline itself. Run `bash ~/forge/bin/status` to list all tasks.

## 4. Report
Tell the user concisely in Chinese with clickable `file://` links: tasks merged (or branched in external repo), rounds used, what actually changed (verified from diff, not Pi's claim), anything escalated or blocked, and what AGY spot-checked.
