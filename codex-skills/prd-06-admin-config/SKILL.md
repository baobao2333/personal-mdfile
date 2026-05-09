---
name: prd-06-admin-config
description: Identify only the necessary backend, admin, and operations configuration for a PRD. Use when a feature needs operational control, resource configuration, manual handling, or admin visibility. Do not use to automatically add a large admin system to every feature.
---

# PRD Admin Config

## Purpose

Define backend and operations controls only when they are required for launch, safety, or maintainability.

The default stance is conservative: no admin feature should be added unless it protects launch, reduces real operational risk, or is explicitly required by the business.

## Inputs

- Business boundary.
- Rule model.
- Page and flow specs.
- Known operations process, if available.

## Process

1. Identify operations actions required for this version.
2. Identify configuration values that cannot safely be hardcoded.
3. Identify emergency controls.
4. Identify admin validation and operation logs.
5. Split admin requirements into `Must-have`, `Can hardcode this version`, and `Later`.

## Admin config rules

- Do not add a config item just because it might be useful someday.
- For every config item, explain the cost of not having it.
- Prefer hardcoded defaults when the value is stable and the launch risk is low.
- Add operation logs when manual actions can affect user rights, money, resources, rankings, or eligibility.
- If operations can misconfigure something harmful, specify validation or confirmation.
- If this version does not need admin or operations controls, say so explicitly and keep the artifact short.
- Do not fill admin tables with speculative modules just to make the section look complete.

## Output format

```markdown
# 05 Admin & Operations Config: {Feature Name}

## 1. Admin necessity summary
| Area | Needed this version? | Reason |
|---|---:|---|

## 2. Configuration items
| Config item | Must-have? | Default value | Allowed values | Validation | Not having it means |
|---|---:|---|---|---|---|

## 3. Operations actions
| Action | Operator role | Condition | Result | Needs log? | Needs confirmation? |
|---|---|---|---|---:|---:|

## 4. Emergency controls
| Control | Trigger to use | Result | Risk |
|---|---|---|---|

## 5. Admin pages / modules
| Module | Purpose | Fields | Actions | Priority |
|---|---|---|---|---|

## 6. Can be hardcoded this version
| Item | Why hardcoding is acceptable | Revisit trigger |
|---|---|---|

## 7. Handoff to next stage
Recommended next skill: `prd-07-data-acceptance`
```

## Definition of done

The admin config spec is complete when operations can safely run the feature without the PRD turning into a fake “everything configurable” system.
