---
name: prd-05-page-interaction
description: "Convert PRD flows into page-level and interaction-level product specs: entry, layout information hierarchy, components, button states, empty states, error states, and user copy. Use after flows are stable. Do not use for visual design, brand style, or backend configuration."
---

# PRD Page Interaction

## Purpose

Describe what each page or component must communicate and how it behaves. This skill supports design and frontend development without pretending to replace design work.

## Inputs

- Flow model.
- Rule model.
- Known product pages or entry points.

## Process

1. Identify required pages, modules, or components.
2. Define information hierarchy for each.
3. Define visible fields and their source meaning.
4. Define button states and disabled reasons.
5. Define copy for success, failure, empty, loading, and confirmation states.
6. Identify interactions that need design attention.

## Interaction writing rules

- Do not specify pixel-perfect UI unless provided by the user.
- Do not invent visual style.
- Do specify information priority, state, and user feedback.
- Each button must have enabled, disabled, loading, success, and failure behavior when relevant.
- Each empty state must explain why it is empty and what the user can do next, if anything.

## Output format

```markdown
# 04 Page & Interaction Spec: {Feature Name}

## 1. Page / component list
| Page or component | Purpose | Entry | Depends on rule / state |
|---|---|---|---|

## 2. Page spec
### {Page Name}

#### Purpose
{What this page helps the user understand or do}

#### Information hierarchy
| Priority | Content | Notes |
|---|---|---|

#### Fields
| Field | Meaning | Display condition | Empty / abnormal display |
|---|---|---|---|

#### Actions
| Action | Enabled condition | Disabled condition | Success result | Failure result |
|---|---|---|---|---|

#### States
| State | Display | User can do |
|---|---|---|
| Loading |  |  |
| Empty |  |  |
| Normal |  |  |
| Error |  |  |
| No permission |  |  |
| Expired / ended |  |  |

#### Copy
| Scenario | Copy | Notes |
|---|---|---|

## 3. Design attention points
| Point | Why it matters | Required decision |
|---|---|---|

## 4. Handoff to next stage
Recommended next skill: `prd-06-admin-config`
```

## Definition of done

The page spec is complete when design knows what must be represented and frontend knows what states must be implemented.
