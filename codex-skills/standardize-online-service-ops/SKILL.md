---
name: standardize-online-service-ops
description: Standardize, audit, and evolve production online services with a stable operations framework. Use when Codex is asked to maintain, harden, release, observe, version, deploy, roll back, or create runbooks for API services, model APIs, background workers, business services, Docker/Kubernetes deployments, CI pipelines, config/secrets handling, metrics, logs, tracing, incidents, or any live service change where compatibility and operational stability matter.
---

# Standardize Online Service Ops

## Purpose

Use this skill to turn online service work into a repeatable operations contract: preserve public behavior, separate config concerns, make lifecycle decisions observable, and keep delivery boring.

Treat model APIs and ordinary business services as the same maintenance problem unless the code proves otherwise. Do not impose a framework template. Inspect the project first, then apply the smallest operations rule that fits the existing architecture.

## Core Workflow

1. Map the real service boundary before proposing or editing:
   - Entrypoints, public routes, worker jobs, CLIs, scheduled tasks, and external integrations.
   - Config sources, secret sources, runtime arguments, deployment manifests, CI, Dockerfiles, and release scripts.
   - Metrics, logs, traces, health checks, dashboards, alerts, and existing runbooks.
   - Versioning, compatibility guarantees, rollback path, and deprecation state.
2. Classify the user request:
   - Audit existing operational readiness.
   - Add or change service behavior.
   - Add a new model or API/business version.
   - Change config, secrets, deployment, or release flow.
   - Debug a production issue or prepare rollback.
   - Create or update a runbook/checklist.
3. Choose the narrowest maintenance plane:
   - Interface contract.
   - Config and secret separation.
   - Version lifecycle.
   - Observability.
   - Delivery and release.
   - Incident, rollback, and deprecation.
4. Make the smallest coherent change that fits local conventions. Reuse existing tooling and naming. Do not introduce new platforms, libraries, abstractions, or file layers unless the current repo already has that pattern or the user asks.
5. Validate with existing checks that match the touched surface. Run tests, linters, build, smoke checks, or manifest validation when available. Add tests only when the user explicitly asks for tests or the repository's current task already includes test work.
6. Report the operational effect, not just the code diff: what is safer now, what remains manual, and what signal proves it in production.

## Maintenance Planes

### Interface Contract

Protect existing consumers. Do not rename, move, or silently change existing public routes, request shapes, response shapes, event payloads, job names, queue names, or CLI flags when adding new behavior.

When behavior must change, prefer a new explicit version, endpoint, command, job, or event type. Keep the old surface intact until traffic and dependency evidence show it can be removed.

### Config And Secrets

Separate three concerns:

- Secrets: credentials, tokens, private keys, database passwords. Read from environment, secret manager, vault, or platform secret objects. Never put them in committed config.
- App config: model IDs, thresholds, feature values, limits, timeouts, and business knobs. Keep them reviewable and overrideable by deployment environment.
- Runtime args: host, port, enabled versions, worker count, dry-run flags, one-shot commands. Keep them at process/deployment entrypoints.

If these concerns are mixed, fix only the part needed for the current change and call out the remaining risk.

### Version Lifecycle

Add versions by adding physically isolated implementation paths that match the repo's structure. Avoid routing all versions through one mutable switch that makes compatibility hard to reason about.

When deprecating a version, require evidence before removal:

- Metrics show zero or accepted traffic for a defined window.
- Logs or tracing identify no important consumers.
- Dashboards and alerts can distinguish old and new behavior.
- Rollback keeps the removed version recoverable until the release is proven.

### Observability

Every live service should expose enough signal to answer:

- Is it up?
- Is it accepting work?
- How fast is it?
- How often does it fail?
- Which version, route, job, tenant, model, or dependency is responsible?
- Can we tell whether an old version is safe to remove?

Prefer instrumentation that is automatic at the boundary and hard to forget at call sites. Keep metric names stable and low-cardinality. Use labels only when the repo already controls their cardinality.

### Delivery And Release

Keep delivery boring:

- No direct commits to protected production branches when the repo uses PRs.
- Local checks, pre-commit checks, and CI should run the same meaningful commands where practical.
- Container builds should install dependencies in cache-friendly layers and run at least one build-time import or startup sanity check.
- Release tags, images, and deployment artifacts should be created by one clear pipeline.
- Humans should choose intent; automation should perform repetitive release mechanics.

### Incident And Rollback

For incidents, stabilize before redesigning:

1. Identify blast radius and current user impact.
2. Find the last known good version, config, image, or deployment.
3. Prefer rollback, disablement, traffic shift, or config revert before code surgery.
4. Preserve evidence: logs, metrics windows, failing inputs, release IDs, and timestamps.
5. After recovery, make the smallest prevention change that would have caught or contained the failure.

## Reference

For detailed audit prompts, done criteria, and output shapes, read `references/ops-contract.md` when the task is an audit, new service setup, release process, deprecation, or incident workflow.
