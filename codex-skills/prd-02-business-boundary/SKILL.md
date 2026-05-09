---
name: prd-02-business-boundary
description: Define product scope, version boundary, business constraints, non-goals, and stakeholder decisions for a PRD. Use after the idea has been clarified. Do not use for detailed rule tables, page copy, or final PRD compression.
---

# PRD Business Boundary

## Purpose

Compress the expanded idea into a versioned business boundary. This skill decides what belongs in the current release, what is explicitly excluded, and what requires stakeholder sign-off.

## Inputs

- Intake brief.
- Any business constraints.
- Known deadlines, dependencies, or team capacity.
- Existing product context, if available.

## Process

1. Define the business goal of the current version.
2. Identify mandatory user paths.
3. Identify what must be true for the feature to be considered launched.
4. Split scope into `This version`, `Not this version`, and `Later`.
5. Identify stakeholder decisions.
6. Identify historical system areas that may conflict with the feature.

## Boundary rules

- If a capability is useful but not necessary for the first usable version, put it in `Later`.
- If a capability adds operational or technical complexity without protecting the core goal, put it in `Not this version`.
- If the business owner must choose between cost, risk, and user experience, mark it as `Decision needed`.
- If current system behavior is unknown, do not assume it is easy to change. Mark it as `Needs history check`.

## Output format

```markdown
# 01 Business Boundary: {Feature Name}

## 1. Version goal
{What this version must achieve}

## 2. Success definition
| Dimension | Definition | Must-have? |
|---|---|---|

## 3. Scope
### This version
| Item | Reason | Owner of decision |
|---|---|---|

### Not this version
| Item | Reason for exclusion | Risk if someone re-adds it |
|---|---|---|

### Later versions
| Item | Trigger to revisit | Dependency |
|---|---|---|

## 4. Business boundaries
| Boundary | Product decision | Notes |
|---|---|---|
| User boundary |  |  |
| Time boundary |  |  |
| Resource boundary |  |  |
| Permission boundary |  |  |
| Cost boundary |  |  |
| Operations boundary |  |  |

## 5. Stakeholder sign-off points
| Decision | Options | Recommended default | Who signs off |
|---|---|---|---|

## 6. Needs history check
| Area | Possible conflict | Who should confirm |
|---|---|---|

## 7. Handoff to next stage
Recommended next skill: `prd-03-rule-modeler`
```

## Definition of done

The boundary document is complete when a product manager can say: “This is the release I am willing to defend.”
