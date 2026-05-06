# Operations Contract

Use this reference when the task needs a concrete checklist, review output, or implementation plan for production operations.

## Service Map

Build a short evidence-backed map before changing operations:

- Runtime: language, framework, process manager, worker model, ports, CLIs, cron or queue entrypoints.
- Public contract: routes, events, jobs, schemas, version prefixes, clients, backward compatibility notes.
- State: databases, queues, caches, object stores, model files, migrations, external APIs.
- Config: committed config, environment variables, secret manager, runtime flags, deployment values.
- Delivery: package manager, build command, test command, Dockerfile, CI workflows, image registry, release tags.
- Operations: health endpoint, readiness/liveness, metrics, logs, traces, alerts, dashboards, runbooks.

Stop and ask only when a production-changing action is impossible to infer safely, such as live deploy credentials, target cluster, or whether downtime is acceptable.

## Audit Output Shape

When auditing, use this compact shape:

1. Current state: list confirmed operational facts with file paths or commands.
2. Risks: rank issues by production impact and likelihood.
3. Minimal fixes: propose the smallest repo-local changes that reduce the top risks.
4. Validation: name the exact checks to run and what result would prove success.
5. Open decisions: only include decisions that require owner input.

## Done Criteria By Plane

### Interface Contract

Done when existing consumers keep working and new behavior has an explicit boundary.

Check:

- Existing route, schema, event, job, or CLI names are unchanged unless the user asked for a breaking change.
- New behavior has a version, prefix, command, event type, or compatibility path.
- Rollback can return traffic to the previous behavior.
- Validation covers at least the public boundary touched by the change when tests are in scope.

### Config And Secrets

Done when reviewers can tell what is secret, what is app config, and what is runtime control.

Check:

- Secrets are not committed and are loaded only from trusted secret channels.
- App config is reviewable, environment-specific, and overrideable by deployment.
- Runtime args live at process start, CLI, or deployment layers.
- Missing config fails early enough to avoid partial production startup.

### Version Lifecycle

Done when add, enable, disable, and remove are separate decisions.

Check:

- Multiple versions can coexist if compatibility requires it.
- Enablement is controlled by deployment or runtime config, not code edits at release time.
- Metrics/logs/traces can distinguish versions.
- Deprecation includes a warning signal, zero-traffic evidence, and removal plan.

### Observability

Done when an operator can answer "what is broken, where, and since when" without redeploying.

Check:

- Health/readiness exists and reflects real dependencies when the platform needs it.
- Request/job counts, latency, failures, and in-flight work are visible.
- Version, route/job, dependency, and error class are distinguishable without high-cardinality labels.
- Logs include correlation or request IDs when the stack supports them.
- Dashboards or queries exist for rollout and deprecation decisions.

### Delivery And Release

Done when the same artifact can be built, checked, released, and rolled back predictably.

Check:

- CI runs the repo's existing lint/type/build/test commands for the changed surface.
- Docker or package build uses lockfiles and cache-friendly dependency layers when applicable.
- Images or packages include a version/revision signal.
- Release is triggered by one documented branch, tag, or release event.
- Rollback target is known before deploy.

### Incident And Rollback

Done when recovery is possible faster than a new code fix.

Check:

- Last good artifact/config is identifiable.
- Rollback, traffic shift, disablement, or config revert is documented.
- Production evidence is preserved before cleanup.
- Follow-up changes are limited to detection, containment, or the direct root cause.

## Common Playbooks

### Add A New API Or Model Version

1. Read existing version layout and routing style.
2. Add the new version in a physically separate path that matches the repo.
3. Register it in the smallest existing registry or routing table.
4. Add version-specific metrics/log fields using the repo's current observability style.
5. Keep old behavior untouched.
6. Validate the old and new public boundaries.

### Change A Business Rule In A Live Service

1. Identify whether the rule is part of the public contract.
2. If it changes externally visible behavior, add an explicit version or compatibility path.
3. Keep the rule in the existing domain module or config location.
4. Add or update the smallest operational signal that proves the rule is active.
5. Validate with the repo's existing command for that module.

### Prepare A Release

1. Confirm branch, version, changelog/release note convention, and CI status.
2. Confirm build artifact identity: version, commit SHA, image tag, package version.
3. Confirm deploy target, migration needs, config changes, and rollback target.
4. Run existing checks or summarize the latest CI evidence.
5. Produce a short release note with risk, validation, and rollback.

### Deprecate Or Remove A Version

1. Add warning logs or response headers only if the repo already has a deprecation pattern or the user asks.
2. Use metrics/logs/traces to prove traffic is zero or approved for removal.
3. Remove route/handler/job/config/metrics together, not as dangling compatibility shims.
4. Keep rollback artifact available through the next release window.
5. Report the evidence window used for the removal decision.

### Respond To An Incident

1. State current impact and confidence.
2. Identify the change window and candidate releases/configs.
3. Choose the fastest safe recovery path.
4. Execute only repo-local fixes unless the user explicitly authorizes live operations.
5. After recovery, add the smallest guardrail that would have detected or contained the issue.

## Review Language

Prefer concrete operational statements:

- "This route is a public contract because it is mounted under `/api` and covered by the client SDK."
- "This config is deploy-time app config, not a secret, because it is a threshold with no credential value."
- "Removal is not ready because metrics do not distinguish v1 from v2 traffic."
- "Rollback is available through image tag `x`; config rollback is separate."

Avoid vague statements:

- "Add observability."
- "Make deployment safer."
- "Refactor version handling."
- "Improve monitoring."
