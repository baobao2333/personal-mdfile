# forge

User + AGY own top-level planning, framing, spec/check authoring, and final acceptance. Coding execution prioritizes `openai/gpt-6.2-sol` (`xhigh` + `ultrafast`) up to `SOL_MAX_PROCS` (default `2`) concurrent slots via `bin/sched` and automatically overflows excess concurrent tasks to `google/gemini-4-neon` (`xhigh`); GPT-6.2 (`astra`/`sol`) handles L1 in-loop review, Gemini 4 Carbon (`pragmatic-arbiter`) adjudicates edge cases, and Gemini 4 (`neon`/`hydrogen`) handles optional L2 architectural audits.

- `bin/run <id>`           Schedule executor (`openai/gpt-6.2-sol` primary -> `google/gemini-4-neon` `xhigh` overflow via `bin/sched`; fallback `openai/gpt-6.2-astra` only after L0 failures) -> `bin/gate` -> L1 `bin/review` -> Carbon (`ARBITER_MIN_ROUND=1`) -> optional L2 `bin/audit`
- `bin/sched status [--json]` Inspect live `openai/gpt-6.2-sol` execution slot leases (`occupied_exec_slots / SOL_MAX_PROCS`) without lock contention
- `bin/batch [--jobs N]`   Run multiple independent tasks in parallel with bounded concurrency
- `bin/review <id>`        L1 orthogonal cross-model in-loop review (`PI_REVIEW_LOGIC_MODEL=openai/gpt-6.2-astra` + `PI_REVIEW_STYLE_MODEL=openai/gpt-6.2-sol` with automatic `gemini-4-neon` overflow when `sol` slots are full, `PI_REVIEW_THINKING=high`) with deterministic `file:line` grounding
- `bin/arbiter <id> <round>` Independent `pragmatic-arbiter` (`AGY_ARBITER_MODEL=gemini-4-carbon-medium`) on a read-only detached snapshot and public task context. From Round 1 onward (`ARBITER_MIN_ROUND=1`), when `bin/gate` passes and L1 fails, Carbon directly asserts which hypothetical edge cases need no fix (`accept_as_is` -> `READY`), narrows the next retry to real business defects (`narrow_fix`/`simplify_and_fix`), praises strong work (`praise_zh`), or escalates. Set `ARBITER_ENABLED=0` to disable.
- `bin/mr-review <repo> <base> <head> [--peer <repo>:<ref>]` Standalone pre-MR/pre-push diff audit by `openai/gpt-6.2-astra` (`high` thinking, read-only repo tools)
- `bin/audit [--light] [--review <path>] [--arbiter <path>] <id>` L2 top-level cross-model architectural & intent audit (`PI_AUDIT_MODEL=google/gemini-4-neon`, `--light` uses `google/gemini-4-hydrogen`)
- `tasks/<id>/spec.md`     AGY: goal, verified premise, negative constraints, acceptance criteria
- `tasks/<id>/check.sh`    AGY: public acceptance check (or `smoke.sh` paired with hidden `accept/<id>/check.sh`)
- `accept/<id>/check.sh`   AGY (optional): hidden holdout acceptance check run only by `bin/gate`
- `tasks/<id>/status.json` Executor: `{"state": "done|blocked", "note": "..."}` (valid block: `前提:` / `环境:` / `权限:` only)
- `logs/<id>/`             round logs, gate/review/arbiter/audit outputs, summary (`summary.txt`)
- `worktrees/<id>`         isolated git worktree on branch `task/<id>`

Run: `bin/run <id>`   Batch: `bin/batch <id1> <id2>`   Top Audit: `bin/audit <id>`   Check: `bin/status [id]`   Merge: `bin/merge <id>`
