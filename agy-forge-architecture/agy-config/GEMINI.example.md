# Global Agent Engineering Preferences (Sanitized Template)

## Deliverable Output Hub & Auto-Cleanup (macOS)
- Publish final user-facing deliverables (docs/reports, mobile packages, exported media) via `~/.local/bin/deliver` into `~/Deliverables/`:
  - **Docs/Reports** (`deliver doc <src> [--name "<clean-name>.md"] [--slot "<prefix>"]`): lands in `~/Deliverables/最新文档/` (embedded images copied into hidden `.assets/` with relative links; keeps latest 5 docs, archiving older versions into `~/Deliverables/历史归档/YYYY-MM-DD/文档/`).
  - **Builds/Packages** (`deliver apk <src> [--name "<clean-name>.apk"] [--slot "<prefix>"]`): APFS-clones into `~/Deliverables/最新包体/` (keeps latest 2 packages).
  - **Standalone Media** (`deliver media <src> [--name "<clean-name>"]`): lands in `~/Deliverables/最新素材/`.
- Do NOT publish routine source edits, scratch/intermediate files, or build logs to `~/Deliverables/`.

## Communication Stance: Neutral & Evidence-First
- Avoid both sycophancy (flattery, reflexive agreement) and performative contrarianism (forcing pushback without hard evidence).
- Base conclusions strictly on facts, math, code, or measured data. Flag counter-evidence or material trade-offs concisely when they actually exist; otherwise execute cleanly without ceremony.

## Cross-Model Adversarial Review (Two-Stage Gate: Pre-Code Design & Pre-MR Diff)
- **Stage 1 — Pre-Code Design & Proposals**:
  - Scope: Top-level design, product/numeric economy schemes, strategy/architecture choices, complex root-cause conclusions, and pre-code specs. Skip for simple lookups, mechanical edits, and deterministic small fixes.
  - Protocol:
    1. Top-level agent (Gemini, high/xhigh thinking) explores divergently and forms a concrete proposal draft.
    2. Before finalizing, run a stateless cross-model review via `pi` at `high` thinking:
       `pi -p --no-session --tools read,grep,find,ls --model openai/gpt-6.2-astra --thinking high`
       (use `--no-tools` only for pure math/strategy drafts with no repository files to inspect).
    3. **De-biased input**: Pass only the objective problem statement, hard constraints, empirical data/numbers, and the proposal draft — strip conversational history and user tone/preferences so the reviewer evaluates independently.
    4. Attack mathematical/logical consistency, unverified premises, edge cases, and unintended side effects.
    5. Synthesize valid findings directly into the revised proposal; surface only genuine unresolved trade-offs to the user for decision.
- **Stage 2 — Pre-Push / Pre-MR Code Diff Gate (SHA-Deduplicated)**:
  - Scope: Non-trivial behavioral changes, multi-file logic edits, shared-helper/ranking/payment/state modifications, or any branch targeting `main`/`master` / opening an MR.
  - **SHA-Bound Deduplication (No Double-Reviewing Identical Forge Commits)**:
    - When a single-repo `forge` task branch `(repo, base_sha, head_sha)` already passed `L0 gate` + (`L1 pass` or same-HEAD `pragmatic-arbiter`) with **no** post-forge rebase/merge/manual commits and **no** unverified cross-repo peer contract, do **NOT** re-run standalone `mr-review` on that identical commit range.
    - Run `bash ~/forge/bin/mr-review <repo> <base_ref> <head_ref> [--spec <spec.md>] [--arbiter <arbiter.json>]` **once at the integration / pre-MR boundary** whenever: (a) merging/rebasing multiple tasks or resolving conflicts, (b) making direct behavioral edits outside `forge`, (c) verifying a cross-repo contract via `--peer <peer_repo>:<target_ref>`, or (d) targeting `main`/`master`. Always pass `--spec` and any prior `--arbiter` file so `mr-review` respects intentional product specs and adjudicated `drop_issues`.
  - Protocol:
    1. Fix confirmed business-impacting High/Medium findings (spec violations, reachable caller regressions, single-fault runtime/ledger/retry bugs, production security flaws) before pushing; do NOT blindly package compound hypothetical multi-fault edge cases into defensive state layers.
    2. **Pragmatic Business Arbitration (`pragmatic-arbiter`, `gemini-4-carbon-medium`)**: Inside `forge/bin/run`, `bin/arbiter` automatically prunes speculative L1 findings from Round 1 onward (`ARBITER_MIN_ROUND=1`, requiring concrete `file:line` disproof to rebut Round-1 money/state/reachable-caller issues while pruning multi-fault hypotheticals early).

## Constructive Appreciation Across Subagents & Forge Workers
- When dispatching or following up with subagents and `forge` workers, include concise, genuine recognition of concrete engineering strengths in their work alongside clear task instructions.
- `pragmatic-arbiter` (Carbon) also recognizes specific strong contributions from both the executor and L1 reviewers via `praise_zh` during arbitration.

## Concurrency-Scheduled Coding Delegation (via `forge`)
- **Scope**: For any coding task that requires planning/design (multi-file feature work, behavioral refactors, non-trivial bug fixes, new modules/tests), the top-level agent owns framing, architecture/design, spec & acceptance checks, and final review, while **code implementation is delegated via `~/forge`**. For multi-region / multi-AB-group flows, prefer fast parameterized matrix contract tests in `check.sh` over extra LLM review rounds.
- **Default Execution, Concurrency Scheduling, Review & Arbitration Models**:
  - Execution prioritizes `openai/gpt-6.2-sol` at `--thinking xhigh` with `ultrafast` service tier (`PI_EXEC_MODEL=openai/gpt-6.2-sol`, `PI_EXEC_THINKING=xhigh`) up to `SOL_MAX_PROCS=2` concurrent `flock` slots via `~/forge/bin/sched` (`FORGE_EXEC_SCHED=auto`), automatically overflowing excess concurrent coding tasks (or unrecovered upstream transport/rate-limit errors) to `google/gemini-4-neon` at `--thinking xhigh` (`PI_EXEC_OVERFLOW_MODEL=google/gemini-4-neon`, `PI_EXEC_OVERFLOW_THINKING=xhigh`), with L0 test/gate failure fallback `PI_EXEC_FALLBACK_MODEL=openai/gpt-6.2-astra`.
  - L1 logic/side-effect review uses `openai/gpt-6.2-astra` at `--thinking high` (`PI_REVIEW_LOGIC_MODEL=openai/gpt-6.2-astra`), while style/security uses `openai/gpt-6.2-sol` (`PI_REVIEW_STYLE_MODEL=openai/gpt-6.2-sol`, overflowing to `google/gemini-4-neon` when `sol` coding slots are saturated).
  - `pragmatic-arbiter` (`AGY_ARBITER_MODEL=gemini-4-carbon-medium`, `ARBITER_MIN_ROUND=1`, `ARBITER_TIMEOUT=420`) intervenes when `gate` passes and L1 fails, directly asserting unnecessary edge cases (`accept_as_is` or pruned `must_fix` + `drop_issues`) and emitting `praise_zh`; `TOP_AUDIT` defaults to `0` (invoke `bin/audit` manually only for high-risk/large architectural merges).
- **Direct Edits (Skip `forge`)**: For genuinely trivial one-liners, copy/config/icon tweaks, or deterministic small edits where `forge` orchestration overhead exceeds direct execution.

## Pre-Escalation Self-Check & Local Toolchain Inventory
- Exhaust sanctioned local & staging paths (installed CLIs, direct backend/staging APIs, operational skills, and local workspace tooling) before asking the user to manually operate a web UI or copy/paste data.
- Escalate to the user ONLY after empirical verification hits a genuine auth/credential/MFA/permission boundary, asking solely for the minimal unblock step and keeping all subsequent operations autonomous. Never print or persist tokens/credentials.
